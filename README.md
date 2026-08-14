
# Fleet Management Tracking

A web application for managing and tracking a fleet of vehicles. Built with Node.js, Express, PostgreSQL, and Docker.

## Features

- View all vehicles in the fleet
- Add new vehicles
- Edit vehicle details
- Delete vehicles
- Dashboard with fleet stats (total, available, maintenance, average mileage)

## Tech Stack

- **Backend:** Node.js, Express
- **Database:** PostgreSQL
- **Templating:** EJS
- **Containerization:** Docker, Docker Compose

## Prerequisites

- [Docker](https://www.docker.com/) installed
- [Node.js](https://nodejs.org/) (for running locally without Docker)

## Running with Docker

1. Clone the repository:
   ```bash
   git clone https://github.com/tobeynd/fleet-management.git
   cd fleet-management
   ```

2. Start the app:
   ```bash
   docker-compose up --build
   ```

3. Open your browser at `http://localhost:3002`

## Running Locally (without Docker)

1. Install dependencies:
   ```bash
   npm install
   ```

2. Create a `.env` file in the root directory:
   ```
   PORT=3002
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=<your_password>
   DB_NAME=fleet_management
   ```

3. Set up the database:
   ```bash
   psql -U postgres -d fleet_management -f src/database/schema.sql
   ```

4. Start the server:
   ```bash
   npm run dev
   ```

5. Open your browser at `http://localhost:3002`

## Docker Hub

The image is available on Docker Hub:
```bash
docker pull tobeynd/fleet-management
```

## Project Structure

```
src/
├── config/         # Database connection
├── controllers/    # API route handlers
├── database/       # SQL schema and seed data
├── middlewares/    # Error handler and 404 handler
├── models/         # Database query functions
├── routes/         # Web and API routes
└── views/          # EJS templates
```
=======

