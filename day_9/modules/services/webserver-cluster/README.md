# Day 9 — Advanced Terraform Modules: Versioning & Gotchas

In professional infrastructure, we don't just "write code"—we manage a **lifecycle**. Versioning is the bridge between experimental development and stable production, ensuring that a change in one environment doesn't accidentally break another.

---

## 🎯 The Versioning Mindset
Yesterday, we separated the **blueprint** from the **build site**. Today, we lock that blueprint in a **Vault (Git)**. By using versioning, you treat your infrastructure exactly like software: you release updates, test them in Dev, and only promote them to Production when they are proven stable.
```
day_9/
├── modules/ (The Blueprint)           ──> Push to GitHub (v0.0.1, v0.0.2)
└── live/ (The Build Site)
    ├── dev/                           ──> Uses v0.0.2 (Testing new features)
    └── production/                    ──> Uses v0.0.1 (Stay on Stable)
```

---

## 🛑 Step 1: Master the Module Gotchas

Before versioning, you must avoid these three common mistakes that catch engineers off guard:

- **Gotcha 1: The File Path Trap**: Relative paths like `./script.sh` resolve to the terminal's location, not the module's.
  - **The Fix**: Use `path.module` (e.g., `"${path.module}/user-data.sh"`).
- **Gotcha 2: Inline Blocks vs Separate Resources**: Mixing `ingress` blocks and standalone `aws_security_group_rule` resources causes conflicts.
  - **The Rule**: Use separate resources in modules to allow callers to add their own custom rules.
- **Gotcha 3: Output Dependencies**: Depending on a module output makes Terraform wait for the *entire* module.
  - **The Fix**: Expose specific, granular outputs to keep your dependency tree fast.

---

## 📦 Step 2: Put Your Module in the "Vault" (Versioning)
Professional teams use Git tags to snapshot their modules. Here's how to do it based on your setup:

### 2a. Versioning with an EXISTING Repository

We are **reusing the modular architecture** from Day 8 (the `modules/` and `live/` folders). If you are already tracking your project from the root (as we are), Git tags the **entire repository** at once. You don't need to "navigate" inside the module folder for Git; you just need to ensure your code is committed.

**The CLI Workflow for Stable & Dev Tags:**
```bash
# 1. Stay in the root of your project
# 2. Add and commit all modular changes
git add .
git commit -m "Day 9: Versioning the Day 8 webserver-cluster module"

# 3. Create a STABLE tag for Production
git tag -a "v0.0.1" -m "Stable Version"
git push origin v0.0.1

# 4. Create a DEV tag for experimentation
# (Engineers often use '-dev' or '-test' suffixes)
git tag -a "v0.0.1-dev" -m "Development testing version"
git push origin v0.0.1-dev
```
*Note: Although Git tags the whole repo, Terraform "navigates" to the specific module folder using the `//` syntax in the source URL (see Step 3).*

### 2b. Versioning with a NEW Repository
Use this if you are creating a dedicated repository for this module from scratch:

```bash
# 1. Start fresh in the module folder
cd modules/services/webserver-cluster/
git init

# 2. Add and commit your code
git add .
git commit -m "Initial commit of webserver-cluster module"

# 3. Link to a NEW GitHub repo and push
git remote add origin https://github.com/your-username/terraform-aws-webserver-cluster
git push origin main

# 4. Tag and push the tag
git tag -a "v0.0.1" -m "First stable release"
git push origin --tags
```

### B. Creating a GitHub Release (The Pro Look)
To make your module look professional for your team:
1. Go to your repository on **GitHub**.
2. Click on **Releases** (on the right sidebar).
3. Click **Draft a new release**.
4. Click **Choose a tag** and select `v0.0.1`.
5. Enter a title (e.g., "First Stable Release") and describe the changes.
6. Click **Publish release**.

---

## 🏗️ Step 3: Deployment & The Private Repo Problem

### The Sub-Folder "Gotcha" (Double Slash)
Since your module is inside `day_9/modules/...`, you MUST tell Terraform exactly where to look inside the repo using the **Double Slash (`//`)**:
```hcl
module "webserver_cluster" {
  # Format: github.com/<user>/<repo>//<folder_path>?ref=<tag>
  source = "github.com/felexkuria/-terraform-aws-2026//day_9/modules/services/webserver-cluster?ref=v0.0.1"
  
  # ... inputs
}
```

---

## 👨‍🏫 Why Versioning Matters

Without versioning, if you change `modules/main.tf` to test something in **Dev**, you accidentally change **Production** at the same time.

**With Versioning:**
1. You push changes and tag them as `v0.0.2`.
2. You update **Dev** to `v0.0.2` and verify it works.
3. **Production** remains untouched on `v0.0.1` until you are 100% ready to switch.

---

## ⚠️ Challenges & Fixes

### 🛑 `terraform init` Caching
If you update a tag in Git, Terraform might still use the old version cached in `.terraform/modules`.
- **Fix:** Run `terraform init -upgrade` to force a fresh download of the module.

### 🛑 Git Source URL Format
The URL must be precise. For GitHub, it usually looks like:
`github.com/<user>/<repo>?ref=<tag>`

### 🛑 The "Side Effect" Module
Avoid modules that create "global" resources (like an IAM Role with a hardcoded name). If you call that module twice, the names will collide. Always make global resource names dynamic using `var.cluster_name`.

---

## 🔄 Summary
You have now transitioned from "Terraform Beginner" to "Infrastructure Architect." You are no longer just writing code; you are managing a **lifecycle**.

#30DayTerraformChallenge #IaC #DevOps #Versioning #Aesthetics
