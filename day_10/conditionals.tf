variable "enable_autoscaling" {
  description = "Enable autoscaling for the cluster"
  type        = bool
  default     = true
}

resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
  
  name                   = "scale-out"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "example-asg"
}

# Environment-based instance sizing
variable "environment" {
  type    = string
  default = "dev"
}

locals {
  instance_type = var.environment == "production" ? "t2.medium" : "t2.micro"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
  instance_type = local.instance_type
  
  tags = {
    Name        = "example-server"
    Environment = var.environment
  }
}
