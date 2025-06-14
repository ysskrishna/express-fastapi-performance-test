# fastapi-vs-node-crud-performance-test


```
docker compose down
docker compose up --build
docker stats
```

https://www.artillery.io/docs/get-started/get-artillery
```
npm install -g artillery@2.0.21
artillery version 
```

```
artillery run load-test-fastapi-sync.yml -o reports/fastapi-sync.json
artillery report reports/fastapi-sync.json --output reports/fastapi-sync-report.html
```