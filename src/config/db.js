const{Pool} = require('pg');
const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'HewCharaSaw@&2410',
    database: process.env.DB_NAME || 'fleet_management'
})

pool.on('connect', () => {
    console.log('Connection to the database established')
})

pool.on('error', (err) => {
    console.error('Database connection error:', err)
})

pool.query('SELECT 1').then(() => {
    console.log('Database reachable')
}).catch(err => {
    console.error('Database test query failed:', err.message)
})

module.exports = pool