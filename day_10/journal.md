# Day 10 Learning Journal: Terraform Loops and Conditionals

## 1. count Example
```hcl
resource "aws_iam_user" "example" {
  count = 3
  name  = "user-${count.index}"
}
```
**Explanation**: `count.index` gives you the current iteration index (0, 1, 2).
**Breakage Scenario**: If you use `count = length(var.user_names)` and remove an item from the middle of the list, Terraform renumbers all subsequent resources and recreates them. This is destructive and can lead to downtime or unintended resource replacement.

## 2. for_each Example
```hcl
resource "aws_iam_user" "example" {
  for_each = toset(["alice", "bob", "charlie"])
  name     = each.value
}
```
**Explanation**: `for_each` keys resources on the actual value. If you remove "alice", only "alice" is touched. "bob" and "charlie" remain unchanged because their keys ("bob" and "charlie") didn't change.

## 3. for Expression
```hcl
output "uppercase_names" {
  value = [for name in var.user_names : upper(name)]
}
```
**Explanation**: This transforms a list of names into a list of uppercase names. It's useful for formatting outputs or preparing data for other resources without creating new physical resources.

## 4. Conditional Logic
```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
  # ...
}
```
**Explanation**: This uses the ternary operator to decide whether to create the resource (count = 1) or skip it (count = 0).

## 5. Refactored Infrastructure
I refactored the `webserver-cluster` module:
- Replaced static tags in the ASG with a `dynamic "tag"` block using `for_each = var.custom_tags`.
- Added `aws_autoscaling_schedule` resources using `count = var.environment == "prod" ? 1 : 0` to enable automated scaling only in production.
- Used a `local` block to determine `instance_type` based on the `environment` variable.

## count vs for_each — My Verdict
I would choose `count` only for truly identical resources where order doesn't matter (e.g. 10 identical background workers). For anything identified by a unique name or where the list can change, `for_each` is the safer, more robust choice.

## Chapter 5 Learnings
When you use `count`, Terraform creates a list of resources accessible via `<TYPE>.<NAME>[<INDEX>]`. For `for_each`, it creates a map accessible via `<TYPE>.<NAME>["<KEY>"]`.

## Challenges and Fixes
- **Error**: `each.value` confusion when using maps vs sets. *Fix*: Remember that for a set, `each.key` and `each.value` are the same, but for a map, `each.key` is the map key and `each.value` is the map value.
- **Error**: Type constraints in `dynamic` blocks. *Fix*: Ensure the `for_each` points to a map or set that matches the expected structure.
