provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-2026-felexirunguvault"
    key    = "day_13/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}
# 1. Fetch the secret version from Secrets Manager
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
  
}
# 2. Parse the JSON string retrieved from AWS
locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}
# 3. Use the secret to deploy a Database
resource "aws_db_instance" "example" {
  identifier_prefix   = "lab-secrets"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "example_db"
  username = "admin"
  password = local.db_creds.password
}
variable "db_password" {
  type = string
  sensitive = true
}
# 4. Output the connection string
output "db_connection_string" {
 value     = "mysql://${aws_db_instance.example.username}@${aws_db_instance.example.endpoint}"
#  sensitive = true
}