# After the Course — Going Further

This course gives you the foundation to land your first job. But DevOps is a vast field. Here are tools and concepts you did **not** cover in the course and that you'll encounter in the workplace.

## Security — The Basics You'll Be Asked in Interviews

Security comes up in almost every DevOps interview. You don't need to be an expert, but you must know these concepts:

| Concept | Explanation | Concrete Example |
|---------|------------|-----------------|
| **Principle of Least Privilege** | Each user/service should only have access to what it needs, nothing more | A CI/CD pipeline doesn't need admin AWS access — just the right to push a Docker image and deploy to ECS |
| **Secrets Management** | Passwords, tokens, and API keys should **never** be in the code or in plain text | Use GitHub Secrets for CI/CD, environment variables on the server, or Vault in production. Never commit a `.env` file to Git |
| **Secret Rotation** | Regularly change passwords and tokens to limit damage in case of a leak | AWS lets you configure automatic IAM key rotation every 90 days |
| **Vulnerability Scanning** | Automatically analyze Docker images and dependencies to find known flaws | Trivy in the CI/CD pipeline: `trivy image my-app:latest` — blocks deployment if a critical vulnerability is found |
| **HTTPS Everywhere** | All traffic should be encrypted, even between internal services | TLS certificates with Let's Encrypt (free) or AWS Certificate Manager |
| **Network: Limit Exposure** | Only services that need to be public should be. Everything else stays on a private network | The database is only accessible from the VPC, never from the Internet. Only the load balancer is public |

> **In interviews:** You'll often be asked "How do you manage secrets?" or "What is the principle of least privilege?". These 6 concepts cover 90% of security questions for a junior/mid position.

## Accessible quickly (after the course)

| Tool | What is it | Why it's useful |
|------|-----------|-----------------|
| **HashiCorp Vault** | Centralized secrets management (passwords, tokens, API keys) | In companies, secrets aren't in `.env` files or GitHub Secrets — they're in Vault. It's the standard |
| **Trivy / Snyk** | Vulnerability scanners — they analyze your Docker images and dependencies to find security flaws | Increasingly in demand, integrates into the CI/CD pipeline |
| **Testcontainers** | Automatically starts the containers your tests need, from the test code itself | The logical next step after what you did in Module 4 with service containers. Available for Java, Python, Go, Node... |
| **Datadog / New Relic** | SaaS monitoring (all-in-one, paid) — metrics, logs, traces in a single interface | Many companies use these instead of Prometheus + Grafana. The concept is the same, only the tool changes |
| **Loki** | Log collector by Grafana — like ELK but simpler | Complements Prometheus (metrics) with centralized logs |

## Senior level (you'll encounter these with experience)

| Tool | What is it | Why it's senior-level |
|------|-----------|----------------------|
| **Helm** | Package manager for Kubernetes — like `apt` for Linux but for K8s. You describe your app in a reusable "chart" | Requires solid K8s knowledge first. You'll only use it if your company runs K8s in prod |
| **ArgoCD** | GitOps — the Git repo IS the source of truth for deployment. You push YAML to Git, ArgoCD automatically deploys it to K8s | Very powerful but complex. Requires K8s + Helm + advanced Git |
| **Istio / Service Mesh** | Manages traffic between microservices (security, observability, automatic retry) | Only useful with 10+ microservices. Overkill otherwise |
| **OpenTelemetry** | Standard for distributed tracing — follow a request end-to-end across multiple services | Requires a microservices architecture to be meaningful |
| **Terragrunt** | Wrapper around Terraform for managing dozens of modules and environments | Useful when you have a massive Terraform infrastructure (5+ environments, 20+ modules) |

> **The advice:** Don't spread yourself thin. Learn these tools **when you need them** (your company uses it, a project requires it), not "just in case". The fundamentals from this course will carry you a long way. The rest comes naturally with experience.

## The Equivalents — "It's the same thing, just a different name"

In the workplace, you'll come across tools different from those in the course. Don't panic — the concepts are the same, only the name changes. If you master the left column, you can learn the right column in a few days.

| What you know (course) | Equivalent you'll encounter | What changes |
|------------------------|---------------------------|--------------|
| **GitHub Actions** (CI/CD) | GitLab CI, Jenkins, CircleCI | The YAML file syntax. The concepts (jobs, steps, triggers) are identical |
| **AWS** (cloud) | GCP (Google), Azure (Microsoft) | The service names change (EC2 → Compute Engine, S3 → Cloud Storage, RDS → Cloud SQL). The concepts are the same |
| **Terraform** (IaC) | OpenTofu (open-source fork), Pulumi (IaC in Python/TS), CloudFormation (AWS-specific IaC) | Terraform and OpenTofu are nearly identical. Pulumi uses a real programming language instead of HCL. CloudFormation = same idea but locked to AWS |
| **Docker Compose** (local orchestration) | Podman Compose, Docker Swarm | Podman = Docker without a daemon (more secure). Swarm = basic orchestration built into Docker |
| **Floci** (local AWS emulator) | LocalStack, Testcontainers, moto | LocalStack was the reference until 2026, the year its free edition was discontinued — Floci is its open-source replacement, with the same port and conventions. Testcontainers starts services from the test code itself. `moto` does the same, but for Python only |
| **Prometheus + Grafana** (monitoring) | Datadog, New Relic, CloudWatch | Same concept (metrics + dashboards + alerts), but paid SaaS. Easier to set up, less control |
| **Ansible** (configuration) | Chef, Puppet, SaltStack | Ansible = agentless (SSH). Chef/Puppet = agent installed on each server. Same goal: configure servers automatically |
| **GitHub** (code hosting) | GitLab, Bitbucket | Git is the same everywhere. Only the web interface and built-in features change (CI/CD, issues, etc.) |

## Your Concrete Next Steps

1. **Finish the course** — modules 0 through 6 are the foundation. Do them in order, don't skip
2. **Prepare your resume and LinkedIn** — don't wait until the end. Contact [Souhib TRABELSI](https://www.linkedin.com/in/souhib-trabelsi/) for help
3. **Practice interviews** — do the [interview questions](interview-questions.md), the [scenario exercises](interview-experience.md), and the [system design exercises](system-design-exercises.md). Out loud, like the real thing
4. **Build a personal project** — deploy an app of your choice on AWS with Terraform and a CI/CD pipeline. It's the best argument in an interview: "I built this end-to-end"
5. **Learn a tool from the list above when you need it** — not before. Vault when your company uses it, Helm when you're running K8s in prod
6. **Stay curious** — follow blogs (DevOps Weekly, CNCF blog), watch conference talks (KubeCon, HashiConf), and contribute to open-source projects when you get the chance
