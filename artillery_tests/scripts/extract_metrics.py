import json
import csv
from pathlib import Path

# Valid frameworks and test types
VALID_PROFILES = ["fastapi-sync", "fastapi-async", "express"]
VALID_TESTS = ["write-heavy", "spike", "stress", "soak", "read-heavy", "breakpoint-read", "breakpoint-write"]

def extract_framework_and_test(filename):
    filename = filename.stem
    for profile in VALID_PROFILES:
        if filename.startswith(profile):
            test_part = filename[len(profile):].lstrip('-')
            for test in VALID_TESTS:
                if test_part.startswith(test):
                    return profile, test
    raise ValueError(f"Could not parse framework and test type from filename: {filename}")

def extract_aggregate_metrics(json_file):
    with open(json_file, 'r') as f:
        data = json.load(f)

    metrics = []
    try:
        framework, test_type = extract_framework_and_test(json_file)
    except ValueError as e:
        print(f"Error processing {json_file}: {e}")
        return metrics

    agg = data.get("aggregate", {})
    if not agg:
        return metrics

    rt = agg.get("summaries", {}).get("http.response_time", {})
    counters = agg.get("counters", {})
    rates = agg.get("rates", {})

    # Response time
    metrics.extend([
        (framework, test_type, 'min_response_time', rt.get('min', 0)),
        (framework, test_type, 'median_response_time', rt.get('median', 0)),
        (framework, test_type, 'p95_response_time', rt.get('p95', 0)),
        (framework, test_type, 'p99_response_time', rt.get('p99', 0)),
        (framework, test_type, 'max_response_time', rt.get('max', 0)),
        (framework, test_type, 'mean_response_time', rt.get('mean', 0)),
    ])

    # Counters
    metrics.extend([
        (framework, test_type, 'total_requests', counters.get('http.requests', 0)),
        (framework, test_type, 'successful_requests', counters.get('http.codes.200', 0)),
        (framework, test_type, 'failed_requests', counters.get('vusers.failed', 0)),
        (framework, test_type, 'total_vusers', counters.get('vusers.created', 0)),
        (framework, test_type, 'completed_vusers', counters.get('vusers.completed', 0)),
        (framework, test_type, 'requests_per_second', rates.get('http.request_rate', 0))
    ])

    # Error rate
    total = counters.get('http.requests', 0)
    success = counters.get('http.codes.200', 0)
    if total > 0:
        error_rate = (total - success) / total * 100
        metrics.append((framework, test_type, 'error_rate', error_rate))

    return metrics

def extract_timeseries_metrics(json_file):
    with open(json_file, 'r') as f:
        data = json.load(f)

    try:
        framework, test_type = extract_framework_and_test(json_file)
    except ValueError as e:
        print(f"Error processing {json_file}: {e}")
        return []

    intermediate = data.get("intermediate", [])
    if not intermediate:
        return []

    # Use first period as base
    start = int(intermediate[0]["period"])

    rows = []
    for entry in intermediate:
        period = int(entry["period"])
        rel_sec = (period - start) // 1000

        counters = entry.get("counters", {})
        rates = entry.get("rates", {})
        
        completed = counters.get("vusers.completed", 0)
        failed = counters.get("vusers.failed", 0)
        total = completed + failed

        success_percent = (completed / total * 100) if total > 0 else 0
        error_percent = (failed / total * 100) if total > 0 else 0

        row = {
            "relative_sec": rel_sec,
            "framework": framework,
            "test_type": test_type,
            "http_200": counters.get("http.codes.200", 0),
            "vusers_failed": failed,
            "vusers_created": counters.get("vusers.created", 0),
            "vusers_completed": completed,
            "request_rate": rates.get("http.request_rate", 0),
            "success_percent": success_percent,
            "error_percent": error_percent,
        }
        rows.append(row)

    return rows

def main():
    base_dir = Path(__file__).parent
    reports_dir = base_dir.parent / "reports"
    agg_csv = base_dir / "artillery_aggregate_metrics.csv"
    ts_csv = base_dir / "artillery_timeseries_metrics.csv"

    aggregate_data = []
    timeseries_data = []

    for json_file in reports_dir.glob("*.json"):
        if json_file.suffix != ".json":
            continue
        print(f"Processing {json_file.name}")
        aggregate_data.extend(extract_aggregate_metrics(json_file))
        timeseries_data.extend(extract_timeseries_metrics(json_file))

    # Write aggregate metrics CSV
    with open(agg_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['framework', 'test_type', 'metric', 'value'])
        writer.writerows(aggregate_data)

    # Write timeseries metrics CSV
    if timeseries_data:
        keys = timeseries_data[0].keys()
        with open(ts_csv, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            writer.writerows(timeseries_data)

    print(f"\nAggregate metrics written to: {agg_csv}")
    print(f"Time-series metrics written to: {ts_csv}")

if __name__ == '__main__':
    main()
