# DevOps — From Zero to Interview-Ready

A hands-on course to learn DevOps. No fluff, simple analogies, copy-paste commands, and a hands-on project that evolves from start to finish.

## What is DevOps?

In the software world, there are generally three major domains:

- **Frontend** — what the user sees and interacts with: buttons, pages, design. The frontend developer writes the code that runs in your browser (or your mobile app). Technologies: React, Vue, HTML/CSS, etc.
- **Backend** — what runs on the server, behind the screen. The core of the backend is the **API**: a program that runs 24/7 on a server and receives messages from the frontend. When you open your cart, the frontend sends a message to the API ("give me this user's cart"), the API fetches the data from the database and sends it back to the frontend which displays it. When you click "Place my order", the frontend sends another message to the API, and the API processes the request: it checks the cart, charges the card, saves the order to the database, and responds to the frontend "all good, order confirmed". Technologies: Python, Java, Go, Node.js, etc.
- **DevOps** — everything between the code and the end user. The code is written, ok — but how do we test it automatically? How do we put it online? On which server? How do we know it's working? How do we handle 10,000 users at the same time? **That's DevOps.**

Concretely, DevOps is the job of **building and maintaining the infrastructure** that allows code to run in production. You don't code the application — you make sure it's delivered, deployed, monitored, and that it can handle the load.

### Why it's a good choice to get started

In frontend, you'll often be asked to understand backend and have a good sense of design/UX. In backend, they'll expect you to also know basic frontend and sometimes DevOps. These two domains have blurry boundaries — you quickly end up wearing multiple hats.

**DevOps is a domain of its own.** In a company, you won't be asked to code frontend features or design pages. Your scope is clear: infrastructure, deployment, automation, monitoring. You can focus on a single domain and become productive quickly.

It's also a field with high demand, and the core skills (Linux, Docker, CI/CD, Cloud) can be learned in a few weeks with practice. This course is built for that.

> **You don't know the terms below (Docker, Terraform, Kubernetes...)?** That's normal — that's exactly what the course will teach you, one by one. Start with [Module 0](00-prerequisites.md) and everything will become clear as you go.

## Learning Path

```
Module 0 (Git + WSL) ─▶ Module 1 (Linux) ─▶ Module 2 (Network) ─▶ Module 3 (Docker)
                                                                        │
                                             ┌──────────────┬───────────┼──────────────┐
                                             ▼              ▼           ▼              ▼
                                       Module 4        Module 8       Module 9    (all following
                                       (CI/CD)         (Monitoring)   (K8s)        modules)
                                             │         optional    awareness
                                             ▼
                                       Module 5
                                       (AWS)
                                             │
                                             ▼
                                       Module 6
                                       (Terraform)
                                             │
                                             ▼
                                       Module 7
                                       (Ansible)
                                       optional
```

**Legend:** Arrows show dependencies. Module 3 (Docker) is the crossroads — it unlocks CI/CD, K8s, and Monitoring. Modules 7, 8, and 9 are optional/awareness.

## The Hands-on Project

A simple **Task List**: React frontend + FastAPI backend. The app itself is trivial — it's the infrastructure around it that matters.

The code is in [`devops-project/`](devops-project/).

We evolve it with each module:
- **Module 0-1:** We clone it, we run it locally
- **Module 3:** We dockerize it
- **Module 4:** We add a CI/CD pipeline
- **Module 5:** We deploy it on AWS manually
- **Module 6:** We automate the infra with Terraform
- **Module 7:** We configure the server with Ansible
- **Module 8:** We monitor it with Prometheus + Grafana
- **Module 9:** We orchestrate it with Kubernetes

## How long does it take?

If you dedicate about **1 hour every 2 days**, you can finish the course in **6 to 8 weeks**. It's not a race — better to go slowly and understand than to skim through everything.

But the course is just the beginning. The DevOps world has **a huge number of technologies** and it's constantly evolving. This course gives you a solid foundation (Docker, CI/CD, AWS, Terraform, monitoring) — that's enough to land your first job. But you'll need to keep practicing and discovering other tools over time. See [After the Course — Going Further](aller-plus-loin.md).

What will take you the most time is not the course — it's **finding a job**. That's why you shouldn't wait until the end of the course to start preparing your resume and LinkedIn. Contact [Souhib TRABELSI](https://www.linkedin.com/in/souhib-trabelsi/) **before the end of the course** so he can help you build your profile (LinkedIn, resume, interview prep). With his support, it can go much faster.

> **Resume example:** [CV Souhib TRABELSI](assets/cv-exemple-souhib-trabelsi.pdf) — this is a backend developer profile, but you'll find a lot of DevOps in it (Docker, Terraform, Ansible, AWS, CI/CD, ECS) because as explained above, backend and DevOps are closely related. This is just an example to see how to structure a technical resume — adapt it to your own background and to a DevOps position.

## How to use this course

1. Follow the modules **in order** (each module depends on the previous ones)
2. **Type the commands yourself** — don't copy-paste without reading
3. When you're stuck, look at the 💡 hints before searching on Google
4. After each module, do the **Interview Corner** to check your understanding
5. The [cheatsheet](cheatsheet.md) is your quick reference for commands
6. The consolidated [interview questions](interview-questions.md) are your final review

## Required environment

- Windows with WSL2 + Ubuntu (see [Module 0](00-prerequisites.md))
- VS Code with the Remote WSL extension
- A GitHub account
- Internet connection

## Modules

| # | Module | File | Required |
|---|--------|------|----------|
| 0 | Prerequisites | [00-prerequisites.md](00-prerequisites.md) | ✅ |
| 1 | Linux | [01-linux-basics.md](01-linux-basics.md) | ✅ |
| 2 | Network | [02-networking.md](02-networking.md) | ✅ |
| 3 | Docker | [03-docker.md](03-docker.md) | ✅ |
| 4 | CI/CD | [04-cicd.md](04-cicd.md) | ✅ |
| 5 | AWS | [05-aws.md](05-aws.md) | ✅ |
| 6 | Terraform | [06-terraform.md](06-terraform.md) | ✅ |
| 7 | Ansible | [07-ansible.md](07-ansible.md) | Optional |
| 8 | Monitoring | [08-monitoring.md](08-monitoring.md) | Awareness |
| 9 | Kubernetes | [09-kubernetes.md](09-kubernetes.md) | Optional |

## A typical day as a DevOps engineer

> This question comes up often in interviews: "What does the job actually look like?"

**In the morning:**
- Check the **dashboards** (Grafana, Datadog) — is everything running smoothly? Any errors overnight?
- Read the **alerts** received during the night — sort between noise and real problems
- Review the **pull requests** waiting — code review, especially infrastructure changes (Terraform, Dockerfiles, CI/CD)

**During the day:**
- **Improve the infra** — optimize a slow CI/CD pipeline, upgrade a Kubernetes version, migrate a service to a new provider
- **Help the devs** — "my container is crashing", "the deployment doesn't work", "how do I configure the env variable in staging?"
- **Write infrastructure code** — Terraform for a new service, an Ansible playbook, a new GitHub Actions workflow
- **Automate** — anything done manually more than twice should be scripted

**When things go wrong (incident):**
- Diagnose: logs, metrics, traces
- Fix urgently (rollback, restart, scale up)
- Communicate with the team (status page, Slack)
- Write a **post-mortem** after the incident (what happened, how to prevent it from happening again)

**Key daily skills:**

| Skill | Why |
|-------|-----|
| Linux + terminal | You live in the terminal |
| Docker + containers | Everything runs in containers |
| CI/CD | You build and maintain pipelines |
| Cloud (AWS/GCP/Azure) | The infra is in the cloud |
| IaC (Terraform) | The infra is code |
| Monitoring | You need to know if it's working |
| Communication | You're the link between devs and prod |

## Resources

- [Cheatsheet](cheatsheet.md) — all the key commands in one file
- [Troubleshooting](troubleshooting.md) — the most common errors and how to fix them
- [After the Course — Going Further](aller-plus-loin.md) — tools to discover after the course + equivalents table

## Preparing for your interview

In a DevOps interview, there are 3 types of questions. Practice them **in this order**:

| Step | Question type | Resource |
|------|--------------|----------|
| **1. Definitions** | "What is a Docker container?", "What is the Terraform state?" | [Interview Questions](interview-questions.md) (Part 1) |
| **2. Experience** | "Tell me about a prod incident", "How do you handle a rollback?" | [Experience Questions](interview-experience.md) (QuickBite context) |
| **3. System design** | "How would you deploy this app for 50,000 users?" | [System Design Exercises](system-design-exercises.md) (5 scenarios) |

The [situational questions](interview-questions.md) (Part 2) mix all 3 types — practice after the 3 steps.
