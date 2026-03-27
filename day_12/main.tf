provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-2026-felexirunguvault"
    key    = "day_12/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt =true
  }
}
# Step 1 create launch template
resource "aws_launch_template" "web_server_lt" {
  name_prefix = "web_server_template_lt-"

  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
#   key_name = "web_server_key"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "<h1>Hello World from Terraform ${var.instance_type}</h1>" > index.html
              nohup python3 -m http.server ${var.port_tcp} &
              EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}
# Step 2 create webserver security group

resource "aws_security_group" "web_server_sg" {
  name_prefix = "web_server_sg-"
  description = "Allow SSH and HTTP traffic"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = var.port_tcp
    to_port = var.port_tcp
    protocol = var.protocol_tcp
 security_groups = [aws_security_group.web_server_lb_sg.id]
 }

 # Step 3 create webserver load balancer security group
  }
  resource "aws_security_group" "web_server_lb_sg" {
    name_prefix = "web_server_lb_sg-"
    description = "Allow SSH and HTTP traffic"
    vpc_id = data.aws_vpc.default.id
    ingress {
      from_port = var.port_http
      to_port = var.port_http
      protocol = var.protocol_tcp
      cidr_blocks =var.cidr_blocks
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks =var.cidr_blocks
    }
  }
  # Step 4 create webserver load balancer
resource "aws_lb" "web_server_lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_server_lb_sg.id]
  subnets = data.aws_subnets.default.ids
}
#Step 5 create listener
resource "aws_lb_listener" "web_server_listener" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port = var.port_http
  protocol = var.protocol_http
  
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello World You are lost in the cloud"
      status_code  = "404"
    }
    
  }
  
}
#Step 6 create listener rule
resource "aws_lb_listener_rule" "web_server_listener_rule" {
  listener_arn = aws_lb_listener.web_server_listener.arn
  priority = 100
  
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  
  action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.web_server_tg_blue.arn : aws_lb_target_group.web_server_tg_green.arn
  }
}
#Step 7 create target group
#Step 7: Create Blue and Green Target Groups
resource "aws_lb_target_group" "web_server_tg_blue" {
  name     = "web-server-tg-blue"
  port     = var.port_tcp
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "web_server_tg_green" {
  name     = "web-server-tg-green"
  port     = var.port_tcp
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

#Step 8 create asg
resource "aws_autoscaling_group" "web_server_asg" {
  name_prefix     = "web-server-asg-${random_id.asg_id.hex}-"
  desired_capacity = 2
  max_size         = 5
  min_size         = 1
  vpc_zone_identifier = data.aws_subnets.default.ids
  launch_template {
    id = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }
  
  # Use the Target Group based on the active environment
  target_group_arns = [var.active_environment == "blue" ? aws_lb_target_group.web_server_tg_blue.arn : aws_lb_target_group.web_server_tg_green.arn]

  tag {
    key = "Name"
    value = "web_server_asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Step 9: Use random_id to handle ASG replacement
resource "random_id" "asg_id" {
  keepers = {
    # Generate a new ID whenever the launch template changes
    lt_id = aws_launch_template.web_server_lt.default_version
  }
  byte_length = 4
}

#Step 9 create scaling policy
resource "aws_autoscaling_policy" "web_server_asg_policy" {
  name = "web_server_asg_policy"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}
#Step 10 register instances to target group

resource "aws_autoscaling_attachment" "asg_attachment" {
  # Which Agency are we watching?
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.id

  # Where are we sending the new hires?
  lb_target_group_arn    = var.active_environment == "blue" ? aws_lb_target_group.web_server_tg_blue.arn : aws_lb_target_group.web_server_tg_green.arn
}
