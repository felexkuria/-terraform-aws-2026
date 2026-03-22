

### Step 1: Creating the "Library" (The Directory Structure)

In app development, we don't just throw files everywhere. We use a logical hierarchy. We need to create two distinct worlds:
1.  **`modules/`**: The "Blueprint Vault." This is where the reusable code lives.
2.  **`live/`**: The "Construction Site." This is where we actually deploy the code.

To create this entire structure in one go on your Unix-like system, run this  command in your terminal:

```bash
# -p ensures it creates the parents and all subfolders at once
cd day_8
mkdir -p modules/services/webserver-cluster
mkdir -p live/dev/services/webserver-cluster
mkdir -p live/production/services/webserver-cluster

# Now, let's "touch" the empty files into existence inside the module
touch modules/services/webserver-cluster/{main.tf,variables.tf,outputs.tf,README.md}

# And create the deployment files
touch live/dev/services/webserver-cluster/main.tf
touch live/production/services/webserver-cluster/main.tf
```

---

### Step 2: The Module "Blueprint" (The Black Box)

Inside `modules/services/webserver-cluster/`, we define our logic.

#### A. `variables.tf` (The Input Terminals)
Think of these as the **knobs and dials** on the outside of a control panel. The user of your module can turn these, but they don't see the wiring inside.

```hcl
variable "cluster_name" {
  description = "The name for the cluster resources (Nairobi, Mombasa, etc.)"
  type        = string
}

variable "instance_type" {
  description = "EC2 size (t3.micro for free tier)"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum engines running"
  type        = number
}

variable "max_size" {
  description = "Maximum engines allowed"
  type        = number
}
```

#### B. `outputs.tf` (The Signal Indicators)
This is the **Digital Voltmeter**. It’s the only information the module "shouts" back to the user.

```hcl
output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The URL where the website is 'Live'"
}
```

#### C. `main.tf` (The Internal Wiring)
Here, you use your resources (ASG, ALB, Launch Config) but **Crucially**: you replace hardcoded values with `var.name`. You are "wiring" the resources to the knobs you created in `variables.tf`.

---

### Step 3: The Deployment (The "Installation")

Now we move to the `live/dev/` folder. This is where we "Call" the module. 

In `live/dev/services/webserver-cluster/main.tf`, we write:

```hcl
module "webserver_cluster" {
  # THE SOURCE: Four steps back to get out of 'live/dev/services/webserver-cluster'
  # and into the 'modules' directory.
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-dev"
  instance_type = "t3.micro"
  min_size      = 2
  max_size      = 4
}

# We must 're-wire' the output if we want to see it in our dev terminal
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
```

---

### Step 4: Energizing the Circuit (The Execution)

Now, navigate to your dev folder:
`cd live/dev/services/webserver-cluster/`

1.  **`terraform init`**: Terraform sees the `source` path. It goes four folders back, finds your blueprint, and "links" it.
2.  **`terraform apply`**: Terraform reads your inputs (2 servers), checks the blueprint (the module), and builds exactly what you asked for.

---

### 👨‍🏫 The Malan Summary: Why did we do this?

If tomorrow Kenya Railways says, "We need a new cluster for the Kisumu terminal," you don't write 200 lines of code. You simply:
1.  Make a `live/kisumu` folder.
2.  Copy your 10-line `module` call.
3.  Change the `cluster_name` to "Kisumu."

**You have achieved Abstraction.** You’ve separated the **"How it works"** (the Module) from the **"Where it runs"** (the Live environment).

