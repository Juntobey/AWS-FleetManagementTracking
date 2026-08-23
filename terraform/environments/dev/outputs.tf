output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.tobeynd_rds.endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.tobeynd_vpc.id
}

output "alb_dns_name" {
  description = "ALB DNS name (your app's public URL)"
  value       = aws_lb.tobeynd_alb.dns_name
}
