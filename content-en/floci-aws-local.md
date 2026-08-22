# AWS Locally — Practise Without an Account or a Credit Card

> **Prerequisites:** [Module 3 (Docker)](03-docker.md) — Floci runs with Docker, so you need it installed and understood first.
>
> **In short:** You install a program that **imitates AWS on your own machine**. Your `aws` commands, your Python code and your Terraform talk to it exactly as they would talk to real AWS. You can create anything, break anything, and start over — for free and with no risk.

## The problem we're solving

[Module 5 (AWS)](05-aws.md) introduces you to the cloud. But to touch real AWS you need to:

- create an account,
- **hand over a credit card number**,
- stay careful not to exceed the Free Tier,
- remember to delete everything after each exercise, or the bill arrives.

The result: most people don't dare try anything. They read the module, they understand the theory, but they never **practise**. And in an interview it shows immediately — reciting "S3 is object storage" impresses nobody. Saying "I created a bucket, I hit a permissions error, here's how I fixed it" changes everything.

## What is an emulator?

**An emulator is a program that pretends to be another system, well enough that the programs around it can't tell the difference.**

An analogy: a **flight simulator**. It isn't a plane. But the controls are in the same place, they react the same way, and the instruments show the same things. A pilot can train for hundreds of hours, botch landings, and try again — with no risk and no fuel burned. It doesn't replace real flight hours, but without it nobody could train that much.

**Floci** is the flight simulator of AWS.

- It's **free and open-source software** (MIT licence) that runs in a Docker container on your machine.
- It **speaks the same language** as AWS. When your program sends a "create an S3 bucket" request, Floci receives it, understands it, and answers exactly the way AWS would have.
- It needs **no account, no password, and no internet connection** once installed.
- It's **light**: a few dozen megabytes of RAM.

> **Some context that's useful in interviews.** Until March 2026, the reference tool for this was called **LocalStack**. Its vendor discontinued the free "community edition" that year. Floci was created just before, as a free replacement: it uses the same port, the same conventions, and most projects migrated from one to the other without changing a single line of code. If a recruiter mentions LocalStack, you know what they mean.

## What you'll be able to do

| You'll actually practise | Where you only used to read |
|---|---|
| **S3** — create a bucket, upload and read files back | Module 5 |
| **SQS** — send a message to a queue, consume it | Module 5 |
| **DynamoDB** — create a table, write to it, read from it | Module 5 |
| **Lambda** — deploy a function and run it | Module 5 |
| **RDS** — create a PostgreSQL database and connect to it | Module 5 |
| **VPC / Subnet / Security Group** — build a network | Module 5 |
| **EC2** — launch a server and SSH into it | Module 5 |
| **CloudWatch Logs, Route 53, Secrets Manager** | Module 5 |
| **Terraform** — `apply` and `destroy` as often as you like | Module 6 |
| **Integration tests in CI** — with no AWS secrets in GitHub | Module 5 |

---

## Installation

### 1. Check the prerequisites

```bash
# Docker must be installed and running (Module 3)
docker --version
# Docker version 24.x.x or later

# The AWS CLI must be installed (Module 5)
aws --version
# aws-cli/2.x.x
```

> **If `aws` isn't installed**, go back to the [AWS CLI section of Module 5](05-aws.md). You do **not** need to run `aws configure` or own any credentials — we're going to do without them.

### 2. Start Floci

The hands-on project already ships everything you need, in the `floci/` folder:

```bash
cd ~/devops-project/floci
docker compose up -d
```

The first time, Docker downloads the image (~350 MB), which takes a minute or two. After that, startup takes a few seconds.

### 3. Check that it works

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4566/health
# 200
```

**`200` is the HTTP status code meaning "all good"** (see the status codes in [Module 2](02-networking.md)). If you get `000` or `Connection refused`, Floci hasn't started yet — wait 10 seconds and try again.

You can also list the emulated services:

```bash
curl -s http://localhost:4566/health | head -c 300
# {"version":"1.7.0","services":{"s3":"running","sqs":"running","ec2":"running",...
```

---

## Configuring the AWS CLI — and the trap to avoid

### The problem

By default, the `aws` command sends **everything to real AWS**. You need to tell it to target Floci instead. Floci's address is `http://localhost:4566`.

In AWS jargon, that address is called an **endpoint** — literally the point where requests are sent.

### ⚠️ The trap everyone falls into

Plenty of tutorials tell you to do this:

```bash
export AWS_ENDPOINT_URL=http://localhost:4566   # ⚠️ doesn't work everywhere
```

**That variable is only understood by recent versions of the AWS CLI (2.13 and later).** On an older version it is **silently ignored**: your command goes to real AWS, and you get a baffling error:

```
An error occurred (InvalidAccessKeyId) when calling the CreateBucket operation:
The AWS Access Key Id you provided does not exist in our records.
```

You then spend an hour looking for what's wrong with Floci... when Floci was never contacted at all.

### The fix: an alias

We'll create a **command shortcut** (an "alias") called `awslocal` that adds Floci's address automatically. The benefits:

- it works with **every** version of the AWS CLI;
- you can **see** in the command that you're local (`awslocal` ≠ `aws`);
- it's impossible to send a command to real AWS by mistake.

Add these lines to the end of your `~/.bashrc`:

```bash
# ─── Local AWS (Floci) ───
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
alias awslocal='aws --endpoint-url=http://localhost:4566'
```

Then reload the file:

```bash
source ~/.bashrc
```

> **What is `~/.bashrc`?** A configuration file read automatically every time you open a terminal. Anything you put in it applies to every new session. `source` applies it right now, without reopening the terminal. (See environment variables in [Module 1](01-linux-basics.md).)

### Why fake credentials?

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
```

**Floci doesn't check credentials.** It accepts anything. But the AWS CLI refuses to send a request when no credentials are set — it stops before even trying. So we give it fake ones, purely to satisfy it.

**And `us-east-1`?** That's a **region** — a place in the world where AWS has data centres. Floci doesn't care (everything runs on your machine), but the AWS CLI requires one. We pick `us-east-1` because it's the default in most tools, which avoids surprises with Terraform.

---

## Your first round trip

```bash
# 1. Create a bucket (a file storage space)
awslocal s3 mb s3://my-first-bucket
# make_bucket: my-first-bucket

# 2. Create a test file on your machine
echo "My first file in the cloud" > test.txt

# 3. Upload it to the bucket
awslocal s3 cp test.txt s3://my-first-bucket/
# upload: ./test.txt to s3://my-first-bucket/test.txt

# 4. Check that it's there
awslocal s3 ls s3://my-first-bucket/
# 2026-08-22 14:12:03         27 test.txt

# 5. Download it back under another name
awslocal s3 cp s3://my-first-bucket/test.txt received.txt
cat received.txt
# My first file in the cloud
```

**These five commands are EXACTLY the ones you'd type against real AWS.** The only difference is `awslocal` instead of `aws`. That's the whole point: what you learn here transfers directly.

---

## Day-to-day lifecycle

```bash
cd ~/devops-project/floci

# Start
docker compose up -d

# Check its health
docker compose ps
# STATUS should show "Up (healthy)"

# Read the logs (essential when something misbehaves)
docker compose logs -f floci
#   Ctrl+C to exit

# Stop (and ERASE everything — see below)
docker compose down
```

### Starting from scratch

Floci is configured in **`memory`** mode: everything you create lives in RAM. So `docker compose down` erases it all, and the next `up` gives you a **brand new** AWS.

That's deliberate, and it's a good thing for learning: you can break anything, and it takes 10 seconds to get back to a clean slate.

```bash
docker compose down && docker compose up -d
# → a fresh AWS
```

> **If you want to keep your data** between sessions, change `FLOCI_STORAGE_MODE: memory` to `FLOCI_STORAGE_MODE: persistent` in `floci/docker-compose.yml`.

### Resources created automatically

On startup, Floci runs the scripts in `floci/init/ready.d/`. The project ships one that pre-creates:

| Resource | What it's for |
|---|---|
| Bucket `taskflow-pieces-jointes` | Task attachments (S3) |
| Queue `taskflow-traitements` | Long-running jobs (SQS) |
| Bucket `taskflow-tfstate` | Terraform state ([Module 6](06-terraform.md)) |

This is an important DevOps principle: **anything you do by hand more than twice should be scripted.**

---

## What Floci really does (and what it doesn't)

This is the most important section on this page. An emulator isn't magic, and knowing exactly where its limits are will save you hours of confusion.

### ✅ What behaves like real AWS

| Service | What you can do |
|---|---|
| **S3** | Create buckets, upload/read/delete files, generate presigned URLs |
| **SQS** | Create queues, send and receive messages |
| **DynamoDB** | Create tables, write and read items |
| **Lambda** | Deploy real Python code and actually execute it |
| **RDS** | Create a database: Floci starts a **real PostgreSQL** you connect to with `psql` |
| **EC2** | Launch an instance: Floci starts a **real Ubuntu container** you can **SSH** into |
| **VPC / Subnet / Security Group / Elastic IP** | Build a complete network |
| **IAM** | Create users, policies, roles |
| **CloudWatch Logs**, **Route 53**, **Secrets Manager**, **ECR**, **CloudFormation** | The common operations |
| **Terraform / OpenTofu** | `init`, `plan`, `apply`, `destroy`, and even **remote state on S3** |

### ❌ What doesn't work — and why

| Limitation | Explanation | What it means for you |
|---|---|---|
| **IAM permissions are not enforced** | Floci accepts **any** credentials and has no authorization engine. You can write a very restrictive policy and it will block nothing. | You learn IAM **syntax**, not its **effect**. You'll only meet real `AccessDenied` errors on real AWS. |
| **No web console** | AWS has a website with buttons; Floci only has an API. | You only practise on the command line. That's a real gap: interviewers sometimes ask you to describe the console. |
| **No billing, no quotas** | Nothing is metered or limited. | You don't learn to think in terms of cost — and that's a genuine DevOps skill. |
| **No access from the internet** | Your "EC2" has no publicly reachable IP. Its "public IP" is `127.0.0.1`, your own machine. | You can't show your app to somebody else. |
| **Docker doesn't run *inside* an emulated EC2 instance** | The emulated instance is already a container. Installing Docker in it works, but **running** a container fails (a nested storage limitation). | ⚠️ **The project's final deployment (`docker compose up` on the server) must be done on real AWS.** |
| **Coverage varies by service** | Floci is a young project (first public release March 2026). The main services are solid, the more exotic ones less so. | If a rare command fails, it isn't necessarily your fault. Check [the project repository](https://github.com/floci-io/floci). |

### The rule to remember

> **Floci is for learning and repeating. Real AWS is for validating.**
>
> Do all your experimenting on Floci — as often as you like, for free. Then do the final deployment **once** on real AWS, so you've genuinely done it and can talk about it in an interview.

---

## Troubleshooting

### `Could not connect to the endpoint URL: "http://localhost:4566/"`

Floci isn't running, or isn't ready yet.

```bash
cd ~/devops-project/floci
docker compose ps          # STATUS should be "Up (healthy)"
docker compose up -d       # if it isn't running
docker compose logs floci  # to see what's wrong
```

### `InvalidAccessKeyId ... does not exist in our records`

**Your command went to REAL AWS.** This is the endpoint trap described above.

- Did you type `aws` instead of `awslocal`?
- Is the alias loaded? Check with `alias awslocal` — it should print the definition. If not, run `source ~/.bashrc`.

### `Unable to locate credentials`

The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` variables aren't set.

```bash
echo $AWS_ACCESS_KEY_ID   # should print "test"
source ~/.bashrc          # if it's empty
```

### `Bind for 0.0.0.0:4566 failed: port is already allocated`

Another program is using port 4566 — most often an old Floci still running.

```bash
docker ps | grep 4566           # see what's holding the port
cd ~/devops-project/floci
docker compose down             # shut it down cleanly
```

### An EC2 instance or RDS database goes straight to `terminated` / fails

Floci can't reach Docker. Check the logs:

```bash
docker compose logs floci | grep -i "BindException\|Failed to launch"
```

If you see `java.net.BindException: Permission denied`, the `dockerproxy` service from `docker-compose.yml` didn't start. Check:

```bash
docker compose ps    # BOTH services must be running
docker compose up -d
```

### I SSH into my EC2 and get `Connection closed`

Two possible causes, in this order:

1. **The instance hasn't finished booting.** The Ubuntu image has no SSH server: Floci installs it at launch, which takes a good minute. `running` doesn't mean "ready". Wait and retry — exactly the same behaviour as on real AWS.
2. **The SSH server couldn't start.** It's missing a directory. The fix is in the UserData in [Module 5](05-aws.md) — check that you passed it with `--user-data`.

### I can't connect to my RDS database

The address returned by `describe-db-instances` is a **Docker-internal** address (like `172.x.x.x`), which means nothing from your machine. Use `localhost` with **the same port**:

```bash
awslocal rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].Endpoint' --output table
# Address: 172.25.0.3   Port: 7001
#          ^^^^^^^^^^ ignore the address, keep the PORT

psql -h localhost -p 7001 -U postgres
#       ^^^^^^^^^ always localhost from your machine
```

---

## Summary

```bash
# Start            cd ~/devops-project/floci && docker compose up -d
# Check            curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4566/health
# Use              awslocal s3 ls
# Reset            docker compose down && docker compose up -d
# Stop             docker compose down
```

| What to remember | |
|---|---|
| Floci's address | `http://localhost:4566` |
| From another container | `http://floci:4566` (never `localhost`) |
| Credentials | Any — we use `test` / `test` |
| The command | `awslocal` (= `aws --endpoint-url=http://localhost:4566`) |
| Your data | Erased on every `docker compose down` (that's intended) |
| What it doesn't replace | The real final deployment, the console, permissions, costs |

## Going further

- [Floci's official repository](https://github.com/floci-io/floci) — the full list of services and their support level
- [Floci's documentation](https://floci.io/) — there are also emulators for Azure, Google Cloud and Oracle Cloud
- [Testcontainers](https://testcontainers.com/) — the same idea taken further: automatically start the services your tests need, from the test code itself
