# Module 5: AWS

> **Prerequisites:** Module 2 (Networking -- IP, ports, subnets), Module 3 (Docker -- to deploy the app)

> **In a nutshell:** You discover the cloud by building an AWS infrastructure (VPC + EC2 + IAM) and by **practising** the major services (S3, SQS, RDS, DynamoDB, Lambda...). Everything is done first **locally and for free**, on an AWS emulator -- then you deploy **once** on a real AWS account, so you've genuinely done it and can talk about it in an interview.

## What is AWS and why does it exist?

**The problem:** Before the cloud, to put a website online, you had to buy a physical server (expensive), plug it in somewhere (data center), configure it, maintain it, and pray it wouldn't break down. If your site explodes in traffic, you're stuck. If nobody comes, you still pay.

**AWS** (Amazon Web Services) lets you rent servers, storage, databases -- exactly what you need, when you need it, in a few clicks. It's like **renting an apartment** instead of building a house.

**The analogies:**
- **AWS** = hardware superstore
- **EC2** = renting a computer
- **S3** = renting a storage locker
- **VPC** = your private room in the AWS building
- **IAM** = the badge system (who is allowed to do what)
- **RDS** = hiring someone to manage your database
- **Lambda** = a freelance chef who comes, cooks a dish, and leaves (you only pay for the dish)

## How we'll work: two tracks

There's a real obstacle when learning AWS: **creating an account requires a credit card.** And once the account exists, you don't dare try anything for fear of the bill. The result: you read, you don't practise.

We get around it with **two complementary tracks**.

| | **Track A -- Local** | **Track B -- Real AWS** |
|---|---|---|
| **With what** | An AWS emulator on your machine ([Floci](floci-aws-local.md)) | A real account on [aws.amazon.com](https://aws.amazon.com) |
| **Credit card** | No | Yes |
| **Cost** | €0 | €0 if you stay within the Free Tier |
| **Can you make mistakes?** | As often as you like | You have to be careful |
| **When** | Throughout the module, for **every** exercise | **Once only**, at the end, for the final deployment |
| **What it gives you** | Practice, reflexes, commands | Real experience, the console, a live app |

**In practice:** you do every exercise in this module on Track A, calmly. Then, at the end, you do the full deployment **once** on Track B.

> **Why not stay local the whole way?** Because an emulator teaches you neither the web console, nor real permission errors, nor how to reason about cost. And because in an interview, "I deployed an app on AWS" and "I deployed an app on an emulator" don't carry the same weight. The two tracks complement each other; neither replaces the other.

### Track A -- Set up local AWS

One command, and you can start:

```bash
cd ~/devops-project/floci
docker compose up -d

# Check (should print 200)
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4566/health
```

Then set up the `awslocal` shortcut by following **[the AWS Locally guide](floci-aws-local.md)**. It's a **one-time** setup -- spend the 10 minutes, everything else in this module depends on it.

In the rest of this module, every **🧪 Practice** box is an exercise to do on Track A.

### Track B -- Create your AWS account

Do this when you reach the [hands-on project](#hands-on-project-deploy-the-project-on-aws), not before.

1. Go to [aws.amazon.com](https://aws.amazon.com) and create an account
2. You'll need a credit card (but the Free Tier is free for 12 months)

⚠️ **IMPORTANT -- Free Tier limits:**
- **EC2**: 750h/month of t3.micro (1 instance 24/7 = OK)
- **S3**: 5 GB of storage
- **RDS**: 750h/month of db.t3.micro
- **Lambda**: 1 million requests/month free (more than enough for learning)
- For this curriculum's project, you only use **EC2** (750h/month = 1 instance 24/7).
- Beyond that, you pay. **Set up a billing alert:**
  - AWS Console -> Billing -> Budgets -> Create Budget -> 5$ threshold

## IAM -- The permissions system

IAM (Identity and Access Management) controls who can do what on your AWS account.

| Concept | What it is |
|---------|-----------|
| **User** | A user account (a person or a program) |
| **Role** | A set of permissions you can temporarily "put on" |
| **Policy** | A JSON document that says "authorized to do X on Y" |

**Best practice:** Never use the root account for work. Create an IAM user with the necessary permissions.

**How to create an IAM user (step by step in the browser):**

1. Log in to the [AWS console](https://console.aws.amazon.com) (this is the AWS website, not a terminal)
2. In the search bar at the top, type **"IAM"** and click on it
3. In the left menu, click on **"Users"** (it's in the Users section, not elsewhere)
4. Click on **"Create user"**
5. Name: `admin-dev` -> **Next**
6. Click **"Attach policies directly"** -> search and check **"AdministratorAccess"** -> **Next** -> **Create user**
7. Click on the `admin-dev` user you just created
8. Tab **"Security credentials"** -> scroll down to **"Access keys"** -> **"Create access key"**
9. Choose **"Command Line Interface (CLI)"** -> check the confirmation -> **Next** -> **Create access key**
10. **Note the Access Key ID and the Secret Access Key** (you won't see them again after closing this page)

> **"AdministratorAccess" is for the course only.** In production, you give the minimum required permissions (principle of least privilege).

### 🧪 Practice: create a user and a policy

> Track A -- [Floci running](floci-aws-local.md) and the `awslocal` alias configured.

```bash
# Create a user
awslocal iam create-user --user-name intern

# Write a policy: "the right to READ from S3, nothing else"
cat > read-s3.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetObject"],
      "Resource": "*"
    }
  ]
}
EOF

# Create the policy from that file
awslocal iam create-policy --policy-name S3ReadOnly --policy-document file://read-s3.json

# Attach it to the user
awslocal iam attach-user-policy \
  --user-name intern \
  --policy-arn arn:aws:iam::000000000000:policy/S3ReadOnly

# Check
awslocal iam list-attached-user-policies --user-name intern
```

**Read the JSON -- that's where everything happens:**

| Field | What it means |
|---|---|
| `Effect` | `Allow` or `Deny` |
| `Action` | The operations concerned. `s3:GetObject` = download a file. Wildcards work too: `s3:*` = every S3 action |
| `Resource` | WHAT it applies to. `*` = everything. In practice you use a precise ARN, e.g. `arn:aws:s3:::my-bucket/*` |

**An ARN** is the unique identifier of an AWS resource. Structure: `arn:aws:service:region:account:resource`. Here `000000000000` is the dummy account number used by the emulator.

> ⚠️ **An important limitation.** The emulator **creates** users and policies, but it does **not enforce** them: it accepts any credentials and never denies anything. So you learn IAM *syntax*, not its *effect*. You'll only see real `AccessDenied` errors on Track B. This is the most important limitation of Track A -- don't forget it.

## AWS CLI

```bash
# Installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install

aws --version
# aws-cli/2.x.x

# Configuration
aws configure
# AWS Access Key ID: your_key
# AWS Secret Access Key: your_secret
# Default region name: eu-west-3  (Paris)
# Default output format: json
```

## EC2 -- Renting a server

EC2 (Elastic Compute Cloud) = a virtual server in the cloud.

> 🧪 **The EC2 exercise comes a little further down**, after the VPC section -- because a server has to sit inside a network. Read this section and the VPC one first, then go do [the full exercise](#-practice-build-a-network-and-launch-a-server-in-it).

### Vocabulary

| Term | What it is |
|------|-----------|
| **Instance** | A running EC2 server |
| **AMI** | The operating system image (Ubuntu, Amazon Linux...) |
| **Instance type** | The power (t3.micro = free, small) |
| **Key pair** | SSH key to connect |
| **Security group** | Instance firewall |

### Launch an instance (console)

1. **EC2** -> **Launch Instance**
2. Name: `devops-server`
3. AMI: **Ubuntu Server 24.04 LTS**
4. Instance type: **t3.micro** (Free Tier)
5. Key pair: **Create new** -> `devops-key` -> Download `.pem`
6. Security group: allow **SSH (22)**, **HTTP (80)**, **port 8000** (the backend API port in our Docker Compose)
7. **Launch**

### Connect

```bash
# Make the key usable
chmod 400 ~/devops-key.pem

# Connect
ssh -i ~/devops-key.pem ubuntu@YOUR_INSTANCE_PUBLIC_IP
# Welcome to Ubuntu...
```

### With AWS CLI

```bash
# List your instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]' --output table

# Stop an instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start an instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

## S3 -- Storage

> **Not needed for the project**, but good to know -- S3 is one of the most used AWS services.

S3 (Simple Storage Service) = unlimited storage space in the cloud.

| Term | What it is |
|------|-----------|
| **Bucket** | A file container (like a root folder) |
| **Object** | A file in a bucket |

```bash
# Create a bucket
aws s3 mb s3://mon-bucket-unique-12345

# Upload a file
aws s3 cp fichier.txt s3://mon-bucket-unique-12345/

# List contents
aws s3 ls s3://mon-bucket-unique-12345/

# Download
aws s3 cp s3://mon-bucket-unique-12345/fichier.txt ./
```

### 🧪 Practice: S3 for real

> Track A. Just replace `aws` with `awslocal` in the commands above.

```bash
# Create a bucket
awslocal s3 mb s3://my-personal-bucket

# Put a file in it
echo "Hello from the cloud" > note.txt
awslocal s3 cp note.txt s3://my-personal-bucket/

# List the contents
awslocal s3 ls s3://my-personal-bucket/

# Download it back
awslocal s3 cp s3://my-personal-bucket/note.txt received.txt && cat received.txt

# Generate a temporary download URL (valid for 1 hour)
awslocal s3 presign s3://my-personal-bucket/note.txt --expires-in 3600
```

**What is a presigned URL, and why is it useful?** Your bucket is private: nobody can reach it. But sometimes you want to let **one** user download **one** specific file for **a limited time** -- their invoice PDF, for instance. Rather than making the bucket public (dangerous) or routing the file through your server (slow and expensive), you generate a signed URL that expires on its own.

```bash
# Try it: it works with no credentials at all
curl "$(awslocal s3 presign s3://my-personal-bucket/note.txt)"
# Hello from the cloud
```

This is a pattern you'll be asked about in interviews: *"how do you let a user download a private file?"*

## VPC -- Your private network

A VPC (Virtual Private Cloud) isolates your AWS resources in your own network.

| Concept | What it is | Analogy |
|---------|-----------|---------|
| **VPC** | Your private network | Your building |
| **Public subnet** | Accessible from the Internet | Ground floor with a door to the street |
| **Private subnet** | Not accessible from the Internet | Upper floors with no direct access |
| **Internet Gateway** | The door to the Internet | The building's front door |
| **Route Table** | The routing rules | The evacuation plan |
| **NAT Gateway** | Allows the private subnet to access the Internet (but not the other way around) | Emergency exit |

### How it all fits together

```
         Internet
            |
     +------+------+
     | Internet     |
     | Gateway      |
     +------+------+
            |
+-----------+------------------------------------------+
|  VPC (10.0.0.0/16)                               |
|                                                   |
|  +---------------------+  +--------------------+ |
|  | Subnet PUBLIC        |  | Subnet PRIVATE      | |
|  | 10.0.1.0/24         |  | 10.0.2.0/24        | |
|  |                     |  |                     | |
|  |  +--------------+   |  |  +--------------+  | |
|  |  | EC2          |   |  |  | RDS          |  | |
|  |  | (backend)    |------>|  | (PostgreSQL) |  | |
|  |  | Public IP    |   |  |  | No public IP |  | |
|  |  +--------------+   |  |  +--------------+  | |
|  |                     |  |                     | |
|  |  Security Group:    |  |  Security Group:    | |
|  |  SSH(22), HTTP(80)  |  |  PostgreSQL(5432)   | |
|  |  from Internet      |  |  from EC2 only      | |
|  +---------------------+  +--------------------+ |
|                                                   |
+---------------------------------------------------+
```

> The subnet and CIDR concepts come from Module 2 (Networking). Security Groups work like the firewalls seen in Module 2 (`ufw`).

**What to remember:**
- The EC2 is in the **public** subnet -> it has a public IP, accessible from the Internet
- The RDS database is in the **private** subnet -> no public IP, accessible only from within the VPC
- Security Groups filter traffic: the RDS only accepts port 5432 coming from the EC2
- The Internet Gateway connects the public subnet to the Internet

**For this curriculum's project: a VPC with a single public subnet is enough.** The diagram above with a private subnet + RDS is to show you how it works in production -- you don't need to create it.

### 🧪 Practice: build a network and launch a server in it

> Track A. This is the most complete exercise in the module: you'll create a network, a firewall, then a server, and **SSH into it**. Allow 15 minutes.

#### 1. The network

```bash
# Create the VPC and keep its id in a variable
VPC=$(awslocal ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
echo "My VPC: $VPC"

# A subnet inside it
SUBNET=$(awslocal ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)
echo "My subnet: $SUBNET"
```

> **What is `VPC=$(...)`?** That's bash: `$( )` runs the command and **captures its output** into a variable instead of printing it. It saves you from retyping ids like `vpc-909faca6` by hand. `--query` and `--output text` keep only the id, without the surrounding JSON.

#### 2. The firewall (Security Group)

```bash
SG=$(awslocal ec2 create-security-group \
  --group-name my-server-sg \
  --description "My server firewall" \
  --vpc-id $VPC \
  --query 'GroupId' --output text)

# Allow SSH (port 22) from anywhere
awslocal ec2 authorize-security-group-ingress \
  --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0
```

**`--cidr 0.0.0.0/0` means "from any IP address in the world".** Handy for learning, but in production you restrict it to your own IP (`--cidr 82.65.12.34/32`). This is an interview classic: *"why is opening SSH to 0.0.0.0/0 risky?"* — because your server then gets scanned and attacked non-stop by bots.

#### 3. The SSH key

```bash
# Generate a key pair on your machine
ssh-keygen -t rsa -b 2048 -f ~/devops-key -N ""

# Give the PUBLIC key to AWS
awslocal ec2 import-key-pair \
  --key-name devops-key \
  --public-key-material fileb://~/devops-key.pub

chmod 400 ~/devops-key
```

> ⚠️ **`import-key-pair`, not `create-key-pair`.** `create-key-pair` asks AWS to generate the key — but the emulator then returns a dummy private key you won't be able to connect with. So we generate the key ourselves and hand over the public half. (Reminder from [Module 1](01-linux-basics.md): the **private** key never leaves your machine, the **public** key is meant to be distributed.)

#### 4. The server

```bash
# A script the server runs automatically on first boot
cat > userdata.sh <<'EOF'
#!/bin/bash
mkdir -p /run/sshd
/usr/sbin/sshd
EOF

INSTANCE=$(awslocal ec2 run-instances \
  --image-id ami-ubuntu2404-amd64 \
  --instance-type t3.micro \
  --key-name devops-key \
  --subnet-id $SUBNET \
  --security-group-ids $SG \
  --user-data file://userdata.sh \
  --count 1 \
  --query 'Instances[0].InstanceId' --output text)

echo "My server: $INSTANCE"
```

> **On an Apple Silicon Mac (M1/M2/M3/M4)**, use `--image-id ami-ubuntu2404-arm64 --instance-type t4g.micro` instead. `t3` types are Intel processors, `t4g` are ARM (Graviton) — and an image must match the processor. The emulator refuses the mismatch, **exactly like real AWS**.

**What is `--user-data`?** A script the server runs by itself on its very first boot. It's THE standard way to automate the setup of a fresh server. Here it creates a directory the SSH server needs to start (the emulator's Ubuntu image doesn't ship it).

#### 5. Wait, then connect

```bash
# Follow the state
awslocal ec2 describe-instances --instance-ids $INSTANCE \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]' --output table
```

⚠️ **`running` does NOT mean "ready".** The server is powered on, but it's still installing its SSH server — that takes a good minute. Same behaviour as on real AWS: there's always a gap between the `running` state and the moment SSH answers.

```bash
# Find which port on your machine maps to the server's SSH
PORT=$(docker ps --filter "name=floci-ec2-$INSTANCE" --format '{{.Ports}}' \
       | sed -n 's/.*:\([0-9]*\)->22\/tcp.*/\1/p')
echo "SSH port: $PORT"     # 2200 for the first instance, 2201 for the next...

# Connect (retry if it says "Connection closed" — it isn't ready yet)
ssh -i ~/devops-key -p $PORT root@127.0.0.1
```

> **Two differences from real AWS to keep in mind:**
>
> | | Track A (emulator) | Track B (real AWS) |
> |---|---|---|
> | User | `root` | `ubuntu` (on an Ubuntu AMI) |
> | Address and port | `127.0.0.1` on port 2200+ | the public IP, on port 22 |
>
> Why? Because your "server" is really a container on your machine. It has no public internet IP: the emulator forwards a local port to its port 22.

#### 6. Once connected

```bash
# You're on the server. Check:
hostname
cat /etc/os-release | head -2

# IMDS: the service that lets an instance know "who am I"
curl -s http://169.254.169.254/latest/meta-data/instance-id
# i-040d1ec4b5bb76c6a
```

**The address `169.254.169.254` is worth memorising.** It's a special address, identical on every EC2 instance in the world, that answers from inside the instance. Its most important job: **automatically supplying the credentials of the instance's IAM role**. That's how an application on EC2 reaches S3 without a single password stored anywhere. It's the right answer to the interview question *"how do you handle AWS secrets on a server?"*.

#### 7. Clean up

```bash
exit   # leave the server

awslocal ec2 terminate-instances --instance-ids $INSTANCE
```

> **Get into the habit of cleaning up, even locally.** On Track B, a forgotten running instance is a bill at the end of the month.

## RDS -- Managed database

> **You do NOT need to create an RDS for the project.** The backend uses PostgreSQL in a Docker container on the EC2 (as in Module 3). This section is here to understand what it is and when to use it in production.

**The problem:** You can install PostgreSQL on an EC2 yourself. But who does the backups? Who updates the database? Who restarts it if it crashes at 3 AM? You. Alone. All the time.

**RDS** (Relational Database Service) = you choose your engine (PostgreSQL, MySQL, etc.), AWS handles everything else: automated backups, security updates, high availability, replication.

**Analogy:** Instead of baking your own bread every day (installing and maintaining PostgreSQL on EC2), you go to the bakery (RDS). The bread is the same, but you don't have to worry about the oven.

### Key concepts

| Concept | What it is |
|---------|-----------|
| **RDS Instance** | A managed database server |
| **Engine** | The database type: PostgreSQL, MySQL, MariaDB, etc. |
| **Multi-AZ** | Your database is automatically copied to a 2nd datacenter. If the first goes down, the 2nd takes over. That's "high availability". |
| **Read Replica** | A read-only copy of your database. Read queries go to the copy, relieving the main database. |
| **Automated Backups** | AWS makes a full backup of your database every day automatically. If you break everything, you can go back to yesterday's backup. |

### Create an RDS instance (console) -- Example for reference

> **You don't have to follow these steps.** This is an example to show you how to create an RDS if you ever need one in production. For the curriculum project, PostgreSQL runs in a Docker container on your EC2 -- that's sufficient.

1. **RDS** -> **Create database**
2. Engine: **PostgreSQL**
3. Template: **Free Tier**
4. Instance type: **db.t3.micro**
5. Master username: `admin`
6. Master password: choose a strong password
7. VPC: `devops-vpc`
8. Public access: **No** (best practice: the DB should not be exposed to the Internet)
9. Security group: create one that allows port **5432** only from the EC2's Security Group
10. **Create**

### Connect from EC2 (if you had created an RDS)

```bash
# (Example for reference -- you don't need to do this for the project)
# From your EC2 instance (not from your local machine!):
sudo apt install -y postgresql-client
psql -h MY-INSTANCE.rds.amazonaws.com -U admin -d postgres
# Password: your_password
# postgres=>
```

The important point: the RDS database is in a **private subnet** (no direct Internet access). Your EC2 in the same VPC can access it through AWS's internal network.

### With AWS CLI

```bash
# List your RDS instances
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,Engine,DBInstanceStatus,Endpoint.Address]' --output table

# Delete (be careful!)
aws rds delete-db-instance --db-instance-identifier my-instance --skip-final-snapshot
```

⚠️ **If you created an RDS (not needed for the project), don't forget to delete it** -- even on the Free Tier, if you exceed 750h/month, it costs money.

### When to use RDS vs PostgreSQL on EC2?

| | RDS | PostgreSQL on EC2 |
|--|-----|-------------------|
| Backups | Automatic | You configure them yourself |
| Updates | Managed by AWS | You do them yourself |
| High availability | Multi-AZ in one click | You set up replication yourself |
| Price | More expensive | Less expensive |
| Control | Limited (no SSH access to the machine) | Full |

**In a nutshell:** In production, use RDS. The extra cost is easily offset by the time you don't spend managing the database.

### 🧪 Practice: create a database and connect to it

> Track A. The emulator starts a **real PostgreSQL** — this is not an imitation.

```bash
awslocal rds create-db-instance \
  --db-instance-identifier my-database \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password MyPassword123 \
  --allocated-storage 20

# Wait for the status to become "available" (a few seconds)
awslocal rds describe-db-instances --db-instance-identifier my-database \
  --query 'DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port]' --output table
```

**The endpoint** is the database's address. On real AWS it looks like `my-database.c9x.eu-west-3.rds.amazonaws.com`, and it's what you put in your `DATABASE_URL`.

```bash
# Connect (install psql if needed: sudo apt install -y postgresql-client)
psql -h localhost -p 7001 -U postgres
# Password: MyPassword123

# Once inside:
#   SELECT version();
#   CREATE TABLE test (id SERIAL PRIMARY KEY, name TEXT);
#   INSERT INTO test (name) VALUES ('it works');
#   SELECT * FROM test;
#   \\q     ← to quit
```

> ⚠️ **The address trap.** `describe-db-instances` returns an address like `172.25.0.3`: that's a **Docker-internal** address, meaningless from your machine. From your terminal, always connect to **`localhost`**, keeping the **port** shown (7001, 7002...).

**Clean up:**

```bash
awslocal rds delete-db-instance --db-instance-identifier my-database --skip-final-snapshot
```

## Lambda -- Serverless (optional)

> This section is optional. Lambda is not used in the Hands-on Project. If you're new to AWS, focus on EC2 + VPC + RDS first and come back here later.

**The concept in 30 seconds:** Lambda runs your code without any server to manage (hence the name "serverless"). You send a Python/JS function, AWS runs it when an event arrives (HTTP request, S3 upload, timer), and you only pay for the execution time. **Automatic scaling** = if 1,000 people call your function at the same time, AWS launches 1,000 copies automatically. No need to configure anything.

**Analogy:** A freelance chef. You call them when you have an order, they cook, they leave. 0 orders = $0.

| | Lambda | EC2 |
|--|--------|-----|
| Execution duration | Short (<15 min) | Unlimited |
| Scaling | Automatic | Manual |
| Price | Per execution | Per hour (even at rest) |
| Use case | Webhooks (see below), one-off tasks | Apps running 24/7 |

**What is a webhook?** It's an automatic message sent by an external service to your API when something happens on their side. For example: when a customer pays on Stripe, Stripe sends an HTTP message to your API to say "payment X has been confirmed". You don't need to ask Stripe every 5 seconds "did someone pay?" -- Stripe notifies you automatically. That's a webhook: a "reverse call" -- instead of YOU calling the service, THE SERVICE calls you.

### 🧪 Practice: your first Lambda

> Track A. The emulator **actually executes** your Python code.

```bash
mkdir -p my-lambda && cd my-lambda

# 1. The function code
cat > lambda_function.py <<'EOF'
def lambda_handler(event, context):
    # "event"   = the incoming data (what triggered the function)
    # "context" = execution info (time remaining, memory...)
    name = event.get("name", "unknown")
    return {"statusCode": 200, "message": f"Hello {name}!"}
EOF

# 2. AWS expects the code as a .zip file
zip function.zip lambda_function.py

# 3. Create the function
awslocal lambda create-function \
  --function-name my-function \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::000000000000:role/lambda-role

# 4. Run it
awslocal lambda invoke \
  --function-name my-function \
  --payload '{"name":"Souhib"}' \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json
# {"statusCode": 200, "message": "Hello Souhib!"}
```

**What is `--handler`?** It's the entry point: `file.function`. Here `lambda_function.lambda_handler` means "in the file `lambda_function.py`, call the function `lambda_handler`". Get it wrong and you get an `Unable to import module` error — the number one Lambda mistake.

**What you just experienced:** you deployed and ran code **without ever mentioning a server**. No machine to pick, no OS to patch, no port to open. That's exactly what "serverless" means.

Full documentation: [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html).

## Other AWS services to know

> **None of these services are needed for the project.** Your app runs on an EC2 with Docker Compose, and that's sufficient. These sections are here for your knowledge and for interviews -- you'll often be asked "what is ECS?" or "RDS vs DynamoDB?".

### SQS -- Message queues (and why they matter)

Before talking about SQS, you need to understand a fundamental problem.

**The problem with direct (synchronous) processing:**

Imagine a restaurant where the waiter takes your order and stands there in front of you while the chef prepares your dish. Meanwhile, they can't take other orders. If 50 customers arrive at the same time, 49 wait standing. And if the chef drops your dish? The waiter doesn't know what to do, your order is lost.

That's what happens when your API processes everything **directly** (**synchronously**): each request blocks a process while waiting for the processing to finish. If the processing is long (sending an email, generating a PDF, processing a payment) or many requests arrive at the same time, everything slows down or crashes.

**The solution: the message queue (asynchronous)**

Now imagine the waiter takes your order, writes it on a ticket and hangs it on a rail in the kitchen. They're immediately free to take the next order. The chef picks up tickets one by one, at their own pace. If the chef drops the dish, the ticket is still there -- they can remake it.

That's exactly what **SQS** (Simple Queue Service) does: a message queue in the cloud.

```
WITHOUT a message queue (synchronous):
  Request -> API processes directly -> if it crashes, it's lost
  Request -> API processes directly -> if 1000 requests arrive, the API crashes

WITH a message queue (asynchronous):
  Request -> API puts a message in SQS -> responds "OK, received" (instant)
                                              |
                                    Lambda/Worker consumes the queue
                                    and processes at its own pace
                                              |
                                    If it fails -> the message stays
                                    in the queue, we retry
```

**SQS** = a message queue managed by AWS. You put messages in, another program consumes them. Messages are never lost -- if the consumer crashes, the message goes back in the queue and will be re-processed.

**When to use a message queue:**
- The processing is **long** (>1 second) -- sending an email, generating a report, processing an image
- The user **doesn't need the result immediately** -- "your order is being processed"
- You have **traffic spikes** -- 1000 requests arrive at once, the queue absorbs the spike
- The processing **must not be lost** -- payment webhooks, orders

**When NOT to use a message queue:**
- The user needs the result **right now** -- displaying a page, reading a task list
- The processing is **fast** (<100ms) -- no need to decouple

| | Direct processing (synchronous) | Message queue (asynchronous) |
|--|------|------|
| Response speed | The client waits for processing to finish | The client receives "OK, received" instantly |
| If it crashes | The message is lost | The message stays in the queue |
| Traffic spikes | The API is overwhelmed | The queue absorbs, the worker processes at its own pace |
| Complexity | Simple | More components to manage |

You'll find SQS in the [system design exercises](system-design-exercises.md) -- it's a pattern used very often in interviews.

#### 🧪 Practice: a message queue

> Track A. You'll play both roles: the one who drops the ticket, and the cook who picks it up.

```bash
# Create the queue
awslocal sqs create-queue --queue-name my-queue
# {"QueueUrl": "http://localhost:4566/000000000000/my-queue"}

Q=http://localhost:4566/000000000000/my-queue

# The waiter drops a ticket
awslocal sqs send-message --queue-url $Q --message-body "Send invoice 1042"

# The cook comes to pick up a ticket
awslocal sqs receive-message --queue-url $Q
```

Look closely at the response: there's a **`ReceiptHandle`** field. It's the most important mechanism in SQS, and it's worth a point in interviews.

**Receiving a message does not delete it.** It only becomes *invisible* to other consumers for a while (the *visibility timeout*, 30 seconds by default). You must delete it **explicitly** once the work is done:

```bash
RECEIPT=$(awslocal sqs receive-message --queue-url $Q --query 'Messages[0].ReceiptHandle' --output text)
awslocal sqs delete-message --queue-url $Q --receipt-handle "$RECEIPT"
```

**Why this odd behaviour?** Because it makes the system crash-resistant. If your program dies **during** processing, it never deletes the message: after 30 seconds it becomes visible again, and another program picks it up. **No work is ever lost.**

Try it: receive a message, don't delete it, wait 30 seconds, and ask again — it's back.

### DynamoDB -- NoSQL database

**RDS** gives you a classic relational database (tables with columns, SQL, relationships between tables). **DynamoDB** is a **NoSQL** (Not Only SQL) database -- instead of rigid tables, you store flexible JSON documents.

| | RDS (PostgreSQL) | DynamoDB |
|--|-------------------|----------|
| Structure | Tables with fixed columns | Flexible JSON documents |
| Language | SQL | AWS API (no SQL) |
| Scaling | Vertical (bigger machine) | Automatic horizontal (AWS handles it) |
| Price | Per hour (even at rest) | Per request (0 requests = $0) |
| Use case | Complex relationships (users + orders + products) | Simple data at very high traffic (sessions, cart, logs) |

**Analogy:** RDS is a filing cabinet with neatly organized sheets in categories. DynamoDB is a pile of sticky notes -- each note can have different info, but it's ultra fast to add or find one.

**When to use which?**
- Your app has relationships between data (a user has orders, an order has products) -> **RDS**
- You need to read/write very fast on simple data (user sessions, cache, real-time counters) -> **DynamoDB**
- You don't know -> **RDS**. SQL is universal, you can always migrate later

#### 🧪 Practice: a NoSQL table

> Track A. Compare with the SQL you ran earlier on RDS.

```bash
# Create a table. We declare ONLY the key -- no other columns.
awslocal dynamodb create-table \
  --table-name Tasks \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Write an item
awslocal dynamodb put-item --table-name Tasks \
  --item '{"id":{"S":"1"},"title":{"S":"Learn DynamoDB"},"done":{"BOOL":false}}'

# Write another one with DIFFERENT fields -- and it works!
awslocal dynamodb put-item --table-name Tasks \
  --item '{"id":{"S":"2"},"title":{"S":"Another task"},"priority":{"N":"3"}}'

# Read it back
awslocal dynamodb get-item --table-name Tasks --key '{"id":{"S":"1"}}'
```

**What this exercise shows you, and a table never will:**

| | RDS (SQL) | DynamoDB (NoSQL) |
|---|---|---|
| Before writing | You must create the table **with all its columns** | You declare **only the key** |
| Two different rows | Impossible: the structure is enforced | Normal: each item carries whatever fields it wants |
| To read | `SELECT ... WHERE ...` on any column | By the **key**, mostly |

**What's that `{"S": "1"}` format?** DynamoDB requires you to state the **type** of every value: `S` = String, `N` = Number, `BOOL` = boolean. It's verbose on the command line, but in real code the libraries handle it for you.

**DynamoDB's real trap, worth knowing:** since you can only query efficiently by the key, **the key you choose up front determines what you'll be able to do later**. Pick the wrong key and you have to migrate everything. With SQL, you add an index and you're done. That's the main reason behind the "when in doubt, use SQL" advice.

### ECS -- Managed containers on AWS

In Module 3, you launched your Docker containers on an EC2 with `docker compose`. It works, but **you're the one managing the server**: updates, monitoring, scaling. If your EC2 goes down, your app goes down.

**ECS** (Elastic Container Service) = you give your Docker images to AWS, and AWS launches them, monitors them, restarts them if they crash, and scales them automatically. You no longer manage the server.

| | Docker on EC2 | ECS |
|--|----------------|-----|
| Who manages the server? | You | AWS (with Fargate) |
| Scaling | Manual (`docker compose up`) | Automatic |
| Monitoring | You configure it yourself | Built-in (CloudWatch) |
| Price | You pay for the EC2 | You pay for CPU/RAM used (Fargate) |
| Complexity | Simple | More initial configuration |

ECS has two modes:
- **EC2 mode** -- your containers run on EC2s that you manage (you have control, but more work)
- **Fargate mode** -- your containers run without any server at all (AWS manages everything, you pay per usage). This is the recommended mode to start with

**Analogy:** Docker on EC2 is cooking at home -- you handle the groceries, the oven, the cleanup. ECS Fargate is a ghost kitchen (dark kitchen) -- you send the recipe (your Docker image), someone else cooks and delivers.

### EKS -- Managed Kubernetes on AWS

If you've done Module 9 (Kubernetes), you already know K8s with minikube locally. **EKS** (Elastic Kubernetes Service) = the same thing, but on AWS. AWS manages the control plane (the brain of the K8s cluster), you manage the workers (the machines running your pods).

| | ECS | EKS |
|--|-----|-----|
| Tool | AWS-specific | Kubernetes (standard, runs anywhere) |
| Portability | Locked into AWS | Migratable (GKE on Google, AKS on Azure) |
| Complexity | Simpler | More complex, but more flexible |
| Community | AWS only | Huge open-source community |
| Price | Cheaper (no control plane fee) | ~$75/month for the control plane + workers |

**When to use which?**
- You're starting out and staying on AWS -> **ECS Fargate** (simplest)
- You want multi-cloud portability or you already know K8s -> **EKS**
- You have a small project with low traffic -> **Docker on EC2** (like in this curriculum)
- You have short, one-off functions -> **Lambda**

```
Small project         --> Docker on EC2
Classic web app       --> ECS Fargate
Multi-cloud / K8s     --> EKS
One-off tasks         --> Lambda
```

### Route 53 -- AWS DNS

You saw DNS in Module 2 (Networking): it's the system that translates a domain name (`myapp.com`) into an IP address (`13.38.42.100`). **Route 53** is AWS's DNS service.

Without Route 53, your users have to type `http://13.38.42.100` to access your app. With Route 53, they type `myapp.com`.

**What Route 53 actually does:**
- **Buy a domain name** directly on AWS (or import one purchased elsewhere)
- **Point the domain** to your EC2, your Load Balancer, your CloudFront, etc.
- **Health checks**: if your server goes down, Route 53 can automatically redirect to a backup server
- **Geographic routing**: send European users to a server in Europe and American users to a server in the US

**Analogy:** It's the Yellow Pages of AWS. You register "my business is called myapp.com and it's located at this IP address". If you move (you change servers), you update the address in Route 53.

| Concept | What it is |
|---------|-----------|
| **Hosted Zone** | Your domain's record -- all DNS rules for `myapp.com` |
| **Record A** | Points a name to an IP (`myapp.com -> 13.38.42.100`) |
| **Record CNAME** | Points a name to another name (`www.myapp.com -> myapp.com`) |
| **TTL** | Time To Live -- how long browsers keep the address cached before re-checking |

In practice, Route 53 is one of the last services you configure -- first you get your app running, then you give it a nice domain name.

#### 🧪 Practice: a DNS zone

> Track A.

```bash
# Create the domain's "record card"
awslocal route53 create-hosted-zone --name myapp.local --caller-reference $(date +%s)

# Get its id
ZONE=$(awslocal route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)

# Add an A record: "myapp.local points to this IP"
awslocal route53 change-resource-record-sets --hosted-zone-id $ZONE --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "myapp.local",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "13.38.42.100"}]
    }
  }]
}'

# Read back what's stored
awslocal route53 list-resource-record-sets --hosted-zone-id $ZONE \
  --query 'ResourceRecordSets[].[Name,Type,ResourceRecords[0].Value]' --output table
```

**`--caller-reference $(date +%s)`**: AWS requires a unique value on every creation, so that re-running the command by accident doesn't create the zone twice. `date +%s` returns the current time in seconds, so it differs every time. This mechanism is called **idempotency**, and you'll meet it everywhere (see [Module 7](07-ansible.md)).

### CloudWatch -- AWS built-in monitoring

In Module 8, you'll see Prometheus + Grafana for monitoring. **CloudWatch** is the AWS-native equivalent -- it's already enabled by default on all your AWS services, without installing anything.

**What CloudWatch does:**
- **Metrics**: CPU, RAM, network of your EC2s, number of requests on your Load Balancer, Lambda errors... everything is collected automatically
- **Logs**: centralizes logs from your ECS containers, your Lambdas, your applications -- instead of connecting via SSH to run `docker logs`
- **Alarms**: "if my EC2's CPU exceeds 80% for 5 minutes, send me an email"

**Analogy:** CloudWatch is your car's dashboard -- speed, fuel level, engine temperature. You don't install it, it's there by default. Prometheus + Grafana is like installing a custom, more advanced dashboard.

| | CloudWatch | Prometheus + Grafana |
|--|------------|---------------------|
| Installation | Nothing to do, already enabled | You install and configure it yourself |
| AWS metrics | Automatic (EC2, RDS, Lambda...) | You have to export them manually |
| Application metrics | Possible but more complex | Very simple (`/metrics` endpoint) |
| Cost | Paid beyond the Free Tier | Free (open-source) |
| Dashboards | Basic | Very powerful and customizable |

In practice, you often use **both**: CloudWatch for AWS infrastructure metrics (EC2 CPU, Lambda errors), and Prometheus + Grafana for application metrics (API response time, number of tasks created).

#### 🧪 Practice: centralise logs

> Track A.

```bash
# A "log group" = a folder of logs (usually one application)
awslocal logs create-log-group --log-group-name /my-app/backend

# A "log stream" = one source inside that folder (usually one instance)
awslocal logs create-log-stream \
  --log-group-name /my-app/backend --log-stream-name server-1

# Send a log line
awslocal logs put-log-events \
  --log-group-name /my-app/backend \
  --log-stream-name server-1 \
  --log-events timestamp=$(($(date +%s) * 1000)),message="API starting"

# Read it back
awslocal logs get-log-events \
  --log-group-name /my-app/backend --log-stream-name server-1 \
  --query 'events[].message' --output text
```

**Why centralise logs?** With one server, `docker logs` is enough. With ten servers, finding an error becomes impossible: you'd have to connect to each of them. Centralising brings every log to one place and makes it **searchable**. And crucially: when a server dies, its local logs die with it — the ones already shipped out survive.

That's the "logs" pillar of observability, which you'll meet again in [Module 8](08-monitoring.md).

## Hands-on Project: Deploy the project on AWS

> **This is where you switch to Track B -- real AWS.** It's the only exercise in the module that requires it.

### Why this one can't be done locally

Every previous exercise ran on the emulator. The final deployment can't -- and it's better to understand why than to just accept it:

| What's needed here | Why the emulator can't do it |
|---|---|
| **Running containers on the server** | Your emulated "server" is itself a container. You can install Docker in it, but you can't launch containers from it (a nested storage limitation). And the whole project relies on `docker compose up`. |
| **An address reachable from the internet** | An emulated instance's "public" IP is `127.0.0.1` -- your own machine. Nobody else can open your app. |
| **The real experience** | The web console, real latency, real permission errors, billing. None of that exists locally. |

And above all: in an interview you want to be able to say **"I deployed an application on AWS"**, not "on an emulator".

### What you've already done

Good news: you have **already** built a VPC, a subnet, a security group, an SSH key and an EC2 instance in the earlier exercises, from the command line. You're going to do the same thing again, but in the web console and for real. The concepts are identical -- only the interface changes.

### 0. Before you start

- [ ] Your AWS account is created (see [Track B](#track-b--create-your-aws-account) above)
- [ ] Your **billing alert** is set up -- don't skip this
- [ ] Your `admin-dev` IAM user exists and you have its access keys
- [ ] Your code is pushed to GitHub

⚠️ **From here on, every resource you create can cost money if you forget it.** Write down what you create, and do the cleanup in step 6 at the end.

### 1. Create a VPC (AWS console)

- **VPC** -> **Create VPC**
- VPC and more -> Name: `devops-vpc`
- CIDR: `10.0.0.0/16`
- 1 public subnet, 0 private subnets
- Leave other options as default -> **Create**

### 2. Launch an EC2 instance

- **EC2** -> **Launch Instance**
- Name: `devops-server`
- AMI: Ubuntu 24.04 LTS
- Type: t3.micro
- Key pair: `devops-key`
- Network: choose `devops-vpc` and the public subnet
- Auto-assign public IP: **Enable**
- Security group: SSH (22), HTTP (80), Custom TCP (8000)
- **Launch**

### 3. Connect and install Docker

```bash
ssh -i ~/devops-key.pem ubuntu@PUBLIC_IP

# On the server:
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker ubuntu
# Disconnect and reconnect
exit
ssh -i ~/devops-key.pem ubuntu@PUBLIC_IP
```

### 4. Launch the application

```bash
# On the server:
mkdir devops-project && cd devops-project

# Create the docker-compose.yml (copy the one from Module 3)
# Or clone your GitHub repo:
git clone https://github.com/YOUR_USER/devops-project.git .

docker compose up -d --build
```

### 5. Test

Open your browser and go to `http://PUBLIC_IP` -- you should see the Task List.

```bash
curl http://PUBLIC_IP:8000/api/tasks
# [{"id":1,"title":"Apprendre Docker","done":false}]
```

💡 **If it doesn't work:** check the Security Group (ports 80 and 8000 open) and that the instance has a public IP.

⚠️ **Don't forget to stop/terminate your instance when you're done** to avoid costs:
```bash
aws ec2 terminate-instances --instance-ids i-YOUR_INSTANCE_ID
```

### 6. Clean up -- don't skip this step

This is the step everyone forgets, and it's the one that costs money.

```bash
# 1. Terminate the instance (it's the most expensive part)
aws ec2 terminate-instances --instance-ids i-YOUR_INSTANCE_ID

# 2. Check nothing is still running
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?State.Name!=`terminated`].[InstanceId,State.Name]' \
  --output table
```

Then, in the console: **VPC** -> delete the `devops-vpc` VPC (this also removes the associated subnet, internet gateway and route tables).

> **The habit to build:** before you close your laptop, open the **Billing -> Bills** page in the AWS console. It shows what's being charged right now. Five seconds of checking beats a surprise bill.

### 7. Bonus -- User Data (automating the installation)

You just did steps 3 and 4 manually (SSH, install Docker, clone, launch). **User Data** lets you automate all of that: it's a bash script you give to the EC2 at creation time, and it runs automatically on first boot.

It's like leaving a note for the delivery person: "when you arrive, install Docker and launch the app."

To use it, when creating the EC2 (step 2), click on **"Advanced details"** at the bottom of the page, and in the **"User data"** field, paste this script:

```bash
#!/bin/bash
apt-get update
apt-get install -y docker.io docker-compose-v2 git
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

mkdir -p /home/ubuntu/devops-project
cd /home/ubuntu/devops-project
git clone https://github.com/YOUR_USER/devops-project.git .
docker compose up -d --build
```

With that, you launch the EC2 and the app runs on its own in 2-3 minutes -- without connecting via SSH. This is exactly what we'll automate with Terraform in Module 6.

> **You don't have to redo the exercise with User Data.** It's just to understand the concept. Module 6 (Terraform) uses it automatically.

## Interview Corner

### Fundamental questions

**Q: What is AWS?**
A: A cloud computing provider. You rent servers (EC2), storage (S3), databases (RDS) and many other services, on demand.

**Q: What is EC2?**
A: Elastic Compute Cloud -- a virtual server in the cloud. You choose the power, the OS, and you pay by the hour.

**Q: What is a VPC?**
A: Virtual Private Cloud -- an isolated network in AWS. You put your resources in it (EC2, RDS). You control the subnets, routing, and access.

**Q: Difference between a public and private subnet?**
A: Public = accessible from the Internet (via Internet Gateway). Private = no direct access from the Internet. You put web servers in public, databases in private.

**Q: What is IAM?**
A: Identity and Access Management -- AWS's permissions system. Users, roles, policies. Principle of least privilege: you only give the necessary permissions.

**Q: What is an IAM Policy?**
A: A JSON document that defines permissions: which actions (e.g.: `s3:GetObject`) are allowed or denied, on which resources (e.g.: a specific bucket). You attach it to a User, Group or Role to grant these rights.

**Q: What is the principle of least privilege?**
A: Grant only the permissions strictly necessary to do the job, and nothing more. If a Lambda only needs to read an S3 bucket, you give it only `s3:GetObject` on that specific bucket -- not `AdministratorAccess`. This limits the damage if credentials are compromised.

**Q: What is a Security Group?**
A: A virtual firewall for EC2 instances. It controls inbound and outbound traffic by port and source IP.

**Q: What is S3?**
A: Simple Storage Service -- unlimited object (file) storage, high durability. Used for backups, static files, logs, etc.

### Database questions

**Q: What is RDS?**
A: Relational Database Service -- a database managed by AWS. You choose the engine (PostgreSQL, MySQL...), AWS handles backups, updates, and high availability.

**Q: Why use RDS instead of installing PostgreSQL on an EC2?**
A: RDS handles backups, security updates, replication, and high availability automatically. Less operational work. In return, it's slightly more expensive and you have less control.

**Q: What is DynamoDB?**
A: A NoSQL database managed by AWS. Instead of SQL tables with fixed columns, you store flexible JSON documents. Scaling is automatic and pricing is per request.

**Q: When to use RDS vs DynamoDB?**
A: RDS when your data has relationships (users -> orders -> products) and you need complex SQL queries. DynamoDB when you have simple data at very high traffic (sessions, cache, counters). When in doubt, RDS -- it's more versatile.

### Container and compute questions

**Q: What is ECS?**
A: Elastic Container Service -- you give your Docker images to AWS, and it launches them, monitors them and scales them. With Fargate, you don't even have a server to manage -- you only pay for CPU and RAM used.

**Q: What is EKS?**
A: Elastic Kubernetes Service -- managed Kubernetes on AWS. AWS manages the control plane, you manage the workers. The advantage over ECS: K8s is a standard, your setup is portable to any cloud (GKE, AKS).

**Q: ECS vs EKS, which would you choose?**
A: ECS if I'm staying on AWS and want something simple and cheap. EKS if I need multi-cloud portability or the team already knows Kubernetes. EKS has a fixed cost for the control plane (~$75/month), ECS doesn't.

**Q: What is Lambda?**
A: Serverless -- you send your code, AWS runs it when needed, you pay per execution. No server to manage. Ideal for short, one-off tasks.

**Q: When to use Lambda vs EC2 vs ECS?**
A: Lambda for short tasks (<15 min) and one-off jobs. ECS/EKS for containerized apps running continuously with automatic scaling. EC2 when you need full control over the server or for simple small projects.

**Q: What is a cold start?**
A: The first execution of a Lambda is slower because AWS has to start an environment. Subsequent executions (warm start) are faster.

**Q: Difference between horizontal and vertical scaling?**
A: Vertical = increase the power of a machine (more CPU, more RAM). Horizontal = add more machines. Vertical has a physical limit, horizontal is virtually unlimited. In the cloud, horizontal scaling is preferred.

**Q: What is the shared responsibility model?**
A: AWS manages security **of** the cloud (datacenters, physical network, hypervisors). You manage security **in** the cloud (your data, your Security Groups, your IAM policies, your code). If your Security Group is open to everyone, that's your fault, not AWS's.

> **System design exercises:** To practice answering questions like "how would you deploy this app?", check out the [5 system design exercises](system-design-exercises.md). This is the kind of question you'll be asked in DevOps interviews.

## Best practices

- **Least privilege (IAM).** Never give `AdministratorAccess` in production. Create policies that only authorize what the user/role needs. It's constraining but it's what prevents a hack from becoming a catastrophe.
- **Never the root account.** The root account can do everything, including deleting the AWS account. Create an IAM user for your daily use. Enable MFA (multi-factor authentication) on root.
- **DB in a private subnet.** Always. A database exposed to the Internet is a ransomware waiting to happen.
- **Billing alert.** Set up a Budget alert from day 1. People have gotten $10,000 bills for a forgotten NAT Gateway.
- **Tag your resources.** `Name`, `Environment` (dev/staging/prod), `Project`. When you have 50 resources, it's the only way to know what they're for and whether you can delete them.
- **One region, one choice.** Pick your region (eu-west-3 = Paris) and stick with it. Resources aren't visible across regions, which creates confusion.

## Common mistakes

- **Leaving instances running** -> Unexpected cost. Always `terminate` when you're done.
- **Using the root account** -> Bad practice. Create an IAM user.
- **Security Group too open (0.0.0.0/0 on everything)** -> Anyone can access it. Only open the necessary ports.
- **Forgetting to assign a public IP** -> You won't be able to access your instance from the Internet.
- **Choosing the wrong region** -> Your resources are in one region. If you search and can't find them -> check the region in the top right.
- **RDS with public access** -> Never expose a database to the Internet. Always in a private subnet, accessible only from your EC2/VPC.
- **Forgetting to delete the RDS instance** -> Even on the Free Tier, it costs if you exceed 750h/month.
- **Lambda timeout too short** -> Default is 3s. If your function makes an external API call, increase the timeout.

## Going further

- **CloudWatch**: monitoring and centralized logs on AWS -- you'll use it from your first deployment
- **SQS / SNS**: message queues and notifications -- very common pattern for decoupling services
- **API Gateway**: create complete APIs in front of Lambda (auth, rate limiting, versioning)
- **AWS Well-Architected Framework**: cloud architecture best practices -- useful for system design interviews
- **Other clouds**: GCP (Google), Azure (Microsoft) -- same concepts, different names
- **[AWS Locally with Floci](floci-aws-local.md)**: the full guide to the emulator, its limits and its troubleshooting. Emulators also exist for Azure and GCP
- **Testcontainers**: the same idea as Floci, but started automatically from your test code

## You can move on to the next module if...

**Track A -- local practice**

- [ ] You can start Floci and check that it responds
- [ ] You know what `awslocal` does and why you don't just type `aws`
- [ ] You created an S3 bucket, uploaded a file and generated a presigned URL
- [ ] You built a VPC + subnet + security group from the command line
- [ ] You launched an EC2 instance and connected to it via SSH
- [ ] You created an RDS database and connected to it with `psql`
- [ ] You sent and received a message in an SQS queue, and can explain the `ReceiptHandle`
- [ ] You deployed and ran a Lambda
- [ ] You can name **two** things the emulator cannot do

**The concepts**

- [ ] You know what EC2, S3, VPC, RDS, IAM, DynamoDB, ECS and EKS are (in one sentence each)
- [ ] You understand the difference between a public and private subnet
- [ ] You know what a Security Group is (AWS firewall)
- [ ] You know what the address `169.254.169.254` is for

**Track B -- real AWS**

- [ ] You have an AWS account with a billing alert configured
- [ ] The Hands-on Project runs on an EC2 accessible from your browser
- [ ] You've properly terminated/deleted all AWS resources to avoid costs
