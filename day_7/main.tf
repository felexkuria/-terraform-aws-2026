provider "aws" {
  region="us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-2026-felexirunguvault"
  key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-1" 
    use_lockfile=true
    encrypt        = true
  }
}
resource "aws_instance" "example" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    tags = {
        Name = var.instance_name
    }
    vpc_security_group_ids = [aws_security_group.web_server_sg.id]
    user_data = <<-EOF
    #!/bin/bash
    echo "${var.html_content}" > index.html
    nohup busybox httpd -f -p ${var.port}&
    EOF
    
  
}
resource "aws_security_group" "example_sg" {
    name = "example_sg"
    description = "Example security group"
    ingress {
        from_port   = var.port
        to_port     = var.port
        protocol    = var.protocol
        cidr_blocks = ["[IP_ADDRESS]"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["[IP_ADDRESS]"]
    }
}