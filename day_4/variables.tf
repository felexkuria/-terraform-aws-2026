variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "name" {
  type = string
  default = "web_server"
}
variable "port" {
    type = number
    default = 8080
  
}
variable "protocol" {
    type = string
    default = "tcp"
  
}
variable "cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
  
}
variable "region" {
    type = string
    default = "us-east-1"
  
}
variable "sg_name" {
    type = string
    default = "web_server_sg" 
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # The Filter: "Give me everything EXCEPT us-east-1e"
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}
