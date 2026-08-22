# DevOps Cheatsheet

> **3 frequency levels:**
> - **daily** — you type these every day, learn them by heart. If you know these, you'll be fine.
> - occasional — useful regularly, you'll come back here to look them up when needed.
> - *rarely* — you'll need these once or twice, mostly for setup or cleanup.

> **Words between `<angle brackets>` are placeholders** — replace them with your own value.
> Example: `git checkout -b <branch>` → `git checkout -b feature/login`

## Git

| Command | Description | Frequency |
|---------|------------|-----------|
| `git status` | See the current state | **daily** |
| `git add .` | Stage everything | **daily** |
| `git commit -m "<message>"` | Commit | **daily** |
| `git push` | Push to the remote | **daily** |
| `git pull` | Pull from the remote | **daily** |
| `git checkout -b <branch>` | Create and switch to a branch | **daily** |
| `git log --oneline` | Compact history | occasional |
| `git merge <branch>` | Merge a branch | occasional |
| `git init` | Initialize a repo | *rarely* |
| `git branch <branch>` | Create a branch (without switching to it) | *rarely* |

## Linux

| Command | Description | Frequency |
|---------|------------|-----------|
| `ls -la` | List everything (including hidden files) | **daily** |
| `cd <path>` | Move to a directory | **daily** |
| `cat <file>` | Read a file | **daily** |
| `mkdir -p <path>` | Create directories recursively | **daily** |
| `grep -r "<text>" <directory>/` | Search for text | **daily** |
| `sudo apt update && sudo apt install -y <package>` | Install a package (e.g. `curl`, `git`) | **daily** |
| `pwd` | Show current directory | occasional |
| `nano <file>` | Edit a file in the terminal | occasional |
| `rm -r <directory>` | Delete (recursive) | occasional |
| `cp -r <source> <destination>` | Copy (recursive) | occasional |
| `mv <source> <destination>` | Move / rename | occasional |
| `chmod 755 <file>` | Change permissions | occasional |
| `export <VAR_NAME>="<value>"` | Set an environment variable | occasional |
| `ps aux` | List processes | occasional |
| `kill <PID>` | Kill a process (`PID` = number shown by `ps aux`) | occasional |
| `find . -name "*.py"` | Search for files | *rarely* |
| `chown <user>:<group> <file>` | Change the owner | *rarely* |
| `systemctl start/stop/status <service>` | Manage a service (e.g. `nginx`, `docker`) | *rarely* |
| `whoami` | Show current user | *rarely* |
| `printenv` | List environment variables | *rarely* |
| `journalctl -u <service>` | View logs for a service | *rarely* |

## Network

| Command | Description | Frequency |
|---------|------------|-----------|
| `curl <URL>` | HTTP request (e.g. `curl http://localhost:8000/api/tasks`) | **daily** |
| `ss -tlnp` | Open ports | occasional |
| `ping <host>` | Test connectivity (e.g. `ping google.com`) | occasional |
| `curl -I <URL>` | View headers | occasional |
| `dig +short <domain>` | Resolve a DNS (e.g. `dig +short google.com`) | *rarely* |
| `wget <URL>` | Download a file | *rarely* |
| `hostname -I` | View your private IP | *rarely* |
| `curl ifconfig.me` | View your public IP | *rarely* |
| `traceroute <host>` | Network path | *rarely* |
| `sudo ufw allow <port>` | Open a port (e.g. `sudo ufw allow 8000`) | *rarely* |
| `sudo ufw enable` | Enable the firewall | *rarely* |
| `sudo ufw status` | View the rules | *rarely* |

## HTTP Methods

| Method | What it does | Example |
|--------|-------------|---------|
| `GET` | Read a resource | `curl http://localhost:8000/api/tasks` |
| `POST` | Create a resource | `curl -X POST -H "Content-Type: application/json" -d '{"title":"..."}' http://localhost:8000/api/tasks` |
| `PATCH` | Update an existing resource | `curl -X PATCH http://localhost:8000/api/tasks/1` |
| `PUT` | Update an existing resource | (not used in this project) |
| `DELETE` | Delete | `curl -X DELETE http://localhost:8000/api/tasks/1` |

> **PATCH vs PUT:** to keep it simple, both are used to **update data that already exists**. The technical difference: `PATCH` only modifies the fields you send, `PUT` replaces the entire resource. In practice, many APIs use one or the other interchangeably. In this course we use `PATCH` — if you see `PUT` elsewhere, just think of it as the same idea.

## Docker

| Command | Description | Frequency |
|---------|------------|-----------|
| `docker compose up -d --build` | Start with Compose | **daily** |
| `docker compose down` | Stop everything | **daily** |
| `docker compose ps` | View service status | **daily** |
| `docker compose logs -f` | Logs for all services | **daily** |
| `docker ps` | Running containers | **daily** |
| `docker logs -f <container>` | Follow a container's logs | **daily** |
| `docker exec -it <container> bash` | Enter a container | occasional |
| `docker build -t <name>:<tag> .` | Build an image (e.g. `docker build -t my-app:1.0 .`) | occasional |
| `docker stop <container>` | Stop a container | occasional |
| `docker rm <container>` | Remove the container | occasional |
| `docker ps -a` | All containers (including stopped ones) | occasional |
| `docker run -d -p <host_port>:<container_port> --name <name> <image>` | Run a container without Compose | *rarely* |
| `docker rmi <image>` | Remove the image | *rarely* |
| `docker pull <image>` | Download an image (e.g. `docker pull postgres:16`) | *rarely* |
| `docker images` | List local images | *rarely* |
| `docker system df` | View disk space used by Docker | *rarely* |
| `docker system prune -a` | Clean up unused images/containers | *rarely* |

## Bun (frontend)

| Command | Description | Frequency |
|---------|------------|-----------|
| `bun install` | Install dependencies | **daily** |
| `bun run dev` | Start the dev server | **daily** |
| `bun run build` | Build for production | occasional |
| `bunx oxlint .` | Run the linter | occasional |

> Bun replaces npm + Node.js. The equivalent npm commands: `npm install`, `npm run dev`, `npx oxlint .`

## uv (Python backend)

| Command | Description | Frequency |
|---------|------------|-----------|
| `uv sync` | Install dependencies | **daily** |
| `uv run uvicorn main:app --reload` | Start the backend server | **daily** |
| `uv run pytest` | Run the tests | **daily** |
| `uv run ruff check .` | Run the linter | occasional |
| `uv add <package>` | Add a dependency (e.g. `uv add fastapi`) | *rarely* |

> uv replaces pip + venv. The equivalent commands: `pip install -r requirements.txt`, `python -m pytest`

## GitHub Actions

```yaml
# Minimal structure
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello CI"
```

| Concept | Syntax |
|---------|--------|
| Secret | `${{ secrets.<SECRET_NAME> }}` |
| Dependency between jobs | `needs: <job_name>` |
| Condition | `if: github.ref == 'refs/heads/main'` |

## AWS CLI

| Command | Description | Frequency |
|---------|------------|-----------|
| `aws ec2 describe-instances` | List instances | **daily** |
| `aws ec2 stop-instances --instance-ids <ID>` | Stop (e.g. `--instance-ids i-0abc123`) | **daily** |
| `aws ec2 start-instances --instance-ids <ID>` | Start | **daily** |
| `aws s3 cp <file> s3://<bucket>/` | Upload | occasional |
| `aws s3 ls s3://<bucket>/` | List bucket contents | occasional |
| `aws ec2 terminate-instances --instance-ids <ID>` | Permanently delete | occasional |
| `aws configure` | Configure credentials | *rarely* |
| `aws s3 mb s3://<bucket>` | Create a bucket | *rarely* |
| `aws rds describe-db-instances` | List RDS databases | *rarely* |
| `aws rds delete-db-instance --db-instance-identifier <ID> --skip-final-snapshot` | Delete an RDS database | *rarely* |
| `aws lambda list-functions` | List Lambda functions | *rarely* |
| `aws lambda invoke --function-name <NAME> output.json` | Invoke a Lambda | *rarely* |
| `aws lambda delete-function --function-name <NAME>` | Delete a Lambda | *rarely* |

## AWS locally (Floci)

See the [full guide](floci-aws-local.md). The shortcut to put in `~/.bashrc`:

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
alias awslocal='aws --endpoint-url=http://localhost:4566'
```

| Command | Description | Frequency |
|----------|------------|-----------|
| `cd ~/devops-project/floci && docker compose up -d` | Start local AWS | **daily** |
| `curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4566/health` | Check it answers (should print `200`) | **daily** |
| `awslocal <command>` | Any AWS command, locally | **daily** |
| `docker compose down && docker compose up -d` | Start from a clean AWS | occasional |
| `docker compose logs -f floci` | See what's happening | occasional |
| `docker compose down` | Stop everything and erase it | occasional |

**Remember:** from your machine → `http://localhost:4566`. From another container → `http://floci:4566`.

**Terraform locally** — add to the `provider "aws"` block:

```hcl
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
```

## Terraform

| Command | Description | Frequency |
|---------|------------|-----------|
| `terraform plan` | Preview | **daily** |
| `terraform apply` | Apply | **daily** |
| `terraform init` | Initialize (download providers) | occasional |
| `terraform destroy` | Delete everything | occasional |
| `terraform fmt` | Format the code | occasional |
| `terraform validate` | Check the syntax | *rarely* |
| `terraform state list` | View managed resources | *rarely* |

## Ansible

| Command | Description | Frequency |
|---------|------------|-----------|
| `ansible-playbook -i <inventory> <playbook>.yml` | Run a playbook | **daily** |
| `ansible -i <inventory> <hosts> -m ping` | Test the connection | occasional |
| `ansible-playbook -i <inventory> <playbook>.yml --check` | Dry run | occasional |
| `ansible-vault encrypt <file>` | Encrypt a file | *rarely* |

## Kubernetes (kubectl)

| Command | Description | Frequency |
|---------|------------|-----------|
| `kubectl get pods` | List pods | **daily** |
| `kubectl get services` | List services | **daily** |
| `kubectl logs <pod>` | View logs | **daily** |
| `kubectl apply -f <file>.yml` | Apply a config | **daily** |
| `kubectl describe pod <pod>` | Pod details | occasional |
| `kubectl get deployments` | List deployments | occasional |
| `kubectl delete -f <file>.yml` | Delete | occasional |
| `kubectl scale deployment <name> --replicas=<N>` | Scale (e.g. `--replicas=3`) | occasional |
| `kubectl rollout status deployment/<name>` | Track a deployment | *rarely* |
| `kubectl get namespaces` | List namespaces | *rarely* |
| `kubectl set image deployment/<name> <container>=<image>:<tag>` | Update the image | *rarely* |
| `minikube start` | Start the local cluster | *rarely* |
| `minikube stop` | Stop the local cluster | *rarely* |
| `minikube image load <image>` | Load a local image into minikube | *rarely* |
| `minikube service <name> --url` | Get a service's URL | *rarely* |

## Monitoring

| Command / URL | Description | Frequency |
|---------------|------------|-----------|
| `http://localhost:9090` | Prometheus UI | **daily** |
| `http://localhost:3001` | Grafana UI | **daily** |
| `curl http://localhost:8000/metrics` | View raw metrics | occasional |
| `rate(<metric>[1m])` | Rate per second (PromQL) | *rarely* |
| `histogram_quantile(0.95, ...)` | 95th percentile (PromQL) | *rarely* |
| `docker compose up -d` (with prometheus.yml) | Start Prometheus + Grafana | *rarely* |
