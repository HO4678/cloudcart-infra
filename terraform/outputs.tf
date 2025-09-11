output "alb_dns_name" {
  description = "ALB DNS"
  value       = aws_lb.alb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.address
}
