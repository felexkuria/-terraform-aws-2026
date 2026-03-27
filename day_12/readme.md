# Zero-Downtime Deployments with Terraform

Welcome to Day 12 of the Terraform challenge! Today, we explore one of the most critical patterns in infrastructure engineering: **Zero-Downtime Deployments**.

In a world where digital services are expected to be available 24/7, how do we update our application code or server configuration without dropping a single request? The answer lies in the orchestration of Load Balancers and Autoscaling Groups.

## The Architecture

Our infrastructure consists of several interconnected components:

1.  **Application Load Balancer (ALB)**: The entry point for all traffic. It distributes requests across a fleet of servers.
2.  **Target Group**: A logical grouping of instances that the ALB sends traffic to. It performs health checks to ensure only "healthy" instances receive traffic.
3.  **Launch Template**: The blueprint for our servers, defining the AMI, instance type, security groups, and user data.
4.  **Autoscaling Group (ASG)**: The manager of our server fleet. It ensures the desired number of instances are running and integrates with the Target Group.

## Achieving Zero-Downtime

The "magic" of zero-downtime in this setup comes from three key configurations:

### 1. `create_before_destroy`
Inside our `aws_launch_template`, we use a `lifecycle` block:
```hcl
lifecycle {
  create_before_destroy = true
}
```
This ensures that when we update the Launch Template, Terraform will create the new version before destroying the old one.

### 2. ASG Instance Refresh
When the Launch Template changes, the ASG needs to roll out the new instances. By using `min_size` and `desired_capacity` greater than 1, and linking to the ALB, the ASG can bring up new instances, wait for them to pass health checks, and then terminate the old ones.

### 3. ELB Health Checks
We configure the ASG to use `ELB` health checks:
```hcl
health_check_type = "ELB"
```
Instead of just checking if the EC2 instance is "on," the ASG now asks the Load Balancer: "Is this instance actually serving web traffic?" This prevents traffic from being sent to an instance that hasn't finished booting up.

## How to Use

1.  **Initialize**: Run `terraform init` to set up the S3 backend and providers.
2.  **Plan**: Run `terraform plan` to see the infrastructure that will be created.
3.  **Apply**: Run `terraform apply` to deploy the stack.
4.  **Verify**: Access the `web_server_lb_dns_name` output in your browser.

## Summary of Files

-   `main.tf`: The core infrastructure logic.
-   `variable.tf`: Input parameters for flexibility.
-   `data.tf`: External data sources (VPC, Subnets, AMI).
-   `output.tf`: Key results (LB DNS name, ASG details).

This is a robust, production-ready pattern for scaling web applications with confidence. Happy coding!
