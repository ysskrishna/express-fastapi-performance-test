const { Pool } = require('pg');

const pool = new Pool({
  user: 'service_user',
  host: 'localhost',
  database: 'service_db',
  password: 'service_password',
  port: 5432,
});

module.exports = pool;
