module "webserver_cluster" {
  # THE SOURCE: Four steps back to get out of 'live/dev/services/webserver-cluster'
  # and into the 'modules' directory.
  # source = "../../../../modules/services/webserver-cluster"
  source = "github.com/felexkuria/-terraform-aws-2026//day_9/modules/services/webserver-cluster?ref=v0.0.1"

  cluster_name  = "webservers-dev"
  instance_type = "t3.small"
  environment = "dev"
  min_size      = 2
  max_size      = 4
}


# We must 're-wire' the output if we want to see it in our dev terminal
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}

terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-2026-felexirunguvault"
    key    = "live/dev/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}