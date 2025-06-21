# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup with FastAPI (async and sync) and Express.js implementations
- PostgreSQL database integration
- Docker and docker-compose configuration
- Basic project documentation in README.md
- Comprehensive Artillery.io test suite with multiple test scenarios:
  - Read-heavy test: Simulates high-volume read operations with random pagination
  - Write-heavy test: Tests concurrent create and update operations
  - Spike test: Evaluates system behavior under sudden load spikes
  - Stress test: Determines system breaking points under sustained load
  - Soak test: Long-running test to identify memory leaks and stability issues
- Automated test runner script (`run_artillery_test.sh`) with features:
  - Support for multiple test profiles (fastapi-sync, fastapi-async, express)
  - Automatic service orchestration using Docker Compose
  - Test report generation in both JSON and HTML formats
  - Built-in validation for test profiles and types
  - Automatic cleanup of test resources
- Test reporting system:
  - JSON reports for detailed analysis
  - HTML reports for visual representation of test results
