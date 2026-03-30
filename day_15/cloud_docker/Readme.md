# 🏛️ Lab: The Cloud Orchestra (Terraform & Docker)

OH, THIS IS FANTASTIC! You're asking about orchestrating the modern world with the power of infrastructure as code! Deploying Docker containers with Terraform – this isn't just a technical task, it's a symphony of automation, a beautiful dance between defining your environment and running your applications! Let's dive in with that signature CS50 energy!

---

## 🛠️ Phase 0: Local Orchestration (Testing the Waters)

Before we launch into the cloud, let's use **Terraform** to orchestrate our infrastructure **locally**. This is an excellent way to test our container configuration without spending a dime in a cloud provider!

In the `local_docker/` folder, we've defined a blueprint that uses a **Docker Provider**. Instead of you typing `docker build -t ...`, Terraform will handle the image creation and container management for you:

```terraform
# Define the Docker Provider
terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker" }
  }
}

# Build and Run our "Beautiful Website" Container
resource "docker_image" "beautiful_site" {
  name = "crash_course_app:latest"
  build { context = "../lab_docker_website" }
}

resource "docker_container" "beautiful_site_container" {
  name  = "my-cs50-site"
  image = docker_image.beautiful_site.image_id
  ports { internal = 80, external = 8080 }
}
```

### 🚀 How to Test Locally:
1. `cd day_15/local_docker/`
2. `terraform init`
3. `terraform apply`
4. Visit `localhost:8080`!

**If it works here, it’s ready for the cloud!**

---

## The Grand Vision: Docker & Terraform

First, let's just *marvel* at what we're talking about here.

*   **Docker:** Think of Docker as the ultimate, perfectly organized moving box for your software. You put your application, all its dependencies, libraries, everything it needs, into this box. Then, no matter where you ship this box – whether it's my laptop, your server, or a cloud provider – it *just works* exactly the same way every single time! It's consistent, isolated, and incredibly powerful for packaging applications.

*   **Terraform:** Now, Terraform is like a master architect with an incredible set of blueprints. Instead of manually clicking buttons to spin up servers, databases, networks, or load balancers in the cloud, you *write down* what you want your infrastructure to look like in simple, declarative code. Terraform reads those blueprints, figures out the most efficient way to build it, and then *poof!* Your infrastructure appears, exactly as you specified. It's reproducible, version-controlled, and eliminates human error.

---

## The "Aha!" Moment: How They Connect

Now, here's the crucial insight: **Terraform doesn't *directly* run Docker containers in the same way you might type `docker run` on your laptop.**

Think of it this way:
*   **Terraform is the architect building the house (your server infrastructure).** It creates the walls, the roof, the electricity, the plumbing.
*   **Docker is the moving company bringing in and setting up the furniture (your application containers) *inside* that house.**

So, for Terraform to deploy a Docker container, it first needs to build a "house" (a server, a virtual machine, or a specialized container service) *where Docker can live and run your containers*.

---

## 🔬 Deep Dive: The Terraform Anatomy

Before we build in the cloud, let's look at our **blueprint collection**. We've modularized our infrastructure into four distinct files to keep our "master architect" organized:

### 1. `variables.tf`: The Parameters
Think of this as the "input" to our program. Instead of hardcoding values like the AWS region or instance size, we define them here. This makes our infrastructure **reusable** and **flexible**.

```terraform
variable "aws_region" {
  description = "The AWS region to deploy our beautiful website."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The size of our cloud server (t2.micro is cost-effective!)."
  type        = string
  default     = "t2.micro"
}
```

### 2. `data.tf`: The Brain
Sometimes, we don't want to hardcode an AMI ID that might change tomorrow. Instead, we use a **Data Source** to ask AWS: "What is the latest, most secure version of Ubuntu 22.04?" Terraform "queries" the cloud and brings that information back into our build.

```terraform
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

### 3. `outputs.tf`: The Voice
Once the infrastructure is built, how do we find it? This file tells Terraform exactly what information to report back to us—in this case, the **Public IP address** of our new server.

```terraform
output "public_ip" {
  description = "The public IP address of the Docker host."
  value       = aws_instance.docker_host.public_ip
}
```

### 4. `main.tf`: The Heart
This is where the actual resources live. We define our **Security Group** (the digital firewall) and our **EC2 Instance** (the actual server).

```terraform
resource "aws_security_group" "web_sg" {
  name        = "web-server-security-group"
  description = "Allow HTTP and SSH traffic"

  ingress { # Incoming HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ... (and egress rules to allow all outbound traffic)
}

resource "aws_instance" "docker_host" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web_sg.name]
  # ... (user_data script follows)
}
```

### 🚀 The `user_data` Symphony
Inside `main.tf`, you'll see a massive block of shell commands. This is the **Bootstrapper**. When the server first wakes up in the AWS data center, it automatically:

```bash
# 1. Install Docker
sudo apt-get update -y && sudo apt-get install -y docker.io

# 2. Re-create the "Beautiful Website" files
cat << 'INDEX' > index.html
<!-- HTML structure here -->
INDEX

cat << 'CSS' > style.css
/* CSS aesthetics here */
CSS

# 3. Build and Launch the container
sudo docker build -t crash_course_app .
sudo docker run -d -p 80:80 --name my-cs50-site crash_course_app
```

By the time you get the IP address, the entire stack is already running!

---

## 🚀 The Mission: Deploying Your "Beautiful Website"

In this lab, we're taking our **Local Mastery**—that vibrant, glassmorphic landing page we built—and launching it into the global cloud. We'll use Terraform to provision an AWS EC2 instance, install Docker, and automatically serve our masterpiece to the world.

### Step 1: Pre-requisites

To play this part of the symphony, you'll need:
1.  An **AWS Account**.
2.  **AWS CLI** configured (`aws configure`).
3.  **Terraform** installed.

### Step 2: Initialize the Architect

In your terminal, within the `cloud_docker/` directory, run:

```bash
terraform init
```

This tells Terraform to download the necessary "tools" (the AWS provider) to build in the cloud.

### Step 3: The Blueprint (Plan)

Now, ask the architect to show you the blueprints:

```bash
terraform plan
```

Read carefully! Terraform will tell you it's going to create a **Security Group** (our digital walls) and an **EC2 Instance** (our cloud server).

### Step 4: Building the Infrastructure

If everything looks correct, let's bring it to life!

```bash
terraform apply
```

Type `yes` when prompted. **Wait for the magic to happen.** Terraform is currently communicating with AWS data centers, spinning up a server, installing Docker, and launching your container!

---

## 🌐 Step 5: High-Five the Cloud

Once `terraform apply` finishes, it will output a **`public_ip`**. Copy that IP address and paste it into your browser:

`http://[YOUR_PUBLIC_IP]`

**VOILA!** Your beautiful, glassmorphic website is now live on the global internet, served from a Docker container inside an AWS EC2 instance. 

---

## 🎓 The Graduation

You have successfully:
1.  **Crafted** a modern web application.
2.  **Containerized** it for perfect portability.
3.  **Orchestrated** its global deployment with Infrastructure as Code.

**This is the modern way to build. This is CS50.**
