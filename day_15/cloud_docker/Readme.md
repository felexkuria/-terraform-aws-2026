# 🏗️ Lab: The Automated Builder (Terraform & Docker)

OH, THIS IS EXCITING! We've moved beyond the manual world. You've mastered `docker build` and `docker run` on the command line. But in the professional world, we don't want to keep typing the same commands over and over. We want **Automation**.

Welcome to **Phase 2: The Automated Builder**.

In this lab, we use **Terraform**—the master orchestrator—to take the wheel. Instead of you manually managing Colima and Docker CLI, we'll write a blueprint that tells Terraform: *"Look in that folder, build that image, and run that container!"*

---

## 🔬 The Grand Vision: Orchestration

Think of it this way:
*   **Docker CLI** is like you manually packing a box and carrying it to your new house.
*   **Terraform** is the **Moving Company**. You give them the address and the checklist, and they handle the packing, the transport, and the unpacking for you.

By using the **Terraform Docker Provider**, we eliminate the need for manual `docker` commands. One command—`terraform apply`—handles the entire lifecycle!

---

## 🔬 The Terraform Anatomy: Under the Hood

Before we build, let's look at our **blueprint collection**. We've modularized our infrastructure into three distinct files to keep our "master architect" organized:

### 1. `variables.tf`: The Controls 🎮
Think of this as the "input" to our program. Instead of hardcoding values, we define them here. This makes our infrastructure **reusable** and **flexible**.

```terraform
variable "external_port" {
  description = "The local port to access our website (e.g., 8080)."
  type        = number
  default     = 8080
}
```
*   **What it does:** It creates a "knob" we can turn. If we want to run our website on port `9000` instead of `8080`, we just change the `default` here without touching the main logic.

### 2. `main.tf`: The Heart 💓
This is where the actual resources live. We define the **Docker Provider**, our **Image**, and our **Container**.

```terraform
# Step 1: Automated Image Construction
resource "docker_image" "beautiful_site" {
  name = "${var.image_name}:latest"
  build {
    context = "../lab_docker_website"
  }
}

# Step 2: Automated Deployment
resource "docker_container" "beautiful_site_container" {
  name  = var.container_name
  image = docker_image.beautiful_site.image_id
  ports {
    internal = 80
    external = var.external_port
  }
}
```
*   **`docker_image`**: This is the "Builder." It tells Terraform to go to our `lab_docker_website` folder, read the `Dockerfile`, and compile all our HTML/CSS into a ready-to-use image.
*   **`docker_container`**: This is the "Runner." It takes that image and starts a living process, mapping our local computer's port (like `8080`) to the container's internal port (`80`).

### 3. `outputs.tf`: The Voice 🗣️
Once the orchestration is complete, Terraform will report its success.

```terraform
output "website_url" {
  description = "The URL to access your beautiful website!"
  value       = "http://localhost:${var.external_port}"
}
```
*   **What it does:** It prints the final local URL to your terminal so you don't have to guess where your website is running!

---

## ❓ Why do we still need Colima? 🏎️

You might be wondering: *"If Terraform is doing all the work, why do I still need to run Colima?"*

Think of it like this:
*   **Terraform is the Architect & Driver**: It knows exactly *how* to build the image and *when* to start the container.
*   **Colima is the Engine & The Road**: It provides the actual Linux environment and the **Docker Daemon**—the invisible "engine" that holds the containers in place.

Terraform is just a **Client**. It sends commands over a "phone line" (the Docker Socket) to the engine. If the engine (Colima) isn't running, there's no one on the other end to pick up the phone and do the heavy lifting!

---

## 🚀 The Mission: Automated Deployment

Ready to conduct the orchestra? Follow these steps:

### Step 1: Initialize the Architect
Open your terminal in the `cloud_docker/` folder and run:
```bash
terraform init
```
This tells Terraform to download the **Docker Provider**—the specialized tool it needs to talk to your local Docker daemon.

### Step 2: Conduct the Symphony
Now, tell Terraform to bring your blueprint to life:
```bash
terraform apply
```
Type `yes` when prompted. **Watch the console!** You'll see Terraform building the image and starting the container automatically. No more manual `docker build` or `docker run`!

### Step 3: High-Five the Result
Check the **Outputs** in your terminal. You'll see a `website_url`. Visit it in your browser:
`http://localhost:8080`

**VOILA!** Your beautiful, glassmorphic website is live, automated perfectly by Terraform.

---

## 🧗‍♂️ The Journey: Challenges & Victories

In the real world, things rarely go perfectly on the first try. During this lab, we faced **real-world engineering challenges** and overcame them together:

1.  **The Socket Connection Mystery**: 
    *   **Challenge**: Terraform couldn't find the Docker daemon (`unix:///var/run/docker.sock`).
    *   **Solution**: We discovered that Colima users have a specialized "phone line" at `~/.colima/default/docker.sock`. We mapped this in our `variables.tf`, and suddenly, the Architect could talk to the Builder!

2.  **The Container Name Conflict**:
    *   **Challenge**: Docker shouted: *"That name is already taken!"* because we had a manual container running from our earlier practice.
    *   **Solution**: We used `docker rm -f my-cs50-site` to clear the site, allowing Terraform to take full ownership of the infrastructure.

3.  **The Central Vault (S3 Backend)**:
    *   **Success**: We successfully moved our state to the cloud. Now, our progress is encrypted, locked, and safe in an AWS S3 bucket.

---

## 🖼️ Success Gallery: The Final Symphony

Behold the result of our hard work. One command—`terraform apply`—and the entire infrastructure comes to life!

![Terraform Success Screenshot](file:///Users/felexirungu/Downloads/ProjectLevi/Terraform/terraform-aws-2026/day_15/cloud_docker/assets/terraform_success.png)

---

## 🎓 The Graduation
You have successfully:
1.  **Automated** your local development environment.
2.  **Hardened** your infrastructure with a Remote State Backend.
3.  **Triumphantly solved** complex configuration challenges.

**This is the modern way to build. This is CS50.**

---

## 📚 Further Reading & Resources

Want to dive even deeper into the world of Docker and Terraform? Check out these world-class resources:

*   **[Spacelift: How to Use Terraform with Docker](https://spacelift.io/blog/terraform-docker)** — A comprehensive guide on orchestration best practices.
*   **[Terraform Docker Provider Documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)** — The official blueprint manual for your master orchestrator.
