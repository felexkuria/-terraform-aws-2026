# Output uppercase names using a for expression
output "uppercase_usernames" {
  value = [for name in var.user_names_list : upper(name)]
}

# Output a map of name -> ARN (mocking ARN since we aren't actually applying)
output "user_arn_map" {
  value = { for name, user in aws_iam_user.foreach_example : name => user.arn }
}
