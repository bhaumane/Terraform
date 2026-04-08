# TERRAFORM

Terraform is an open-source Infrastructure as Code (IaC) tool used to define, provision, and manage cloud and on-premises resources (like VMs, networks, and databases) using declarative configuration files. It enables developers to automate infrastructure deployment across multiple providers (AWS, Azure, GCP) using a single, consistent workflow.

---
## Key Uses of Terraform:

- **Infrastructure Provisioning**: Automates the creation and updating of cloud resources (servers, databases, load balancers) via code instead of manual, click-based configuration.
- **Multi-Cloud Deployment**: Allows managing resources across different providers simultaneously, providing a single "connective tissue" for complex, hybrid environments.
- **Infrastructure Lifecycle Management**: Manages the entire lifecycle—from creation to modification and destruction—safely and efficiently.
- **Environment Standardization**: Creates identical, reproducible environments (e.g., development, staging, production) to reduce configuration drift.
- **Version Control**: Because infrastructure is defined as code (HCL), it can be stored in version control systems (like Git) to track changes and audit history.

---

## Configure AWS Access Key and Secret Key for use with Terraform

# 🔐 1. Create AWS Access Keys
- Step 1: Go to IAM
    Open the AWS Management Console
    Navigate to AWS IAM
- Step 2: Create / Select User
    Click Users
    Either:
        Create a new user (recommended for Terraform), OR
        Select an existing user
- Step 3: Assign Permissions
    Attach policies like:
        AdministratorAccess (for testing only)
        Or scoped policies (best practice)
- Step 4: Create Access Keys
    Go to Security credentials
    Click Create access key
    Choose:
        “Command Line Interface (CLI)” or “Application running outside AWS”
    Save:
        Access Key ID
        Secret Access Key ⚠️ (shown only once)

# 💻 2. Install AWS CLI (if not installed)

Terraform commonly uses AWS CLI credentials.
    - Install AWS CLI
    - Verify:
```bash
aws --version
```

# ⚙️ 3. Configure Credentials Using AWS CLI

Run:
```bash
aws configure
```

Enter:
```bash
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: us-east-1   # or your region
Default output format: json
```

**This creates**:
~/.aws/credentials
~/.aws/config

Example:
```bash
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

# 🧱 4. Configure Terraform AWS Provider

In your Terraform file:
```bash
provider "aws" {
  region = "us-east-1"
}
```

Terraform automatically reads credentials from:

AWS CLI config files ✅ (recommended)

---
## terraform init

The terraform init command is the first step in any Terraform workflow. It prepares the current working directory by downloading provider plugins, initializing the backend for state storage, and fetching any referenced modules.

### Core Functions

When you run terraform init, the CLI performs the following critical tasks:
- **Backend Initialization**: Configures where Terraform stores your state file (e.g., locally, or in remote storage like AWS S3 or Terraform Cloud).
- **Provider Installation**: Identifies the cloud providers (AWS, Azure, GCP, etc.) defined in your configuration and downloads the necessary provider plugins from the Terraform Registry.
- **Module Installation**: Downloads any external modules referenced in your code.
- **Lock File Creation**: Generates or updates the .terraform.lock.hcl file to ensure consistent provider versions across different environments.

## When to Run terraform init

You should run (or re-run) this command whenever you:
- Start a new project or clone a repository for the first time.
- Add a new provider or change a provider's version constraint.
- Add or modify a module source or version.
- Change the backend configuration (e.g., moving from local state to Azure Blob Storage).

### Troubleshooting & Safety

**Idempotency**: It is always safe to run terraform init multiple times. It will not delete your existing infrastructure or state; it only brings your local directory up to date with your configuration.

**.terraform Directory**: This command creates a hidden .terraform folder containing the downloaded plugins. This directory should never be committed to version control; only the lock file should be saved to your Git repository.

---

# terraform plan

The terraform plan command is a primary step in the Terraform workflow, acting as a "dry run" to preview changes before they are actually applied to your infrastructure.

## How it Works

When you execute terraform plan, Terraform performs the following operations:
Reads Configuration: It scans all .tf files in your current working directory to understand the "desired state."

**Refreshes State**: It queries your cloud provider (e.g., AWS, Azure) to get the current "actual state" of existing resources.
**Calculates the Diff**: It compares the current state with your desired configuration.
**Generates a Plan**: It outputs a list of proposed actions:
- **+ Create**: New resources to be added.
- **~ Update**: Existing resources to be modified in-place.
- **- Destroy**: Resources to be deleted.
- **-/+ Replace**: Resources that must be deleted and recreated due to certain attribute changes.

## Common Command Usage

**Basic Preview**:
terraform plan
The most common use to see what changes would occur.

**Saving a Plan File**:
terraform plan -out=tfplan
Saves the execution plan to a file named tfplan. This ensures that when you run terraform apply with this file (terraform apply tfplan), exactly these changes (and no others) are performed.

**Specifying Variables**:
terraform plan -var="instance_type=t2.micro"
Passes a variable value directly via the command line.

**Targeting Specific Resources**:
terraform plan -target=aws_instance.web
Focuses the plan only on a specific resource (use with caution as it ignores dependencies).

**Destroy Plan**:
terraform plan -destroy
Previews what would happen if you were to destroy all managed infrastructure.

## Best Practices

**Always Plan Before Applying**: Never run terraform apply without reviewing the plan output first to avoid accidental deletions.

**Review Replacements**: Pay close attention to resources marked with -/+. This indicates a "destroy and then create" action, which usually causes downtime for that resource.

**Use in CI/CD**: In automated pipelines, always use the terraform plan -out option to guarantee that the version of the code reviewed in the plan is the exact version that gets applied.

---

## terraform apply

The terraform apply command is the final step in the standard Terraform workflow, responsible for making the changes defined in your configuration real by creating, updating, or deleting infrastructure resources.

# Core Functionality

When you run terraform apply, the tool performs the following steps:
- **Generates a Plan**: By default, it creates an execution plan (similar to terraform plan) to show you what changes will occur.

- **Requests Approval**: It pauses and waits for you to type yes to confirm the actions, unless you have provided a pre-saved plan or used an override flag.

- **Executes Changes**: It uses provider APIs (e.g., AWS, Azure, Google Cloud) to reach the "desired state" described in your code.

- **Updates State**: Once the operations complete, Terraform updates your State File (typically terraform.tfstate) to reflect the current reality of your infrastructure.

# Common Usage Examples

**Standard Apply**: Automatically creates a plan and asks for confirmation.
```bash
terraform apply
```

**Auto-Approval**: Skips the interactive confirmation prompt. This is commonly used in CI/CD automation pipelines.
```bash
terraform apply -auto-approve
```

**Apply a Saved Plan**: For production environments, it is best practice to first create a plan with terraform plan -out=tfplan and then apply that specific file to ensure no unexpected changes occur between planning and applying.
```bash
terraform apply "tfplan"
```

**Pass Variables**: You can set or override variables directly at the command line.
```bash
terraform apply -var="instance_type=t3.medium"
```

## Best Practices

- **Always Review the Plan**: Before typing yes, check the plan summary (e.g., "Plan: 2 to add, 1 to change, 0 to destroy") to ensure you aren't accidentally deleting critical resources.
- **Use Version Control**: Ensure your Terraform configuration is stored in a Version Control System (VCS) like GitHub or GitLab.
- **Run Init First**: You must run terraform init at least once before you can use the apply command to ensure all necessary providers and modules are downloaded.
- **Handle Interruptions Carefully**: If you press Ctrl+C during an apply, Terraform will try to gracefully stop the current operation, but stopping it abruptly can leave your infrastructure in a partially-applied or "tainted" state.

---

## terraform destroy

The terraform destroy command is used to deprovision all infrastructure managed by a specific Terraform configuration. It reads your state file to identify which real-world resources currently exist and then systematically deletes them.

# How to Use It
To delete all resources managed by your current working directory, run:
```bash
terraform destroy
```

**Preview**: Terraform will first show you an execution plan (a list of everything it intends to delete).
**Confirmation**: It will prompt you to type yes to confirm the destruction.

## Common Options & Flags

**Targeted Destruction**: If you only want to destroy a specific resource without touching the rest of your stack, use the -target flag.
```bash
terraform destroy -target=aws_instance.example
```

**Skip Confirmation**: In automated environments like CI/CD, use -auto-approve to bypass the manual "yes" prompt.

```bash
terraform destroy -auto-approve
```

**Preview Only**: To see what would be destroyed without actually doing it, use the command.
```bash
terraform plan -destroy
```

**Refresh State**: By default, Terraform queries your cloud provider to ensure its state is up-to-date before destroying. You can skip this with -refresh=false to speed up the process.

## Important Considerations

**Dependency Management**: Terraform is "intelligent"—it destroys resources in the reverse order of how they were created. For example, it will delete an EC2 instance before deleting the VPC it resides in.

**Prevention**: You can protect critical resources (like production databases) from accidental destruction by adding prevent_destroy = true inside a lifecycle block in your code.

**State Management**: After a successful destroy, your Terraform state file will be updated to show that those resources no longer exist.

**Alternative Method**: Since Terraform v0.15.2, terraform destroy is technically an alias for terraform apply -destroy.

## Best Practices

**Always Review the Plan**: Even if you are confident, review the output list to ensure you aren't deleting shared infrastructure by mistake.

**Use Workspaces**: Isolate environments (e.g., dev, staging, prod) using Terraform Workspaces to ensure a destroy in dev doesn't impact production.

**Back Up State**: Before running a major destruction, ensure your state file is backed up, especially if using a local backend.

---

# Terraform state file

## What is a Terraform state file?

Terraform manages infrastructure as code. When you write Terraform code to create, update, or delete resources (like servers, databases, networks), Terraform needs a way to remember what resources exist and their current state.

This is what the state file does. It is a JSON file (usually called terraform.tfstate) that acts like Terraform’s memory.

Think of it like a map of your infrastructure. Without it, Terraform wouldn’t know what’s already created or what needs to change.

## Why is the state file important?

The state file is critical because it:

- **Tracks resources**: Terraform knows which cloud resources exist, their IDs, and their current settings.
- **Plans accurately**: When you run terraform plan, Terraform compares your current code with the state file to figure out what changes are needed.
- **Prevents duplication**: Without the state file, Terraform might try to create resources that already exist.
- **Improves performance**: Terraform doesn’t need to query the cloud for every resource every time—it can use the local state file.

## What does the state file contain?

The state file contains:

**Resource type** (e.g., aws_instance, google_compute_instance)
**Resource ID** (unique ID in the cloud provider)
**Resource attributes** (IP address, size, tags, etc.)
**Metadata** (Terraform version, workspace, etc.)
It’s in **JSON format**, so technically you can open it and see everything Terraform knows about your infrastructure—but it’s usually best to let Terraform manage it.

## How Terraform uses the state file

Here’s the workflow:

- You write Terraform code (.tf files).
- You run terraform apply.
- Terraform checks the state file to see what already exists.
- Terraform calls the cloud provider API to create, update, or delete resources as needed.
- Terraform updates the state file to reflect the new reality.
- Think of the state file as **Terraform’s memory of the world**. If it forgets something, Terraform might accidentally create duplicate resources or destroy the wrong ones.

## Key commands related to state

Terraform provides commands to manage and inspect state:

- **terraform show** → See what the state file contains
- **terraform state list** → List all resources Terraform tracks
- **terraform state rm** → Remove a resource from the state file without deleting it in the cloud
- **terraform state mv** → Move or rename resources in the state file

---

## 🔹 1. List Variable in Terraform

A list is an ordered collection of values.

**Key Characteristics**:
- Indexed (0-based index)
- Maintains order
- Values are usually of the same type

**Example**:
```bash
variable "instance_types" {
  type = list(string)
  default = ["t2.micro", "t2.small", "t2.medium"]
}
```
**Usage**:
```bash
resource "aws_instance" "example" {
  instance_type = var.instance_types[0]
}
```

👉 Here:

- var.instance_types[0] → "t2.micro"
- Access is done using index

## 🔹 2. Map Variable in Terraform

A map is a key-value pair collection.

**Key Characteristics**:
- Unordered (conceptually)
- Accessed via keys (not index)
- Each value is associated with a unique key

**Example**:
```bash
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    test = "t2.small"
    prod = "t2.medium"
  }
}
```

**Usage**:
```bash
resource "aws_instance" "example" {
  instance_type = var.instance_types["dev"]
}
```

👉 Here:
- var.instance_types["dev"] → "t2.micro"
- Access is done using key

## 🧠 When to Use What?

**✅ Use List when**:
- Order matters
- You just need a sequence of values
- Example: subnet IDs, availability zones

**✅ Use Map when**:
- You need meaningful labels
- You want environment-based config
- Example: dev/test/prod settings

---

## 🔷 1. Tuple in Terraform

A tuple is an ordered collection of elements, where:

- Each element can have a different data type
- Access is done using index (position)

**✅ Key Characteristics**:
- Ordered (index-based)
- Fixed number of elements
- Can mix types (string, number, bool, etc.)
- Structure is positional (not named)

📌 **Example of Tuple Variable**
```bash
variable "server_config" {
  type = tuple([string, number, bool])

  default = ["t2.micro", 2, true]
}
```
🔍 **Accessing Values**:
```bash
# index-based access
var.server_config[0]  # "t2.micro"
var.server_config[1]  # 2
var.server_config[2]  # true
```

## 🔷 2. Object in Terraform

An object is a collection of named attributes, where:

- Each attribute has a name (key) and type
- Access is done using attribute names

**✅ Key Characteristics**:
- Key-value structure
- Strongly typed schema
- Self-descriptive
- Easier to read and maintain

**📌 Example of Object Variable**
```bash
variable "server_config" {
  type = object({
    instance_type    = string
    instance_count   = number
    enable_monitoring = bool
  })

  default = {
    instance_type    = "t2.micro"
    instance_count   = 2
    enable_monitoring = true
  }
}
```

**🔍 Accessing Values**:
```bash
var.server_config.instance_type
var.server_config.instance_count
var.server_config.enable_monitoring
```

### 🧠 When to Use What?

**✅ Use Tuple when**:
- Data is strictly positional
- Structure is fixed and simple
- Rare in real-world Terraform

**✅ Use Object when**:
- You want clean, readable configs
- Working with real infrastructure inputs
- Writing reusable modules

---

## 🔷 1. count in Terraform

count is used to create N identical resources based on a number.

**✅ Basic Example**
```bash
resource "aws_instance" "example" {
  count = 3

  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
```

**🔍 How it works**:
- count = 3 → creates 3 instances
- count.index → gives index (0, 1, 2)

**🧠 Output**:

Resources created:
```bash
aws_instance.example[0]
aws_instance.example[1]
aws_instance.example[2]
```

**⚠️ Limitation of count**

If you modify the list/order:
```bash
count = length(var.instances)
```
Terraform tracks resources by index, so:

- Removing an element in the middle → shifts indexes
- Causes unwanted destroy + recreate

## 🔷 2. for_each in Terraform

for_each is used to create resources based on a map or set of strings.

** ✅ Example with Map**
```bash
variable "instances" {
  default = {
    dev  = "t2.micro"
    test = "t2.small"
    prod = "t2.medium"
  }
}

resource "aws_instance" "example" {
  for_each = var.instances

  ami           = "ami-123456"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
```

**🔍 How it works**:
- Creates resources per key
- each.key → dev, test, prod
- each.value → instance type

**🧠 Output**:

Resources created:
```bash
aws_instance.example["dev"]
aws_instance.example["test"]
aws_instance.example["prod"]
```

**✅ Example with Set**
```bash
resource "aws_s3_bucket" "example" {
  for_each = toset(["bucket1", "bucket2"])

  bucket = each.key
}
```


** 🚨 Real-World Problem with count**

Example:
```bash
variable "names" {
  default = ["a", "b", "c"]
}
```

Using count:
```bash
count = length(var.names)
```

If you change:

["a", "c"]

**👉 Terraform will**:

- Destroy index 1 ("b")
- Recreate index 1 ("c")

*⚠️ Even though "c" already existed → unnecessary change!*

**✅ Same Scenario with for_each**
```bash
for_each = toset(var.names)
```

**👉 Terraform will**:

- Only remove "b"
- Keep "c" untouched

- ✔️ No unnecessary recreation

### 🧠 When to Use What?

**✅ Use count when**:
- Resources are identical
- No unique identifiers needed
- Simple conditions:
- count = var.create_instance ? 1 : 0

**✅ Use for_each when**:
- Resources have unique values
- You need stable infrastructure
- Using maps or named configs

###🔥 Advanced Example (Best Practice)
```bash
variable "servers" {
  default = {
    app1 = {
      instance_type = "t2.micro"
    }
    app2 = {
      instance_type = "t2.small"
    }
  }
}

resource "aws_instance" "example" {
  for_each = var.servers

  ami           = "ami-123456"
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}
```

### 🚀 Pro Tips (Very Important)
- ❌ Don’t mix count and for_each on same resource
- ❌ Avoid count for dynamic lists
- ✅ Prefer for_each for production Terraform
- ✅ Use maps for better control

---

# 🏗️ 1. Production Terraform Repo Structure
```bash

terraform-infra/
│
├── README.md
├── .gitignore
├── providers.tf
├── outputs.tf
├── terraform.tfvars
├── backend.tf
├── versions.tf
│
├── modules/                     # Reusable building blocks
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ec2/
│   ├── rds/
│   ├── s3/
│   └── iam/
│
├── environments/               # Environment-specific configs
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   │
│   ├── staging/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       ├── terraform.tfvars
│       └── outputs.tf
│
└── global/                     # Shared/global resources
    ├── iam/
    ├── route53/
    └── cloudfront/

```
# 📄 2. Core Terraform Files (Explained)

### 🔹 main.tf
**👉 Purpose**:
The main configuration file
**Contains**:
- Resources
- Data sources
- Module calls

**Example**:
```bash
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```

### 🔹 variables.tf

**👉 Purpose**:
Defines input variables

**Example**:
```bash
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

### 🔹 outputs.tf
**👉 Purpose**:
Defines output values after execution

**Example**:
```bash
output "instance_id" {
  value = aws_instance.example.id
}
```

### 🔹 providers.tf

**👉 Purpose**:
Defines provider configuration (e.g., AWS)

**Example**:
```bash
provider "aws" {
  region = "us-east-1"
}
```

### 🔹 versions.tf

**👉 Purpose**:
Specifies Terraform and provider versions

**Example**:
```bash
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 🔹 backend.tf

**👉 Purpose**:
Configures remote state storage

**Example**:
```bash
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 🔹 terraform.tfvars

**👉 Purpose**:
Provides values for variables

**Example**:
```bash
instance_type = "t2.small"
```

### 🔹 *.auto.tfvars

**👉 Purpose**:
Auto-loaded variable files

**Example**:
```bash
dev.auto.tfvars
prod.auto.tfvars
```

👉 Terraform loads them automatically without -var-file

### 🧩 3. Modules Structure

Modules help you reuse infrastructure code.

📁 Example Module (modules/ec2/)
```bash
ec2/
├── main.tf
├── variables.tf
└── outputs.tf
Usage:
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t2.micro"
}
```

### 🌍 4. Environment-Based Structure

Used in real projects:
```bash
environments/
├── dev/
├── staging/
└── prod/
```
Each environment may have:

- Separate state
- Separate variables

## 🔄 5. Important Hidden/Generated Files

### 🔹 .terraform/ (Directory)
**👉 Contains**:
- Downloaded providers
- modules

### 🔹 terraform.tfstate
**👉 Purpose**:
Stores current infrastructure state

***⚠️ Never edit manually***

### 🔹 terraform.tfstate.backup
Backup of state file

### 🔹 .terraform.lock.hcl
**👉 Purpose**:
Locks provider versions

## ⚖️ 6. File Naming Rules
Terraform loads all:
*.tf files
*.tfvars files

**👉 Order does not matter**
**👉 Terraform treats them as one combined configuration**

---

# 🧩 2. Modules Layer (Reusable Code)

Each module is self-contained and reusable.

📁 Example: modules/ec2/
```bash
ec2/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

**✅ Example: main.tf inside module**
```bash
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}
```

**✅ Example: variables.tf**
```bash
variable "ami" {}
variable "instance_type" {}
variable "name" {}
```

### 🌍 3. Environment Layer (dev/staging/prod)

Each environment:

- Uses modules
- Has its own state
- Has different configs

**📁 Example: environments/dev/main.tf**
```bash
module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.0.0.0/16"
}

module "ec2" {
  source = "../../modules/ec2"

  ami           = "ami-123456"
  instance_type = "t2.micro"
  name          = "dev-server"
}
```

**📁 Example: terraform.tfvars**
```bash
instance_type = "t2.micro"
```

**📁 Example: backend.tf**
```bash
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
```

### 🔐 4. Remote State Management (Production Standard)
- S3 → stores state
- DynamoDB → state locking

**👉 Prevents**:

- State corruption
- Concurrent execution issues

### 🌐 5. Global Layer

Used for:

- IAM roles
- DNS (Route53)
- CDN (CloudFront)

👉 Shared across all environments

### ⚙️ 6. Root-Level Files

**🔹 providers.tf**
```bash
provider "aws" {
  region = var.region
}
```

**🔹 versions.tf**
```bash
terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 🚫 7. .gitignore (VERY IMPORTANT)
```bash
.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars
```

**👉 Never commit**:

- State files
- Secrets

## 🔄 8. CI/CD Integration (Real Production)

**Typical pipeline**:

GitHub Actions / GitLab CI / Jenkins

Steps:
```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

---