terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-2026-felexirunguvault"
    key          = "day-10/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

# provider "aws" {
#   region = "us-east-1"
# }

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "test1" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}
# resource "aws_iam_user" "test2" {
#   count = 3
#   name  = "${var.name}-${count.index}"
# }
