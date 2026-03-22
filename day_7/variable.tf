variable "port" {
    type = number
    default = 8080
  
}
variable "html_content" {
    type = string
    default = "<h1>Hello World</h1>"
  
}
variable "instance_name" {
    type = string
    default = "web_server"
  
}
variable "instance_type" {
    type = string
    default = "t3.micro"
  
}
variable "protocol" {
    type = string
    default = "tcp"
  
}
variable "cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
  
}   