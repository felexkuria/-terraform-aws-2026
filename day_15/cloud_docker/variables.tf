# --- Variables: The Parameters of our Orchestration ---

variable "external_port" {
  description = "The local port to access our website (e.g., 8080)."
  type        = number
  default     = 8080
}

variable "container_name" {
  description = "The name of our running Docker container."
  type        = string
  default     = "my-cs50-site"
}

variable "image_name" {
  description = "The name for our Docker image."
  type        = string
  default     = "crash_course_app"
}
variable "docker_host" {
  description = "The path to the Docker socket (Crucial for Colima users!)."
  type        = string
  default     = "unix:///Users/felexirungu/.colima/default/docker.sock"
}

