# --- Outputs: The Voice of our Infrastructure ---

# This is how we'll find our website after Terraform builds and runs it!
output "website_url" {
  description = "The URL to access your beautiful, automated website!"
  value       = "http://localhost:${var.external_port}"
}
output "container_id" {
  description = "The ID of the container"
  value       = docker_container.beautiful_site_container.id
}
output "image_id" {
  description = "The ID of the image"
  value       = docker_image.beautiful_site.image_id
}