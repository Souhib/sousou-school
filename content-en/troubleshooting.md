# Troubleshooting — Reading and Understanding Errors

> A DevOps engineer spends about 50% of their time reading logs and solving problems. This file shows you the most common errors you'll encounter, what they mean, and how to fix them.

## The Method — Always the Same

No matter the error, the approach is always the same:

1. **Read the error message** — the answer is often right there, word for word
2. **Identify WHICH component has the problem** — is it Docker? The app? The DB? The network?
3. **Check the logs** — `docker logs`, `kubectl logs`, the terminal output
4. **Search for the message on Google / AI** — if you don't understand, copy-paste the message

**Never** do this: ignore the error and retry the same command hoping it will work.

---

## Linux

### `No space left on device`

```
write /var/lib/docker/...: no space left on device
```

**What it means:** The disk is full. This is one of the most frequent crash causes in production. Often caused by Docker images piling up, logs growing, or backups stacking up.

**How to fix:**
```bash
# Check disk space
df -h
# Filesystem      Size  Used Avail Use%
# /dev/sda1        30G   29G  1.0G  97%   ← almost full!

# If Docker is taking up the space (most common case)
docker system df                  # view space used by Docker
docker system prune -a            # remove everything that's not in use

# If it's the logs
du -sh /var/log/*                 # see which logs take up the most space
sudo truncate -s 0 /var/log/syslog  # empty a log file without deleting it
```

---

### `command not found`

```
bash: terraform: command not found
```

**What it means:** The program is not installed, or it is installed but not in the PATH (the list of directories where Linux looks for programs).

**How to fix:**
```bash
# Is it installed?
which terraform
# If nothing shows up → not installed. Install it.

# If it's installed but not found → PATH issue
echo $PATH
# Check that the directory containing the program is in the list

# Common case after an installation: restart the terminal
# or run:
source ~/.bashrc
```

---

### `Permission denied` when editing a file

```
bash: /etc/nginx/nginx.conf: Permission denied
```

**What it means:** You're trying to modify a system file without administrator privileges.

**How to fix:**
```bash
# Add sudo before the command
sudo nano /etc/nginx/nginx.conf
```

---

## Docker

### `Error response from daemon: port is already allocated`

```
Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:8000 failed: port is already allocated
```

**What it means:** Another program is already using port 8000 on your machine. Two programs cannot listen on the same port.

**How to fix:**
```bash
# Find what's using port 8000
ss -tlnp | grep 8000

# If it's an old Docker container
docker ps -a | grep 8000
docker stop <container_name>
docker rm <container_name>

# If it's a local process (e.g. uvicorn started manually)
kill <PID>
```

---

### `Exited (1)` — The application crashed

```
CONTAINER ID  IMAGE       STATUS                     NAMES
abc123        mon-app     Exited (1) 30 seconds ago  backend
```

**What it means:** Exit code `1` = the application itself crashed (bug, missing dependency, missing environment variable, syntax error...). This is a problem in the code or config, not in Docker.

**How to fix:**
```bash
# ALWAYS start with the logs
docker logs backend
# The error is in the last lines:
# - "ModuleNotFoundError" → dependency not installed (check the Dockerfile)
# - "KeyError: 'DATABASE_URL'" → missing environment variable
# - "SyntaxError" → syntax error in the code
# - "FileNotFoundError" → an expected file doesn't exist in the container
```

---

### `Exited (137)` — Container killed by the system

```
CONTAINER ID  IMAGE       STATUS                      NAMES
abc123        mon-app     Exited (137) 2 minutes ago  backend
```

**What it means:** Code `137` = the process received a SIGKILL (128+9=137). Something **external** killed the container, not the application itself.

| Cause | How to check |
|-------|-------------|
| **OOM Kill** (too much memory) — most common | `docker stats` → memory is close to the limit |
| **`docker stop` timeout** (the container doesn't stop within 10s) | Check if you ran `docker stop` just before |
| **Resource limit exceeded** (Docker Compose or K8s) | Check `resources.limits` in your config |

**How to fix (OOM case):**
```bash
docker stats
# CONTAINER  CPU %  MEM USAGE / LIMIT
# backend    2%     450MiB / 512MiB     ← almost at the limit!

# Increase the memory limit in docker-compose.yml:
#   deploy:
#     resources:
#       limits:
#         memory: 1024M

# If memory keeps rising non-stop → memory leak
# → escalate to the devs with Grafana metrics
```

---

### `COPY failed: file not found in build context`

```
COPY failed: file not found in build context or excluded by .dockerignore
```

**What it means:** The Dockerfile is trying to copy a file that doesn't exist in the build directory, or that is excluded by `.dockerignore`.

**How to fix:**
```bash
# Check that the file exists in the right directory
ls -la
# The build "context" is the directory after the "." in "docker build -t my-app ."

# Check the .dockerignore — maybe the file is excluded
cat .dockerignore

# Common mistake: being in the wrong directory when running docker build
pwd
# You must be in the directory that contains the Dockerfile
```

---

### `no matching manifest for linux/arm64` (Mac M1/M2/M3)

```
no matching manifest for linux/arm64/v8 in the manifest list entries
```

**What it means:** The Docker image is built for Intel processors (x86), but your Mac has an ARM processor. The image is not compatible.

**How to fix:**
```bash
# Force the build for the Intel platform
docker build --platform linux/amd64 -t mon-app .

# Or in docker-compose.yml:
#   services:
#     backend:
#       platform: linux/amd64
```

> This problem doesn't happen on WSL/Linux. You'll only run into it if you're working on a Mac.

---

## CI/CD (GitHub Actions)

### `Error: Process completed with exit code 1`

```
Error: Process completed with exit code 1
```

**What it means:** A command in the pipeline failed. `exit code 1` means "generic error". The real message is **above** in the logs.

**How to fix:**
```
# Scroll up in the GitHub Actions job logs
# The error is in the lines BEFORE "Process completed with exit code 1"
# Examples:
# "ruff check failed" → the linter found style errors → fix the code
# "FAILED tests/test_main.py" → a test failed → check which one and why
# "docker build failed" → error in the Dockerfile → read the Docker message
```

---

### `Permission denied` when pushing to Docker Hub

```
denied: requested access to the resource is denied
```

**What it means:** GitHub Actions is trying to push an image to Docker Hub but doesn't have the permissions.

**How to fix:**
```
# Check the secrets in GitHub:
# Settings → Secrets and variables → Actions
# - DOCKERHUB_USERNAME → your Docker Hub username
# - DOCKERHUB_TOKEN → an Access Token (not your password!)
#   Created at https://hub.docker.com/settings/security

# Common mistake: the secret is misnamed
# In the YAML: ${{ secrets.DOCKERHUB_TOKEN }}
# In GitHub: the secret must be named EXACTLY "DOCKERHUB_TOKEN"
```

---

### The pipeline passes but the app is broken in prod

**What it means:** The tests don't cover the case that breaks. The pipeline does its job (it runs the tests), but the tests don't check everything.

**How to fix:**
```
# This is not a pipeline bug — it's a missing test
# 1. Identify what broke in prod (the app logs)
# 2. Write a test that reproduces the bug (ticket for the devs)
# 3. The pipeline will catch this case next time

# Prevention: add a "smoke test" after deployment
# = a basic test that checks the app responds (curl /api/health)
```

---

## SSH and AWS

### `Connection refused` vs `Connection timed out`

These are **two completely different problems**:

| Error | What it means | Likely cause |
|-------|--------------|--------------|
| `Connection refused` | The machine is reachable BUT nothing is listening on that port | The SSH service isn't running, or the port is wrong |
| `Connection timed out` | The machine is NOT reachable at all | Wrong IP, Security Group is blocking port 22, the machine is off |

```bash
# Connection refused → check that SSH is running on the server
sudo systemctl status sshd

# Connection timed out → check:
# 1. Is the IP correct?
# 2. Does the Security Group allow port 22 from your IP?
# 3. Is the instance "Running" in the AWS console?
```

---

### `Permission denied (publickey)`

```
Permission denied (publickey).
```

**What it means:** The server doesn't recognize your SSH key.

**How to fix:**
```bash
# 1. Are you using the right key?
ssh -i ~/devops-key.pem ubuntu@IP
# (not ssh -i ~/other-key.pem)

# 2. Are the key permissions correct?
chmod 400 ~/devops-key.pem
# SSH refuses a key with permissions that are too open

# 3. The right user?
# Ubuntu → ubuntu
# Amazon Linux → ec2-user
# Debian → admin
```

---

### `WARNING: UNPROTECTED PRIVATE KEY FILE`

```
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions 0644 for 'devops-key.pem' are too open.
```

**What it means:** The SSH key is readable by other users on your machine. SSH refuses to use it for security reasons.

**How to fix:**
```bash
chmod 400 ~/devops-key.pem
# 400 = read-only, for you only
```

---

### `AccessDenied` / `UnauthorizedOperation` on AWS

```
An error occurred (AccessDenied) when calling the DescribeInstances operation:
User: arn:aws:iam::123456:user/admin-dev is not authorized to perform: ec2:DescribeInstances
```

**What it means:** Your IAM user doesn't have the permissions to perform this action on AWS.

**How to fix:**
```bash
# Check which user you're using
aws sts get-caller-identity
# This shows you which user/role is active

# Add the missing permissions in IAM:
# AWS Console → IAM → Users → your user → Attach policies
# For the course: "AdministratorAccess" (not in prod!)
```

---

## Terraform

### `Error: No valid credential sources found`

```
Error: error configuring Terraform AWS Provider: no valid credential sources found
```

**What it means:** Terraform can't find your AWS credentials.

**How to fix:**
```bash
aws configure list
# If "access_key" and "secret_key" are empty → reconfigure:
aws configure
```

---

### `Error: resource already exists`

```
Error: creating EC2 Instance: InvalidParameterValue:
  An instance with the name 'devops-server' already exists
```

**What it means:** Terraform is trying to create a resource that already exists (created manually or by a previous `apply`).

**How to fix:**
```bash
# Option 1: import the existing resource into the state
terraform import aws_instance.web i-1234567890abcdef0

# Option 2: delete the resource manually on AWS, then rerun
terraform apply
```

---

### `Error: Error acquiring the state lock`

```
Error: Error acquiring the state lock
Lock Info:
  ID:        abc123
  Operation: OperationTypeApply
  Who:       user@machine
```

**What it means:** Someone else (or you in another terminal) is running `terraform apply` at the same time. Terraform locks the state to avoid conflicts.

**How to fix:**
```bash
# Wait for the other operation to finish
# OR if you're sure nobody else is working on it:
terraform force-unlock <LOCK_ID>
# ⚠️ Only if the other operation is stuck/dead
```

---

### `Error: Cycle` — Circular dependency

```
Error: Cycle: aws_security_group.web, aws_security_group.db
```

**What it means:** Two resources depend on each other, creating an infinite loop. Terraform doesn't know which one to create first.

**How to fix:**
```bash
# Identify the loop in your code:
# The SG "web" references the SG "db", AND the SG "db" references the SG "web"
# → Break the loop by using separate rules (aws_security_group_rule)
#   instead of putting rules inside the Security Group block
```

---

## Ansible

### `UNREACHABLE` — Unable to connect

```
fatal: [13.38.42.100]: UNREACHABLE! => {
    "msg": "Failed to connect to the host via ssh"
}
```

**What it means:** Ansible can't connect to the server via SSH. Same causes as "Connection refused" / "Connection timed out".

**How to fix:**
```bash
# 1. Test the SSH connection manually
ssh -i ~/devops-key.pem ubuntu@13.38.42.100
# If it works → the problem is in the Ansible inventory (wrong user, wrong key)
# If it doesn't work → network/AWS issue (see SSH section)

# 2. Check the inventory
cat inventory.ini
# Is the IP correct? Is ansible_user correct? Is the key path correct?
```

---

### `MODULE FAILURE` — An Ansible module failed

```
fatal: [13.38.42.100]: FAILED! => {
    "msg": "No package matching 'docker.io' is available"
}
```

**What it means:** The Ansible module (here `apt`) encountered an error. The `msg` tells you exactly what went wrong.

**How to fix:**
```bash
# Read the "msg" — it's the answer
# "No package matching" → the package doesn't exist (wrong name or apt not updated)
# "Permission denied" → missing become: true (sudo)
# "Could not find" → the source file (for copy) doesn't exist on your machine

# Common fix: add update_cache: true in the apt task
# (equivalent to running apt update before apt install)
```

---

## Database

### `FATAL: too many connections`

```
psycopg2.OperationalError: FATAL: too many connections for role "admin"
```

**What it means:** PostgreSQL has reached its limit of simultaneous connections.

**How to fix:**
```bash
# See how many connections are open
psql -h <RDS_ENDPOINT> -U admin -d tasks -c "SELECT count(*) FROM pg_stat_activity;"

# QUICKFIX: increase max_connections in the RDS settings
# PERMANENT FIX: the devs implement a connection pool (ticket)
```

---

### `Connection refused` to the database

```
psycopg2.OperationalError: could not connect to server: Connection refused
    Is the server running on host "db" and accepting connections on port 5432?
```

**What it means:** The application can't connect to the database. Either the DB isn't running, or the network is blocking it.

**How to fix:**
```bash
# In Docker Compose:
docker compose ps
# Is the "db" service "Up"? If not → docker compose logs db

# Check the DATABASE_URL
# The host must be the SERVICE NAME ("db"), not "localhost"
# DATABASE_URL=postgresql://user:pass@db:5432/tasks  ← correct
# DATABASE_URL=postgresql://user:pass@localhost:5432/tasks  ← WRONG in Docker

# On AWS (RDS):
# Does the RDS Security Group allow port 5432 from the EC2 Security Group?
```

---

### `FATAL: password authentication failed`

```
FATAL: password authentication failed for user "admin"
```

**What it means:** The password in the DATABASE_URL doesn't match the one in the database.

**How to fix:**
```bash
# Check the password in the environment variable
echo $DATABASE_URL
# The password in the URL must match POSTGRES_PASSWORD in docker-compose.yml
# Or the master password set when creating the RDS instance
```

---

## Kubernetes

### `CrashLoopBackOff`

```
NAME                       READY   STATUS             RESTARTS   AGE
backend-6d4f5b7c9d-abc12   0/1     CrashLoopBackOff   5          3m
```

**What it means:** The container starts, crashes, K8s restarts it, it crashes again... in a loop. `BackOff` = K8s waits longer and longer between each attempt.

**How to fix:**
```bash
# Step 1: the logs — the crash reason is in there
kubectl logs backend-6d4f5b7c9d-abc12
# View the PREVIOUS crash logs:
kubectl logs backend-6d4f5b7c9d-abc12 --previous

# Common causes:
# "ModuleNotFoundError" → dependencies not installed in the image
# "connection refused" → the DB is not reachable
# "Permission denied" → permissions issue in the container
# Silent crash → probably an OOM

# Step 2: the events
kubectl describe pod backend-6d4f5b7c9d-abc12
# Look at the "Events" section at the bottom
```

---

### `ImagePullBackOff`

```
NAME                       READY   STATUS             RESTARTS   AGE
backend-6d4f5b7c9d-abc12   0/1     ImagePullBackOff   0          2m
```

**What it means:** K8s can't download the Docker image.

**How to fix:**
```bash
kubectl describe pod backend-6d4f5b7c9d-abc12
# Look for "Failed to pull image" in Events

# Causes:
# 1. Typo in the image name → check "image:" in the YAML
# 2. The image doesn't exist on Docker Hub (or the repo is private)
# 3. On minikube, the image is local → minikube image load <image>
```

---

### `Pending` — The pod won't start

```
NAME                       READY   STATUS    RESTARTS   AGE
backend-6d4f5b7c9d-abc12   0/1     Pending   0          5m
```

**What it means:** K8s can't find a machine with enough resources to run the pod.

**How to fix:**
```bash
kubectl describe pod backend-6d4f5b7c9d-abc12
# "Insufficient memory" → not enough RAM on the node
# "Insufficient cpu" → not enough CPU
# "no nodes available" → no nodes in the cluster

# On minikube:
minikube stop
minikube start --memory=4096 --cpus=2
```

---

### `OOMKilled` — Pod killed due to lack of memory

```
State:          Terminated
Reason:         OOMKilled
Exit Code:      137
```

**What it means:** The container exceeded the memory limit defined in the Deployment. K8s killed it (same principle as Docker exit 137).

**How to fix:**
```bash
# View the current limit
kubectl describe pod <pod>
# Look for "Limits: memory:"

# Increase the limit in the Deployment YAML:
#   resources:
#     limits:
#       memory: "512Mi"    ← increase this value
#     requests:
#       memory: "256Mi"

# If memory keeps growing → memory leak (ticket for the devs)
```

---

## Summary — The reflex for any error

```
1. READ the message         → the answer is often right there
2. IDENTIFY the component   → Linux? Docker? App? DB? Network? CI/CD? K8s?
3. CHECK the logs           → docker logs, kubectl logs, GitHub Actions logs
4. SEARCH the message       → Google, AI (opencode), Stack Overflow
5. QUICKFIX if urgent       → get prod back on its feet
6. PERMANENT FIX            → fix the root cause (ticket, PR, config)
7. DOCUMENT                 → post-mortem, update the runbook
```
