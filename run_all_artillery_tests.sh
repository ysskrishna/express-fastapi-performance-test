#!/bin/bash

set -e

# Configuration
REPORT_DIR="artillery_tests/reports"
CONFIG_DIR="artillery_tests"
LOG_FILE="artillery_test_run.log"
SUMMARY_FILE="test_summary.txt"

# Valid profiles and test types
VALID_PROFILES=("fastapi-sync" "fastapi-async" "express")
VALID_TESTS=( "read-heavy" "write-heavy" "spike" "stress" "soak" "breakpoint-read" "breakpoint-write")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize counters
TOTAL_TESTS=0
SUCCESSFUL_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Function to run a single test
run_test() {
    local profile=$1
    local test_type=$2
    local test_number=$3
    local total_tests=$4
    
    local test_id="${profile}-${test_type}"
    local report_json="$REPORT_DIR/${test_id}.json"
    local report_html="$REPORT_DIR/${test_id}-report.html"
    local config_file="$CONFIG_DIR/${test_type}-test.yml"
    
    log_message "INFO" "Starting test $test_number/$total_tests: $test_id"
    
    # Start services
    log_message "INFO" "Starting services for $profile..."
    if ! docker compose --profile "$profile" up -d --build >> "$LOG_FILE" 2>&1; then
        log_message "ERROR" "Failed to start services for $profile"
        return 1
    fi
    
    # Wait for services to warm up
    log_message "INFO" "Waiting 15 seconds for services to warm up..."
    sleep 15
    
    # Run Artillery test
    log_message "INFO" "Running Artillery test for $test_id..."
    if ! artillery run -e "$profile" "$config_file" -o "$report_json" >> "$LOG_FILE" 2>&1; then
        log_message "ERROR" "Artillery test failed for $test_id"
        return 1
    fi
    
    # Generate HTML report
    log_message "INFO" "Generating HTML report for $test_id..."
    if ! artillery report "$report_json" --output "$report_html" >> "$LOG_FILE" 2>&1; then
        log_message "WARNING" "Failed to generate HTML report for $test_id"
    fi
    
    # Stop and remove containers
    log_message "INFO" "Stopping and removing containers for $profile..."
    docker compose --profile "$profile" down -v >> "$LOG_FILE" 2>&1
    
    log_message "SUCCESS" "Completed test: $test_id"
    echo "📄 Report: $report_html"
    return 0
}

# Function to print banner
print_banner() {
    echo ""
    echo "=================================================="
    echo "🚀 FastAPI vs Express Performance Test Suite"
    echo "=================================================="
    echo "Profiles: ${VALID_PROFILES[*]}"
    echo "Test Types: ${VALID_TESTS[*]}"
    echo "Total Tests: $(( ${#VALID_PROFILES[@]} * ${#VALID_TESTS[@]} ))"
    echo "Start Time: $(date)"
    echo "=================================================="
    echo ""
}

# Function to print summary
print_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    local seconds=$((duration % 60))
    
    echo ""
    echo "=================================================="
    echo "📊 Test Suite Summary"
    echo "=================================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Successful: $SUCCESSFUL_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: $(( (SUCCESSFUL_TESTS * 100) / TOTAL_TESTS ))%"
    echo "Duration: ${hours}h ${minutes}m ${seconds}s"
    echo "Log File: $LOG_FILE"
    echo "Summary File: $SUMMARY_FILE"
    echo "Reports Directory: $REPORT_DIR"
    echo "=================================================="
    
    # Save summary to file
    cat > "$SUMMARY_FILE" << EOF
FastAPI vs Express Performance Test Suite Summary
================================================
Date: $(date)
Total Tests: $TOTAL_TESTS
Successful: $SUCCESSFUL_TESTS
Failed: $FAILED_TESTS
Success Rate: $(( (SUCCESSFUL_TESTS * 100) / TOTAL_TESTS ))%
Duration: ${hours}h ${minutes}m ${seconds}s
Log File: $LOG_FILE
Reports Directory: $REPORT_DIR

Test Results:
EOF
    
    # Add individual test results to summary
    for profile in "${VALID_PROFILES[@]}"; do
        echo "" >> "$SUMMARY_FILE"
        echo "Profile: $profile" >> "$SUMMARY_FILE"
        echo "----------------------------------------" >> "$SUMMARY_FILE"
        for test_type in "${VALID_TESTS[@]}"; do
            local report_html="$REPORT_DIR/${profile}-${test_type}-report.html"
            if [[ -f "$report_html" ]]; then
                echo "✅ $test_type: $report_html" >> "$SUMMARY_FILE"
            else
                echo "❌ $test_type: FAILED" >> "$SUMMARY_FILE"
            fi
        done
    done
}

# Function to cleanup on exit
cleanup() {
    log_message "INFO" "Cleaning up containers..."
    docker compose down -v >> "$LOG_FILE" 2>&1 || true
    log_message "INFO" "Cleanup completed"
}

# Set up trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    # Check if running in parallel mode
    local parallel_mode=false
    if [[ "$1" == "--parallel" ]]; then
        parallel_mode=true
        log_message "INFO" "Running tests in parallel mode"
    fi
    
    # Initialize
    print_banner
    mkdir -p "$REPORT_DIR"
    
    # Calculate total tests
    TOTAL_TESTS=$(( ${#VALID_PROFILES[@]} * ${#VALID_TESTS[@]} ))
    local test_number=0
    
    # Run tests
    for profile in "${VALID_PROFILES[@]}"; do
        for test_type in "${VALID_TESTS[@]}"; do
            test_number=$((test_number + 1))
            
            if [[ "$parallel_mode" == true ]]; then
                # Run in background for parallel execution
                run_test "$profile" "$test_type" "$test_number" "$TOTAL_TESTS" &
                # Limit concurrent tests to avoid resource exhaustion
                if (( test_number % 3 == 0 )); then
                    wait
                fi
            else
                # Run sequentially
                if run_test "$profile" "$test_type" "$test_number" "$TOTAL_TESTS"; then
                    SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
                else
                    FAILED_TESTS=$((FAILED_TESTS + 1))
                fi
            fi
        done
    done
    
    # Wait for all background processes if running in parallel
    if [[ "$parallel_mode" == true ]]; then
        log_message "INFO" "Waiting for all tests to complete..."
        wait
        
        # Count successful tests by checking for HTML reports
        for profile in "${VALID_PROFILES[@]}"; do
            for test_type in "${VALID_TESTS[@]}"; do
                local report_html="$REPORT_DIR/${profile}-${test_type}-report.html"
                if [[ -f "$report_html" ]]; then
                    SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
                else
                    FAILED_TESTS=$((FAILED_TESTS + 1))
                fi
            done
        done
    fi
    
    # Print summary
    print_summary
    
    # Exit with error if any tests failed
    if [[ $FAILED_TESTS -gt 0 ]]; then
        log_message "WARNING" "Some tests failed. Check the log file for details."
        exit 1
    else
        log_message "SUCCESS" "All tests completed successfully!"
        exit 0
    fi
}

# Show usage if help is requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0 [--parallel] [--help]"
    echo ""
    echo "Options:"
    echo "  --parallel    Run tests in parallel (faster but may use more resources)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "This script will run all artillery tests for all profiles:"
    echo "Profiles: ${VALID_PROFILES[*]}"
    echo "Test Types: ${VALID_TESTS[*]}"
    echo "Total Tests: $(( ${#VALID_PROFILES[@]} * ${#VALID_TESTS[@]} ))"
    exit 0
fi

# Run main function
main "$@" 