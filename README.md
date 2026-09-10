# Fleet Management Tracking

A web application for managing and tracking a fleet of vehicles. Built with Node.js, Express, PostgreSQL, and Docker, deployed on AWS using Terraform.

## Features

- View all vehicles in the fleet
- Add new vehicles
- Edit vehicle details
- Delete vehicles
- Dashboard with fleet stats (total, available, maintenance, average mileage)

## Tech Stack

- **Backend:** Node.js, Express
- **Database:** PostgreSQL (AWS RDS)
- **Templating:** EJS
- **Containerization:** Docker, Docker Compose
- **Reverse Proxy:** Nginx
- **Infrastructure:** AWS (ALB, EC2 Auto Scaling Group, RDS, SSM Parameter Store, CloudWatch)
- **IaC:** Terraform

## Project Structure

```
├── backend/
│   ├── config/         # Database connection
│   ├── controllers/    # Route handlers
│   ├── database/       # SQL schema and seed data
│   ├── middlewares/    # Error handler and 404 handler
│   ├── models/         # Database query functions
│   └── routes/         # Web and API routes
├── frontend/
│   └── views/          # EJS templates
├── nginx/              # Nginx config
├── terraform/
│   └── environments/
│       └── dev/        # Terraform config for dev environment
├── Dockerfile
└── docker-compose.yaml
```

## Prerequisites

- [Docker](https://www.docker.com/) installed
- [Node.js](https://nodejs.org/) (for running locally without Docker)
- [Terraform](https://www.terraform.io/) (for AWS deployment)
- An AWS account with appropriate permissions

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
   psql -U postgres -d fleet_management -f backend/database/schema.sql
   ```

4. Start the server:
   ```bash
   npm run dev
   ```

5. Open your browser at `http://localhost:3002`

## Deploying to AWS with Terraform

1. Navigate to the dev environment:
   ```bash
   cd terraform/environments/dev
   ```

2. Create a `terraform.tfvars` file:
   ```hcl
   db_name              = "fleet_management"
   db_username          = "<your_db_username>"
   db_password          = "<your_db_password>"
   active_target_group  = "blue"
   ```

3. Initialise and apply:
   ```bash
   terraform init
   terraform apply
   ```

4. Access the app at the ALB DNS output:
   ```bash
   http://<alb_dns_name>
   ```

## Blue/Green Deployments

Traffic is controlled via the `active_target_group` variable. To switch from blue to green:

```hcl
active_target_group = "green"
```

Then run `terraform apply`. To roll back, switch back to `"blue"` and apply again.

## Docker Hub

The image is available on Docker Hub:
```bash
docker pull tobeynd/fleet-management
```
