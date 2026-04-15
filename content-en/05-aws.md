# Module 5: AWS

> **Prerequisites:** Module 2 (Networking -- IP, ports, subnets), Module 3 (Docker -- to deploy the app)

> **In a nutshell:** You discover the cloud by deploying your application on a real AWS server (EC2 + VPC + IAM). You also discover other services (S3, RDS, Lambda, ECS, etc.) to understand them -- but for the project, you only need an EC2 with Docker Compose.

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

## Account creation + Free Tier

1. Go to [aws.amazon.com](https://aws.amazon.com) and create an account
2. You'll need a credit card (but the Free Tier is free for 12 months)

⚠️ **IMPORTANT -- Free Tier limits:**
- **EC2**: 750h/month of t3.micro (1 instance 24/7 = OK)
- **S3**: 5 GB of storage
- **RDS**: 750h/month of db.t3.micro
- **Lambda**: 1 million requests/month free (more than enough for learning)
- For this curriculum's project, you only use **EC2** (750h/month = 1 instance 24/7). The other services are explained for your knowledge but aren't needed.
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

To create and test a Lambda, see the [AWS Lambda documentation](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html).

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

## Hands-on Project: Deploy the project on AWS

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

### 6. Bonus -- User Data (automating the installation)

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

## You can move on to the next module if...

- [ ] You have an AWS account with a billing alert configured
- [ ] You know what EC2, S3, VPC, RDS, IAM, DynamoDB, ECS and EKS are (in one sentence each)
- [ ] You know how to launch an EC2 instance and connect via SSH
- [ ] You understand the difference between a public and private subnet
- [ ] You know what a Security Group is (AWS firewall)
- [ ] The Hands-on Project runs on an EC2 accessible from your browser
- [ ] You've properly terminated/deleted all AWS resources to avoid costs
