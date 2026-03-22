variable "port" {
    type = number
    default = 8080
  
}
variable "html_content" {
    type = string
    default = "<h1>Hello World</h1>"
  
}
variable "instance_type" {
  type = map(string)
  default = {
    "default"    = "t2.micro" # Add this line!
    "dev"        = "t2.micro"
    "staging"    = "t2.micro"
    "production" = "t2.micro"
  }
}

variable "protocol" {
    type = string
    default = "tcp"
  
}
variable "cidr_blocks" {
    type = list(string)
    default = ["0.0.0.0/0"]
  
}   