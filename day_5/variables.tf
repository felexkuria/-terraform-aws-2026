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
variable "instance_type" {
  type = string
  default = "t3.micro"
}