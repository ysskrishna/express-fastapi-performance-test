# FastAPI vs Express Performance Test

This project compares the performance of three different backend implementations:
- FastAPI (Synchronous)
- FastAPI (Asynchronous)
- Express.js

The comparison is done through load testing using Artillery.io, measuring response times, throughput, and error rates under various load conditions.

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
- Artillery.io (version 2.0.21)

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
# Start the services
docker compose --profile fastapi-sync up --build

# Run the load test
artillery run -e fastapi-sync stress_test/load-test.yml -o reports/fastapi-sync.json
artillery report reports/fastapi-sync.json --output reports/fastapi-sync-report.html

# Stop the services and remove volumes
docker compose --profile fastapi-sync down -v
```

2. FastAPI (Asynchronous):
```bash
# Start the services
docker compose --profile fastapi-async up --build

# Run the load test
artillery run -e fastapi-async stress_test/load-test.yml -o reports/fastapi-async.json
artillery report reports/fastapi-async.json --output reports/fastapi-async-report.html

# Stop the services and remove volumes
docker compose --profile fastapi-async down -v
```

3. Express.js:
```bash
# Start the services
docker compose --profile express up --build

# Run the load test
artillery run -e express stress_test/load-test.yml -o reports/express.json
artillery report reports/express.json --output reports/express-report.html

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
