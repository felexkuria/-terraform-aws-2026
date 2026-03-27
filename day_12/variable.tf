variable "port_tcp" {
  description = "Port number for the web server"
  type        = number
  default     = 8080
}
variable "protocol_tcp" {
  description = "Protocol for the web server"
  type        = string
  default     = "tcp"
}
variable "cidr_blocks" {
  description = "CIDR blocks for the web server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "instance_type" {
  description = "Instance type for the web server"
  type        = string
  default     = "t3.micro"
}
variable "protocol_http" {
  description = "Protocol for the web server"
  type        = string
  default     = "HTTP"
}
variable "port_http" {
  description = "Port number for the web server"
  type        = number
  default     = 80
}

variable "active_environment" {
  description = "The active environment: blue or green"
  type        = string
  default     = "blue"
}