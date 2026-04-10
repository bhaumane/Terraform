# Terraform Important Concepts

### What is Terraform state?

Terraform state is a snapshot of infrastructure managed by Terraform. It records resource attributes, metadata, and dependencies so Terraform can track real-world resources and detect changes. This state file (typically terraform.tfstate) allows Terraform to plan updates accurately and avoid recreating resources unnecessarily.

State can be stored locally or remotely (e.g., in S3 or Terraform Cloud) for collaboration and security. Remote backends also support state locking to prevent concurrent modifications.

The Terraform state file is named terraform.tfstate by default and is held in the same directory where Terraform is run. It is created after running terraform apply.

This file’s actual content is a JSON-formatted mapping of the resources defined in the configuration to those in your infrastructure. When Terraform is run, it can use this mapping to compare the infrastructure to the code and make any necessary adjustments.

### Storing state files

State files are stored in the local directory where Terraform is run by default. If you are using Terraform for testing or a personal project, this is fine (as long as your state file is secure and backed up!). However, when working on Terraform projects in a team, this becomes a problem because multiple people will need to access the state file.

You should store your state files remotely, not on your local machine! The location of the remote state file can then be referenced using a backendblock in the terraform block (which is usually in the main.tf file).

It is not a good idea to store the state file in source control. This is because Terraform state files contain all data in plain text, which may contain secrets.

```bash
terraform {
  backend "s3" {
    bucket = "my-terraform-start-bucket"
    key = "global/s3/terraform.tfstate"
    region = "us-west-2"
    use_lockfile = true
    
  }
}
```

**Isolating through multiple state files**

A better way is to use multiple state files for parts of your infrastructure. Logically separating resources from each other and giving them their own state file in the backend means that changes to one resource will not affect the other. Different state files for different environments are also a good idea.

---

### What is a Terraform workspace?

Terraform workspaces let you manage multiple deployments of the same configuration. When you create cloud resources using Terraform’s configuration language, they are created in the default workspace. Workspaces are a handy tool for testing configurations, offering flexibility in resource allocation, regional deployments, multi-account deployments, and more.

Terraform stores information about all managed resources in a state file. It is important to store this file in a secure location. Every Terraform run is associated with a state file for validation and reference. Any modifications to the Terraform configuration, whether planned or applied, are validated against the state file first, and the result is updated back to it.

If you are not consciously using a workspace, all of this already happens in the default workspace. Workspaces help you isolate independent deployments of the same Terraform configuration while using the same state file.

### How to use the Terraform workspace command
The terraform workspace command manages multiple state environments within a single configuration, allowing teams to maintain separate infrastructure states for stages like development, staging, and production.

To begin, let’s look at the options available to us in the help:

![alt text](image.png)

---

## Terraform Taint

### What is Terraform taint?

Terraform taint marks a resource as degraded or damaged, indicating that this resource will be destroyed and recreated during the next apply operation. This can be particularly useful when a resource is in an undesirable or unexpected state, but its configuration hasn’t changed. Terraform basically forces the recreation of resources even if the configuration matches the current state. 

This command is deprecated and you should use the “-replace” option of terraform apply to achieve the same behavior.

Terraform maintains a state file that contains information regarding the real-world resources managed by Terraform IaC. This is a crucial piece of information, as all the task executions of Terraform depend on this file for coordination.

As established earlier, when a resource becomes misconfigured or corrupt, it is desirable to replace it with a new instance. The taint command updates the corresponding resource state as a “tainted” resource so that in the next apply cycle, Terraform replaces that resource.

**Note: The taint command is deprecated since Terraform version 0.15.2. If you are using a version that is lower than this, continue using taint and untaint. Otherwise, it is recommended to use the replace command discussed below.**

### What is Terraform untaint?

Terraform untaint is the opposite operation of Terraform taint. If a resource has been marked as taint which signifies it will be recreated in the next apply, the untaint command will remove this mark, ensuring the resource stays unchanged in the following operations.

This is useful when resources have been marked as taint by mistake, or if there are changes in operational decisions. As the taint workflow is deprecated, if you are not using it at all, the untaint command will also be obsolete.

### Replace (-replace) - Terraform taint alternative

Terraform replace is a flag used with the Terraform apply command and is the suggested way to force Terraform to recreate specific resources. As the name suggests, it replaces the specified resource. Its value defines the resource identifier that should be replaced with the existing configuration mentioned in the same Terraform code.

```bash
terraform apply -replace="aws-instance.my_vm_1"
```

---

## What is Terraform drift?

Terraform drift refers to the situation where the actual state of infrastructure in an environment diverges from the state defined in Terraform configuration files. Drift can happen due to changes outside of the Terraform workflow, such as manual modifications, automated external processes, or resource eviction.

- **Manual changes**: As a DevOps engineer, when you have severity one issues, you may make manual changes just to get the systems up and running, but this also means that you have to make these changes in the code afterward. Sometimes, you forget that you’ve made these changes, and your configuration will drift.

- **External processes**: You may have automated processes outside Terraform’s control, such as autoscaling actions triggered by cloud providers or external scripts that make changes to your infrastructure.

- **Resource eviction**: Due to cost-saving measures and policy violations, resources can be evicted or deleted, which can cause drift.

### How to detect Terraform drifts?

You can identify the existence of drift by running a couple of Terraform commands. The recommended way to surface drift with the Terraform CLI today is:

- **terraform plan** — implicitly refreshes state in memory and shows any differences between configuration, state, and real infrastructure.

- **terraform plan -refresh-only** — explicitly refreshes state and shows the changes that would be written to the state file without proposing infrastructure changes.

---

## What is a Terraform linter?

A Terraform linter is a tool that helps ensure the quality and consistency of Terraform code by analyzing it for potential issues, errors, or violations of best practices.

Linting is the process of using a static code analysis tool to identify potential errors, bugs, stylistic errors, and suspicious constructs in your code. The term “lint” comes from the Unix utility lint, which was used to analyze C code for errors. Linting tools are available for use with most coding languages, not just Hashicorp Configuration Language (HCL) used by Terraform.

By using linting tools, development teams can establish a consistent coding style across projects, make the code more readable and understandable, and catch common mistakes that might go unnoticed during manual code reviews. Linting promotes best practices and helps maintain a high level of code quality throughout the development lifecycle.

## What is TFLint?
TFLint is a popular open-source linter and static analysis tool designed explicitly for Terraform. It performs automated checks on Terraform configurations to identify potential issues, errors, and violations of best practices. TFLint helps maintain code quality, consistency, and reliability in Terraform projects.

TFLint automatically scans .tf files and reports potential issues. It works by analyzing Terraform code for stylistic errors, security problems, or provider-specific issues before deployment. 

You can extend functionality using plugins for cloud providers like AWS, Azure, or Google Cloud. Configuration is done via a .tflint.hcl file, where you can enable or disable rules and set custom checks.

## How to install TFLint

If you use the popular package manager for Windows ‘chocolately’, you can easily install TFLint by running **choco install tflint**.

Using homebrew for Mac, simply run **brew install tflint**.

If you are using Linux or want to install from the source package, check out the TFLint page on GitHub to download it and get started:

Download tflint_linux_amd64.zip for Linux
Extract the downloaded ZIP file.
Add the extracted binary (tflint or tflint.exe) to a directory listed in your system’s PATH environment variable.
You can also use Docker to pull down the TFLint image using **docker pull wata727/tflint**.

After installation, you can verify that TFLint is properly installed by running **tflint --version**.

---