# --- The Automated Builder: Local Orchestration ---

# This configuration replaces manual "docker build" and "docker run" commands.
# Terraform now acts as the "Moving Company" that handles the entire lifecycle!

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}


provider "docker" {}
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-2026-felexirunguvault"
    key    = "day_15/cloud_docker/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

# --- Step 1: Automated Image Construction ---
# Terraform looks into our website folder, reads the Dockerfile, 
# and builds the image automatically. No more "docker build -t ..."!
resource "docker_image" "beautiful_site" {
  name = "${var.image_name}:latest"
  build {
    # We point to the sibling directory where our source code lives!
    context = "../lab_docker_website"
  }
}

# --- Step 2: Automated Deployment ---
# Terraform starts the container, ensuring it's always running 
# and correctly mapped to our local port. No more "docker run -d ..."!
resource "docker_container" "beautiful_site_container" {
  name  = var.container_name
  image = docker_image.beautiful_site.image_id

  ports {
    internal = 80
    external = var.external_port
  }
}
