# Zero-Downtime Deployments with Terraform

Welcome to Day 12 of the Terraform challenge! Today, we explore one of the most critical patterns in infrastructure engineering: **Zero-Downtime Deployments**.

In a world where digital services are expected to be available 24/7, how do we update our application code or server configuration without dropping a single request? The answer lies in the orchestration of Load Balancers and Autoscaling Groups.

## The Architecture

Our infrastructure consists of several interconnected components:

1.  **Application Load Balancer (ALB)**: The entry point for all traffic. It distributes requests across a fleet of servers.
2.  **Target Group**: A logical grouping of instances that the ALB sends traffic to. It performs health checks to ensure only "healthy" instances receive traffic.
3.  **Launch Template**: The blueprint for our servers, defining the AMI, instance type, security groups, and user data.
4.  **Autoscaling Group (ASG)**: The manager of our server fleet. It ensures the desired number of instances are running and integrates with the Target Group.

## Challenges & Solutions

During the development of this infrastructure, we encountered several common Terraform and AWS pitfalls. Here is how we solved them:

1.  **Syntax Error: Unexpected attribute "path"**
    - **Problem**: Attempting to set `path` directly on `aws_lb_listener`.
    - **Solution**: Removed the invalid attribute. Listener rules or fixed responses should handle paths, not the listener itself.

2.  **ALB Naming Violations**
    - **Problem**: Using underscores in Load Balancer and Target Group names (e.g., `web_server_lb`).
    - **Solution**: Renamed resources to use hyphens (`web-server-lb`), as AWS ALB/TG names only allow alphanumeric characters and hyphens.

3.  **Invalid Resource Type: `aws_listener_rule`**
    - **Problem**: Using the wrong resource name.
    - **Solution**: Corrected to `aws_lb_listener_rule`.

4.  **502 Bad Gateway**
    - **Problem**: The ALB returned a 502 error because the backend instances weren't serving traffic. The `user_data` script created an `index.html` but didn't start a web server.
    - **Solution**: Updated `user_data` to start a server using `python3 -m http.server`.

5.  **Duplicate Security Group Error**
    - **Problem**: `terraform apply` failed because a security group with the same name already existed during a resource replacement.
    - **Solution**: Switched from `name` to `name_prefix` to ensure unique names during "create before destroy" operations.

---

## Step-by-Step Guide to Zero-Downtime Deployment
*Based on Terraform: Up & Running (Chapter 5)*

To achieve a truly zero-downtime deployment where new instances are brought up before old ones are removed, follow these steps:

### Step 1: Use `create_before_destroy`
In your **Launch Template** or **Launch Configuration**, always set the `create_before_destroy` lifecycle rule to `true`. This ensures Terraform doesn't leave you without a template during an update.

### Step 2: Force ASG Replacement
Historically, Brikman suggests embedding the Launch Template's name or ID into the **Autoscaling Group's name**:
```hcl
resource "aws_autoscaling_group" "example" {
  name = "web-server-asg-${aws_launch_template.example.latest_version}"
  # ...
}
```
This forces Terraform to create an entirely new ASG when the Launch Template changes, rather than updating the existing one in place.

### Step 3: Configure `min_elb_capacity`
Ensure the ASG waits for instances to be healthy in the Load Balancer before considering the deployment successful. In modern Terraform, this is often handled by `wait_for_elb_capacity`.

### Step 4: Use ELB Health Checks
Set `health_check_type = "ELB"` in the ASG. This tells the ASG to use the Load Balancer's health check (which checks if the app is actually responding) rather than just the EC2 status (which only checks if the VM is on).

### Step 5: Clean Up
Because of `create_before_destroy`, Terraform will:
1.  Create the new ASG.
2.  Wait for the new instances to be healthy.
3.  Terminate the old ASG and its instances.

This "Blue-Green" approach within a single Terraform module ensures your users never see a 404 or a timeout.

## Summary of Files

-   `main.tf`: The core infrastructure logic.
-   `variable.tf`: Input parameters for flexibility.
-   `data.tf`: External data sources (VPC, Subnets, AMI).
-   `output.tf`: Key results (LB DNS name, ASG details).

This is a robust, production-ready pattern for scaling web applications with confidence. Happy coding!
