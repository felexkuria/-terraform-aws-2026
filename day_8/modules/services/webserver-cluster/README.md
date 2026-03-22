# Day 8 — Reusable Infrastructure with Terraform Modules

> **Goal:** Write your infrastructure code once inside a **Module**, then call it from any environment (dev, prod, staging) with just 10 lines.

---

## 📁 How to Organise Your `.tf` Code

This is the most important rule in Terraform: **separate the blueprint from the build site.**

```
day_8/
├── modules/                          ← 📦 The Blueprint Vault (reusable code)
│   └── services/
│       └── webserver-cluster/
│           ├── main.tf               ← All resource definitions (ASG, ALB, SG)
│           ├── variable.tf           ← All input variables (the "knobs")
│           ├── output.tf             ← All outputs (the "signal indicators")
│           └── README.md             ← This file
│
└── live/                             ← 🏗️ The Construction Site (environment deployments)
    ├── dev/
    │   └── services/
    │       └── webserver-cluster/
    │           └── main.tf           ← Calls the module with dev settings
    └── production/
        └── services/
            └── webserver-cluster/
                └── main.tf           ← Calls the module with prod settings
```

### The Golden Rule of File Organisation

| File | Lives In | Purpose |
|------|----------|---------|
| `main.tf` | `modules/` | Defines **how** resources are built. Uses `var.*` — never hardcoded values. |
| `variable.tf` | `modules/` | Declares every input the module accepts. |
| `output.tf` | `modules/` | Declares what the module exposes to the caller. |
| `main.tf` | `live/env/` | **Calls** the module. Provides the actual values for each environment. |

---

## Step 1: Creating the Directory Structure

Run this once in your terminal to scaffold the entire project:

```bash
# -p creates all parent folders in one shot
cd day_8
mkdir -p modules/services/webserver-cluster
mkdir -p live/dev/services/webserver-cluster
mkdir -p live/production/services/webserver-cluster

# Create the module files
touch modules/services/webserver-cluster/{main.tf,variable.tf,output.tf,README.md}

# Create the deployment files
touch live/dev/services/webserver-cluster/main.tf
touch live/production/services/webserver-cluster/main.tf
```

---

## Step 2: The Module Blueprint

### A. `variable.tf` — The Input Terminals

Think of these as the **knobs and dials** on the outside of a control panel. The caller sets these; the module just uses them internally.

```hcl
# modules/services/webserver-cluster/variable.tf

variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the cluster"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "port" {
  description = "Port the server uses for HTTP requests"
  type        = number
  default     = 8080
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
```

---

### B. `output.tf` — The Signal Indicators

This is the **Digital Voltmeter** — the only values the module broadcasts back to the caller.

```hcl
# modules/services/webserver-cluster/output.tf

output "alb_dns_name" {
  value       = aws_lb.web_server_alb.dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.web_server_asg.name
  description = "The name of the Auto Scaling Group"
}
```

---

### C. `main.tf` — The Internal Wiring

This is the heart of the module. Every resource uses `var.*` — **no hardcoded values**. The `${var.cluster_name}` prefix on every resource name ensures dev and prod never collide inside the same AWS account.

```hcl
# modules/services/webserver-cluster/main.tf

provider "aws" {
  region = var.region
}

# ── Security Group ─────────────────────────────────────────────────────────────
resource "aws_security_group" "web_server_sg" {
  # DYNAMIC NAME: Prevents name collisions between dev and prod in the same VPC
  name = "${var.cluster_name}-alb-sg"

  # Rule 1: Allow the internet to reach the ALB on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule 2: Allow the ALB to reach EC2 instances on the app port (8080)
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── Launch Template ────────────────────────────────────────────────────────────
resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "terraform-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y busybox
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.port} &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ─────────────────────────────────────────────────────────
resource "aws_autoscaling_group" "web_server_asg" {
  name = "${var.cluster_name}-asg"

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size            = var.min_size
  max_size            = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

# ── Application Load Balancer ──────────────────────────────────────────────────
resource "aws_lb" "web_server_alb" {
  # Result: "webservers-dev-alb" or "webservers-production-alb"
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}

# ── Target Group + Routing Rule ────────────────────────────────────────────────
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# ── ASG → ALB Attachment ───────────────────────────────────────────────────────
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.id
  lb_target_group_arn    = aws_lb_target_group.asg.arn
}
```

---

## Step 3: The Deployment — Calling the Module

### Dev Environment (`live/dev/services/webserver-cluster/main.tf`)

```hcl
module "webserver_cluster" {
  # 4 levels up: live/dev/services/webserver-cluster → day_8/modules/...
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-dev"
  instance_type = "t3.micro"   # Free Tier eligible
  min_size      = 2
  max_size      = 4
}

# Outputs must be re-declared by the caller to appear in the terminal
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
```

### Production Environment (`live/production/services/webserver-cluster/main.tf`)

```hcl
module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-production"
  instance_type = "t2.small"   # More capacity for prod traffic
  min_size      = 4
  max_size      = 10
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
```

---

## Step 4: Executing the Deployment

Navigate to the environment you want to deploy:

```bash
# Deploy Dev
cd live/dev/services/webserver-cluster/
terraform init    # Links the module source path
terraform plan    # Preview what will be created
terraform apply   # Build the infrastructure

# Deploy Production
cd live/production/services/webserver-cluster/
terraform init
terraform plan
terraform apply
```

> **`terraform init`** reads the `source` path, navigates four folders back, finds your module blueprint, and links it locally.  
> **`terraform apply`** reads your inputs, checks the blueprint, and builds exactly what you specified.

---

## 👨‍🏫 The Summary: Why did we do this?

If tomorrow Kenya Railways says, "We need a new cluster for the Kisumu terminal," you don't write 200 lines of code. You simply:
1. Make a `live/kisumu` folder.
2. Copy your 10-line `module` call.
3. Change the `cluster_name` to `"kisumu"`.

**You have achieved Abstraction.** You've separated the **"How it works"** (the Module) from the **"Where it runs"** (the Live environment).

---

## ⚠️ Challenges Encountered

### 🛑 The Relative Path Problem
The `source` path must navigate **exactly four levels up** (`../../../../`) to escape `live/dev/services/webserver-cluster/` and find the `modules/` directory. One wrong step and `terraform init` fails without a descriptive error.

```hcl
# Correct — four levels up from live/dev/services/webserver-cluster/
source = "../../../../modules/services/webserver-cluster"
```

### 🛑 The Output Re-wiring
Outputs defined **inside** a module do not automatically appear in the caller's terminal. After defining `alb_dns_name` in `modules/.../output.tf`, it must be explicitly re-declared in the `live/` config to surface during `terraform apply`.

```hcl
# Required in live/dev/services/webserver-cluster/main.tf
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
```

### 🛑 The Hardcoded Value Trap
Early drafts had resource names and AMI IDs hardcoded inside `modules/.../main.tf`. Anything hardcoded breaks reusability — dev and prod end up fighting over the same resource names. Every environment-specific value must be a `variable` passed in by the caller.
