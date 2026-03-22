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
  ami = data.aws_ami.ubuntu.id
  # This pulls the correct type based on your active workspace!
  instance_type = "t3.micro"
  tags = {
    Name = "web-${terraform.workspace}"
    # This adds a dedicated Environment tag for easy filtering
    Environment = terraform.workspace
    ManagedBy   = "Terraform"

  }
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  user_data              = <<-EOF
    #!/bin/bash
    echo "${var.html_content}" > index.html
    nohup busybox httpd -f -p ${var.port}&
    EOF


}
resource "aws_security_group" "example_sg" {
 name = "example_sg-${terraform.workspace}"
  description = "Example security group"
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }
  tags = {
    Name = "example_sg-${terraform.workspace}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
  }
}
