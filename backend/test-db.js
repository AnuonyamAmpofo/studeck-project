require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Connection failed:', err.message);
  } else {
    console.log('Connected! Database time is:', result.rows[0].now);
  }
  pool.end();
});