# Mastering Loops and Conditionals in Terraform

### "This is Day 10 of the 30-Day Terraform Challenge!"

Today was a massive leap forward. We moved from static, repetitive declarations to dynamic, programmable infrastructure. If you've been copy-pasting resource blocks, today is the day that ends.

## The Tools of the Trade

### 1. `count`: The Simple Repeater
`count` is great when you need identical resources. But beware! 

```hcl
resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}
```

**The Index Problem**: If `var.user_names` is `["alice", "bob", "charlie"]` and you remove `"alice"`, Terraform shifts the indices. Bob becomes index 0, Charlie becomes index 1. Terraform will **delete and recreate** both Bob and Charlie! This is why `count` should be used with caution for lists.

### 2. `for_each`: The Robust Choice
`for_each` keys resources on the *value* themselves.

```hcl
resource "aws_iam_user" "example" {
  for_each = set(var.user_names)
  name     = each.value
}
```
Now, if you remove "alice", only "alice" is deleted. Bob and Charlie are safe!

### 3. `for` Expressions: Reshaping Data
Think of `for` expressions as "list comprehension" for HCL.

```hcl
output "upper_names" {
  value = [for name in var.user_names : upper(name)]
}
```

### 4. Conditionals: Logic at Scale
Using the ternary operator `condition ? true : false`, we can make infrastructure optional.

```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
  # ...
}
```

## Summary
Loops and conditionals turn Terraform into a powerful, flexible tool that can handle any scale. No more repetition—just clean, dry code!

#Terraform #IaC #DevOps #AWS #30DayTerraformChallenge
