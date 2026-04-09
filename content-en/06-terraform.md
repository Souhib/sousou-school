# Module 6: Terraform

> **Prerequisites:** Module 5 (AWS -- understand EC2, VPC, Security Groups before automating them)

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

> You created this infrastructure manually in Module 5 (AWS). Terraform automates exactly the same steps.

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

## The State File

The `terraform.tfstate` file records the current state of your infrastructure -- it's Terraform's memory. It knows "I created a server with ID i-abc123, a VPC with ID vpc-def456, etc.". When you rerun `terraform apply`, it compares this file with your code to know what to create, modify, or delete.

⚠️ **NEVER modify the state file by hand.**
⚠️ **NEVER commit the state file to Git** (it can contain secrets).

In a team, you store the state on a remote backend (S3 for example) so everyone works on the same state.

## Modules (concept)

A module = a reusable block of Terraform code. Like a function in programming. If you often create a VPC + EC2 + Security Group, you put that in a module and call it with different parameters.

We won't create one in this course, but know that they exist.

## Hands-on Project: Recreate the AWS infrastructure with Terraform

We'll recreate exactly what we did by hand in Module 5, but in code.

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

- [ ] You can explain Infrastructure as Code in one sentence
- [ ] You know the 4 commands: `init`, `plan`, `apply`, `destroy`
- [ ] You can write a basic HCL resource (provider, resource, variable, output)
- [ ] You understand the role of the state file (and why not to commit it)
- [ ] You've recreated the Module 5 AWS infrastructure with `terraform apply`
- [ ] You've cleaned up with `terraform destroy`
