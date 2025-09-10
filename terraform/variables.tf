variable "aws_region" {
  default = "us-east-1"
}

variable "docker_image" {
  description = "Docker image to run on EC2"
  type        = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
