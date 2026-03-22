provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-2026-felexirunguvault"
    key          = "workspaces-example/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.example_sg.id]

  # Hardcode "dev" or use a local variable
  tags = {
    Name        = "web-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "${var.html_content}" > index.html
    nohup busybox httpd -f -p ${var.port}&
    EOF
}

resource "aws_security_group" "example_sg" {
  name        = "example_sg-dev"
  description = "Security group for dev environment"

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }

  tags = {
    Name = "example_sg-dev"
  }
}