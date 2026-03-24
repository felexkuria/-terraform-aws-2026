# 1. Using count (Simple Loop)
resource "aws_iam_user" "count_example" {
  count = 3
  name  = "user-${count.index}"
}

# 2. Using count with a list (Fragile!)
variable "user_names_list" {
  type    = list(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "count_list_example" {
  count = length(var.user_names_list)
  name  = var.user_names_list[count.index]
}

# 3. Using for_each with a set (Safer)
variable "user_names_set" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "foreach_example" {
  for_each = var.user_names_set
  name     = each.value
}

# 4. Using for_each with a map (Rich Data)
variable "users_map" {
  type = map(object({
    department = string
    admin      = bool
  }))
  default = {
    alice = { department = "engineering", admin = true }
    bob   = { department = "marketing",   admin = false }
  }
}

resource "aws_iam_user" "foreach_map_example" {
  for_each = var.users_map
  name     = each.key
  tags = {
    Department = each.value.department
    Admin      = each.value.admin
  }
}
