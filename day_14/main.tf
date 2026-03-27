terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-2026-felexirunguvault"
    key            = "day_14/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

# 1. Default Provider (Ohio)
provider "aws" {
  region = "us-east-2"
}

# 2. Aliased Provider (California)
provider "aws" {
  region = "us-west-1"
  alias  = "california"
}

# 3. Data Source for Ohio
data "aws_ami" "ubuntu_ohio" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# 4. Data Source for California (Using Alias)
data "aws_ami" "ubuntu_cali" {
  provider    = aws.california
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# 5. Instance in Ohio (Uses Default Provider)
resource "aws_instance" "east_server" {
  ami           = data.aws_ami.ubuntu_ohio.id
  instance_type = var.instance_type
  tags          = { Name = "Malan-East" }
}

# 6. Instance in California (Uses Aliased Provider)
resource "aws_instance" "west_server" {
  provider      = aws.california
  ami           = data.aws_ami.ubuntu_cali.id
  instance_type = var.instance_type
  tags          = { Name = "Malan-West" }
}

# --- Multi-Account Setup Example (Theory) ---
# Suppose you have a separate "Production" account.
# You would define a provider that "Assumes a Role" in that account.

/*
provider "aws" {
  region = "us-east-1"
  alias  = "production"

  assume_role {
    role_arn     = "arn:aws:iam::PROD_ACCOUNT_ID:role/TerraformDeployRole"
    session_name = "TerraformSession"
  }
}
*/
