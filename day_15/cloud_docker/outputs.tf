# --- Outputs: The Voice of our Infrastructure ---

# This is how we'll find our server's address after it's built!
output "public_ip" {
  description = "The public IP address of the Docker host."
  value       = aws_instance.docker_host.public_ip
}
