# variable "enable_autoscaling" {
#   description = "Enable autoscaling for the cluster"
#   type        = bool
#   default     = true
# }

# # resource "aws_autoscaling_policy" "scale_out" {
# #   count = var.enable_autoscaling ? 1 : 0
# #   
# #   name                   = "scale-out"
# #   scaling_adjustment      = 1
# #   adjustment_type         = "ChangeInCapacity"
# #   cooldown                = 300
# #   autoscaling_group_name  = "example-asg" # This requires an ASG to exist!
# # }

# # Environment-based instance sizing
# variable "environment" {
#   type    = string
#   default = "dev"
# }

# locals {
#   instance_type = var.environment == "production" ? "t2.medium" : "t2.micro"
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
#   owners = ["099720109477"] # Canonical
# }

# resource "aws_instance" "example" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = local.instance_type
  
#   tags = {
#     Name        = "example-server"
#     Environment = var.environment
#   }
# }
