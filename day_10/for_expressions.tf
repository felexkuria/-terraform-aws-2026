variable "user_names" {
  type    = list(string)
  default = ["alice", "bob", "charlie"]
}

# Transform list to list (uppercase)
output "upper_names" {
  value = [for name in var.user_names : upper(name)]
}

# Transform list to list (filter)
output "short_upper_names" {
  value = [for name in var.user_names : upper(name) if length(name) < 5]
}

# Transform list to map
output "bios" {
  value = { for name in var.user_names : name => "Hi, I am ${name}" }
}
