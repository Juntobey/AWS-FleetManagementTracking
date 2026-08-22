output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.tobeynd_rds.endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.tobeynd_vpc.id
}
