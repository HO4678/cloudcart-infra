#!/bin/bash
# Install Docker
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Pull and run Docker container
docker pull ${docker_image}
docker run -d -p 80:3000 ${docker_image}
