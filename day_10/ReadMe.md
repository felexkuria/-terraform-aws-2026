# Day 10: Terraform Loops and Conditionals — Dynamic Infrastructure at Scale

### "Welcome back! This is Day 10 of the Terraform Challenge! And THIS... is Terraform!" — David Malan (style)

***

## What You Will Accomplish Today
Until now, every resource in your configurations has been declared individually. That works for small setups, but it breaks down **fast** when you need ten IAM users, five S3 buckets, or a security group rule per environment. Today, you will learn the tools that eliminate that repetition entirely: `count`, `for_each`, `for` expressions, and conditional logic. 

These are the features that make Terraform feel like a **real programming language** — and they are tested extensively in the Terraform Associate exam!

***

## 1. 📚 Read
**Book**: *Terraform: Up & Running* by Yevgeniy Brikman — Chapter 5, pages 141–160
**Key Sections**:
- Loops with `count` and `for_each`
- Conditionals with Terraform

> [!IMPORTANT]
> Pay close attention to the author's guidance on when to use `count` versus `for_each`, and why `count` has a subtle limitation when dealing with lists that can change. This distinction comes up directly in the exam!

***

## 2. 🛠️ Complete the Hands-On Labs
- **Lab 1**: Terraform Modules
- **Lab 2**: Module Sources

***

## 3. 🔄 Loops with `count`
`count` is the simplest loop — use it when you need **N identical copies** of a resource.

```hcl
resource "aws_iam_user" "example" {
  count = 3
  name  = "user-${count.index}"
}
```

> [!WARNING]
> **The Fragility of `count`**: If you use `count = length(var.user_names)` and then remove an item from the *middle* of the list, Terraform renumbers all subsequent resources and recreates them! This is destructive behavior!

***

## 4. 🔀 Loops with `for_each`
`for_each` solves the ordering problem by keying resources on a **map or set value** rather than an index. Removing one entry only affects that specific resource!

```hcl
variable "user_names" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "example" {
  for_each = var.user_names
  name     = each.value
}
```

***

## 5. 🏗️ `for` Expressions
`for` expressions transform collections **inline** — inside resource arguments, outputs, or locals. They do not create resources; they **reshape data**.

```hcl
# Produce a list of uppercase names
output "upper_names" {
  value = [for name in var.user_names : upper(name)]
}
```

***

## 6. 🚦 Conditionals
Terraform conditionals use the **ternary operator**: `condition ? true_value : false_value`. Combine them with `count` to make resources optional!

```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
  # ...
}
```

***

## 7. 🚀 Refactor Your Infrastructure
Go back to your webserver cluster code (Days 3–9) and:
1. Replace repeated resource blocks with `for_each`.
2. Use `count = var.some_bool ? 1 : 0` for optional resources.
3. Use `for` expressions in outputs for useful maps.
4. Centralize conditional logic in `locals`.

***

## 📝 How to Submit
Use the **Workspace tab** to submit your work for today. Include:
- **Repository Link**: Refactored code link.
- **Live App Link**: Social media post.
- **Documentation**: Your full learning journal entry.

> [!TIP]
> Make your blog post the definitive reference you wish you had before today!

***
*This challenge is brought to you by AWS AI/ML UserGroup Kenya, Meru HashiCorp User Group, and EveOps.*
