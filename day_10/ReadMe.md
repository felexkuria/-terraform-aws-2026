# Day 10: Terraform Loops and Conditionals — Dynamic Infrastructure at Scale

### "Welcome back! This is Day 10 of the Terraform Challenge! And THIS... is Terraform!"

***

## 🌟 The Big Picture: Why are we here?
Imagine you're a teacher and you need to give the same worksheet to 30 students. Would you handwrite each one, one by one? **No!** You'd use a **photocopier**. 

In Terraform, up until today, we've been handwriting our infrastructure. One server here, one user there. Today, we learn to use the "photocopier" of Terraform: **Loops** and **Conditionals**. 

***

## 🔒 Step 1: The Secure Vault (S3 Backend)
Before we build anything, we need to decide where our "Source of Truth" lives. If you store your Terraform state on your laptop, and your laptop breaks... **you lose your infrastructure.**

We're using an **S3 Bucket** to store our state safely in the cloud.

### 💻 Look at `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-2026-felexirunguvault"
    key          = "day-10/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

***

## 🛠️ Step 2: The Photocopier (`count`)
Sometimes you just need **N** identical copies.

### 💻 Look at `iam_users.tf`:
```hcl
# Simple Loop: Just give me 3 users!
resource "aws_iam_user" "count_example" {
  count = 3
  name  = "user-${count.index}"
}
```
> **What's happening?** `count.index` is a number that goes 0, 1, 2. It creates `user-0`, `user-1`, and `user-2`.

***

## 🔀 Step 3: The Labeling Machine (`for_each`)
The photocopier is great, but what if you want specific names? If you use `count` with a list and remove someone, the whole list might shift and recreate everyone! **Dangerous.**

`for_each` is the safer labeling machine.

### 💻 Look at `iam_users.tf`:
```hcl
variable "user_names_set" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "foreach_example" {
  for_each = var.user_names_set
  name     = each.value
}
```
Now, if you remove "alice", only Alice is deleted. Bob and Charlie are safe because they are identified by their **names**, not their numbers.

***

## 🏗️ Step 4: The Translator (for expressions)
Need to turn a list of names into a list of **UPPERCASE** names for a report? Use `for` expressions.

### 💻 Look at `for_expressions.tf`:
```hcl
output "upper_names" {
  value = [for name in var.user_names : upper(name)]
}
```

***

## 🚦 Step 5: The Light Switch (Conditionals)
Should we turn on the scale-out policy? Only if `enable_autoscaling` is true!

### 💻 Look at `conditionals.tf`:
```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
}
```
This is a "Ternary Operator". It says: **"Is this true? Yes? Give me 1. No? Give me 0."**

***

## 🧪 Step 6: The Lab: How to Test Your Code
Now, how do you know it works? We use three essential commands.

### 1. `terraform init`
This downloads the "plug-ins" for AWS and connects to your S3 Backend. **Run this first!**

### 2. `terraform validate`
Think of this as a spell-checker. It checks if your syntax is correct without actually touching AWS.
```bash
terraform validate
```

### 3. `terraform plan`
This is the most important command. It shows you a **preview** of what will happen.
```bash
terraform plan
```
> **Pro Tip:** Look for the "+", "-", and "~" symbols. 
> - `+` means "I'm creating this."
> - `-` means "I'm deleting this."
> - `~` means "I'm changing this."

***

## ✅ Your Graduation Checklist
- [x] Initialized the backend with `terraform init`.
- [x] Verified code structure with `terraform validate`.
- [x] Pre-checked the loops and logic with `terraform plan`.
- [x] Mastered `count`, `for_each`, and `conditionals`.





