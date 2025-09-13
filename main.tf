provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "cloudcart_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudcart-vpc"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudcart-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudcart-public-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "cloudcart-private-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "cloudcart-private-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cloudcart_vpc.id

  tags = {
    Name = "cloudcart-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet_1.id

  tags = {
    Name = "cloudcart-nat"
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloudcart_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cloudcart-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cloudcart_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "cloudcart-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rta_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
resource "aws_security_group" "app_sg" {
  name = "cloudcart-app-sg"
  description = "Allow SSH/HTTP to app servers"
  vpc_id = aws_vpc.cloudcart_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudcart-app-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name = "cloudcart-db-sg"
  description = "Allow Postgres from app servers"
  vpc_id = aws_vpc.cloudcart_vpc.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudcart-db-sg"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "cloudcart-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "Managed by Terraform"

  tags = {
    Name = "cloudcart-db-subnet-group"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier              = "terraform-postgres-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.5"               # Valid Postgres version
  instance_class          = "db.t3.micro"
  db_name                 = "cloudcartdb"        # Add database name
  username                = "cloudcartadmin"     # Not 'admin'
  password                = "StrongPassword123!" # Keep secret in real project
  parameter_group_name    = "default.postgres15"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  publicly_accessible     = false

  tags = {
    Name = "cloudcart-postgres"
  }
}


# EC2 Instance
resource "aws_instance" "app_instance" {
  ami = "ami-0c02fb55956c7d316" # Ubuntu 22.04
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name = "habib-keypair"

  tags = {
    Name = "cloudcart-app"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
