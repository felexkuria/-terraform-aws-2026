
provider "aws" {
  region=var.region
}



resource "aws_security_group" "web_server_sg" {
   # DYNAMIC NAME: Prevents name collisions in the VPC
  name = "${var.cluster_name}-alb-sg"
   # Rule 1: Allow the World to talk to the ALB on Port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule 2: Allow the ALB to talk to the instances on 8080
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
              sudo apt-get update -y
              sudo apt-get install -y busybox
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.port} &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "web_server_asg" {
  # We now point to the "Launch Template" block
  name                 = "${var.cluster_name}-asg"
  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest" # Always use the most recent version of the template
  }

  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 1
  max_size = 2

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}
resource "aws_lb" "web_server_alb" {
  # DYNAMIC NAME: This will be "webservers-dev-alb" or "webservers-prod-alb"
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_sg.id]
  subnets            = data.aws_subnets.default.ids
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.port # Your 8080 port from Day 4
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# The Rule: Send all traffic to our target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# The Attachment: Hook the ASG to the Target Group
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.id
  lb_target_group_arn    = aws_lb_target_group.asg.arn
}
