const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'HewCharaSaw@&2410',
    database: process.env.DB_NAME || 'fleet_management',
    ssl: process.env.DB_HOST ? { rejectUnauthorized: false } : false
})

pool.on('connect', () => {
    console.log('Connection to the database established')
})

pool.on('error', (err) => {
    console.error('Database connection error:', err)
})

// Auto-create tables on startup
const initDb = async () => {
    try {
        const schema = fs.readFileSync(path.join(__dirname, '../database/schema.sql'), 'utf8');
        await pool.query(schema);
        console.log('Database tables initialized successfully');
    } catch (err) {
        console.error('Database initialization failed:', err.message);
    }
}

initDb();

module.exports = pool
