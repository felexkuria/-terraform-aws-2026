variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the cluster"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "server_port" {
  description = "Port the server uses for HTTP"
  type        = number
  default     = 8080
}
variable "port" {
  type = number
  default = 8080
}
variable "protocol" {
  type = string
  default = "HTTP"
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "sg_name" {
  type = string
  default = "web_server_sg"
}
variable "cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
variable "environment" {
  type        = string
  description = "The deployment environment (dev, stage, prod)"
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
  default     = false
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}
# variable "instance_type" {
#   type = string
#   default = "t3.micro"
# }