# fastapi-vs-node-crud-performance-test


```bash
docker compose down -v
docker compose up --build
docker compose --profile fastapi-sync up --build
docker compose --profile fastapi-async up --build
docker stats
```

https://www.artillery.io/docs/get-started/get-artillery
```bash
npm install -g artillery@2.0.21
artillery version 
```

```bash
artillery run -e fastapi-sync load-test.yml  -o reports/fastapi-sync.json
artillery report reports/fastapi-sync.json --output reports/fastapi-sync-report.html
```


```bash
artillery run -e fastapi-async load-test.yml  -o reports/fastapi-async.json
artillery report reports/fastapi-async.json --output reports/fastapi-async-report.html
```