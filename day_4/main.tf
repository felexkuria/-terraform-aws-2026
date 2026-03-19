provider "aws" {
  region=var.region
}

resource "aws_instance" "web_server" {
ami = data.aws_ami.ubuntu.id
instance_type=var.instance_type
vpc_security_group_ids = [aws_security_group.web_server_sg.id]
tags = {Name=var.name}
user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p ${var.port} &
EOF
  user_data_replace_on_change = true
}

resource "aws_security_group" "web_server_sg" {
    name = var.sg_name
    ingress {
        from_port =var.port
        to_port = var.port
        protocol = var.protocol
        cidr_blocks = var.cidr_blocks
    }
}
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
}
