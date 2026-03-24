module "webserver_cluster" {
  # source = "../../../../modules/services/webserver-cluster"
  source = "github.com/felexkuria/-terraform-aws-2026//day_9/modules/services/webserver-cluster?ref=v0.0.2"

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