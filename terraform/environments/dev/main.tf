data "aws_availability_zones" "available" {
  state = "available"
}

# VPC 
resource "aws_vpc" "tobeynd_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tobeynd_vpc"
  }
}

# --- PUBLIC SUBNETS ---
resource "aws_subnet" "tobeynd_public_subnet_1" {
  vpc_id                  = aws_vpc.tobeynd_vpc.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tobeynd_public_subnet_1"
  }
}

resource "aws_subnet" "tobeynd_public_subnet_2" {
  vpc_id                  = aws_vpc.tobeynd_vpc.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "tobeynd_public_subnet_2"
  }
}

# --- PRIVATE SUBNETS ---
resource "aws_subnet" "tobeynd_private_subnet_1" {
  vpc_id            = aws_vpc.tobeynd_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tobeynd_private_subnet_1"
  }
}

resource "aws_subnet" "tobeynd_private_subnet_2" {
  vpc_id            = aws_vpc.tobeynd_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "tobeynd_private_subnet_2"
  }
}

# --- INTERNET GATEWAY ---
resource "aws_internet_gateway" "tobeynd_igw" {
  vpc_id = aws_vpc.tobeynd_vpc.id

  tags = {
    Name = "tobeynd_igw"
  }
}

# --- ELASTIC IP FOR NAT GATEWAY ---
resource "aws_eip" "tobeynd_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "tobeynd_nat_eip"
  }
}

#----NAT Gateway ( in public subnet, used by the private subnets)-----
resource "aws_nat_gateway" "tobeynd_nat_gw" {
  allocation_id = aws_eip.tobeynd_nat_eip.id
  subnet_id     = aws_subnet.tobeynd_public_subnet_1.id

  tags = {
    Name = "tobeynd_nat_gw"
  }

  depends_on = [aws_internet_gateway.tobeynd_igw]
}

#--- ROUTE TABLES ---

# --- PUBLIC ROUTE TABLE ---

resource "aws_route_table" "tobeynd_public_rt" {
  vpc_id = aws_vpc.tobeynd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tobeynd_igw.id
  }

  tags = {
    Name = "tobeynd_public_rt"
  }
}


#--- PRIVATE ROUTE TABLE ---
resource "aws_route_table" "tobeynd_private_rt" {
  vpc_id = aws_vpc.tobeynd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tobeynd_nat_gw.id
  }

  tags = {
    Name = "tobeynd_private_rt"
  }
}

# --- ROUTE TABLE ASSOCIATIONS ---
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.tobeynd_public_subnet_1.id
  route_table_id = aws_route_table.tobeynd_public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.tobeynd_public_subnet_2.id
  route_table_id = aws_route_table.tobeynd_public_rt.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.tobeynd_private_subnet_1.id
  route_table_id = aws_route_table.tobeynd_private_rt.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.tobeynd_private_subnet_2.id
  route_table_id = aws_route_table.tobeynd_private_rt.id
}

# --- SECURITY GROUPS---

# --- ALB ---
resource "aws_security_group" "tobeynd_alb_sg" {
  name        = "tobeynd_alb_sg"
  description = "Allow HTTP and HTTPS from the internet"
  vpc_id      = aws_vpc.tobeynd_vpc.id

  ingress {

    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "tobeynd_alb_sg"
  }
}

# ---EC2 instance sg ---
resource "aws_security_group" "tobeynd_ec2_sg" {

  name        = "tobeynd_ec2_sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.tobeynd_vpc.id


  ingress {
    description     = "App port from ALB only"
    from_port       = 3002
    to_port         = 3002
    protocol        = "tcp"
    security_groups = [aws_security_group.tobeynd_alb_sg.id]

  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "tobeynd_ec2_sg"
  }

}

#--- RDS ----
resource "aws_security_group" "tobeynd_rds_sg" {
  name        = "tobeynd_rds_sg"
  description = "Allow PostgreSQL from EC2 instances only"
  vpc_id      = aws_vpc.tobeynd_vpc.id

  ingress {
    description     = " PostgreSQL from EC2 instances only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.tobeynd_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tobeynd_rds_sg"
  }
}

# --- RDS SUBNET GROUP ---
# --- RDS SUBNET GROUP ---
resource "aws_db_subnet_group" "tobeynd_db_subnet_group" {
  name       = "tobeynd-db-subnet-group"
  subnet_ids = [
    aws_subnet.tobeynd_private_subnet_1.id,
    aws_subnet.tobeynd_private_subnet_2.id
  ]

  tags = {
    Name = "tobeynd_db_subnet_group"
  }
}

# --- RDS POSTGRESQL INSTANCE ---
resource "aws_db_instance" "tobeynd_rds" {
  identifier     = "tobeynd-fleet-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.tobeynd_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.tobeynd_db_subnet_group.name

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "tobeynd_fleet_db"
  }
}







