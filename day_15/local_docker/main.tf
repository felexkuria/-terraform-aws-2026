# --- Phase 0: Local Orchestration with Terraform ---

# This configuration uses the Terraform Docker provider to build and run 
# our container locally before we even touch the cloud!

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# --- Step 1: Build the Image ---
# We tell Terraform to build the image using the Dockerfile in our website folder.
resource "docker_image" "beautiful_site" {
  name = "crash_course_app:latest"
  build {
    context = "../lab_docker_website"
  }
}

# --- Step 2: Run the Container ---
# We tell Terraform to start the container, mapping port 8080 (local) to 80 (internal).
resource "docker_container" "beautiful_site_container" {
  name  = "my-cs50-site"
  image = docker_image.beautiful_site.image_id

  ports {
    internal = 80
    external = 8080
  }
}
