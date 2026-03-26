

# # 2. Using count with a list (Fragile!)
# variable "user_names_list" {
#   type    = list(string)
#   default = ["alice", "bob", "charlie"]
# }

# resource "aws_iam_user" "count_list_example" {
#   count = length(var.user_names_list)
#   name  = "count-${var.user_names_list[count.index]}"
# }


# # resource "aws_iam_user" "foreach_example" {
# #   for_each = var.user_names_set
# #   name     = "foreach-${each.value}"
# # }


# resource "aws_iam_user" "foreach_map_example" {
#   for_each = var.users_map
#   name     = "map-${each.key}"
#   tags = {
#     Department = each.value.department
#     Admin      = each.value.admin
#   }
# }
