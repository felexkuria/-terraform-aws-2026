# Day 11: locals.tf — The Brain of Your Infrastructure

locals {
  # Logic happens here!
  is_production = var.environment == "production"

  instance_type = local.is_production ? "t3.small" : "t3.micro"
  min_size      = local.is_production ? 3 : 1
  max_size      = local.is_production ? 10 : 3

  # Environment-specific tagging
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Day-11-Challenge"
  }
}
