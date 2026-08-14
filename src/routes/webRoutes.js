const express = require('express')
const router = express.Router()
const pool = require('../config/db')

// Dashboard
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vehicles ORDER BY id DESC')
        const vehicles = result.rows
        const total = vehicles.length
        const available = vehicles.filter(v => v.status === 'Available').length
        const maintenance = vehicles.filter(v => v.status === 'Maintenance').length
        const avgMileage = total > 0
            ? Math.round(vehicles.reduce((sum, v) => sum + Number(v.current_mileage), 0) / total)
            : 0
        console.log('Rendering dashboard with:', { total, available, maintenance, avgMileage, vehicleCount: vehicles.length })
        res.render('dashboard', { vehicles, total, available, maintenance, avgMileage })
    } catch (err) {
        console.error('Dashboard error:', err.message)
        res.status(500).send('Server error: ' + err.message)
    }
})

// Vehicles list
router.get('/vehicles', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vehicles ORDER BY id ASC')
        res.render('vehicles', { vehicles: result.rows })
    } catch (err) {
        console.error(err)
        res.status(500).send('Server error')
    }
})

// Add vehicle form
router.get('/vehicles/new', (req, res) => {
    res.render('addVehicle', { error: null })
})

// Create vehicle
router.post('/vehicles', async (req, res) => {
    const { license_plate, make_model, current_mileage, status } = req.body
    try {
        await pool.query(
            'INSERT INTO vehicles (license_plate, make_model, current_mileage, status) VALUES ($1,$2,$3,$4)',
            [license_plate, make_model, current_mileage, status]
        )
        res.redirect('/vehicles')
    } catch (err) {
        console.error(err)
        res.render('addVehicle', { error: 'Failed to add vehicle. Please try again.' })
    }
})

// Edit vehicle form
router.get('/vehicles/:id/edit', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vehicles WHERE id = $1', [req.params.id])
        if (result.rows.length === 0) return res.redirect('/vehicles')
        res.render('editVehicle', { vehicle: result.rows[0], error: null })
    } catch (err) {
        console.error(err)
        res.redirect('/vehicles')
    }
})

// Update vehicle
router.post('/vehicles/:id/edit', async (req, res) => {
    const { license_plate, make_model, current_mileage, status } = req.body
    try {
        await pool.query(
            'UPDATE vehicles SET license_plate=$1, make_model=$2, current_mileage=$3, status=$4 WHERE id=$5',
            [license_plate, make_model, current_mileage, status, req.params.id]
        )
        res.redirect('/vehicles')
    } catch (err) {
        console.error(err)
        const result = await pool.query('SELECT * FROM vehicles WHERE id = $1', [req.params.id])
        res.render('editVehicle', { vehicle: result.rows[0], error: 'Failed to update vehicle.' })
    }
})

// Delete vehicle
router.post('/vehicles/:id/delete', async (req, res) => {
    try {
        await pool.query('DELETE FROM vehicles WHERE id = $1', [req.params.id])
        res.redirect('/vehicles')
    } catch (err) {
        console.error(err)
        res.redirect('/vehicles')
    }
})

module.exports = router
