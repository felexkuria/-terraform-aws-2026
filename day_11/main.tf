# Day 11: main.tf — The Implementation

# 1. Provide the AWS Provider
provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-2026-felexirunguvault"
    key          = "day-11/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}




# 3. Conditional Resource: Create new VPC if NOT using existing
resource "aws_vpc" "new" {
  count      = var.use_existing_vpc ? 0 : 1
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "new-vpc-${var.environment}" })
}

# 4. EC2 Instance using conditional locals
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id # Amazon Linux 2 (Double check your region's AMI!)
  instance_type = local.instance_type
  
  tags = merge(local.common_tags, { Name = "web-server-${var.environment}" })
}

# 5. Conditional Resource: Alarm only if monitoring is enabled
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_detailed_monitoring ? 1 : 0

  alarm_name          = "high-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
}
