# 🔐 Day 13 Lab: From Zero to Secure Secrets with AWS

This lab guides you from a brand-new AWS account to a secure database deployment using **AWS Secrets Manager**. We will move from absolute zero to managing sensitive credentials without ever hardcoding them in our files.

---

## 📋 Prerequisites

- **AWS Account**: Sign up at [aws.amazon.com](https://aws.amazon.com).
- **Terraform installed**: Follow instructions for your OS (e.g., `brew install terraform`).

---

## 🛠️ Step 1: Bootstrap IAM (The Human Entry Point)

You cannot safely use your "root" account for daily tasks. We must create a **Programmatic User**.

1. In the **AWS Console**, search for **IAM**.
2. Click **Users** -> **Create user**. Name it `terraform-user`.
3. Select **Attach policies directly** and check **AdministratorAccess**.
4. Once created, click on the user -> **Security credentials** tab.
5. Create an **Access key** for **Command Line Interface (CLI)**.

> [!IMPORTANT]
> **Crucial**: Copy your **Access Key ID** and **Secret Access Key**. They disappear forever after this screen. Save them in a password manager.

---

## 💻 Step 2: Set Environment Variables

In your terminal, "inject" these credentials into your session. This allows Terraform to use them without you ever writing them in a plain-text file:

```bash
export AWS_ACCESS_KEY_ID="your_access_key_id_here"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key_here"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## 🔒 Step 3: Store the Secret in AWS Secrets Manager

We will store the "Master Password" for our future database in the AWS vault.

1. In the **AWS Console**, search for **Secrets Manager**.
2. Click **Store a new secret**.
3. Choose **Other type of secret**.
4. **Key/Value pairs**:
   - **Key**: `password`
   - **Value**: `a-very-secure-password-123`
5. Name the secret `db-creds` and click **Store**.

---

## 🏗️ Step 4: The Terraform Configuration

Create a file named `main.tf`. We will use a **Data Source** to fetch the secret we just made.

```hcl
provider "aws" {
  region = "us-east-1"
}

# 1. Fetch the secret version from Secrets Manager
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
}

# 2. Parse the JSON string retrieved from AWS
locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

# 3. Use the secret to deploy a Database
resource "aws_db_instance" "example" {
  identifier_prefix   = "lab-secrets"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "example_db"

  # We use the local variable which holds our fetched secret
  username = "admin"
  password = local.db_creds.password
}
```

---

## 🚀 Step 5: Execution and Verification

1. Run `terraform init` to download the AWS provider.
2. Run `terraform apply`. Type `yes` when prompted.

> [!NOTE]
> **Verification**: Look at the console output. Notice that Terraform handles the password carefully and marks it as `(sensitive)` during the plan.

> [!WARNING]
> **Security Warning**: Open the generated `terraform.tfstate` file in your text editor. Search for your password. **It is there in plain text.** This is why you must protect your state file in a remote, encrypted backend like S3.

---

## 🧹 Step 6: Cleanup

To avoid unnecessary charges, run:

```bash
terraform destroy
```

---

## 💡 The Great Paradox: Why Secrets Manager?

Suppose for a moment, you've done everything correctly. You've used Secrets Manager. You've avoided hardcoding. But then, you open your `terraform.tfstate` file and... **Wait!** There it is. Your password. In plain text. 

You might ask, "What was the point? If the secret is still in the state, have we actually gained anything?" 

**The answer is yes. This is abstraction.**

### 🍎 The Analogy: The Safe vs. The Post-it Note
Imagine your password is on a Post-it note.
*   **Hardcoding** is sticking that Post-it note on your front door (GitHub). Anyone walking by can see it. 
*   **Secrets Manager** is putting that Post-it note inside a high-security vault (AWS). 

Now, Terraform is the **unseen courier**. To do its job, Terraform must go to the vault, take the note, and carry it to the Database. At any given moment, the courier *knows* the secret. The `tfstate` is simply the courier's private notebook where they've written down what they did.

### 🔑 The Key Insights
1.  **Separation of Concerns**: Your source code is for everyone. Your state file is for the courier. By using Secrets Manager, you've ensured that your **Source Code** remains "blind" to the secret.
2.  **Layered Security**: We don't protect the state file by making it "clever." We protect it with **Encryption at Rest** (S3) and **Access Control** (IAM). 
3.  **Rotation**: Because the courier fetches the note *every time they run*, we can change the note in the vault (rotation) without ever touching the code!

**This is Terraform.** 🛡️🦾

---

## ⚠️ Challenges & Solutions

### 1. The "Resource Not Found" Error (Region Mismatch)
- **The Problem**: Terraform failed with `Error: reading Secrets Manager Secret Version (db-creds|AWSCURRENT): couldn't find resource`.
- **The Root Cause**: The secret was created in **`us-east-1`**, but the Terraform provider was initially configured for **`us-east-2`**. 
- **The Solution**: Update the `region` in your `main.tf` provider block to match the region where you stored your secret in the AWS Console.

### 2. The "Access Denied" Error (IAM Permissions)
- **The Problem**: `Error: creating RDS DB Instance: operation error RDS: CreateDBInstance... User is not authorized`.
- **The Root Cause**: The IAM user being used (e.g., `dev_felex`) did not have the `rds:CreateDBInstance` policy attached.
- **The Solution**: Ensure you are using the credentials of the `terraform-user` created in Step 1, which has `AdministratorAccess`, or manually attach the `AmazonRDSFullAccess` policy to your current user.

### 3. The "Dangling State Lock"
- **The Problem**: `Error: Error acquiring the state lock... PreconditionFailed`.
- **The Root Cause**: A previous Terraform process was interrupted (or crashed) and didn't release the lock in S3.
- **The Solution**: Use `terraform force-unlock <LOCK_ID>` using the ID provided in the error message.

### 4. JSON Attribute Mismatch
- **The Problem**: `Error: Unsupported attribute... This object does not have an attribute named "username"`.
- **The Root Cause**: Trying to access `local.db_creds.username` when the JSON in Secrets Manager only contained a `password` key.
- **The Solution**: Ensure the `jsondecode` keys match the exact Key/Value pairs stored in the AWS Secrets Manager console.

### 5. Reference to Undeclared Local
- **The Problem**: `Error: Reference to undeclared local value "db_credentials"`.
- **The Root Cause**: Renaming a `local` block (e.g., from `db_creds` to `db_credentials`) but forgetting to update the references in the `aws_db_instance` resource.
- **The Solution**: Perform a "Find and Replace" to ensure all resource attributes match the new local naming convention.

### 6. The Mysterious Password Prompt
- **The Problem**: Terraform prompts `var.db_password: Enter a value` even though you are using Secrets Manager.
- **The Root Cause**: Declaring a `variable "db_password" {}` block without a `default` value. Terraform assumes it *must* have a value from the user, even if it's not being used in any resource.
- **The Solution**: Remove unused variable declarations to keep the deployment non-interactive.

---

*Happy Securing!* 🛡️
