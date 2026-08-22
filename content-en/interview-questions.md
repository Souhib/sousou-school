# DevOps Interview Questions

This file is split into two parts:
1. **Quick definitions** — the classic "what is X" questions, so you don't blank out on the basics. Start here.
2. **Scenario-based questions** — real problems you'll be asked in interviews to see how you think

---

# Part 1: Definitions and technical questions

For each technology, the questions you'll be asked in interviews.

**How to use this section:**
1. Read the question and try to answer it yourself (out loud is best)
2. If you're stuck, open the **hint** — it gives you a lead without giving away the answer
3. Open the **answer** to compare with yours

## Git

**Q: What is Git?**
<details><summary>💡 Hint</summary>Think of a backup system, with a history and the ability to work as a team.</details>
<details><summary>✅ Answer</summary>A distributed version control system. It keeps a history of every code change and lets multiple people work together without stepping on each other's toes.</details>

**Q: Merge vs Rebase?**
<details><summary>💡 Hint</summary>Both are used to integrate changes from one branch into another. One preserves the history as-is, the other rewrites it.</details>
<details><summary>✅ Answer</summary>Merge preserves the history (creates a merge commit). Rebase rewrites it (linear history, cleaner, but more dangerous since you're rewriting commits).</details>

**Q: Pull vs Fetch?**
<details><summary>💡 Hint</summary>Both retrieve remote changes. One applies them directly, the other doesn't.</details>
<details><summary>✅ Answer</summary>Fetch downloads remote changes without applying them. Pull = fetch + merge. Pull applies them directly.</details>

**Q: A colleague and you modified the same line — what happens?**
<details><summary>💡 Hint</summary>Git can't decide on its own which version to keep.</details>
<details><summary>✅ Answer</summary>A merge conflict. Git shows you both versions, you choose which one to keep (or combine both), then you commit the resolution.</details>

**Q: What's your team's Git workflow?**
<details><summary>💡 Hint</summary>Think of the cycle: create a branch → work → push → request a review → merge.</details>
<details><summary>✅ Answer</summary>We create a branch per feature, commit on it, push, and open a Pull Request. A colleague reviews the code, and if it's good we merge into main. Nobody pushes directly to main — everything goes through a PR.</details>

**Q: What's the difference between `git add` and `git commit`?**
<details><summary>💡 Hint</summary>One prepares files, the other saves them. Think of a box you fill then seal.</details>
<details><summary>✅ Answer</summary><code>git add</code> stages files (staging area), <code>git commit</code> saves them in the history. It's like putting items in a box (add) then sealing and labeling the box (commit).</details>

**Q: What is a branch?**
<details><summary>💡 Hint</summary>Think of a parallel universe of the code where you can work without touching the main version.</details>
<details><summary>✅ Answer</summary>A parallel copy of the code. You develop on it without touching the main branch (main). When it's ready, you merge.</details>

**Q: What is a Pull Request?**
<details><summary>💡 Hint</summary>It's the mechanism to propose your changes to the team before integrating them into the main branch.</details>
<details><summary>✅ Answer</summary>A request to merge code. You create a branch, work on it, and when it's ready you open a PR on GitHub. A colleague reviews your code (code review), and if it's good, you merge into main. It ensures code is checked before it reaches production.</details>

## Linux

**Q: Explain the 755 permissions**
<details><summary>💡 Hint</summary>3 blocks of 3 permissions (read, write, execute) for 3 categories of people. Each permission has a numeric value.</details>
<details><summary>✅ Answer</summary>3 blocks (owner/group/others). read=4, write=2, execute=1. 755 = owner can do everything (7), group and others can read and execute (5).</details>

**Q: What is an environment variable?**
<details><summary>💡 Hint</summary>Think of a way to pass configuration to an application without putting it in the code.</details>
<details><summary>✅ Answer</summary>A value stored in the system, accessible by programs. Used to pass configuration (database URL, API keys, debug mode) without putting it in the code. <code>export MY_VAR="value"</code> to create one.</details>

**Q: A process is eating all the CPU — how do you find and kill it?**
<details><summary>💡 Hint</summary>There's a command to list processes sorted by consumption, and another to stop a process by its number (PID).</details>
<details><summary>✅ Answer</summary><code>top</code> or <code>ps aux</code> to find it (sort by CPU), <code>kill &lt;PID&gt;</code> to stop it, <code>kill -9 &lt;PID&gt;</code> if that's not enough.</details>

**Q: How do you check disk space on a server?**
<details><summary>💡 Hint</summary>A short command with a flag that makes the output human-readable.</details>
<details><summary>✅ Answer</summary><code>df -h</code> — shows used and available disk space on each partition. The <code>-h</code> = human-readable (GB, MB instead of bytes). A full disk is a frequent cause of production crashes.</details>

**Q: How do you see which process is listening on a port?**
<details><summary>💡 Hint</summary>The <code>ss</code> command with the right flags, combined with <code>grep</code> to filter.</details>
<details><summary>✅ Answer</summary><code>ss -tlnp | grep &lt;port&gt;</code> — shows the process listening on that port.</details>

**Q: What is sudo?**
<details><summary>💡 Hint</summary>Think "Run as administrator" on Windows.</details>
<details><summary>✅ Answer</summary>"Super User DO" — run a command as administrator (root). Needed to install software, modify system config, etc.</details>

**Q: Difference between `>` and `>>`?**
<details><summary>💡 Hint</summary>Both redirect command output to a file. One overwrites, the other doesn't.</details>
<details><summary>✅ Answer</summary><code>></code> overwrites the file. <code>>></code> appends to the end. Example: <code>echo "log" > file.txt</code> replaces the content, <code>echo "log" >> file.txt</code> adds a line.</details>

**Q: How do you view a service's logs?**
<details><summary>💡 Hint</summary>There's a specific command for systemd services, and a classic directory for system logs.</details>
<details><summary>✅ Answer</summary><code>journalctl -u service_name</code> for systemd services, or look in <code>/var/log/</code> for classic system logs.</details>

**Q: What is a process?**
<details><summary>💡 Hint</summary>Every program running on your machine is one. Each has a unique number.</details>
<details><summary>✅ Answer</summary>A program currently running. When you run <code>python3 main.py</code>, it creates a process. Each process has a unique number (PID). You can see them with <code>ps aux</code> or <code>top</code>.</details>

**Q: What is the PATH?**
<details><summary>💡 Hint</summary>It's what the system checks when you type a program name in the terminal. If the program isn't there...</details>
<details><summary>✅ Answer</summary>An environment variable containing the list of directories where the system looks for programs. When you type <code>python3</code>, Linux searches through PATH directories to find the file. If you get "command not found", it's often because the program isn't in the PATH.</details>

## Networking

**Q: What is an IP address?**
<details><summary>💡 Hint</summary>It's an identifier. There are two types depending on whether you're on the Internet or on a local network.</details>
<details><summary>✅ Answer</summary>An identifier for a machine on the network. Public = visible on the Internet. Private = visible only on the local network.</details>

**Q: What is a port?**
<details><summary>💡 Hint</summary>A machine can run multiple services (web, SSH, database). The port identifies which one.</details>
<details><summary>✅ Answer</summary>A number (1-65535) that identifies a service on a machine. 22=SSH, 80=HTTP, 443=HTTPS, 5432=PostgreSQL.</details>

**Q: What is DNS?**
<details><summary>💡 Hint</summary>Think of a phone book that translates something human-readable into something machine-readable.</details>
<details><summary>✅ Answer</summary>The system that translates domain names (google.com) into IP addresses. Without DNS, you'd have to remember the IP of every website.</details>

**Q: Difference between TCP and UDP?**
<details><summary>💡 Hint</summary>One is reliable but slower, the other is fast but doesn't verify anything. Think HTTP vs video streaming.</details>
<details><summary>✅ Answer</summary>TCP is reliable (verifies that data arrives in order). UDP is fast (no verification). HTTP uses TCP, video streaming often uses UDP.</details>

**Q: A user tells you "the site doesn't work" — where do you start?**
<details><summary>💡 Hint</summary>A command that gives you the HTTP response code. The code tells you what type of problem it is (network, proxy, code).</details>
<details><summary>✅ Answer</summary><code>curl</code> the site to see the response code (200, 502, timeout). If timeout → network/DNS problem. If 502 → the app behind the proxy is down. If 500 → bug in the code.</details>

**Q: What happens when you type a URL in your browser?**
<details><summary>💡 Hint</summary>5 steps: address resolution, request, server-side processing, response, rendering. Think DNS, HTTP, and the browser.</details>
<details><summary>✅ Answer</summary>1. <strong>DNS resolution</strong> — the browser asks a DNS to translate the domain name into an IP address. 2. <strong>Sending the request</strong> — the browser sends an HTTP request to the server. 3. <strong>Server-side processing</strong> — the server receives the request and prepares the response. 4. <strong>Server response</strong> — the server sends back the content (HTML/CSS/JS and data in JSON). 5. <strong>Rendering</strong> — the browser assembles and displays the page.</details>

**Q: What is a CIDR /24?**
<details><summary>💡 Hint</summary>It's a notation to describe a subnet. The number after / indicates how many IP addresses are available.</details>
<details><summary>✅ Answer</summary>A subnet of 256 IP addresses. Example: 10.0.1.0/24 = 10.0.1.0 to 10.0.1.255. The higher the number after /, the fewer addresses.</details>

**Q: What is a firewall?**
<details><summary>💡 Hint</summary>Think of a bouncer controlling who enters and exits a building.</details>
<details><summary>✅ Answer</summary>A filter that controls incoming and outgoing network traffic. It allows or blocks traffic based on rules (port, source IP, protocol). On Linux, <code>ufw</code> is a simple tool to configure the firewall.</details>

**Q: What does a 502 code mean?**
<details><summary>💡 Hint</summary>It's a proxy problem — the server receiving your request can't reach the server behind it.</details>
<details><summary>✅ Answer</summary>Bad Gateway — the proxy/load balancer server can't reach the application server behind it. Common cause: the application has crashed.</details>

**Q: Difference between HTTP and HTTPS?**
<details><summary>💡 Hint</summary>The S stands for "Secure". Think of the padlock in the browser's address bar.</details>
<details><summary>✅ Answer</summary>HTTPS = HTTP + encryption (TLS/SSL). Data is encrypted between your browser and the server — nobody can read it in transit. The padlock in the browser = HTTPS. Today, every serious site must use HTTPS.</details>

**Q: What is a reverse proxy?**
<details><summary>💡 Hint</summary>It's an intermediate server between users and your application. It can do several useful things (traffic distribution, HTTPS, caching).</details>
<details><summary>✅ Answer</summary>A server that sits in front of your application and receives requests on its behalf. It can distribute traffic between multiple servers, handle HTTPS, cache content, etc. Nginx is the most common reverse proxy.</details>

**Q: What is a load balancer?**
<details><summary>💡 Hint</summary>If you have multiple servers, how do you distribute requests between them?</details>
<details><summary>✅ Answer</summary>A tool that distributes traffic across multiple servers. If you have 3 backend servers, the load balancer sends each request to a different server to spread the load. If a server goes down, the load balancer stops sending traffic to it.</details>

## Docker

**Q: Difference between image and container?**
<details><summary>💡 Hint</summary>Think of a recipe vs a cooked dish. One is a template, the other is a running instance.</details>
<details><summary>✅ Answer</summary>Image = read-only template (the recipe). Container = running instance (the cooked dish). One image can create multiple containers.</details>

**Q: What is a Dockerfile?**
<details><summary>💡 Hint</summary>A text file with instructions. Think of the keywords: FROM, COPY, RUN, CMD.</details>
<details><summary>✅ Answer</summary>A text file that describes step by step how to build a Docker image. FROM for the base, COPY for files, RUN for commands, CMD for the startup command.</details>

**Q: A container keeps crashing in a loop — how do you debug it?**
<details><summary>💡 Hint</summary>The first thing is always the logs. If the container isn't running anymore, there's a way to launch the image with a shell instead of the app.</details>
<details><summary>✅ Answer</summary><code>docker logs &lt;container&gt;</code> to read the logs. If the container isn't running anymore, <code>docker run -it --entrypoint bash &lt;image&gt;</code> to get inside and investigate manually.</details>

**Q: Why use a multi-stage build?**
<details><summary>💡 Hint</summary>The goal is the final image size. You separate the build phase and the runtime phase.</details>
<details><summary>✅ Answer</summary>To reduce the final image size. You build in a heavy image (with build tools), then copy only the result into a lightweight image. The frontend goes from 500 MB to 20 MB.</details>

**Q: How do containers communicate with each other in Docker Compose?**
<details><summary>💡 Hint</summary>Docker Compose automatically creates something that lets containers find each other by their service name.</details>
<details><summary>✅ Answer</summary>Via an internal network created automatically. Each container is accessible by its service name (e.g.: <code>backend:8000</code>, <code>db:5432</code>). It's service discovery through internal DNS.</details>

**Q: Difference between CMD and ENTRYPOINT?**
<details><summary>💡 Hint</summary>One can be overridden at launch, the other can't. Which one is used 90% of the time?</details>
<details><summary>✅ Answer</summary>CMD = default command, can be overridden at launch. ENTRYPOINT = fixed command, arguments from <code>docker run</code> are appended after it. In practice, CMD is enough 90% of the time.</details>

**Q: What is Docker?**
<details><summary>💡 Hint</summary>Think of a way to package an application with everything it needs to run the same way everywhere.</details>
<details><summary>✅ Answer</summary>A tool that packages an application with all its dependencies into an isolated container. The container runs the same way everywhere (your PC, a server, the cloud).</details>

**Q: What is Docker Compose?**
<details><summary>💡 Hint</summary>When you have multiple containers (backend, frontend, database), you need a tool to manage them together.</details>
<details><summary>✅ Answer</summary>A tool for managing multiple containers together with a YAML file. You define services, networks, and volumes, then <code>docker compose up</code> launches everything at once.</details>

**Q: What is a Docker volume?**
<details><summary>💡 Hint</summary>By default, container data disappears when it's deleted. How do you persist data?</details>
<details><summary>✅ Answer</summary>Persistent storage. Without a volume, data disappears when the container is deleted. Essential for databases — data survives container restarts.</details>

**Q: Difference between COPY and ADD in a Dockerfile?**
<details><summary>💡 Hint</summary>Both copy files. One does more than the other — but is that always desirable?</details>
<details><summary>✅ Answer</summary>Both copy files into the image. <code>COPY</code> does a simple copy. <code>ADD</code> can also decompress archives (.tar.gz) and download from URLs. In practice, always use <code>COPY</code> — it's more explicit.</details>

**Q: What is a Docker registry?**
<details><summary>💡 Hint</summary>Think of GitHub, but for Docker images instead of source code.</details>
<details><summary>✅ Answer</summary>A server that stores Docker images. Docker Hub is the default public registry. In the workplace, private registries (AWS ECR, GitHub Container Registry) are often used to store your own images.</details>

**Q: Why does the order of instructions in a Dockerfile matter?**
<details><summary>💡 Hint</summary>Docker uses a layer caching system. If a layer changes, all subsequent layers are rebuilt.</details>
<details><summary>✅ Answer</summary>Because of caching. Docker executes each instruction as a layer. If a layer hasn't changed, Docker reuses the cache. By putting <code>COPY requirements.txt</code> + <code>RUN pip install</code> BEFORE <code>COPY . .</code>, dependencies are only reinstalled when they actually change — not on every code modification.</details>

## CI/CD

**Q: What is CI/CD?**
<details><summary>💡 Hint</summary>CI = before deployment (verify). CD = the deployment itself (deliver).</details>
<details><summary>✅ Answer</summary>CI = automatic verification on every push (lint, tests). CD = automatic (or semi-automatic) deployment. The goal: detect bugs as early as possible and deploy with confidence.</details>

**Q: What is "fail fast"?**
<details><summary>💡 Hint</summary>If a quick step fails, do you still run the long steps?</details>
<details><summary>✅ Answer</summary>If lint fails, you don't run the tests. If tests fail, you don't build. You stop as soon as a problem is detected to avoid wasting time.</details>

**Q: Where do you put secrets in a pipeline?**
<details><summary>💡 Hint</summary>Never in the code, never in the committed YAML. There's a dedicated place in GitHub/GitLab for that.</details>
<details><summary>✅ Answer</summary>In the CI secrets (GitHub Secrets, GitLab Variables). They're injected at runtime and never appear in the logs.</details>

**Q: A test passes locally but fails in CI — why?**
<details><summary>💡 Hint</summary>Think about the differences between your machine and the CI runner: versions, environment variables, available services.</details>
<details><summary>✅ Answer</summary>Often an environment difference: different Python/Node version, missing environment variable, dependency not installed, or the test depends on a service (DB) that doesn't exist in CI.</details>

**Q: How do you rollback if a deployment breaks production?**
<details><summary>💡 Hint</summary>Docker images are tagged with the commit hash. How do you use that to go back?</details>
<details><summary>✅ Answer</summary>You redeploy the previous Docker image. That's why we tag images with the commit hash — you can go back to any version in a few minutes.</details>

**Q: What are the stages of a typical CI/CD pipeline?**
<details><summary>💡 Hint</summary>4 stages in order. If the first fails, the next ones don't run.</details>
<details><summary>✅ Answer</summary>Lint (code quality) → Tests → Build (artifact construction) → Deploy. Each stage blocks the next if it fails.</details>

**Q: Difference between Continuous Delivery and Continuous Deployment?**
<details><summary>💡 Hint</summary>Both start with "Continuous D...". The difference: does a human press a button before prod?</details>
<details><summary>✅ Answer</summary>Delivery = ready to deploy but manual button. Deployment = automatic deployment to prod. Most companies do Delivery (a human validates before prod).</details>

**Q: What is a runner?**
<details><summary>💡 Hint</summary>The pipeline doesn't execute itself in a vacuum — it needs a machine to run on.</details>
<details><summary>✅ Answer</summary>The machine (server) that executes pipeline jobs. GitHub provides free runners (<code>ubuntu-latest</code>). You can also use self-hosted runners for more control.</details>

**Q: What is a blue/green deployment?**
<details><summary>💡 Hint</summary>Two identical environments. One serves prod, the other waits for the new version. You switch traffic all at once.</details>
<details><summary>✅ Answer</summary>A deployment strategy with two identical environments. "Blue" serves prod, you deploy the new version to "green", test it, then switch the traffic. If it breaks, you switch back in seconds. Advantage: instant rollback.</details>

**Q: What is a canary deployment?**
<details><summary>💡 Hint</summary>Instead of deploying to everyone at once, you start with a small percentage. The name comes from canaries in coal mines.</details>
<details><summary>✅ Answer</summary>You deploy the new version to a small percentage of servers (e.g., 5%). You monitor the metrics. If everything's fine, you gradually increase (25% → 50% → 100%). If it breaks, only 5% of users are impacted.</details>

**Q: How do you test code that talks to AWS?**
<details><summary>💡 Hint</summary>Three levels: the logic alone, integration against a fake AWS, then validation on a real environment.</details>
<details><summary>✅ Answer</summary>On three levels. <b>1) Unit tests</b>: the business logic, without calling AWS — fast, they run continuously. <b>2) Integration tests against an emulator</b> (Floci, LocalStack, Testcontainers, or <code>moto</code> in Python): you run a fake AWS in CI and the code makes real API calls. That catches parameter mistakes a mock would never see, with no cost and no AWS secrets in the pipeline. <b>3) Validation on a real staging environment</b> before production, because an emulator enforces neither IAM permissions nor quotas.</details>

**Q: Why not just use a real AWS test account for CI?**
<details><summary>💡 Hint</summary>Think about cost, secrets, and what happens when two pipelines run at once.</details>
<details><summary>✅ Answer</summary>Four reasons. <b>Cost</b>: every run creates real resources. <b>Security</b>: you must store real AWS keys in the CI, which become a target. <b>Isolation</b>: two pipelines running in parallel collide (same bucket name, same table). <b>Speed</b>: creating a real RDS takes minutes, an emulator takes seconds. You keep the real account for a staging environment, not for every commit.</details>

**Q: What is a service container in GitHub Actions?**
<details><summary>💡 Hint</summary>A container GitHub starts alongside your steps, for the duration of the job.</details>
<details><summary>✅ Answer</summary>A container started by GitHub before the job's steps and stopped afterwards, reachable on <code>localhost</code>. It's used to give tests a real database, a Redis, or an AWS emulator. Crucially, you must define a <b>health check</b> (<code>--health-cmd</code>), otherwise the tests start before the service answers and fail at random — what's called a <i>flaky</i> test.</details>

**Q: What is a flaky test, and why does it matter?**
<details><summary>💡 Hint</summary>A test that doesn't always give the same result on the same code.</details>
<details><summary>✅ Answer</summary>A test that passes or fails randomly without the code changing. Classic causes: a dependency that isn't ready yet (no health check), tests sharing data, or a dependency on execution order. It matters because the team gets used to re-running the pipeline without looking — and the day the test fails for a real reason, nobody notices.</details>

## AWS

### EC2

**Q: What is EC2?**
<details><summary>💡 Hint</summary>Think of renting a computer instead of buying one.</details>
<details><summary>✅ Answer</summary>A virtual server in the cloud. You choose the power (CPU, RAM), the OS, and you pay by the hour.</details>

**Q: How do you connect to an EC2?**
<details><summary>💡 Hint</summary>A remote connection protocol + a key file downloaded when the instance was created.</details>
<details><summary>✅ Answer</summary>Via SSH with a key pair: <code>ssh -i ~/devops-key.pem ubuntu@PUBLIC_IP</code>. The .pem key is downloaded when the instance is created.</details>

**Q: Your EC2 is unresponsive — what are the first things you check?**
<details><summary>💡 Hint</summary>3 things: the instance itself (is it running?), the network (is the port open?), and the address (does it have a public IP?).</details>
<details><summary>✅ Answer</summary>1. Is the instance "Running" in the AWS console? 2. Does the Security Group allow SSH (22) and HTTP (80) ports? 3. Does the instance have a public IP? 4. If everything looks fine on the AWS side, SSH in and check the app logs.</details>

### Practising and testing AWS

**Q: What is an AWS emulator, and when do you use one?**
<details><summary>💡 Hint</summary>A local program that answers like AWS, with no account and no bill.</details>
<details><summary>✅ Answer</summary>Software that runs on your machine and implements the same APIs as AWS. Your SDK, the AWS CLI and Terraform talk to it unmodified — you only change the <i>endpoint</i>. It's used for local development and for integration tests in CI: no account, no cost, no secrets, and a fresh environment on every run. Common tools: Floci (the open-source successor to LocalStack, whose free edition was discontinued in 2026), Testcontainers, and <code>moto</code> for Python.</details>

**Q: What are the limits of an AWS emulator?**
<details><summary>💡 Hint</summary>It imitates the APIs, not everything else.</details>
<details><summary>✅ Answer</summary>Mainly: <b>IAM permissions are not enforced</b> (it accepts any credentials, so you never actually test your policies), <b>no billing and no quotas</b>, <b>no real network latency</b>, and <b>partial coverage</b> that varies by service. That's why an emulator doesn't replace a real staging environment: it validates that you call the APIs correctly, not that it will work in production.</details>

**Q: What is the address 169.254.169.254 for?**
<details><summary>💡 Hint</summary>A special address, reachable only from inside an EC2 instance.</details>
<details><summary>✅ Answer</summary>It's the IMDS (Instance Metadata Service): the service every EC2 instance queries to learn about itself (its id, region, type). Its most important use is supplying <b>the temporary credentials of the IAM role attached to the instance</b>. That's what lets an application read an S3 bucket without any key written in the code or on disk — the right answer to "how do you handle AWS secrets on a server?".</details>

### VPC and Networking

**Q: What is a VPC?**
<details><summary>💡 Hint</summary>It's your private network in AWS. You put your resources in it and control who can access what.</details>
<details><summary>✅ Answer</summary>Virtual Private Cloud — an isolated network in AWS. You put your resources in it (EC2, RDS). You control the subnets, routing, and access.</details>

**Q: Difference between public and private subnet?**
<details><summary>💡 Hint</summary>One is accessible from the Internet, the other isn't. Think about where you'd put a web server vs a database.</details>
<details><summary>✅ Answer</summary>Public = accessible from the Internet (via Internet Gateway). Private = no direct Internet access. You put web servers in public, databases in private.</details>

**Q: What is a Security Group?**
<details><summary>💡 Hint</summary>It's like a firewall. It controls traffic by port and source. It's "stateful" — what does that mean?</details>
<details><summary>✅ Answer</summary>A virtual firewall attached to an instance. It filters inbound (ingress) and outbound (egress) traffic by port and source IP. "Stateful" = if you allow inbound traffic on a port, the outbound response is automatically allowed.</details>

**Q: What is an Internet Gateway?**
<details><summary>💡 Hint</summary>Without it, your VPC is completely isolated from the Internet. It's the door between your private network and the outside world.</details>
<details><summary>✅ Answer</summary>The door that connects your VPC to the Internet. Without an Internet Gateway, no resource in the VPC can access the Internet (and nobody can access it from the Internet).</details>

### RDS

**Q: Why use RDS instead of installing PostgreSQL on an EC2?**
<details><summary>💡 Hint</summary>Think about everything you DON'T have to manage with RDS: backups, updates, high availability.</details>
<details><summary>✅ Answer</summary>RDS handles automatic backups, security updates, replication and high availability. You don't have to maintain the database server yourself. The extra cost is offset by the time saved.</details>

**Q: What is Multi-AZ on RDS?**
<details><summary>💡 Hint</summary>Your database is copied to a 2nd location. If the first one goes down...</details>
<details><summary>✅ Answer</summary>Your database is automatically replicated to a 2nd datacenter (Availability Zone). If the first one fails, the 2nd takes over automatically. That's high availability.</details>

**Q: How do you protect your database on AWS?**
<details><summary>💡 Hint</summary>Think about the subnet (where it's placed) and the Security Group (who's allowed to connect to it).</details>
<details><summary>✅ Answer</summary>You put it in a private subnet (no public IP), with a Security Group that only allows port 5432 from the EC2's Security Group. Never direct access from the Internet.</details>

### S3

**Q: What is S3?**
<details><summary>💡 Hint</summary>File storage in the cloud. Unlimited, high durability, cheap.</details>
<details><summary>✅ Answer</summary>Simple Storage Service — unlimited object (file) storage in the cloud. Used for backups, static files (images, CSS, JS from a frontend), logs, data exports.</details>

**Q: How do you secure an S3 bucket?**
<details><summary>💡 Hint</summary>By default a bucket is private. The danger is making it public by mistake.</details>
<details><summary>✅ Answer</summary>By default, an S3 bucket is private (that's good). You verify that "Block all public access" is enabled. You control access via bucket policies and IAM roles. Never public access unless for intentionally public static content (frontend).</details>

### IAM

**Q: What is IAM?**
<details><summary>💡 Hint</summary>AWS's permission system. Who is allowed to do what.</details>
<details><summary>✅ Answer</summary>Identity and Access Management. Manages users (Users), roles (Roles) and permissions (Policies). The key principle: least privilege — only grant the permissions that are strictly necessary.</details>

**Q: User vs Role — what's the difference?**
<details><summary>💡 Hint</summary>One is permanent (a person or a program), the other is temporary (you "assume" it when needed).</details>
<details><summary>✅ Answer</summary>User = a permanent account for a person or a program (with fixed credentials). Role = a set of temporary permissions that a service can "assume" (e.g.: an EC2 that needs to access S3 uses a role, not a user).</details>

**Q: What is an IAM Policy?**
<details><summary>💡 Hint</summary>Think of the document that describes permissions. It's in JSON format.</details>
<details><summary>✅ Answer</summary>A JSON document that defines permissions: which actions (e.g.: <code>s3:GetObject</code>) are allowed or denied, on which resources (e.g.: a specific bucket). You attach it to a User, Group or Role to grant these rights.</details>

**Q: What is the principle of least privilege?**
<details><summary>💡 Hint</summary>A fundamental security rule: you grant the minimum permissions needed, nothing more.</details>
<details><summary>✅ Answer</summary>Grant only the permissions strictly necessary to do the job, and nothing more. If a Lambda only needs to read an S3 bucket, you give it only <code>s3:GetObject</code> on that specific bucket — not <code>AdministratorAccess</code>. This limits the damage if credentials are compromised.</details>

### Lambda and SQS

**Q: When to use Lambda vs EC2?**
<details><summary>💡 Hint</summary>Think about execution duration and frequency. One runs 24/7, the other runs on demand.</details>
<details><summary>✅ Answer</summary>Lambda = short tasks (&lt;15 min), occasional, with automatic scaling (webhooks, file processing). EC2 = applications running continuously 24/7 (web API, server). With Lambda you pay per execution, with EC2 you pay by the hour even when idle.</details>

**Q: What is SQS and why is it useful?**
<details><summary>💡 Hint</summary>Think of a queue. Instead of processing messages directly (and risking losing them if it crashes), you put them in...</details>
<details><summary>✅ Answer</summary>Simple Queue Service — a managed message queue. You put messages in, another program consumes them. If the consumer crashes, the message stays in the queue and will be reprocessed. Useful for decoupling services, absorbing traffic spikes, and never losing data.</details>

### ECS and EKS

**Q: What's the difference between ECS and EKS?**
<details><summary>💡 Hint</summary>Both run containers on AWS. One is AWS-specific and simpler, the other is a portable standard.</details>
<details><summary>✅ Answer</summary>ECS = AWS-specific container orchestration (simpler, no control plane fees). EKS = managed Kubernetes (standard, multi-cloud portable, but more complex and more expensive ~$75/month base).</details>

**Q: What is Fargate?**
<details><summary>💡 Hint</summary>An ECS mode where you don't manage any servers. You just provide your Docker image and the amount of CPU/RAM.</details>
<details><summary>✅ Answer</summary>A "serverless" mode for ECS — you provide your Docker image, define CPU and RAM, AWS launches the container somewhere in the cloud. You never see a machine, you don't manage any servers. You only pay for the CPU/RAM used.</details>

**Q: What is AWS?**
<details><summary>💡 Hint</summary>The world's largest cloud provider. You rent computing resources instead of buying them.</details>
<details><summary>✅ Answer</summary>A cloud computing provider. You rent servers (EC2), storage (S3), databases (RDS) and many other services, on demand. You pay for what you use.</details>

**Q: What is RDS?**
<details><summary>💡 Hint</summary>Think of a database where AWS handles all the maintenance for you.</details>
<details><summary>✅ Answer</summary>Relational Database Service — a managed database by AWS. You choose the engine (PostgreSQL, MySQL...), AWS handles backups, updates, and high availability.</details>

**Q: What is DynamoDB?**
<details><summary>💡 Hint</summary>AWS's NoSQL alternative. Instead of SQL tables with fixed columns, you store...</details>
<details><summary>✅ Answer</summary>A NoSQL managed database by AWS. Instead of SQL tables with fixed columns, you store flexible JSON documents. Scaling is automatic and pricing is per-request.</details>

**Q: When to use RDS vs DynamoDB?**
<details><summary>💡 Hint</summary>Think about the data type: does it have relationships (users → orders → products)?</details>
<details><summary>✅ Answer</summary>RDS when your data has relationships and you need complex SQL queries. DynamoDB for simple data at very high traffic (sessions, cache, counters). When in doubt, RDS — it's more versatile.</details>

**Q: What is ECS?**
<details><summary>💡 Hint</summary>You give it Docker images, it runs, monitors and scales them. With Fargate, you don't even manage servers.</details>
<details><summary>✅ Answer</summary>Elastic Container Service — you give AWS your Docker images, and it runs, monitors and scales them. With Fargate, you manage no servers — you pay only for CPU and RAM used.</details>

**Q: What is EKS?**
<details><summary>💡 Hint</summary>Managed Kubernetes on AWS. AWS manages one part, you manage the other. The advantage is portability.</details>
<details><summary>✅ Answer</summary>Elastic Kubernetes Service — managed Kubernetes on AWS. AWS manages the control plane, you manage the workers. Advantage over ECS: K8s is a standard portable across any cloud.</details>

**Q: What is Lambda?**
<details><summary>💡 Hint</summary>Code that runs without a server. You only pay when your code runs.</details>
<details><summary>✅ Answer</summary>Serverless — you send your code, AWS runs it when needed, you pay per execution. No server to manage. Ideal for short, one-off tasks (&lt;15 min).</details>

**Q: When to use Lambda vs EC2 vs ECS?**
<details><summary>💡 Hint</summary>Think about execution duration and whether the app needs to run continuously or not.</details>
<details><summary>✅ Answer</summary>Lambda for short tasks (&lt;15 min) and one-off. ECS/EKS for containerized apps running continuously with auto-scaling. EC2 when you need full server control or for small simple projects.</details>

**Q: What is a cold start?**
<details><summary>💡 Hint</summary>The first Lambda execution is slower. Why?</details>
<details><summary>✅ Answer</summary>The first Lambda execution is slower because AWS has to start an environment. Subsequent executions (warm start) are faster because the environment is already ready.</details>

**Q: Difference between horizontal and vertical scaling?**
<details><summary>💡 Hint</summary>One adds power to a machine, the other adds machines. Which one has a physical limit?</details>
<details><summary>✅ Answer</summary>Vertical = increase the power of a machine (more CPU, more RAM). Horizontal = add more machines. Vertical has a physical limit, horizontal is virtually unlimited. In the cloud, horizontal scaling is preferred.</details>

**Q: What is the shared responsibility model?**
<details><summary>💡 Hint</summary>AWS and you each have a share of responsibility for security. Who manages what?</details>
<details><summary>✅ Answer</summary>AWS manages security <strong>of</strong> the cloud (datacenters, physical network, hypervisors). You manage security <strong>in</strong> the cloud (your data, your Security Groups, your IAM policies, your code). If your Security Group is open to everyone, that's your fault, not AWS's.</details>

## Terraform

**Q: What is Infrastructure as Code?**
<details><summary>💡 Hint</summary>Instead of clicking in a console to create servers, you do what?</details>
<details><summary>✅ Answer</summary>Describe your infrastructure in code files instead of clicking in a console. Reproducible, versioned in Git, auditable, shareable.</details>

**Q: Explain plan, apply, destroy**
<details><summary>💡 Hint</summary>Three steps: preview, execute, delete. Which one do you always do first?</details>
<details><summary>✅ Answer</summary><code>plan</code> shows what will change without doing anything. <code>apply</code> executes the changes. <code>destroy</code> deletes everything. You always run plan before apply to verify.</details>

**Q: What is the state file and why is it important?**
<details><summary>💡 Hint</summary>Terraform needs to know what CURRENTLY exists to compare with what you want. It stores that in a file.</details>
<details><summary>✅ Answer</summary>A JSON file that records the current state of the infrastructure. Terraform compares it with your code to know what to create/modify/delete. Never edit it by hand, never commit it (it can contain secrets).</details>

**Q: How do you interact with a resource that already exists on AWS but not in your Terraform?**
<details><summary>💡 Hint</summary>There's a keyword different from <code>resource</code> that FETCHES information instead of CREATING something.</details>
<details><summary>✅ Answer</summary>With a <code>data</code> block. Unlike <code>resource</code> which creates something, <code>data</code> fetches information that already exists (an AMI, a VPC, an existing Security Group).</details>

**Q: Someone modified the infrastructure by hand in the AWS console — what happens?**
<details><summary>💡 Hint</summary>The state file no longer matches reality. Terraform will detect the difference on the next <code>plan</code>. What is that called?</details>
<details><summary>✅ Answer</summary>That's drift. On the next <code>terraform plan</code>, Terraform shows the differences between the code and reality. Either you import the change into the code, or <code>apply</code> overwrites the manual change.</details>

**Q: What is Terraform?**
<details><summary>💡 Hint</summary>A tool for describing your infrastructure in code files instead of clicking in a console.</details>
<details><summary>✅ Answer</summary>An Infrastructure as Code tool. You describe your infra in HCL files, Terraform creates/modifies/deletes it. Versionable, reproducible, collaborative.</details>

**Q: Terraform vs CloudFormation?**
<details><summary>💡 Hint</summary>One is multi-cloud, the other is specific to a single cloud provider.</details>
<details><summary>✅ Answer</summary>Terraform is multi-cloud (AWS, GCP, Azure). CloudFormation is AWS-specific. Terraform has a larger community and more readable syntax.</details>

**Q: What is a Terraform module?**
<details><summary>💡 Hint</summary>Think of a function in programming — reusable code you call with parameters.</details>
<details><summary>✅ Answer</summary>A reusable block of Terraform code. Instead of copy-pasting the same config for each environment, you create a module and call it with different parameters. It's like a function in programming.</details>

**Q: What is a Terraform provider?**
<details><summary>💡 Hint</summary>Terraform alone can't do anything. It needs plugins to talk to AWS, GCP, etc.</details>
<details><summary>✅ Answer</summary>A plugin that connects Terraform to a service (AWS, GCP, Azure, GitHub...). The AWS provider allows Terraform to create EC2s, S3 buckets, RDS instances. Without a provider, Terraform can't talk to anything.</details>

**Q: How do you test Terraform code before applying it in production?**
<details><summary>💡 Hint</summary>Several safety nets, from cheapest to most expensive.</details>
<details><summary>✅ Answer</summary>In order: <b>1)</b> <code>terraform fmt</code> and <code>terraform validate</code> for syntax; <b>2)</b> <code>terraform plan</code>, which you actually <b>read</b> — that's the main safety net, and it should be posted automatically on the pull request; <b>3)</b> an <code>apply</code> against a local AWS emulator or an ephemeral dev environment, to check it really creates; <b>4)</b> static analysis tools like <code>tfsec</code> or <code>checkov</code> for security flaws (public bucket, port open to 0.0.0.0/0); <b>5)</b> an apply on staging before production. The non-negotiable point: <b>never apply a plan you haven't read</b>.</details>

## Ansible

**Q: What is Ansible?**
<details><summary>💡 Hint</summary>A server configuration tool. The keyword is "agentless" — it doesn't need to install anything on the target server.</details>
<details><summary>✅ Answer</summary>A configuration management tool. Configures servers in an automated way, agentless (connects via SSH, no need to install anything on the target server).</details>

**Q: Ansible vs Terraform?**
<details><summary>💡 Hint</summary>One creates the infrastructure, the other configures what runs on it. Think "building the house" vs "furnishing it".</details>
<details><summary>✅ Answer</summary>Terraform creates the infrastructure (the server exists). Ansible configures what runs on it (installs Docker, copies files, launches the app). Terraform builds the house, Ansible furnishes it.</details>

**Q: What is idempotence?**
<details><summary>💡 Hint</summary>What happens if you run the same playbook 10 times in a row?</details>
<details><summary>✅ Answer</summary>Running a playbook multiple times always gives the same result. If Docker is already installed, Ansible doesn't reinstall it. That's what makes it safe to re-run.</details>

**Q: What is a playbook?**
<details><summary>💡 Hint</summary>It's a file in a format you know well (used everywhere in DevOps). It describes tasks to execute.</details>
<details><summary>✅ Answer</summary>A YAML file that describes tasks to execute on servers. Each task uses a module (apt, copy, service) and is named for readability.</details>

**Q: How do you manage secrets in Ansible?**
<details><summary>💡 Hint</summary>Ansible has a built-in tool to encrypt files. Its name makes you think of a safe.</details>
<details><summary>✅ Answer</summary>With Ansible Vault. You encrypt files containing secrets, and at execution time you pass <code>--ask-vault-pass</code> to decrypt them.</details>

**Q: What is an Ansible inventory?**
<details><summary>💡 Hint</summary>Ansible needs to know which machines to act on. There's a file for that.</details>
<details><summary>✅ Answer</summary>The file that lists the servers Ansible will act on. It contains IP addresses or hostnames, organized in groups (web, db, etc.). Ansible connects via SSH to each machine in the inventory to execute tasks.</details>

**Q: What is an Ansible role?**
<details><summary>💡 Hint</summary>When your playbook grows, you need to organize it into reusable components.</details>
<details><summary>✅ Answer</summary>A way to organize a playbook into reusable components. A role bundles tasks, files, templates, and variables related to a function (e.g., a "docker" role that installs and configures Docker). You can reuse the same role across multiple playbooks.</details>

## Kubernetes

**Q: What is Kubernetes?**
<details><summary>💡 Hint</summary>Think of an orchestra conductor for containers. It manages 3 main things: deployment, scaling, and...</details>
<details><summary>✅ Answer</summary>A container orchestrator. It manages the deployment, scaling and high availability of your containers on a cluster of machines.</details>

**Q: What is a Pod?**
<details><summary>💡 Hint</summary>It's the basic unit. Most of the time, 1 pod = 1 container.</details>
<details><summary>✅ Answer</summary>The basic unit of K8s. 1 pod ≈ 1 container. Kubernetes doesn't manage containers directly — it manages pods.</details>

**Q: A pod crashes — what does Kubernetes do?**
<details><summary>💡 Hint</summary>K8s maintains the number of replicas defined in the Deployment. If one is missing, it...</details>
<details><summary>✅ Answer</summary>The Deployment detects that a pod is missing and automatically recreates one. That's self-healing. That's why you never create pods directly — you go through a Deployment.</details>

**Q: What's the difference between port and targetPort in a Service?**
<details><summary>💡 Hint</summary>One is the "entry" port of the Service, the other is the port the container actually listens on. They can be different.</details>
<details><summary>✅ Answer</summary><code>port</code> = the port to access the Service (from inside the cluster). <code>targetPort</code> = the port on the container that traffic is redirected to. Often the same, but you could map port 80 of the Service to port 8000 of the container.</details>

**Q: How do you update an app without downtime on K8s?**
<details><summary>💡 Hint</summary>K8s replaces pods one by one, not all at once. It waits for the new one to be ready before deleting the old one. What is that called?</details>
<details><summary>✅ Answer</summary>Rolling update (the default). Kubernetes creates a new pod with the new version, waits for it to be ready (health check), then deletes the old one. Pods are replaced one by one — users don't see any downtime.</details>

**Q: Difference between Docker and Kubernetes?**
<details><summary>💡 Hint</summary>One runs ONE container, the other orchestrates dozens/hundreds across multiple machines.</details>
<details><summary>✅ Answer</summary>Docker runs ONE container. Kubernetes orchestrates dozens/hundreds of containers across multiple machines (scheduling, scaling, self-healing).</details>

**Q: What is a Deployment?**
<details><summary>💡 Hint</summary>You never create pods directly. You go through an object that manages them for you.</details>
<details><summary>✅ Answer</summary>An object that manages a group of identical pods. It maintains the desired replica count, manages updates (rolling update), and recreates crashed pods.</details>

**Q: What is a K8s Service?**
<details><summary>💡 Hint</summary>Pods have IPs that change on every restart. You need a stable access point.</details>
<details><summary>✅ Answer</summary>A stable network access point to a group of pods. Pods have ephemeral IPs, the Service has a fixed IP and distributes traffic across the pods.</details>

**Q: What is a Namespace?**
<details><summary>💡 Hint</summary>Think of folders to organize and isolate resources in a cluster.</details>
<details><summary>✅ Answer</summary>A way to isolate resources in a cluster. Useful for separating environments (dev, staging, prod) or teams.</details>

**Q: What is an Ingress?**
<details><summary>💡 Hint</summary>How do you make external HTTP requests reach the right Services inside the cluster?</details>
<details><summary>✅ Answer</summary>A K8s object that manages HTTP(S) routing to Services. It lets you say "requests to <code>api.mysite.com</code> go to the backend Service" and "requests to <code>mysite.com</code> go to the frontend Service". It's the HTTP entry point of the cluster.</details>

**Q: What is a ConfigMap and a Secret?**
<details><summary>💡 Hint</summary>How do you pass configuration and secrets to your pods without putting them in the Docker image?</details>
<details><summary>✅ Answer</summary>K8s objects for storing configuration. A <strong>ConfigMap</strong> stores non-sensitive data (URLs, feature flags). A <strong>Secret</strong> stores sensitive data (passwords, API keys) encoded in base64. Both are injected into pods as environment variables or files.</details>

**Q: What is a liveness probe and a readiness probe?**
<details><summary>💡 Hint</summary>K8s needs to know if your pods are alive and ready. It uses two different types of checks.</details>
<details><summary>✅ Answer</summary>Health checks that K8s runs on your pods. The <strong>liveness probe</strong> checks if the pod is alive — if it fails, K8s restarts the pod. The <strong>readiness probe</strong> checks if the pod is ready for traffic — if it fails, K8s stops sending requests without restarting it.</details>

**Q: Difference between ClusterIP, NodePort, and LoadBalancer?**
<details><summary>💡 Hint</summary>These are the three K8s Service types. Each exposes the Service at a different level of accessibility.</details>
<details><summary>✅ Answer</summary>Three K8s Service types. <strong>ClusterIP</strong> (default) = accessible only from inside the cluster. <strong>NodePort</strong> = accessible from outside via a port on each node. <strong>LoadBalancer</strong> = creates an external load balancer (cloud provider) redirecting to the Service. In production, you typically use an Ingress in front of a ClusterIP Service.</details>

## Monitoring

**Q: What are the 3 pillars of observability?**
<details><summary>💡 Hint</summary>Three types of data: numbers, text, and the path of a request.</details>
<details><summary>✅ Answer</summary>Metrics (numbers — CPU, response time), Logs (text messages from applications), Traces (the path of a request through multiple services).</details>

**Q: How do you tell the difference between a code problem and an infrastructure problem?**
<details><summary>💡 Hint</summary>If all instances have the same problem, it's probably the code. If it's just one instance... think about resources.</details>
<details><summary>✅ Answer</summary>You check infrastructure metrics first (CPU, RAM, disk, network). If everything is normal on the infra side but the app returns errors → it's a code bug (ticket for the devs). If CPU is at 100% or disk is full → it's an infra problem (your problem).</details>

**Q: How do you know if your app is slow?**
<details><summary>💡 Hint</summary>You don't look at the average (it hides problems). You look at a percentile — which one?</details>
<details><summary>✅ Answer</summary>The p95 or p99 of latency in Grafana. The p95 = 95% of requests are faster than this value. If the p95 is at 2 seconds, 5% of your users are waiting more than 2 seconds.</details>

**Q: What's a good alert vs a bad alert?**
<details><summary>💡 Hint</summary>A good alert prompts you to act. A bad alert, you end up ignoring. Think symptoms vs causes.</details>
<details><summary>✅ Answer</summary>Good: actionable, based on symptoms ("the 5xx error rate exceeds 5%"). Bad: noise ("CPU at 80%" — maybe that's normal). If you receive an alert and your reaction is "meh", delete the alert.</details>

**Q: What's the difference between Prometheus and Grafana?**
<details><summary>💡 Hint</summary>One collects data, the other displays it. Think sensor vs dashboard.</details>
<details><summary>✅ Answer</summary>Prometheus collects and stores metrics (it scrapes /metrics every 15s). Grafana displays them in dashboards. Prometheus = the sensor, Grafana = the dashboard.</details>

**Q: Why is monitoring important?**
<details><summary>💡 Hint</summary>Without monitoring, how do you know your app is working correctly?</details>
<details><summary>✅ Answer</summary>Without monitoring, you don't know if your app works correctly. You detect problems before users, identify bottlenecks, and have data for decisions.</details>

**Q: What is Prometheus?**
<details><summary>💡 Hint</summary>A metrics collection tool. It fetches data itself (pull model) instead of waiting for apps to send it.</details>
<details><summary>✅ Answer</summary>A metrics collection system using pull model. It scrapes <code>/metrics</code> endpoints from applications at regular intervals and stores data as time series.</details>

**Q: What is Grafana?**
<details><summary>💡 Hint</summary>It's the visualization tool that goes with Prometheus. Think dashboards and graphs.</details>
<details><summary>✅ Answer</summary>A visualization tool. It connects to data sources (Prometheus, etc.) and creates dashboards with graphs and alerts.</details>

**Q: Difference between pull and push model?**
<details><summary>💡 Hint</summary>Who initiates data collection? The monitoring server, or the application itself?</details>
<details><summary>✅ Answer</summary>Pull = Prometheus fetches the data (scrape). Push = applications send the data. Pull is simpler to manage and debug.</details>

**Q: What are SLI, SLO, and SLA?**
<details><summary>💡 Hint</summary>Three levels: what you measure, what you aim for, what you contractually commit to.</details>
<details><summary>✅ Answer</summary><strong>SLI</strong> (Service Level Indicator) = the measured metric (e.g., 99.2% of requests respond in under 200ms). <strong>SLO</strong> (Service Level Objective) = the internal target (e.g., we aim for 99.5%). <strong>SLA</strong> (Service Level Agreement) = the contractual commitment with the client (e.g., if we drop below 99%, we refund). SLI measures, SLO guides, SLA commits.</details>

---

# Part 2: Scenario-based questions

## Scenario 1 — Deploying a web app to production

> **"You join a startup. They have a web app (React frontend + backend API + PostgreSQL database). Everything runs on the CTO's laptop. How do you put this in production?"**

### How to approach the question

Don't dive straight into tools. Ask questions first:
- How many users? (10? 10,000? 1 million?)
- What budget? ($0? $50/month? $1,000/month?)
- What team? (1 dev, 10 devs? Is there a DevOps?)
- What are the availability requirements? (side project vs. banking app)
- Is the frontend static (just built HTML/JS) or does it need server-side rendering?

This last question is key, because it completely changes the architecture for the frontend.

### The frontend — 3 different approaches

**Our case: React with Vite = static frontend.** The build produces static files (HTML/CSS/JS) that can be served from any web server or CDN.

**Approach 1 — CDN / Static hosting (the simplest and most performant)**

The built frontend is just static files. No need for a server for this.

| Service | What it is | Cost | Complexity |
|---------|-----------|------|-----------|
| **S3 + CloudFront** | S3 bucket (storage) + AWS CDN (worldwide distribution) | ~$0-5/month | Low |
| **Vercel** | Specialized frontend hosting, auto deployment from Git | Free (hobby) | Very low |
| **Netlify** | Same concept as Vercel | Free (hobby) | Very low |
| **AWS Amplify Hosting** | AWS service to host frontend apps, auto deployment from Git | Free (Free Tier) | Low |

**When to choose:** Almost always for a static frontend (built React, Vue, Angular). It's faster (CDN = servers close to users), cheaper, and you have no server to manage.

**Approach 2 — Nginx in a container** (what we do in the Hands-on Project)

You build the frontend, then serve the files with nginx in a Docker container. This is what we do in Module 3.

**When to choose:** When you want everything in the same docker-compose to simplify the deployment, or when you need a custom reverse proxy (complex routing rules).

**Approach 3 — Server-Side Rendering (Next.js, Nuxt, etc.)**

If the frontend does SSR (HTML is generated server-side), then it needs a Node.js server running at all times. In that case, you treat it like a backend (EC2, ECS, App Runner, etc.).

**When to choose:** Critical SEO (e-commerce, blog), dynamic content that changes often.

### The backend + database — From simplest to most robust

**Option A: 1 server, Docker Compose (MVP / side project)**

```
1 EC2 (t3.small)
├── Frontend (nginx)
├── Backend (API container)
└── PostgreSQL (container with volume)
```

**Pros:** Quick to set up, cheap (~$15/month), a single machine.
**Cons:** Single point of failure. DB in Docker = risky (no automatic backup). No scaling.
**When to choose:** MVP, side project, <100 users, ~$0 budget.

**Option B: EC2 + RDS (serious startup)**

```
VPC
├── Public subnet
│   └── EC2 (backend in Docker)
└── Private subnet
    └── RDS PostgreSQL (automatic backups)
+ S3 + CloudFront (static frontend)
```

**Pros:** The DB is managed (backups, auto updates). Network separation. The frontend on CDN is fast and free. You can add a 2nd EC2 + load balancer later.
**Cons:** More expensive (~$50-100/month). You manage the EC2s yourself (OS updates, Docker, etc.).
**When to choose:** App in production, real users, need for reliability, small team.

**Option C: ECS Fargate (scaling without managing servers)**

```
VPC
├── Public subnet
│   └── Application Load Balancer
├── Private subnet
│   ├── ECS Fargate (backend containers, auto-scaling)
│   └── RDS PostgreSQL Multi-AZ
+ S3 + CloudFront (frontend)
+ Route 53 (DNS)
```

ECS (Elastic Container Service) runs your Docker containers without you managing servers. Fargate = you give it a Docker image, define CPU/RAM, it launches the container somewhere in the cloud. You never see a machine.

**Pros:** Auto-scaling, no servers to manage, high availability. You push a Docker image and it's deployed.
**Cons:** More expensive than bare EC2 (~$100-300/month). More complex configuration (task definitions, services, target groups...).
**When to choose:** Variable traffic, need for scaling, don't want to manage EC2s.

**Option D: AWS App Runner (the simplest for containers)**

```
App Runner (backend container)
+ RDS PostgreSQL
+ S3 + CloudFront (frontend)
```

App Runner is the simplest AWS service to run a container web app. You give it your Docker image (or your source code) and it handles everything: build, deployment, scaling, HTTPS, load balancing.

**Pros:** Ultra simple. No network configuration. Auto-scaling included. Automatic HTTPS.
**Cons:** Less control than ECS. No default VPC (configurable). More expensive at high traffic.
**When to choose:** You want to deploy fast, you don't want to configure VPC/ALB/ECS, small team without a dedicated DevOps.

**Option E: AWS Amplify (integrated frontend + backend)**

Amplify is a complete platform that can host a static frontend AND a backend (via Lambda functions or a GraphQL API).

**Pros:** All-in-one: hosting, auth, API, database. Auto deployment from Git. Ideal for fullstack devs who don't want to touch infra.
**Cons:** Strong vendor lock-in (you're tied to the Amplify way of doing things). Less control. Can become limiting for complex architectures.
**When to choose:** Small fullstack project, rapid prototyping, no DevOps on the team.

**Option F: Kubernetes / EKS (large scale)**

```
EKS (managed Kubernetes)
├── Backend deployments (auto-scaling)
├── Worker deployments
├── Ingress Controller (HTTP routing)
+ RDS Multi-AZ
+ S3 + CloudFront (frontend)
+ Helm for packaging
```

**Pros:** Massive scaling, portability (not locked to AWS), fine-grained orchestration.
**Cons:** Complex to operate. EKS costs ~$75/month just for the control plane. Over-engineering if you don't have 10+ microservices.
**When to choose:** Many microservices, large DevOps team, need for multi-cloud portability.

### The global comparison table

| Option | Complexity | Monthly cost* | Scaling | Server management | Use case |
|--------|-----------|--------------|---------|----------------|-------------|
| **EC2 + Docker Compose** | Low | ~$15 | No | Yes | MVP |
| **EC2 + RDS** | Medium | ~$50-100 | Manual | Yes | Serious startup |
| **App Runner + RDS** | Low | ~$30-80 | Auto | No | Small team, fast to prod |
| **ECS Fargate + RDS** | High | ~$100-300 | Auto | No | Variable traffic, scaling |
| **Amplify** | Low | ~$0-50 | Auto | No | Prototyping, solo fullstack |
| **EKS (K8s)** | Very high | ~$200+ | Auto | Partially | Microservices, large scale |

*Approximate costs for a modest-sized app.

### Outside AWS — the alternatives

| Service | What it is | When to use |
|---------|-------------|-----------------|
| **Railway / Render** | PaaS (Platform as a Service). You push your code, they deploy. | Side projects, small apps, don't want to deal with AWS |
| **Fly.io** | Edge containers (close to users). | Global APIs, low latency |
| **DigitalOcean App Platform** | Simple PaaS, cheaper than AWS. | SMBs, startups that want simplicity |
| **GCP Cloud Run** | Google's equivalent of App Runner. Serverless containers. | Already on GCP |
| **Azure Container Apps** | Microsoft's equivalent of App Runner. | Already on Azure |

In an interview, mentioning that alternatives exist shows that you don't only know one provider.

### What the recruiter expects

Not the perfect answer. They want to see that you:
- **Ask questions** before answering (budget, scale, constraints, team)
- **Know multiple options** and can compare them (not just "EC2 and that's it")
- **Separate concerns**: the static frontend doesn't need a server, the DB should be managed
- **Can explain the trade-offs**: simplicity vs. control vs. cost vs. scaling
- **Don't suggest Kubernetes for 50 users** — but you can explain when K8s makes sense

---

## Scenario 2 — The site is down in production

> **"It's 2 PM, you get an alert: the site isn't responding. Users are complaining. What do you do?"**

### The method (from broadest to most specific)

**Step 1 — Confirm and scope the problem (30 seconds)**
```bash
# Is the site responding?
curl -I https://mysite.com
# If timeout → network/DNS/server down problem
# If 502 → the proxy server is running but the app behind it is down
# If 500 → the app is running but crashing

# Is it just me or everyone?
# Test from another network / a colleague
```

**Step 2 — Check the infrastructure (2 minutes)**
```bash
# Is the server up?
ssh user@server
# If "Connection refused" → the server is down or the SSH port is blocked
# → Check in the AWS console: instance running? Security Group OK?

# Are resources OK?
top              # CPU, RAM
df -h            # Disk full?
```

**Step 3 — Check the services (2 minutes)**
```bash
docker ps                        # Are the containers running?
docker logs backend --tail 100   # Recent errors?
systemctl status nginx           # Is the reverse proxy running?
```

**Step 4 — Check dependencies**
```bash
# Is the database responding?
docker exec -it db psql -U user -c "SELECT 1;"

# Are external services responding?
curl https://external-api-we-use.com/health
```

**Step 5 — Fix and communicate**
- Fix the problem (restart the service, free up disk space, rollback the last deployment...)
- **Communicate**: notify the team, update the status page
- After the incident: write a post-mortem (what happened, why, how to prevent it from happening again)

### The most common causes

| Symptom | Likely cause | Quick fix |
|----------|---------------|-----------|
| Total timeout | Server down or Security Group | Restart the instance, check network rules |
| 502 Bad Gateway | The app crashed behind the proxy | `docker restart backend`, check the logs |
| 500 Internal Error | Bug in the code or DB unreachable | App logs, check the DB connection |
| Very slow site | CPU/RAM saturated, slow DB queries | `top`, check slow queries |
| Disk full | Logs accumulating, Docker images | `df -h`, `docker system prune`, log rotation |

### What the recruiter expects

- A structured method, not panic
- You start by checking, not by changing things
- You communicate with the team during debugging
- You mention post-mortem (learning after the incident)

---

## Scenario 3 — Setting up a CI/CD pipeline

> **"The team of 5 devs deploys manually via SSH. It takes 30 min and breaks one out of three times. How do you improve this?"**

### The concrete problem

Today:
1. A dev finishes their code
2. They SSH into the server
3. They run `git pull` on the server
4. They restart the app manually
5. They cross their fingers

Problems: no tests before deployment, no rollback possible, only one dev knows how to do it, it breaks often.

### The progressive solution

**Phase 1 — CI (1-2 days to set up)**
```yaml
# On every push to main:
Lint → Tests → Build Docker image → Push to registry
```
- Devs get immediate feedback: "your code breaks the tests"
- You never deploy code that doesn't compile or doesn't pass tests
- **Impact:** we stop deploying broken code

**Phase 2 — CD to a staging environment (3-5 days)**
```yaml
# After CI:
Automatic deploy to a staging server
```
- Devs and the product owner test on staging before production
- Staging is a copy of production (same config, same infra)
- **Impact:** we test in real conditions before production

**Phase 3 — CD to production (when the team is confident)**
```yaml
# If staging is OK (tests pass, QA validated):
Manual approval → Deploy to prod
```
- A human validates before production (Continuous Delivery, not Deployment)
- Automatic rollback if the health check fails
- **Impact:** deployment in 5 min instead of 30, no SSH connection needed

### Why not automate everything at once?

Because trust is built progressively. If tests don't cover enough cases, a 100% automated deployment to production will deploy bugs faster. Phase 1 → Phase 2 → Phase 3 lets the team build confidence at each step.

### What the recruiter expects

- You don't suggest "let's set up Kubernetes" right away
- You think progressively (quick wins first)
- You mention staging (never directly to production)
- You mention rollback

---

## Scenario 4 — Managing secrets

> **"A dev committed a database password to the Git repo. What do you do?"**

### Immediate reaction (emergency)

1. **Change the password immediately** — the absolute priority. Even if "nobody saw it", consider it compromised.
2. **Check access** — has anyone used this password since the commit?
3. **Remove from Git** — careful, a simple `git rm` is NOT enough. The password stays in the history. You'd need to rewrite the history (`git filter-branch` or `bfg`), but that's heavy. The most important thing is point 1: change the password.

### Set up protections

| Measure | What it does |
|--------|---------------|
| **`.gitignore`** | Ignore `.env` files, `credentials.json`, etc. |
| **Pre-commit hook** | Scan commits BEFORE they're pushed (tools: `gitleaks`, `detect-secrets`) |
| **GitHub Secret Scanning** | GitHub automatically detects committed secrets and alerts you |
| **Environment variables** | Secrets live in the server's env, not in the code |
| **Secrets manager** | AWS Secrets Manager, HashiCorp Vault — secure and centralized storage |

### The rule

Code is **public by default** (even a private repo can leak). Secrets must **never** be in the code. Period.

---

## Scenario 5 — Choosing the right infrastructure for each project

> **"We have 4 projects to host. How do you choose the infrastructure for each one?"**

### Project A: Internal REST API with 1,000 requests/day

**Context:** API used by an internal mobile app. Low traffic, minimal budget, one person to maintain.

**Best choice: Lambda + API Gateway**

Why: very low traffic, no need for a server running 24/7. Lambda = you only pay when a request comes in. Cost: nearly $0 (Free Tier). API Gateway handles HTTPS, rate limiting, and routing.

**Possible alternatives:**
- **App Runner**: if the API is containerized and you want something simple without adapting the code for Lambda. Slightly more expensive but zero code adaptation.
- **EC2**: overkill. You're paying for a 24/7 server for 1,000 requests/day — that's waste.

### Project B: Web SaaS with 10,000 users/day

**Context:** Web application (React + API + PostgreSQL). Regular traffic during the day, low at night. Team of 5 devs. Needs reliability.

**Best choice: ECS Fargate + RDS + S3/CloudFront**

```
CloudFront (CDN) → S3 (static frontend)
ALB → ECS Fargate (API containers, auto-scaling)
       └── RDS PostgreSQL (private subnet)
```

Why: regular traffic, the app must run at all times, persistent connection to the DB. ECS Fargate = no servers to manage, auto-scaling for spikes. RDS = managed DB.

**Possible alternatives:**
- **EC2 + RDS**: cheaper, but you manage the servers (updates, Docker, monitoring). Good choice if the budget is tight and someone on the team knows how to manage servers.
- **App Runner + RDS**: simpler than ECS, but less control over the network (VPC peering, custom security groups). Good for a quick v1.
- **Lambda**: technically possible, but cold starts degrade the user experience, and DB connections are complicated to manage (you need RDS Proxy).

### Project C: Processing uploaded files (resizing images)

**Context:** Users upload photos. They must be resized to 3 sizes and stored. Variable volume: sometimes 10 uploads/day, sometimes 10,000.

**Best choice: Lambda + S3 (event-driven architecture)**

```
User → upload → S3 bucket (originals)
                         │
                         └── trigger Lambda → resize → S3 bucket (results)
```

Why: purely event-driven. A file arrives in S3 → Lambda triggers automatically → processes the file → puts the result back in S3. No need for a server between uploads. Automatic scaling (100 uploads at the same time → 100 Lambdas in parallel).

**Possible alternatives:**
- **ECS with an SQS queue**: if processing takes >15 min (Lambda's limit) or requires a lot of memory (>10 GB). SQS = queue, ECS = workers that consume the queue.
- **Step Functions + Lambda**: if processing has multiple steps (resize → watermark → optimize → notify). Step Functions orchestrates the Lambdas.

### Project D: Company showcase site / blog

**Context:** Marketing site with static content. No custom backend, just content that rarely changes. Near-zero budget.

**Best choice: Amplify Hosting (or Vercel / Netlify)**

Why: it's static content. No need for a server, a container, or anything complex. You push to Git, the site is automatically deployed on a worldwide CDN.

```
Git push → Amplify Hosting → Worldwide CDN → users
```

Cost: free (Amplify Free Tier, or Vercel/Netlify free plan).

**Possible alternatives:**
- **S3 + CloudFront**: same result, manual configuration. Better if you want full control on the AWS side.
- **EC2 with nginx**: absolute overkill. A 24/7 server to serve HTML files — that's a waste of money and time.

### The decision table

| Criteria | Lambda | App Runner | ECS Fargate | EC2 | Amplify / Vercel |
|---------|--------|-----------|-------------|-----|-----------------|
| Traffic | Sporadic | Low constant | Variable / high | Constant | Static |
| Execution duration | < 15 min | Unlimited | Unlimited | Unlimited | N/A |
| Stateful | No | No | Yes | Yes | No |
| DB connection | Complicated | Easy | Easy | Easy | No (or via API) |
| Scaling | Auto, instant | Auto | Auto (configurable) | Manual / ASG | Auto (CDN) |
| Server management | None | None | None | You | None |
| Low traffic cost | ~$0 | ~$5-15/month | ~$20-50/month | ~$15-30/month | ~$0 |
| High traffic cost | Can spike | Medium | Predictable | Predictable | Low (CDN) |
| Config complexity | Low | Very low | High | Medium | Very low |

### What the recruiter expects

- You don't give the same answer for all 4 projects
- You justify with concrete criteria (traffic, duration, cost, state, team)
- You know the limits of each solution AND the alternatives
- You know that "the best choice" depends on the context — there is no universal answer
- You separate static frontend / backend / async processing: each has a different solution

---

## Scenario 6 — Infrastructure as Code: a colleague modified the infra by hand

> **"Your team uses Terraform. You run `terraform plan` and you see changes that nobody made in the code. What's happening and how do you handle it?"**

### What happened

Someone modified the infrastructure directly in the AWS console (added a Security Group rule, changed an instance type, etc.) without going through Terraform. The Terraform state file no longer matches reality.

This is called **drift**.

### How to resolve it

**Option A — Import the change into Terraform (if the change is intentional)**
```bash
# 1. Identify what changed
terraform plan
# ~ aws_security_group.web will be updated in-place
#   - ingress rule for port 3306 (added manually)

# 2. Add the rule in the Terraform code so it matches reality
# 3. Re-plan → no changes → code and reality are synchronized
terraform plan
# No changes.
```

**Option B — Force a return to the code (if the change is a mistake)**
```bash
# terraform apply will put the infra back to the state described by the code
terraform apply
# The manual change will be overwritten
```

### Prevent the problem

- **Team rule:** you NEVER touch the console to modify the infrastructure. Everything goes through code + pull request.
- **Restrictive IAM:** limit modification permissions in the console for production environments.
- **Drift detection:** run `terraform plan` regularly (in CI) to detect drift.

---

## Scenario 7 — Monitoring and alerting

> **"Your app has been running in production for 3 months. The CTO tells you: 'We have users complaining it's slow but we don't know why.' How do you set up monitoring?"**

### Step 1 — Define what you want to measure

The 4 golden signals (Google SRE's "Golden Signals"):

| Signal | Question | Example metric |
|--------|----------|-------------------|
| **Latency** | Is it fast? | Response time at the 95th percentile |
| **Traffic** | How many people? | Requests per second |
| **Errors** | Does it work? | 5xx error rate |
| **Saturation** | Is it full? | CPU, RAM, disk, DB connections |

### Step 2 — Instrument the app

```
App → exposes /metrics → Prometheus scrapes → Grafana displays
```

- Add the Prometheus library to the app (for our project: `prometheus-fastapi-instrumentator`)
- Deploy Prometheus + Grafana (docker-compose is the simplest)

### Step 3 — Create the dashboards

One dashboard per "audience":
- **Technical dashboard:** latency, errors, CPU, RAM, DB slow queries
- **Business dashboard:** number of active users, number of tasks created (for the CTO)

### Step 4 — Configure alerts

Good alerts:
- "The 5xx error rate exceeds 5% for 5 minutes" → **actionable** (there's a bug or a service is down)
- "The p95 response time exceeds 2 seconds for 10 minutes" → **actionable** (degraded performance)

Bad alerts:
- "CPU at 80%" → **not actionable on its own** (80% CPU might be normal if the app runs fine)
- "1 error 404" → **noise** (a user typed a wrong URL, that's normal)

### What the recruiter expects

- You know the Golden Signals or a similar framework
- You distinguish between technical and business metrics
- You know that an alert must be actionable
- You don't suggest monitoring 200 metrics at once

---

## Scenario 8 — Blue-green / Canary deployment

> **"How do you deploy to production without downtime and without risking breaking it for all users?"**

### Option A — Blue-Green

```
                    ┌─── Blue (v1.0 — current) ◄── 100% of traffic
Load Balancer ──────┤
                    └─── Green (v1.1 — new) ◄── 0% of traffic
```

1. You deploy v1.1 to Green (while Blue still serves users)
2. You test Green (smoke tests, sanity check)
3. You switch the load balancer: Green receives 100% of the traffic
4. If it works → you delete Blue. If it breaks → you switch back to Blue in 10 seconds.

**Pros:** Instant rollback. Zero downtime.
**Cons:** Double infrastructure during the transition (cost). Problem if the DB schema changed between v1.0 and v1.1.

### Option B — Canary

```
                    ┌─── v1.0 ◄── 95% of traffic
Load Balancer ──────┤
                    └─── v1.1 ◄── 5% of traffic (the "canaries")
```

1. You deploy v1.1 to a few instances
2. You send 5% of traffic to v1.1
3. You monitor the metrics (errors, latency)
4. If everything is fine → 25% → 50% → 100%. If it breaks → 0% and rollback.

**Pros:** You detect bugs with limited impact (5% of users).
**Cons:** More complex to set up. Requires good monitoring to detect issues.

### Option C — Rolling Update

This is what Kubernetes does by default. You replace instances one by one:

```
Start:    [v1.0] [v1.0] [v1.0] [v1.0]
Step 1:   [v1.1] [v1.0] [v1.0] [v1.0]
Step 2:   [v1.1] [v1.1] [v1.0] [v1.0]
Step 3:   [v1.1] [v1.1] [v1.1] [v1.0]
End:      [v1.1] [v1.1] [v1.1] [v1.1]
```

**Pros:** Simple, native in K8s, no double infrastructure.
**Cons:** Slower rollback. During the transition, two versions coexist.

### Which one to choose?

| Strategy | Complexity | Rollback | Use case |
|-----------|-----------|----------|-------------|
| **Blue-Green** | Medium | Instant | Critical apps, few deployments |
| **Canary** | High | Fast | High-traffic apps, need to test in real conditions |
| **Rolling** | Low | Medium | Most cases, K8s default |
