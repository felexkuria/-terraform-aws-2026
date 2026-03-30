# --- Variables: The Parameters of our Infrastructure ---

variable "aws_region" {
  description = "The AWS region to deploy our beautiful website."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The size of our cloud server (t2.micro is cost-effective!)."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The specific ID of the Ubuntu AMI to use."
  type        = string
  default     = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS in us-east-1
}
