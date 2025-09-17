# CloudCart: Cloud-Native Web App on AWS with Terraform, Docker, and RDS
CloudCart is a simple Python web application deployed in the cloud using modern DevOps tools and best practices. The app was containerized with Docker, provisioned using Terraform, and deployed on AWS EC2 with a PostgreSQL RDS database backend.

This project demonstrates skills in:
- Infrastructure as Code (Terraform)
- Containerization and image management (Docker & Docker Hub)
- Cloud deployment (AWS EC2, RDS)
- Networking and security (VPC, Security Groups)

# Tech Stack
- Programming: Python (Flask)
- Infrastructure: Terraform, AWS (EC2, RDS, VPC, Security Groups)
- Containerization: Docker, Docker Hub
- Database: PostgreSQL on AWS RDS

# Key Features
1. Infrastructure as Code (IaC):
- Terraform scripts to provision VPC, subnets, EC2, and RDS.
- Outputs RDS endpoint and EC2 public IP.

2. Containerized Application:
- Python app containerized with Docker.
- Image pushed to Docker Hub.

3. Cloud Deployment:
- Docker container runs on AWS EC2 instance.
- Connects to PostgreSQL database hosted on AWS RDS.
- Exposed over port 5000, accessible via browser.

4. Networking & Security:
- Configured security groups for SSH, HTTP, and custom app port (5000).
- Verified secure database connection between EC2 and RDS.

# Project Architecture
                ┌────────────────────────┐
                │        Browser         │
                │ http://<EC2-Public-IP> │
                └────────────┬───────────┘
                             │
                       Port 5000/80
                             │
                ┌────────────▼───────────┐
                │        EC2 Instance    │
                │  Dockerized Flask App  │
                └────────────┬───────────┘
                             │
                         Port 5432
                             │
                ┌────────────▼───────────┐
                │         RDS            │
                │  PostgreSQL Database   │
                └────────────────────────┘

# Deployment Steps

1. Provision Infrastructure:
/n terraform init
/n terraform apply
/n terraform output   # Get RDS endpoint + EC2 IP

2. Build & Push Docker Image:
docker build -t cloudcart-app:latest .
docker tag cloudcart-app:latest <dockerhub-username>/cloudcart-app:latest
docker push <dockerhub-username>/cloudcart-app:latest

3. Run Container on EC2:
docker run -d -p 5000:5000 \
  -e DATABASE_URL='postgresql://<db_user>:<db_password>@<rds_endpoint>/<db_name>' \
  <dockerhub-username>/cloudcart-app:latest

4. Access the App:
- Browser → http://<EC2-Public-IP>:5000
- Example Output: Hello from CloudCart App running in Docker!






