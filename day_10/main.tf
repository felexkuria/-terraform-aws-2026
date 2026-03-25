terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-2026-felexirunguvault"
    key          = "day-10/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
