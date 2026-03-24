module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-production"
  instance_type = "t2.small"
  environment = "prod"
  min_size      = 4
  max_size      = 10
}
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-2026-felexirunguvault"
    key    = "live/production/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}