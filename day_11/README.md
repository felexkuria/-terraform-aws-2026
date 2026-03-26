# Day 11: Mastering Terraform Conditionals — Smarter, More Flexible Deployments

### "Welcome back! This is Day 11 of the 30-Day Terraform Challenge! And THIS... is Terraform!"

***

## 🚀 Step 0: The Entry Point (Where do I start?)
Before we write logic, we need a place to put it! In Terraform, your **Entry Point** is a file named `main.tf`. 

Think of `main.tf` like the `main` function in C or Java. It is where you define your primary resources. For Day 11, you should also have:
- `variables.tf`: To define your "switches" (Input Variables).
- `outputs.tf`: To show your results.
- `locals.tf` (Optional): To store your conditional logic (though you can also put this inside `main.tf`!).

> **Starter Templates:** I've provided the followings "skeleton" files to get you started:
> - [main.tf](file:///Users/felexirungu/Downloads/ProjectLevi/Terraform/terraform-aws-2026/day_11/main.tf): The core logic (AWS provider, VPCs, EC2 instances).
> - [variables.tf](file:///Users/felexirungu/Downloads/ProjectLevi/Terraform/terraform-aws-2026/day_11/variables.tf): Your control panel with validation blocks.
> - [locals.tf](file:///Users/felexirungu/Downloads/ProjectLevi/Terraform/terraform-aws-2026/day_11/locals.tf): The "Brain" where your ternary logic lives.
> - [outputs.tf](file:///Users/felexirungu/Downloads/ProjectLevi/Terraform/terraform-aws-2026/day_11/outputs.tf): Safe ways to view your resources.

> **Go ahead:** Review these files, then run `terraform init` to begin! **This is where the magic happens!**

### 💻 How to Run This (The Terminal)
You must run your commands **inside** the `day_11` directory. Open your terminal and type:

```bash
# 1. Navigate to the day_11 folder
cd day_11

# 2. Initialize the project (Downloads providers)
terraform init

# 3. See what will happen (The Plan)
terraform plan
```
> **Attention:** If you are not in the `day_11` folder, Terraform won't be able to find your `main.tf` and will give you an error!

***

## 🌟 The Big Picture: Why Conditionals?
Yesterday, we dipped our toes into loops. Today, we dive deep into **Conditionals**. 

Imagine you're building a house. In the summer, you want a screen door to let the breeze in. In the winter, you want a heavy, insulated door. You don't build two different houses; you just change the door based on the **condition** of the season!

In Terraform, conditionals allow a **single configuration** to behave differently across environments (Dev, Staging, Prod) without duplicating a single line of code. **In fact**, this is how you make your infrastructure truly "environment-aware."

***

## 🛠️ Step 1: The Ternary Pattern (The "How-To")
The core of Terraform logic is the **ternary expression**. It’s a simple question: "Is this true? If yes, do A. If no, do B."

### 💻 Better Together: Centralizing with `locals`
Don't scatter logic everywhere! Use `locals.tf` to keep your "brain" in one place.

```hcl
# From locals.tf
locals {
  is_production = var.environment == "production"

  instance_type = local.is_production ? "t2.medium" : "t2.micro"
  min_size      = local.is_production ? 3 : 1
  max_size      = local.is_production ? 10 : 3
}
```
> **Pro Tip:** Refactoring logic into `locals` makes your code cleaner and much easier to test. It centralizes the "Why" of your infrastructure.

***

### 🌗 Step 2: To Be or Not to Be (`count`)
What if you only want a resource to exist in Production or when a specific toggle is on? We use the `count = condition ? 1 : 0` pattern.

```hcl
# From main.tf
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  # 1 means "Create it", 0 means "Ignore it"
  count = var.enable_detailed_monitoring ? 1 : 0

  alarm_name          = "high-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
}
```
When `count` is 0, Terraform simply **does not create** the resource. It’s like it was never there!

> [!IMPORTANT]
> **Brikman's Corner: Plan-Time vs. Apply-Time**
> As Yevgeniy Brikman notes in Chapter 5, Terraform must be able to compute `count` and `for_each` during the **plan phase**. 
> - **Works:** Using variables, locals, and data sources.
> - **Fails:** Trying to use an output from a resource that hasn't been created yet (e.g., a random ID). If Terraform doesn't know the number at plan time, it will throw an error!

***

### ⚠️ Step 3: The "Zero-Element" Trap
When you use `count`, you can't just point to the resource anymore. If `count` is 0 and you try to access it... **Error!**

### 💻 The Safe Way:
```hcl
# From outputs.tf
# ❌ WRONG: This will crash if count is 0
output "alarm_arn" {
  value = aws_cloudwatch_metric_alarm.high_cpu.arn
}

# ✅ RIGHT: Check the condition again!
output "alarm_arn" {
  value = var.enable_detailed_monitoring ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : "Not Created"
}
```
By using `[0]`, we access the first element of the list that `count` created. If it doesn't exist, we safely return a string or `null`.

> [!TIP]
> **Expert Pattern: The `one` Function**
> Brikman suggests a cleaner way to handle single optional values using the `one` function:
> `value = one(aws_cloudwatch_metric_alarm.high_cpu[*].arn)`
> This is more descriptive and handles the empty list case automatically!

***

### 🛡️ Step 4: Input Validation (The "Safety Net")
Don't let users pass "tuesday" as an environment name! Use a `validation` block in `variables.tf` to catch errors early.

```hcl
# From variables.tf
variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, or production)"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}
```

***

### 🌲 Step 5: Greenfield vs. Brownfield (Conditional Data Sources)
Need to create a NEW VPC or use an EXISTING one? Use conditionals on both your data sources and resources in `main.tf`.

```hcl
# Look it up ONLY if requested
data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  tags = {
    Name = "existing-vpc" 
  }
}

# Create it ONLY if NOT using existing
resource "aws_vpc" "new" {
  count      = var.use_existing_vpc ? 0 : 1
  cidr_block = "10.0.0.0/16"
}
```


## ✅ Submission Checklist
- [ ] Refactored `locals` block added.
- [ ] `count = condition ? 1 : 0` implemented for optional resources.
- [ ] Outputs updated with ternary guards.
- [ ] Validation blocks active.
- [ ] Blog post and Social Media link ready.

***

### 💡 "This is Day 11. Go forth and make your infrastructure smarter!"
#30DayTerraformChallenge #Terraform #IaC #DevOps #AWS
