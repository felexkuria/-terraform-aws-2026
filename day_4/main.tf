provider "aws" {
  region="us-east-1"
}
resource "aws_instance" "web_server" {
ami = data.aws_ami.ubuntu.id
instance_type="t3.micro"
vpc_security_group_ids = [aws_security_group.web_server_sg.id]
tags = {Name="web_server"}
user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p 8080&
EOF
  user_data_replace_on_change = true
}

resource "aws_security_group" "web_server_sg" {
    name = "web_server_sg"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
}