# Module 6: Terraform

> **Prerequisites:** [Module 5](05-aws.md) (AWS -- understand EC2, VPC, Security Groups before automating them)

> **In a nutshell:** You replace manual clicks in the AWS console with code. Terraform lets you describe your infrastructure in files, versioned in Git, reproducible and shareable. What took you 30 min by hand, Terraform does in 2 min.

## What is Terraform and why does it exist?

**The problem:** You just created your AWS infrastructure by clicking around in the console. It took 30 minutes. Now imagine: your boss tells you "do the same thing for the staging environment". And also for pre-prod. And document what you created for your colleague. And if you make a mistake, roll back.

With clicks, it's impossible to reproduce, impossible to version, impossible to share. **Terraform solves this**: you describe your infrastructure in code. A text file, versioned in Git, that anyone can read and execute.

**The analogy:** Terraform is the **architect's blueprint** for your infrastructure.
- `terraform plan` = reviewing the blueprint with the client ("here's what we'll build")
- `terraform apply` = sending the construction crew
- `terraform destroy` = demolition
- The **state file** = the "as-built" plan

**In one sentence:** Infrastructure as Code (IaC) -- your infra is code, not clicks.

> You created this infrastructure manually in [Module 5](05-aws.md) (AWS). Terraform automates exactly the same steps.

## Installation

```bash
# Add the HashiCorp repo
sudo apt update && sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform

terraform --version
# Terraform v1.x.x
```

## Where we'll apply: locally first

Terraform is learned by **repeating**. You write three lines, you apply, you look at the result, you fix it, you start again. Twenty times.

On a real AWS account that isn't comfortable: every `apply` creates real resources, every `destroy` removes them, and if you forget something, you pay for it.

So we'll apply against the **local AWS** from [Module 5](05-aws.md). Same Terraform, same commands, same files -- but free, instant, and consequence-free.

```bash
cd ~/devops-project/floci && docker compose up -d && cd -
```

### How to point Terraform at the local one

A **provider** is the module that knows how to talk to a service (AWS, GCP, GitHub...). By default the AWS provider sends everything to real AWS. We give it four pieces of information to redirect it:

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "test"        # dummy credentials: the emulator doesn't check them
  secret_key = "test"

  # ─── The 4 "skips": disable the checks that make no sense locally ───
  skip_credentials_validation = true   # don't ask AWS whether these keys are valid
  skip_metadata_api_check     = true   # don't try to detect whether we run on EC2
  skip_requesting_account_id  = true   # don't ask for the AWS account number
  s3_use_path_style           = true   # URLs like .../my-bucket instead of my-bucket....

  # ─── Where to send each service's requests ───
  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}
```

**Without the `skip`s it doesn't work**: Terraform would start by calling real AWS to validate your credentials, and fail before creating anything at all.

**`s3_use_path_style` deserves an explanation.** Real AWS puts the bucket name in the domain name (`my-bucket.s3.amazonaws.com`). Locally there's no DNS for that, so we ask for the other form: `localhost:4566/my-bucket`. Forget this line and S3 fails with baffling DNS resolution errors.

### The same code for local AND production

We obviously don't want two different Terraform files. So we put the address in a **variable**:

```hcl
variable "aws_endpoint" {
  description = "AWS API address. Empty = real AWS."
  type        = string
  default     = ""
}

provider "aws" {
  region = var.aws_region

  # These settings only kick in when a local address is provided.
  skip_credentials_validation = var.aws_endpoint != ""
  skip_metadata_api_check     = var.aws_endpoint != ""
  skip_requesting_account_id  = var.aws_endpoint != ""
  s3_use_path_style           = var.aws_endpoint != ""
  access_key                  = var.aws_endpoint != "" ? "test" : null
  secret_key                  = var.aws_endpoint != "" ? "test" : null

  # dynamic = only generate this block IF the condition holds
  dynamic "endpoints" {
    for_each = var.aws_endpoint != "" ? [1] : []
    content {
      ec2 = var.aws_endpoint
      s3  = var.aws_endpoint
      iam = var.aws_endpoint
    }
  }
}
```

```bash
# Locally
terraform apply -var="aws_endpoint=http://localhost:4566"

# On real AWS: pass nothing, the variable stays empty
terraform apply
```

> **`condition ? value_if_true : value_if_false`** is called a ternary operator -- an `if/else` written on one line. You'll find it in almost every language.

**What you've just seen is the heart of the job.** One infrastructure codebase, several environments, and **only the configuration changes**. It's exactly the dev / staging / prod principle from [Module 1](01-linux-basics.md), applied to infrastructure. In a company, that's how a single codebase is driven by a `dev.tfvars`, a `staging.tfvars` and a `prod.tfvars`.

## IaC -- Before vs After

| | Before (clicks) | After (Terraform) |
|--|--------------|-------------------|
| Reproducible? | No | Yes, `terraform apply` |
| Documented? | No (who remembers the clicks?) | Yes, it's code |
| Versioned? | No | Yes, in Git |
| Reviewable? | No | Yes, pull request |
| Rollback? | No (you click in reverse...) | Yes, previous commit |

## HCL -- Terraform's language

Terraform uses HCL (HashiCorp Configuration Language). It's not a traditional programming language -- it's **declarative**: you describe WHAT YOU WANT ("I want a server with 2 GB of RAM in this region"), and Terraform takes care of the HOW (which APIs to call, in what order, etc.). It's the opposite of **imperative** where you describe each step yourself ("first create the network, then create the server, then attach it to the network...").

### Provider

A provider connects Terraform to a service (AWS, GCP, Azure...).

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Where to find the provider: "publisher/name"
      version = "~> 5.0"          # ~> = "compatible with": accepts 5.1, 5.2... but not 6.0
    }
  }
}

provider "aws" {
  region = "eu-west-3"  # Paris -- the AWS region where your resources will be created
}
```

### Resource

A resource = something that Terraform creates/manages.

```hcl
resource "aws_instance" "mon_serveur" {
  ami           = data.aws_ami.ubuntu.id  # Retrieved automatically (see data source)
  instance_type = "t3.micro"

  tags = {
    Name = "devops-server"
  }
}
```

The syntax: `resource "TYPE" "LOCAL_NAME" { ... }`. The type comes from the provider. The local name is your choice (to reference it in the code).

### Variables

```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project name"
  default     = "devops"
}
```

Usage: `var.instance_type`, `var.project_name`.

### Outputs

Displays info after `apply` (public IP, URL, etc.).

```hcl
# outputs.tf
output "public_ip" {
  value       = aws_instance.mon_serveur.public_ip
  description = "Server public IP"
}
```

## The 4 commands

```bash
# 1. Initialize (downloads the provider)
terraform init
# Initializing provider plugins...
# Terraform has been successfully initialized!

# 2. Preview changes
terraform plan
# Plan: 3 to add, 0 to change, 0 to destroy.
# (shows what will be created/modified/deleted)

# 3. Apply
terraform apply
# Do you want to perform these actions? yes
# Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

# 4. Destroy everything
terraform destroy
# Do you really want to destroy all resources? yes
# Destroy complete! Resources: 3 destroyed.
```

### 🧪 Practice: the loop that makes you improve

This is the highest-return exercise in the module. It doesn't teach you a command -- it teaches you a **reflex**.

Create a sandbox folder:

```bash
mkdir -p ~/tf-sandbox && cd ~/tf-sandbox

cat > main.tf <<'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
  }
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "my-vpc" }
}
EOF

terraform init
terraform apply -auto-approve
```

Now **run these experiments one by one**, and each time read what `terraform plan` says **before** applying:

| Experiment | What you should observe |
|---|---|
| Run `terraform apply` again with no changes | `No changes.` -- Terraform doesn't redo what already exists |
| Change the `tags = { Name = ... }` | `1 to change` -- modified **in place**, the VPC id stays the same |
| Change `cidr_block` to `10.1.0.0/16` | `1 to add, 1 to destroy` -- Terraform **destroys and recreates**: some attributes can't be modified |
| Add an `aws_subnet` referencing the VPC | `1 to add` -- and Terraform creates it **after** the VPC, on its own |
| Remove the resource from the file | `1 to destroy` -- the code is the truth: what's no longer in it gets deleted |
| Delete the resource **by hand** (`awslocal ec2 delete-vpc ...`) then `plan` | `1 to add` -- Terraform notices reality no longer matches the code. That's called **drift** |

> **The "modify in place" vs "destroy and recreate" distinction is an interview classic.** In production, a `plan` announcing an unexpected `destroy` on a database is a disaster narrowly avoided. **Always read the `plan` before applying** -- that's THE professional reflex.

```bash
# Clean up when you're done
terraform destroy -auto-approve
```

Run this loop as often as you like: it costs nothing and takes two seconds each time. That's exactly what local AWS makes possible.

## The State File

The `terraform.tfstate` file records the current state of your infrastructure -- it's Terraform's memory. It knows "I created a server with ID i-abc123, a VPC with ID vpc-def456, etc.". When you rerun `terraform apply`, it compares this file with your code to know what to create, modify, or delete.

⚠️ **NEVER modify the state file by hand.**
⚠️ **NEVER commit the state file to Git** (it can contain secrets).

In a team, you store the state on a remote backend (S3 for example) so everyone works on the same state.

### 🧪 Practice: putting the state on S3

So far the state is a file on your machine. That causes three problems as soon as there's more than one of you:

1. **Your colleague can't see your state.** They think nothing exists and recreate everything twice.
2. **If you lose your disk, you lose the state.** Terraform no longer knows what it created — the resources still exist on AWS, but it doesn't recognise them.
3. **Two `apply`s at the same time** can collide and corrupt the state.

The fix: store the state in a **remote backend**, usually an S3 bucket. Let's do it for real, locally.

```bash
# The bucket already exists (created when Floci starts), otherwise:
awslocal s3 mb s3://taskflow-tfstate
```

Add a `backend` block inside `terraform`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "taskflow-tfstate"              # which bucket
    key    = "formation/terraform.tfstate"   # which path inside it
    region = "us-east-1"

    # ─── Local AWS only ───
    endpoints = {
      s3 = "http://localhost:4566"
    }
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
```

> ⚠️ **The `backend` block doesn't accept variables.** Unlike the rest of your Terraform code, you can't write `var.something` in it: it's read very early, before variables exist. In a company you therefore pass those values separately: `terraform init -backend-config=dev.hcl`.
>
> The `endpoints` field in a backend requires **Terraform 1.6 or later** (`terraform --version` to check).

```bash
# Re-initialise: Terraform detects the new backend
terraform init
# Do you want to copy existing state to the new backend? → yes

terraform apply
```

**Check that it worked:**

```bash
# The state now lives in the bucket
awslocal s3 ls s3://taskflow-tfstate/formation/
# 2026-08-22 14:54:37       1617 terraform.tfstate

# And there's no local file any more
ls terraform.tfstate
# ls: cannot access 'terraform.tfstate': No such file or directory
```

**What you just did is exactly what happens in a company.** The state lives in a shared bucket, every team member works against the same state, and the bucket has versioning enabled so you can roll back. When a recruiter asks *"where do you store your Terraform state?"*, the expected answer is: "in a remote backend, S3 with versioning enabled, never in Git".

## Modules (concept)

A module = a reusable block of Terraform code. Like a function in programming. If you often create a VPC + EC2 + Security Group, you put that in a module and call it with different parameters.

We won't create one in this course, but know that they exist.

## Hands-on Project: Recreate the AWS infrastructure with Terraform

We'll recreate exactly what we did by hand in [Module 5](05-aws.md), but in code.

> **Do it locally first.** Write all the code, run `terraform apply` against local AWS, fix your syntax and dependency mistakes — for free. Once it passes cleanly, do it again on real AWS by simply dropping the `-var="aws_endpoint=..."`.
>
> One caveat: the emulator doesn't validate everything. An `apply` that passes locally **can** still fail on real AWS (IAM permissions, quotas, bucket names already taken worldwide). Local removes 90% of the errors — not 100%.

### 1. Create the structure

```bash
mkdir -p ~/devops-terraform
cd ~/devops-terraform
```

### 2. The main file

Create `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Where to find the provider: "publisher/name"
      version = "~> 5.0"          # ~> = "compatible with": accepts 5.1, 5.2... but not 6.0
    }
  }
}

provider "aws" {
  region = var.aws_region          # The AWS region (defined in variables.tf)
}

# --- VPC ---
# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"    # Network IP address range (65,536 addresses)
  enable_dns_hostnames = true              # Allows instances to have a DNS name (e.g.: ec2-13-38-xx.eu-west-3.compute.amazonaws.com)

  tags = { Name = "${var.project_name}-vpc" }   # ${var.xxx} = inserts the value of a Terraform variable
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id       # Attach this subnet to the VPC created just above
                                                   # aws_vpc.main.id = "the ID of the aws_vpc resource named main"
  cidr_block              = "10.0.1.0/24"          # Sub-range of 256 addresses in the VPC
  map_public_ip_on_launch = true                   # Each instance launched in this subnet automatically gets a public IP
  availability_zone       = "${var.aws_region}a"   # Availability zone (e.g.: "eu-west-3a")

  tags = { Name = "${var.project_name}-public" }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id    # The "front door" that connects the VPC to the Internet

  tags = { Name = "${var.project_name}-igw" }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id    # Route table = the network's "traffic rules"

  route {
    cidr_block = "0.0.0.0/0"                  # "All traffic going to the Internet..."
    gateway_id = aws_internet_gateway.gw.id   # "...goes through the Internet Gateway"
  }

  tags = { Name = "${var.project_name}-rt" }
}

# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id       # Associate the route table with the public subnet
  route_table_id = aws_route_table.public.id   # Without this, the subnet has no route to the Internet
}

# --- Security Group (firewall) ---
# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "web" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.main.id

  # ingress = INBOUND traffic rules (who is allowed to access your server)
  ingress {
    description = "SSH"
    from_port   = 22               # Start port
    to_port     = 22               # End port (same value = a single port)
    protocol    = "tcp"            # TCP = reliable protocol (verifies that data arrives)
    cidr_blocks = ["0.0.0.0/0"]   # From any IP (0.0.0.0/0 = the entire world)
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress = OUTBOUND traffic rules (what your server is allowed to send)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"             # "-1" = all protocols (TCP, UDP, etc.)
    cidr_blocks = ["0.0.0.0/0"]   # To anywhere -- the server can access the entire Internet
  }

  tags = { Name = "${var.project_name}-sg" }
}

# --- AMI (automatically fetch the latest Ubuntu 24.04) ---
# "data" = a data source. Unlike "resource" which CREATES something,
# "data" FETCHES information that already exists on AWS.
# Here, we look for the most recent Ubuntu AMI (image) instead of hardcoding its ID.
# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ubuntu" {
  most_recent = true                           # Take the most recent if multiple match
  owners      = ["099720109477"]               # Canonical (the company that publishes Ubuntu) -- this is their AWS ID

  filter {
    name   = "name"                            # Filter by AMI name
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    # The * at the end = any build date (the AMI is updated regularly)
  }
}

# --- EC2 ---
# Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id          # The Ubuntu image fetched by the data source above
  instance_type          = var.instance_type               # Instance type (t3.micro = free)
  subnet_id              = aws_subnet.public.id            # Which subnet to launch the instance in
  vpc_security_group_ids = [aws_security_group.web.id]     # Which firewall to apply (the [] = a list)
  key_name               = var.key_name                    # SSH key name to connect

  # user_data = a script that runs automatically on the server's first boot
  # This is how you automate Docker installation without connecting via SSH
  # <<-EOF ... EOF = "heredoc" -- a way to write a long multi-line text
  # Everything between <<-EOF and EOF is the script content
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose-v2 git
    usermod -aG docker ubuntu
    systemctl enable docker
    systemctl start docker

    mkdir -p /home/ubuntu/devops-project
    cd /home/ubuntu/devops-project
    # ${var.github_user} = inserts the value of the "github_user" variable
    # This is Terraform's syntax for inserting a variable into text
    # (different from GitHub Actions which uses ${{ }} -- each tool has its own syntax)
    git clone https://github.com/${var.github_user}/devops-project.git .
    # ⚠️ If your repo is private, git clone will fail.
    # Solution: make it public or use a GitHub token in the URL:
    # git clone https://TOKEN@github.com/user/repo.git .
    docker compose up -d --build
  EOF

  tags = { Name = "${var.project_name}-server" }
}
```

### 3. Variables

Create `variables.tf`:

```hcl
variable "aws_region" {
  default = "eu-west-3"
}

variable "project_name" {
  default = "devops"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
}

variable "github_user" {
  description = "Your GitHub username"
}
```

### 4. Outputs

Create `outputs.tf`:

```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/devops-key.pem ubuntu@${aws_instance.web.public_ip}"
}

output "app_url" {
  value = "http://${aws_instance.web.public_ip}"
}
```

### 5. Variables file (`terraform.tfvars`)

Passing variables with `-var="..."` on the command line is tedious and doesn't version easily. In practice, you use a `.tfvars` file:

Create `terraform.tfvars`:
```hcl
key_name    = "devops-key"
github_user = "YOUR_USER"
```

Terraform automatically loads `terraform.tfvars` if it exists. Otherwise, you can specify a file:
```bash
terraform apply -var-file="production.tfvars"
```

This is how you manage multiple environments: a `dev.tfvars`, a `staging.tfvars`, a `prod.tfvars`, each with different values (instance size, project name, etc.).

⚠️ **Don't commit `.tfvars` files that contain secrets.** Add `*.tfvars` to `.gitignore` if needed. Non-sensitive variables (region, instance type) can be committed.

### 6. Launch!

```bash
terraform init
# Terraform has been successfully initialized!

terraform plan
# Plan: 6 to add, 0 to change, 0 to destroy.

terraform apply
# Apply complete! Resources: 6 added
# Outputs:
#   app_url    = "http://13.38.x.x"
#   public_ip  = "13.38.x.x"
#   ssh_command = "ssh -i ~/devops-key.pem ubuntu@13.38.x.x"
```

Wait 2-3 minutes (user_data installs Docker and launches the app), then open the URL.

**What you just did by hand in 30 min, Terraform did in 2 min.** And you can redo it identically with a single `terraform apply`.

### 7. Clean up

```bash
terraform destroy
# Destroy complete! Resources: 6 destroyed.
```

### 8. Bonus -- The same code on both

If you followed the [The same code for local AND production](#the-same-code-for-local-and-production) section, you can now do this:

```bash
# Create the infra locally, test it, destroy it -- in 10 seconds
terraform apply  -var="aws_endpoint=http://localhost:4566" -auto-approve
terraform destroy -var="aws_endpoint=http://localhost:4566" -auto-approve

# Then the real one, once you're confident
terraform apply
```

**One codebase, two environments.** That's the concrete outcome of this whole module.

## Interview Corner

**Q: What is Terraform?**
A: An Infrastructure as Code tool. You describe your infra in HCL files, Terraform creates/modifies/deletes it. Versionable, reproducible, collaborative.

**Q: What is Infrastructure as Code?**
A: Managing infrastructure (servers, networks, databases) via code instead of manual clicks. Benefits: reproducible, versioned, auditable.

**Q: Explain plan, apply, destroy.**
A: `plan` shows what will change without doing anything. `apply` executes the changes. `destroy` deletes everything. You always do plan before apply to verify.

**Q: What is the state file?**
A: A JSON file that records the current state of the infrastructure managed by Terraform. It allows comparing the real state with the code to know what to create/modify/delete.

**Q: Why not commit the state file?**
A: It can contain secrets (passwords, keys). You store it on a remote backend (S3 + DynamoDB for locking).

**Q: Terraform vs CloudFormation?**
A: Terraform is multi-cloud (AWS, GCP, Azure). CloudFormation is AWS-specific. Terraform has a larger community and more readable syntax.

**Q: What is a Terraform module?**
A: A reusable block of Terraform code. Instead of copy-pasting the same config for each environment, you create a module and call it with different parameters. It's like a function in programming.

**Q: What is a Terraform provider?**
A: A plugin that connects Terraform to a service (AWS, GCP, Azure, GitHub...). The AWS provider allows Terraform to create EC2s, S3 buckets, RDS instances. Without a provider, Terraform can't talk to anything.

## Best practices

- **Always `plan` before `apply`.** Read the plan. Check what will be destroyed. An accidental `destroy` of a production database happens.
- **Remote state from day 1.** In a team, local state is a nightmare (conflicts, data loss). Use an S3 backend + DynamoDB for locking.
- **One `.tfvars` per environment.** `dev.tfvars`, `staging.tfvars`, `prod.tfvars`. Same code, different values.
- **Don't commit the state or secrets.** `.gitignore` should contain `*.tfstate`, `*.tfstate.backup`, `.terraform/`. `.tfvars` with secrets too.
- **Format your code.** `terraform fmt` before each commit. It's the equivalent of a linter for Terraform.
- **Name your resources consistently.** `${var.project_name}-${var.environment}-resource`. Example: `devops-prod-sg`. When you have 100 resources in the AWS console, names are the only way to find your way around.
- **No manual modifications.** If someone modifies the infra in the AWS console, the next `terraform apply` will overwrite their changes. Everything goes through code.

## Common mistakes

- **Forgetting `terraform init`** -> "Provider not found". You need to init for every new project or after adding a provider.
- **Modifying the state file by hand** -> It breaks everything. Use `terraform state` if needed.
- **Committing `terraform.tfstate`** -> Add `*.tfstate` to `.gitignore`.
- **Forgetting to destroy after testing** -> Unexpected AWS cost.
- **Hardcoding values** -> Use variables for everything that changes between environments.
- **Passing variables with `-var` on every command** -> Use a `.tfvars` file, it's cleaner and more reproducible.

## Going further

- **Modules**: writing reusable modules -- essential once your Terraform code exceeds 200 lines
- **Import**: `terraform import` to import manually created resources into the state -- you'll need this when taking over an existing infrastructure
- **Workspaces**: managing multiple environments (dev, staging, prod) with the same Terraform code
- **Terragrunt**: a wrapper for managing Terraform at scale -- useful when you have 20+ modules and 5+ environments

## You can move on to the next module if...

- [ ] You can explain what Infrastructure as Code is, and what it brings
- [ ] You know the 4 commands: `init`, `plan`, `apply`, `destroy`
- [ ] You know what the state is, and why you never commit it to Git
- [ ] You've run the apply/plan/destroy loop locally, and can explain the difference between "modify in place" and "destroy and recreate"
- [ ] You've put your state on an S3 backend and verified there's no local file left
- [ ] You know how to point the AWS provider at a local endpoint, and why the `skip_*` flags are needed
- [ ] You've recreated the [Module 5](05-aws.md) infrastructure in Terraform
- [ ] You've run `terraform destroy` on real AWS to avoid costs
