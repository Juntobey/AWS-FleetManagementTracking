const pool  = require('../config/db')

// get all vehicles
exports.getVehicles = async ( req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vehicles ORDER BY id ASC ')
        res.status(200).json(result.rows)
    }
    catch (err) {
        console.error(err)
        res.status(500).json({ message: 'Failed to retrieve vehicles' })
    }
}

// get vehicle by id
exports.getVehicleById = async (req, res) => {
    const{id} = req.params
    try{
        const result = await pool.query('SELECT * FROM vehicles WHERE id = $1', [id])
        if (result.rows.length === 0){
            return res.status(404).json({message: 'Vehicle not found'} ) 
        }
        res.status(200).json(result.rows[0])
    }
    catch(err){
        console.error(err)
        res.status(500).json({ message: 'Failed to retrieve vehicle' })
    }
}

// create vehicle
exports.createVehicle = async (req, res) => {
    const { license_plate, make_model, current_mileage, status } = req.body
    try {
        const result = await pool.query(
            `INSERT INTO vehicles (license_plate, make_model, current_mileage, status)
            VALUES ($1, $2, $3, $4) RETURNING *`,
            [license_plate, make_model, current_mileage, status]
        )
        res.status(201).json(result.rows[0])
    } catch (err) {
        console.error(err)
        res.status(500).json({ message: 'Failed to create vehicle.' })
    }
}

// update vehicle
exports.updateVehicle = async (req, res) => {
    const { id } = req.params
    const { license_plate, make_model, current_mileage, status } = req.body
    try {
        const result = await pool.query(
            `UPDATE vehicles SET license_plate = $1, make_model = $2, current_mileage = $3, status = $4
             WHERE id = $5 RETURNING *`,
            [license_plate, make_model, current_mileage, status, id]
        )
        if (result.rows.length === 0) {
            return res.status(404).json({ message: "Vehicle not found." })
        }
        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Failed to update vehicle." })
    }
}

// delete vehicle
exports.deleteVehicle = async (req, res) => {
    const { id } = req.params
    try {
        const result = await pool.query("DELETE FROM vehicles WHERE id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: "Vehicle not found." })
        }
        res.status(200).json({ message: "Vehicle deleted successfully." })
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Failed to delete vehicle." })
    }
}
