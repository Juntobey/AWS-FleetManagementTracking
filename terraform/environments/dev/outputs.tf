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

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.tobeynd_asg.name
}

output "cpu_high_alarm" {
  description = "Scale-up CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.tobeynd_cpu_high.alarm_name
}

output "cpu_low_alarm" {
  description = "Scale-down CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.tobeynd_cpu_low.alarm_name
}
