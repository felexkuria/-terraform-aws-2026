# Day 11: outputs.tf — The Results

output "vpc_id" {
  description = "The ID of the VPC being used"
  # Use index [0] to access conditionally created data or resource
  value = var.use_existing_vpc ? data.aws_vpc.existing[0].id : aws_vpc.new[0].id
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "alarm_arn" {
  description = "The ARN of the CloudWatch alarm (if created)"
  # Safe ternary guard to avoid errors if count is 0
  value = var.enable_detailed_monitoring ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : "Not Created"
}
