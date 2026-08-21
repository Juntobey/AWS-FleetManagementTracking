require('dotenv').config()

const express = require('express')
const path = require('path')
const cors = require('cors')
const cookieParser = require('cookie-parser');
const vehicleRoutes = require('./routes/vehicleRoutes')
const webRoutes = require('./routes/webRoutes')
const notFound = require('./middlewares/notFound')
const errorHandler = require('./middlewares/errorHandler')

const app = express()

const port = process.env.PORT || 3002

app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cors())
app.use(cookieParser())

app.set('view engine', 'ejs')
app.set('views', path.join(__dirname, '../frontend/views'))
app.use(express.static(path.join(__dirname, '../../public')))

// Web UI routes
app.use('/', webRoutes)

// JSON API routes
app.use('/api/vehicles', vehicleRoutes)

app.use(notFound)
app.use(errorHandler)

app.listen(port, () => {
    console.log(`Server is running on port ${port}`)
})
