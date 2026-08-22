const pool = require('../config/db')

const getAll = () => pool.query('SELECT * FROM vehicles ORDER BY id ASC')

const getById = (id) => pool.query('SELECT * FROM vehicles WHERE id = $1', [id])

const create = ({ license_plate, make_model, current_mileage, status }) =>
    pool.query(
        'INSERT INTO vehicles (license_plate, make_model, current_mileage, status) VALUES ($1,$2,$3,$4) RETURNING *',
        [license_plate, make_model, current_mileage, status]
    )

const update = (id, { license_plate, make_model, current_mileage, status }) =>
    pool.query(
        'UPDATE vehicles SET license_plate=$1, make_model=$2, current_mileage=$3, status=$4 WHERE id=$5 RETURNING *',
        [license_plate, make_model, current_mileage, status, id]
    )

const remove = (id) => pool.query('DELETE FROM vehicles WHERE id = $1 RETURNING *', [id])

module.exports = { getAll, getById, create, update, remove }
