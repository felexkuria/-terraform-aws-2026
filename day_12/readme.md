# Zero-Downtime Deployments with Terraform

Welcome to the comprehensive guide for Day 12. This guide is based on **Chapter 5 of "Terraform: Up & Running" by Yevgeniy Brikman (pages 169–189)**.

## 1. The Challenge: Why Default Terraform Causes Downtime

When you update a resource that cannot be modified in-place (like a Launch Template or Launch Configuration), Terraform's default behavior is to **destroy first, then create**.

### The Downtime Window:
1.  **Old Resource Destroyed**: Your ASG is deleted, and instances are terminated.
2.  **Downtime**: Your application is completely down. This window can last for minutes.
3.  **New Resource Created**: A new ASG is spun up, and new instances begin to boot.
4.  **Recovery**: Your application comes back up after instances pass health checks.

For production services, this is **unacceptable**.

---

## 2. The Solution: `create_before_destroy`

To fix this, we use the `lifecycle` block to reverse the order of operations.

### The Improved Flow:
1.  **New Resource Created**: Terraform creates the new ASG first.
2.  **Transition**: Traffic shifts to the new instances as they become healthy.
3.  **Old Resource Destroyed**: Only once the new fleet is ready, Terraform deletes the old ASG.

```hcl
lifecycle {
  create_before_destroy = true
}
```

---

## 3. The ASG Naming Problem

AWS does not allow two Autoscaling Groups with the same name to exist simultaneously in the same VPC. If your ASG name is hardcoded (e.g., `name = "web-server-asg"`), the `create_before_destroy` operation will fail because Terraform tries to create a new ASG with a name that is still in use by the old one.

### The Fix: `random_id` or `name_prefix`
We use a `random_id` resource or the `name_prefix` attribute to ensure each deployment has a unique name.

```hcl
resource "random_id" "server" {
  keepers = {
    # Generate a new ID whenever the AMI/Launch Template changes
    ami_id = var.ami
  }
  byte_length = 8
}

resource "aws_autoscaling_group" "example" {
  name_prefix = "${var.cluster_name}-${random_id.server.hex}-"
  # ...
}
```

---

## 4. Step-by-Step Guide: Achieving Zero-Downtime

### Step 1: Implement the Logic
Add `create_before_destroy` to both your `aws_launch_template` and `aws_autoscaling_group`. Use `health_check_type = "ELB"` to ensure the ASG waits for the Load Balancer to confirm instances are actually serving traffic.

### Step 2: Continuous Traffic Check
Before deploying an update, open a second terminal and run this loop:
```bash
while true; do
  curl -s http://<your-alb-dns-name>
  sleep 2
done
```

### Step 3: Deploy an Update
Change your `user_data` (e.g., update "v1" to "v2") and run `terraform apply`.

### Step 4: Verify the Transition
Observe the traffic loop. You should see a clean switch from `v1` to `v2` without any connection errors or timeouts.
**Example Output:**
```
Hello World v1
Hello World v1
Hello World v2  <-- The exact moment of transition
Hello World v2
```

---

## 5. Advanced: Blue/Green Deployment

Blue/Green deployment takes zero-downtime further by maintaining two separate environments and switching traffic atomically at the Load Balancer level using variables.

```hcl
variable "active_environment" {
  type    = string
  default = "blue"
}

resource "aws_lb_listener_rule" "blue_green" {
  action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  }
  # ...
}
```

Switching versions becomes a single API call by changing the `active_environment` variable.

---

## 6. Hands-On Labs Reference
- **Lab 1: Module Composition**: Learn how to combine small, specialized modules into complex architectures.
- **Lab 2: Module Versioning**: Implementation of Semantic Versioning (SemVer) for infrastructure code.

---

## Summary of Challenges Fixed
- **Unexpected "path" attribute**: Resolved by moving logic to listener rules.
- **ALB Naming Violations**: Underscores removed for AWS compatibility.
- **502 Bad Gateway**: App server started in `user_data`.
- **Duplicate Security Group Errors**: Fixed with `name_prefix`.

*Happy Deploying!*
