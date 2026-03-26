# Day 11: variables.tf — Your Control Panel

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, or production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable CloudWatch detailed monitoring"
  type        = bool
  default     = false
}

variable "use_existing_vpc" {
  description = "Whether to use an existing VPC"
  type        = bool
  default     = false
}
