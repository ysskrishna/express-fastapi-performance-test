# FastAPI vs Express Performance Test

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat&logo=fastapi)](https://fastapi.tiangolo.com)
[![Express.js](https://img.shields.io/badge/Express.js-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com)
[![Artillery](https://img.shields.io/badge/Artillery-2.0.21-FF0000?style=flat&logo=artillery&logoColor=white)](https://artillery.io)

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
├── stress_test/      # Load testing configuration
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
artillery version 
```

https://www.artillery.io/docs/get-started/get-artillery

## Load Testing

The project includes comprehensive load testing scenarios that simulate:
- CRUD operations
- Read-heavy traffic
- Gradual load increase
- Sustained high load

### Running Tests

1. FastAPI (Synchronous):
```bash
# Build and Start the services in detached mode
docker compose --profile fastapi-sync up -d --build

# Run the load test
artillery run -e fastapi-sync stress_test/load-test.yml -o stress_test/reports/fastapi-sync.json
artillery report stress_test/reports/fastapi-sync.json --output stress_test/reports/fastapi-sync-report.html

# Stop the services and remove volumes
docker compose --profile fastapi-sync down -v
```

2. FastAPI (Asynchronous):
```bash
# Build and Start the services in detached mode
docker compose --profile fastapi-async up -d --build

# Run the load test
artillery run -e fastapi-async stress_test/load-test.yml -o stress_test/reports/fastapi-async.json
artillery report stress_test/reports/fastapi-async.json --output stress_test/reports/fastapi-async-report.html

# Stop the services and remove volumes
docker compose --profile fastapi-async down -v
```

3. Express.js:
```bash
# Build and Start the services in detached mode
docker compose --profile express up -d --build

# Run the load test
artillery run -e express stress_test/load-test.yml -o stress_test/reports/express.json
artillery report stress_test/reports/express.json --output stress_test/reports/express-report.html

# Stop the services and remove volumes
docker compose --profile express down -v
```

## Test Scenarios

The load test configuration includes:
- Warm-up phase: 60 seconds with arrival rate increasing from 5 to 50 requests/second
- Sustained load phase: 300 seconds with constant 50 requests/second
- CRUD operations: Create, read, update, and delete operations
- Read-heavy traffic: Multiple GET requests to simulate read-heavy scenarios

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Author:** [Siva Sai Krishna](https://github.com/ysskrishna)