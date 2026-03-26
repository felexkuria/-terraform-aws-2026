variable "users" {
  default = [ "kiptoo", "wekesa"]
}

# # 4. Using for_each with a map (Rich Data)
# variable "users_map" {
#   type = map(object({
#     department = string
#     admin      = bool
#   }))
#   default = {
#     alice = { department = "engineering", admin = true }
#     bob   = { department = "marketing",   admin = false }
#   }
# }
variable "name" {
  type = string
  default = "neo"
}
variable "user_names" {
  type = list(string)
  default = ["neo", "matrix", "morpheus"]
}
  