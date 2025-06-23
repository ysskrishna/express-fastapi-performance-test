# FastAPI vs Express Performance Test

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat&logo=fastapi)](https://fastapi.tiangolo.com)
[![Express.js](https://img.shields.io/badge/Express.js-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com)
[![Artillery](https://img.shields.io/badge/Artillery-2.0.21-FF0000?style=flat&logo=artillery&logoColor=white)](https://artillery.io)
[![Looker](https://img.shields.io/badge/Looker-4285F4?style=flat&logo=looker&logoColor=white)](https://lookerstudio.google.com/reporting/270e16b6-8831-41d5-aed0-4d2352b39218/page/pqwOF)

This project compares the performance of three different backend implementations:
- FastAPI (Synchronous)
- FastAPI (Asynchronous)
- Express.js

The comparison is done through load testing using [Artillery.io](https://www.artillery.io/), measuring response times, throughput, and error rates under various load conditions.

## Project Structure

```
.
├── fastapi_sync/     # Synchronous FastAPI implementation
├── fastapi_async/    # Asynchronous FastAPI implementation
├── express/          # Express.js implementation
├── postgres/         # Database initialization scripts
├── artillery_tests/  # Load testing configuration and scripts
├── documentation/    # Example reports and analysis
└── docker-compose.yml
```

## Prerequisites

- Docker and Docker Compose
- Node.js (for running Artillery)
- [Artillery.io](Artillery.io) (version 2.0.21)

## Docker Compose Profiles

This project uses Docker Compose profiles to manage different service configurations. Profiles allow us to run specific sets of services without starting the entire stack. The following profiles are defined:

- `fastapi-sync`: Runs the synchronous FastAPI implementation with PostgreSQL
- `fastapi-async`: Runs the asynchronous FastAPI implementation with PostgreSQL
- `express`: Runs the Express.js implementation with PostgreSQL

Each profile can be activated using the `--profile` flag with `docker compose` commands. For example:
```bash
docker compose --profile fastapi-sync up
```

This approach allows us to:
- Run different implementations independently
- Compare performance without interference
- Save resources by only running necessary services
- Maintain clean separation between different implementations

## Resource Limitations

Each service in this project is configured with the following resource constraints:
- CPU: Limited to 0.5 cores (50% of a single CPU core)
- Memory: Limited to 512MB RAM

These limitations ensure:
- Fair comparison between different implementations
- Controlled resource usage during load testing
- Consistent performance measurements
- Prevention of resource exhaustion

## Setup

1. Install Artillery globally:
```bash
npm install -g artillery@2.0.21
npm install -g artillery-plugin-metrics-by-endpoint
artillery version 
```

https://www.artillery.io/docs/get-started/get-artillery

## Load Testing

The project includes a comprehensive load testing suite using Artillery.io that simulates various real-world scenarios:

### 🔬 Test Scenarios

#### 1. **Read-Heavy Test**
* Simulates high-volume `GET` requests
* Includes random pagination and optional filtering
* Evaluates system performance under **read-intensive workloads**
* Identifies latency trends and potential bottlenecks in read paths

#### 2. **Write-Heavy Test**
* Simulates concurrent `POST`, `PUT`, and `DELETE` operations
* Stress-tests the database's write throughput
* Measures system stability and responsiveness under **write-heavy traffic**
* Useful for tuning **transactions, indexing, and batch inserts**

#### 3. **Spike Test**
* Introduces **sudden, large spikes in traffic**
* Tests the system's elasticity and autoscaling behavior (if any)
* Measures degradation in response time and error rates during and after spikes
* Helps validate rate limiting and failover mechanisms

#### 4. **Stress Test**
* Gradually increases the load to **identify system breaking points**
* Helps expose:
  * Memory or CPU bottlenecks
  * Slow database queries
  * Throughput limits
* Evaluates how the system **recovers** after hitting its limits

#### 5. **Soak Test**
* Simulates **continuous moderate load** over an extended duration
* Detects issues like:
  * Memory leaks
  * Connection pool exhaustion
  * Resource starvation over time
* Helps validate system **stability and reliability** for long-running deployments

#### 6. **Breakpoint-Read Test**
* Incrementally increases the number of **read (`GET`) requests**
* Identifies the exact point where:
  * **Response times degrade**
  * **Error rates increase**
* Useful for testing:
  * **Caching mechanisms**
  * **Database read pools**
  * **Horizontal read scaling limits**

#### 7. **Breakpoint-Write Test**
* Gradually increases the number of **write operations (`POST`, `PUT`, `DELETE`)**
* Identifies the load threshold where:
  * **Writes start failing or slowing down**
  * **CPU, memory, or DB locks become critical**
* Helps optimize:
  * **Write throughput**
  * **Transaction handling**
  * **Concurrency limits**

### Running Tests

The project includes an automated test runner script (`run_artillery_test.sh`) that handles:
- Service orchestration using Docker Compose
- Test execution with Artillery.io
- Report generation in both JSON and HTML formats
- Automatic cleanup of test resources

#### Usage

```bash
./run_artillery_test.sh <profile> <test-type>
```

Available profiles:
- `fastapi-sync`: FastAPI with synchronous operations
- `fastapi-async`: FastAPI with asynchronous operations
- `express`: Express.js implementation

Available test types:
- `read-heavy`: Read-intensive workload simulation
- `write-heavy`: Write-intensive workload simulation
- `spike`: Sudden traffic spike simulation
- `stress`: Sustained high load testing
- `soak`: Long-running stability test
- `breakpoint-read`: Read operation threshold testing
- `breakpoint-write`: Write operation threshold testing

Example:
```bash
# Run read-heavy test on FastAPI async implementation
./run_artillery_test.sh fastapi-async read-heavy
```

#### Running All Tests

The project also includes a `run_all_artillery_tests.sh` script to execute the entire test suite. This script will:
- Iterate through all profiles (`fastapi-sync`, `fastapi-async`, `express`).
- Run every test type for each profile.
- Generate a summary report at the end.

This is useful for comprehensive performance validation across all implementations.

Usage:
```bash
./run_all_artillery_tests.sh
```

### Test Reports

Test results are automatically generated in two formats:
1. JSON reports (`artillery_tests/reports/<profile>-<test-type>.json`)
   - Detailed metrics and raw data
   - Suitable for programmatic analysis
   - Contains timing, error rates, and throughput data

2. HTML reports (`artillery_tests/reports/<profile>-<test-type>-report.html`)
   - Visual representation of test results
   - Interactive charts and graphs
   - Summary statistics and key metrics

### Test Configuration

Each test scenario is configured in YAML files under the `artillery_tests` directory:
- `read-heavy-test.yml`: Read operation simulation
- `write-heavy-test.yml`: Write operation simulation
- `spike-test.yml`: Traffic spike simulation
- `stress-test.yml`: Sustained load testing
- `soak-test.yml`: Long-running stability test
- `breakpoint-read-test.yml`: Read operation threshold testing
- `breakpoint-write-test.yml`: Write operation threshold testing

The test configurations can be customized to adjust:
- Virtual user count
- Request rates
- Test duration
- Endpoint patterns
- Custom scenarios and functions

## Monitoring

Monitor Docker container resources during tests:
```bash
docker stats
```

## Cleanup

To stop and remove all containers and volumes:
```bash
docker compose down -v
```

## Documentation and Reports

This project provides comprehensive documentation and pre-generated reports in the `documentation/` directory.

### Interactive Dashboard

An interactive dashboard for visualizing and comparing performance metrics is available on Looker Studio.

- **Public URL**: [View the Performance Dashboard](https://lookerstudio.google.com/reporting/270e16b6-8831-41d5-aed0-4d2352b39218/page/pqwOF)

Here's a snapshot of what an Looker Dashboard looks like:

![Looker Dashboard](./documentation/looker/report_dashboard.png)

A Looker Dashboard PDF version can be downloaded [here](./documentation/looker/report_dashboard.pdf).


### Artillery Reports

Reports for all test scenarios are available in `documentation/artillery_generated_reports`. These can serve as a reference for what to expect from your own test runs.

Here's a snapshot of what an HTML report looks like:

![Artillery Report Sample](./documentation/express-breakpoint-read-report-sample.png)



## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Author:** [Siva Sai Krishna](https://github.com/ysskrishna)