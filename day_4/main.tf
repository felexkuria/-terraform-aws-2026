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
resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "terraform-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # The "Gatekeeper" connection
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.port} &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
}

resource "aws_autoscaling_group" "web_server_asg" {
  # We now point to the "Launch Template" block
  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest" # Always use the most recent version of the template
  }

  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}