# TERRAFORM Question & Answers

## Question and Ansers on Count and for_each

### 🔥 1. What is the main difference between count and for_each?
✅ Answer:
count creates resources based on a number and tracks them using index
for_each creates resources based on a map or set and tracks them using keys

👉 Key point:

count → index-based (fragile)
for_each → key-based (stable)

### 🔥 2. Why is for_each preferred over count in production?
✅ Answer:

Because for_each provides stable resource addressing.

With count, if the list changes (e.g., removing an element), Terraform may:

Shift indexes
Destroy and recreate resources unnecessarily

With for_each:

Resources are tied to unique keys
Only the changed resource is affected

### 🔥 3. What problem occurs when using count with a list?
✅ Example:
variable "names" {
  default = ["a", "b", "c"]
}

If you remove "b":

["a", "c"]
❌ With count:
"c" shifts from index 2 → 1
Terraform destroys and recreates it
✅ Answer Summary:

This is called the index shifting problem, leading to unnecessary infrastructure changes.

### 🔥 4. Can you use for_each with a list?
✅ Answer:

Not directly.

You must convert it:

for_each = toset(var.list)

👉 Because for_each only accepts:

map
set of strings

### 🔥 5. When would you still use count?
✅ Answer:

Use count when:

You need conditional resource creation

Example:

resource "aws_instance" "example" {
  count = var.create ? 1 : 0
}

👉 Simple and effective for boolean conditions

### 🔥 6. Can you use both count and for_each together?
❌ Answer:

No.

Terraform does not allow both on the same resource.

### 🔥 7. How does Terraform identify resources internally for both?
✅ Answer:
count → resource_name[index]
for_each → resource_name[key]

Example:

aws_instance.example[0]
aws_instance.example["dev"]

### 🔥 8. What happens if you change a key in for_each?
✅ Answer:

Terraform will:

Destroy the old resource
Create a new one

👉 Because key = identity

### 🔥 9. Which is better for handling dynamic infrastructure?
✅ Answer:

for_each

Because:

Works well with maps
Maintains consistency
Avoids accidental recreation

### 🔥 10. How do you migrate from count to for_each?
✅ Answer (Important Advanced Question):

Steps:

Change configuration from count → for_each
Use terraform state mv to remap resources

Example:

terraform state mv aws_instance.example[0] aws_instance.example["dev"]

👉 Prevents resource recreation

### 🔥 11. What are the limitations of for_each?
✅ Answer:
Cannot use directly with list (must convert)
Keys must be unique
Slightly more complex syntax than count

### 🔥 12. Explain a real-world scenario where for_each is required
✅ Answer:

Managing environments:

variable "envs" {
  default = {
    dev  = "t2.micro"
    prod = "t2.large"
  }
}

Using for_each:

Clearly separates environments
Avoids accidental resource replacement

### 🔥 13. What happens if you reorder a list in count?
❌ Answer:

Terraform may:

Destroy and recreate resources
Even if nothing actually changed

### 🔥 14. Can for_each be used with modules?
✅ Answer:

Yes, and it's very powerful.

module "ec2" {
  for_each = var.instances
  source   = "./ec2-module"

  name = each.key
}

### 🔥 15. What is the biggest mistake engineers make with count?
✅ Answer:

Using count with dynamic lists instead of for_each, leading to:

Infrastructure instability
Unexpected destruction/recreation
🧠 Pro Interview Tip

If asked:

👉 “Which one should I use?”

🎯 Best Answer:

“Use for_each for most real-world scenarios because it provides stable resource addressing. Use count only for simple, fixed, or conditional resource creation.”

---

## How terraform process the files?

**🔷 Short Answer**

👉 When you run:
```bash
terraform apply
```
- ✔️ Terraform ONLY processes .tf files in the current working directory
- ❌ It does NOT automatically scan subdirectories
- ✔️ It processes other directories ONLY if explicitly referenced (e.g., via modules)

### 🧠 How Terraform Actually Works (Core Concept)

Terraform operates on a concept called a:

**👉 Working Directory**

This directory:

- Contains .tf files
- Is treated as a single configuration unit

### 📁 1. What Files Are Executed?
✅ Terraform loads:
- All *.tf files
- All *.tf.json files

**👉 ONLY in the current directory**

**🔍 Example**
```bash
project/
├── main.tf
├── variables.tf
├── outputs.tf
└── subdir/
    └── extra.tf
```

When you run:
```bash
terraform apply
```
👉 Terraform will:
**✅ Load**:
- main.tf
- variables.tf
- outputs.tf

**❌ IGNORE**:
- subdir/extra.tf

### 🔷 2. Are Files in Subdirectories Executed?
**❌ No — not automatically**

**Terraform does NOT recursively scan directories**

👉 This is by design:

- Prevents accidental infrastructure changes
- Enforces explicit configuration

### 🔷 3. Then How Are Other Directories Used?

Through modules.

### 🧩 4. Modules Are Explicitly Loaded

If you define:
```bash
module "ec2" {
  source = "./modules/ec2"
}
```
👉 Then Terraform will:

- Go into ./modules/ec2
- Load ALL .tf files inside that module directory

📁 Example Structure
```bash
project/
├── main.tf
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

```
**🔍 What Happens?**

When terraform apply runs:

Step-by-step:
- Load current directory .tf files
- See module "ec2" block
- Go to ./modules/ec2
- Load ALL .tf files inside that module
- Merge into execution graph

### 🔷 5. Are All Module Files Executed?
✅ Yes — but only if module is referenced

👉 Inside a module:

- All .tf files are treated as one configuration

### 🔷 6. What About Multiple Environments?
📁 Example:
```bash
environments/
├── dev/
│   └── main.tf
├── prod/
│   └── main.tf
```

**❗ Important Rule**:

If you run:
```bash
cd environments/dev
terraform apply
```
👉 Terraform will:

- ✅ Process only dev/
- ❌ Ignore prod/

---