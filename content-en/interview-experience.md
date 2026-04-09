# Preparing for Experience Questions — DevOps Interview

> In interviews, you'll be asked two types of questions: **technical** questions ("what is a VPC?") and **experience** questions ("tell me about a production incident you handled"). The first type is covered in [interview-questions.md](interview-questions.md). This file prepares you for the second type.

## Why this file exists

A DevOps recruiter always asks questions about your experience: incidents, deployments, technical choices, problems solved. If you're coming out of a training program or a course, you may not have real experience to talk about.

We're going to create a **fictional but realistic context** — a company, an infrastructure, problems, solutions. It's a support to help you practice answering in a structured and credible way. **This is not a script to recite** — it's a foundation you adapt to your own story.

> **If you have your own experience** (internship, apprenticeship, personal project, freelance), use it. The recruiter prefers a real story, even a small one, over a perfectly invented story. This file serves as a safety net if you have nothing to talk about, or as a model to structure your answers.

> **You're not expected to know everything.** In interviews, some technical choices were already in place when you arrived. Being able to say "that's how it was when I joined, and here's what I would have done differently" is a very mature answer. The recruiter isn't looking for someone who did everything — they're looking for someone who understands, thinks, and can explain.

---

## The context: QuickBite

**QuickBite** is a food delivery startup (like Uber Eats, but smaller). ~80 people, 12 developers, 2 DevOps (you + a senior colleague). You worked there for **1 year and a half**.

### The tech stack

| Component | Technology |
|-----------|------------|
| Frontend | React (Vite) |
| Backend | Python (FastAPI) |
| Database | PostgreSQL |
| Containers | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Cloud | AWS (EC2, RDS, ECS, S3) |
| IaC | Terraform |
| Monitoring | Prometheus + Grafana |

### The state of the infrastructure when you arrive

When you join QuickBite, everything is fragile:

- **1 single EC2** runs everything (backend + frontend + PostgreSQL) with Docker Compose
- **No CI/CD** — devs deploy via SSH: `ssh server` → `git pull` → `docker compose up -d`
- **No monitoring** — you find out the app is down when a user complains on Twitter
- **The database is in a Docker container** — no automatic backups, no RDS
- **Secrets are in a `.env` file on the server** — no centralized management
- **No Infrastructure as Code** — everything was created by hand in the AWS console

### What you did in 18 months

#### Phase 1 — Stabilize (Months 1-6)

When you arrive, the priority is to stop production from breaking every two days.

| Month | What you did | Why |
|------|------------------|----------|
| **Month 1** | Set up GitHub Actions (lint → test → build → push Docker Hub) | Devs were deploying untested code. A bug in production every 2 days. |
| **Month 1** | Wrote documentation for the existing infrastructure | Nobody knew what was running where. You mapped the EC2, Security Groups, DNS. |
| **Month 2** | Migrated PostgreSQL to RDS + cleaned up secret management (.env → GitHub Secrets) | DB in Docker = no backup. A dev had committed a token in Git. |
| **Month 2** | Set up separate environments (staging + prod) | Before, devs tested directly in production. You created a 2nd EC2 for staging. |
| **Month 3** | Handled a production incident (DB saturated during a promo) | PostgreSQL connections were exhausted. Cascading 502s. 2h of downtime. |
| **Month 4** | Added Prometheus + Grafana + Slack alerts | After the Month 3 incident, we couldn't afford not knowing what was going on. |
| **Month 4** | Resolved a full disk problem on the EC2 | Docker images were piling up. The server froze at 3 AM. |
| **Month 5** | Moved everything to Terraform (VPC, EC2, RDS, Security Groups) | The infrastructure was created by hand. Impossible to recreate or document what existed. |
| **Month 5** | Diagnosed a memory leak in the backend | The backend container crashed every ~12h. Quickfix: auto restart. Permanent fix by the devs. |
| **Month 6** | Migrated the backend to ECS Fargate | A single EC2 wasn't enough during peak hours (lunch and dinner). Need for auto-scaling. |

#### Phase 2 — Professionalize (Months 7-12)

Production is stable. Now we structure things so it holds at scale.

| Month | What you did | Why |
|------|------------------|----------|
| **Month 7** | Set up a staging environment on ECS (identical to production) | Staging on a separate EC2 didn't reflect production (ECS). Bugs were slipping through. |
| **Month 7** | Added health checks on all services | ECS needs to know if a container is healthy to replace it. Without health checks, zombie containers stayed alive. |
| **Month 8** | Migrated the frontend to S3 + CloudFront | The frontend was served by nginx in a container. On S3+CloudFront it's faster (CDN), cheaper, and infinitely scalable. |
| **Month 8** | Handled an incident: expired SSL certificate | The site displayed "Not Secure" on a Saturday morning. Quickfix: manual renewal. Permanent fix: auto-renewal with Let's Encrypt via AWS Certificate Manager. |
| **Month 9** | Configured automatic RDS backups + tested restoration | We had automatic backups but nobody had ever verified we could actually restore. Test: full restoration in 15 min. |
| **Month 9** | Set up Ansible for server configuration | There were still EC2s for workers (background order processing). Ansible automates their configuration. |
| **Month 10** | Set up centralized logs (CloudWatch Logs) | Logs were in each container. To debug, you had to connect to each instance. CloudWatch centralizes everything. |
| **Month 10** | Incident: a dev deleted a table in staging thinking they were on local | No damage in production (thankfully), but it showed the need to better separate access. We restricted IAM permissions. |
| **Month 11** | Optimized the CI/CD pipeline (Docker cache, parallel tests) | The pipeline took 12 min. With Docker cache and parallel tests, we got it down to 4 min. |
| **Month 12** | Added Route 53 + custom domain (quickbite.fr) | The app was accessible via a public IP. We bought a domain and configured DNS. |

#### Phase 3 — Scale (Months 13-18)

The company is growing. More devs, more users, more services.

| Month | What you did | Why |
|------|------------------|----------|
| **Month 13** | Added a 2nd microservice (notification service) on ECS | The team developed a notification service (email + push). It needed to be deployed, monitored, and integrated into the CI/CD pipeline. |
| **Month 13** | Incident: traffic spike on New Year's Eve | ECS auto-scaling responded well but RDS connections were near the limit. We upgraded the RDS instance (db.t3.small → db.t3.medium). |
| **Month 14** | Set up SQS for order processing | The backend was processing orders synchronously. During spikes, requests timed out. We decoupled with an SQS queue + ECS worker. |
| **Month 15** | Trained the devs on Docker best practices | Devs were writing 900 MB Dockerfiles without .dockerignore. You ran a training session + provided a template Dockerfile. |
| **Month 15** | Incident: deployment breaks payments (on a Friday) | Rollback in 5 min thanks to image tagging by commit. Added tests on the payment endpoint. Rule: no deployments on Friday after 4 PM. |
| **Month 16** | Set up a WAF (Web Application Firewall) | Bots were sending malicious requests. The WAF filters suspicious requests before they reach the app. |
| **Month 17** | Migrated the Terraform state to S3 + DynamoDB (remote state) | Your senior colleague and you were working on the same Terraform. With local state, you were overwriting each other. Remote state solves that. |
| **Month 18** | Documented the entire infrastructure + runbooks for common incidents | You're preparing your departure (or the arrival of a new DevOps). Without documentation, all your knowledge leaves with you. |

### Quickfix vs permanent fix — a reality of the job

In DevOps, you'll often have to make a choice: **do I fix it properly now (takes 2 days) or do I put a band-aid so production works again (takes 10 minutes)?**

The answer: **band-aid first, proper fix next.** When production is down and users can't pay, you don't have 2 days ahead of you. You apply a quickfix to get production back up, and you schedule the real fix for the following week.

This isn't hacking — it's priority management. The recruiter wants to see that you can do both.

Here are concrete examples we experienced at QuickBite:

| Incident | Quickfix (minutes) | Permanent fix (days) |
|----------|-------------------|----------------------|
| DB saturated (100 max connections) | Increase `max_connections` to 300 on RDS | Devs implement a **connection pool** in the code |
| Disk full on EC2 (Docker images) | `docker system prune -a` to free space | **Cron job** for daily cleanup. Later, migration to ECS |
| Memory leak (crash every ~12h) | **auto restart** of the container every 8h | Devs find and fix the leak (list never cleared) |
| Expired SSL certificate | Manual certificate renewal | **Auto-renewal** with AWS Certificate Manager |
| New Year's spike (RDS connections near limit) | Scale up the RDS instance (t3.small → t3.medium) | Add RDS **Read Replicas** + suggest devs implement a connection pool |
| Deployment breaks payments | **Rollback** to previous Docker image (5 min) | Communicate with devs so they add tests on the payment endpoint |

**The key in interviews:** when you talk about an incident, mention both steps. "First I did X to get production back up (quickfix), then we fixed it properly by doing Y (permanent fix)." This shows that you can handle the emergency AND that you don't let the band-aid become the permanent solution.

### Communication — the most important skill

A point that beginners underestimate: **communication is just as important as technical skills**. The first thing to do when you detect a problem isn't to fix it — it's to **notify your team**.

**The reflex for every problem:**

1. **Communicate immediately** — "There's a problem in production, I'm on it." A message on Slack/Teams, right away. Even if you don't know what's going on yet. The team knows someone is handling it, support can notify users, nobody panics.
2. **Diagnose** — identify the problem with your tools (monitoring, logs, metrics)
3. **Update the team** — "The DB is saturating, I'm increasing connections urgently." The more details you give, the more the team can help or take over if needed.
4. **Apply the quickfix** — get production back up
5. **Communicate the resolution** — "It's restored. Here's what happened and what we're going to do so it doesn't happen again."
6. **Propose the permanent fix** — "I think we need a Redis to cache these requests. I can deploy it, the devs will integrate it into the code."
7. **Deploy the infrastructure** — you deploy the Redis (ElastiCache), configure the network, access. You communicate to the devs: "the Redis is ready, here's the endpoint."
8. **Verify** — once the devs have integrated the solution, you verify on the monitoring that the problem is resolved

**What's your responsibility (DevOps):** diagnose, deploy infrastructure (Redis, Read Replicas, scaling, network config), configure monitoring and alerts.

**What's the devs' responsibility:** fix the code (SQL indexes, connection pool, cache integration). You can suggest it, but you don't touch the application code.

**In interviews**, always mention communication. "The first thing I did was notify the team on Slack that there was a problem and that I was on it." It's a simple sentence but it shows a maturity that many candidates lack.

### Post-mortem — The document you write after every incident

After every production incident, you write a **post-mortem**: a document that summarizes what happened, why, and how to prevent it from happening again. It's not to blame anyone — it's for the team to learn.

Here's the post-mortem from the Month 3 incident at QuickBite (DB saturated) — this is exactly the format you'll find in companies:

```
POST-MORTEM — Incident of March 15, 2025
=========================================

Title: PostgreSQL connection saturation during marketing promo
Severity: P1 (service completely unavailable)
Duration: 2h10 (2:20 PM → 4:30 PM)
Impact: 100% of users affected. Unable to place orders.
        Estimate: ~850 lost orders.

WHAT HAPPENED
-------------
- The marketing team launched a "free delivery" promo without notifying tech
- Traffic was multiplied by 5 in 30 minutes
- PostgreSQL connections saturated (100/100 — the default limit)
- The backend started returning cascading 502s
- Quickfix applied (~15 min after detection): max_connections increased to 300 + restart
- Service restored. Post-investigation: the code was opening one connection per request
  without closing it.

ROOT CAUSE
----------
The backend code was opening a new PostgreSQL connection for each HTTP request
without closing it after use. Under normal conditions (low traffic), connections
would eventually timeout and be released. During the promo (traffic x5), all 100
connections were taken in 20 minutes.

Default PostgreSQL configuration: max_connections = 100.
No alert on the number of active connections.

QUICKFIX APPLIED
-----------------
- max_connections increased from 100 to 300 on RDS
- Backend restarted to release stuck connections

PERMANENT FIX
-------------
- [DEVS] Implement a connection pool (reuse connections) — delivered March 18
- [DEVOPS] Add a Prometheus alert: "active connections > 80%" — delivered March 16
- [DEVOPS] Add a Grafana "DB connections" dashboard — delivered March 16
- [PROCESS] Rule: every promo must be communicated to the tech team 48h in advance

LESSONS LEARNED
---------------
1. We had no monitoring on DB connections → we were flying blind
2. The default config (100 connections) had never been reviewed
3. Marketing ↔ tech communication was non-existent
```

> **Tip:** you can use an AI (like opencode, seen in Module 0) to help you write a post-mortem. Give it the incident details (what happened, the timeline, what you did) and it will handle the formatting. It's a huge time saver — what matters is the content, not the writing.

### Runbook — The instruction manual for common incidents

A **runbook** is a document that says "if X happens, do Y." It's like a recipe for solving a problem. The goal: anyone on the team can resolve the incident by following the steps, even at 3 AM when they're half asleep.

Here's an example of a runbook we wrote at QuickBite after the Month 3 incident:

```
RUNBOOK — The database is not responding
=========================================

SYMPTOMS
---------
- Grafana alerts: 5xx error rate rising
- Backend logs show: "connection refused" or "too many connections"
- Users see a blank page or an error

DIAGNOSIS (in this order)
---------------------------
1. Is the backend running?
   $ docker ps                    # or on ECS: check tasks in the console
   → If the container is "Exited" or in restart loop → check the logs (step 2)
   → If the container is running → go to step 3

2. What do the backend logs say?
   $ docker logs backend --tail 50
   → "ModuleNotFoundError" → build problem, not DB. Rebuild the image.
   → "connection refused" → DB is down. Go to step 3.
   → "too many connections" → connections are saturated. Go to step 4.

3. Is the database accessible?
   $ psql -h <RDS_ENDPOINT> -U admin -d tasks -c "SELECT 1;"
   → If it works → the problem is on the backend side, not the DB side
   → If "connection refused" → check RDS status in the AWS console
   → If "timeout" → check the Security Group (port 5432 open from the backend?)

4. Are connections saturated?
   $ psql -h <RDS_ENDPOINT> -U admin -d tasks -c "SELECT count(*) FROM pg_stat_activity;"
   → If close to the max (100 by default):
     QUICKFIX: increase max_connections in RDS settings + restart backend
     PERMANENT FIX: implement a connection pool (ticket for the devs)

5. Is the RDS disk full?
   → AWS Console → RDS → Monitoring → FreeStorageSpace
   → If < 1 GB: increase storage in the console (takes effect immediately)

ESCALATION
----------
- If not resolved in 30 min → notify the lead dev
- If not resolved in 1h → notify the CTO
- Always update the #incidents channel on Slack

AFTER THE INCIDENT
-------------------
- Write a post-mortem (see the template above)
- Create tickets for the permanent fix
- Update this runbook if new steps were identified
```

**In interviews**, if you're asked "how do you document your infrastructure?", you can answer: "We had runbooks for every common incident — database down, disk full, broken deployment. That allows anyone on the team to resolve an incident by following the steps, even without knowing the infra by heart."

---

## How to use these questions

**The principle:** For this exercise, you ARE the DevOps at QuickBite. You worked there for 1 year and a half. You experienced everything described in the timeline above — the incidents, the migrations, the struggles. When the recruiter asks you a question, you answer by talking about YOUR experience at QuickBite, as if you were really there.

Here you have the context in front of you. **In a real interview, you won't have this page.** You'll either need your notes or have to remember your experiences. That's why you need to practice: the more you repeat, the more natural the stories become.

Reread the context and timeline carefully before starting. The better you know them by heart, the smoother your answers will be on the big day.

**For each question, follow this order:**

1. **Read the question** and answer as if you were in an interview — out loud is best. You're the DevOps at QuickBite, you're telling what you experienced there. Don't look at the hints right away.
2. **Open the hints** — they give you leads on what points to mention. Compare with your answer and rephrase if you forgot things.
3. **Open the model answer** — compare with yours. Your answer is different? That's normal. What matters is the structure (context → problem → action → result), not the exact words.
4. **Open "What the recruiter wants to hear"** — this shows you what the recruiter is really evaluating. Check that your answer covers these points.

---

> **IMPORTANT — For your real interviews:**
>
> The problems described in this file (saturated DB, memory leak, full disk, broken deployment, expired certificate...) are **real everyday DevOps problems**. They happen in every company.
>
> **Even if you never encountered these problems in your actual experience, say that it happened to you.** That's the difference between a good DevOps and someone who just knows terms: it's the one who encountered the most problems and solved them (or tried to solve them). A recruiter wants to hear stories of struggles, not just "everything was fine."
>
> **Before each interview:** prepare 3-4 stories of problems you "experienced" (adapted to the context of the company where you worked or did an internship). Write them down. Repeat them out loud. This file gives you the material — it's up to you to adapt it to YOUR background.
>
> This isn't lying — it's preparing. All candidates prepare their stories before an interview. The one who shows up unprepared and says "I never had a problem in production" isn't credible.

---

## The questions

### 1. "What's the biggest production problem you've resolved?"

> Think: in the QuickBite timeline, it's **Month 3**. What happened? How would you have reacted?

<details>
<summary>💡 Hints</summary>

- Think about the Month 3 incident: the marketing promo that wasn't communicated
- What symptoms did you see? (HTTP codes, app behavior)
- How did you identify the cause? (logs, DB queries)
- What did you do urgently? (increase connections)
- What did you do afterward so it doesn't happen again? (code fix, monitoring)

</details>

<details>
<summary>✅ Model answer</summary>

"The biggest incident I handled was at QuickBite — a database saturation during a marketing promo. Traffic was multiplied by 5 in 30 minutes. The PostgreSQL connection pool was at 100 by default, and our code wasn't closing connections properly. In 20 minutes, all 100 connections were taken, the backend was returning cascading 502s.

**How I reacted:**
1. First I identified the problem — the logs showed `too many connections`. I confirmed with `SELECT count(*) FROM pg_stat_activity` on the DB.
2. **Quickfix:** I increased `max_connections` to 300 urgently on RDS and restarted the backend → production was working again.
3. **Permanent fix:** I reported the diagnosis to the devs. They fixed the code to use a **connection pool** (reuse connections instead of opening a new one for each request). That's application code, not infra — my role was to diagnose and provide the data.
4. I added a Prometheus alert on the number of active connections so we wouldn't be caught off guard again.

**What I took away from it:** It's this incident that pushed me to set up monitoring (Prometheus + Grafana). Before that, we were flying blind."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You have a **method** (no panic, you diagnose before acting)
- You explain the **root cause** (not just "I restarted it")
- You put in place **measures so it doesn't happen again** (monitoring, alerts, code fix)
- You're able to **communicate** during the incident (informing the team, support)

**Possible follow-ups:**
- "How long did the incident last?" → ~2h between the first 502s and back to normal
- "Did you do a post-mortem?" → Yes, we documented: cause, timeline, actions taken, preventive measures
- "Was it your fault?" → No, it was a combination of circumstances (promo not communicated + default config + no monitoring). What matters is the fix, not the blame.

</details>

---

### 2. "Have you ever had performance issues?"

> Think: after Month 4 (monitoring), we discover slow endpoints. How would you diagnose? What progressive solutions would you propose?

<details>
<summary>💡 Hints</summary>

- The monitoring (Grafana) revealed a 2.5 second endpoint
- On the DevOps side, you enabled slow query logs on PostgreSQL to diagnose
- The fixes (indexes, cache, queries) are the backend devs' job — you diagnose, escalate the problem, and provide the metrics
- Mention the collaboration with the devs — it's your role to give them the data so they can fix it

</details>

<details>
<summary>✅ Model answer</summary>

"Yes, we had an endpoint that took 2.5 seconds to respond. It's thanks to the monitoring I set up that we caught it — the Grafana graph clearly showed a latency spike on `/api/orders`.

**My role (DevOps) — the diagnosis:**
- I enabled **slow query logs** on PostgreSQL (queries taking more than 500ms)
- I identified the problematic query and escalated the issue to the devs with the data: "this query takes 2.5s, it does a SELECT * with 3 JOINs on 500k-row tables, without indexes"
- I added a dedicated Grafana dashboard for response times per endpoint to track the evolution

**What I proposed as solutions:**
- Add indexes on the columns used in WHERE and JOIN clauses
- Set up a Redis cache for frequent queries (the restaurant list doesn't change every second)
- Review SQL queries to stop doing `SELECT *`

**What I did on the infra side:**
- I **deployed a Redis instance** (ElastiCache on AWS) and configured the network access (Security Group)
- The devs then used this Redis in their code to cache query results

**What the devs did on the code side:**
- Added indexes → 2.5s to 200ms
- Integrated Redis cache into the application
- Reviewed SQL queries

**My role after the fix:** Verify on Grafana that the p95 dropped (from 2.5s to 150ms), and add an alert if any endpoint exceeds 1 second.

**In a nutshell:** The DevOps diagnoses, proposes solutions, deploys the necessary infrastructure (Redis, Read Replicas, etc.) — the devs implement in the code. It's teamwork and communication."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You know how to **diagnose** with DevOps tools (monitoring, slow query logs, metrics)
- You make the **distinction between your role and the devs' role** — you don't fix the code, you provide the data so they can
- You know how to **communicate a problem** clearly and actionably ("this query, this table, this time")
- You **verify** that the fix worked (monitoring after correction)

</details>

---

### 3. "Have you ever managed a production deployment? Using what tool?"

> Think: compare the state when you arrived (SSH + git pull) and what you set up in **Month 1**. Describe the before/after.

<details>
<summary>💡 Hints</summary>

- Describe first how it was BEFORE (manual, risky, no tests)
- Then what you set up (GitHub Actions, 4 pipeline steps)
- Mention the concrete result (how many deployments per day, team confidence)
- If asked "why GitHub Actions?", the answer is simple: the code was on GitHub

</details>

<details>
<summary>✅ Model answer</summary>

"When I arrived, deployment was manual — SSH to the server, `git pull`, `docker compose up`. It broke often and nobody dared deploy on Fridays.

I set up a GitHub Actions pipeline in 4 steps:
1. **Lint** (Ruff + Oxlint) — checks code quality
2. **Tests** (Pytest) — verifies nothing is broken
3. **Build** — builds Docker images and tags them with the commit hash
4. **Push** — sends images to Docker Hub, only on the main branch

Deployment to the server was then done via a script that pulls the new image and restarts the containers. Later, when we moved to ECS, deployment was handled directly by AWS (we push the image, ECS deploys it automatically).

**Result:** We went from 'we deploy when we dare' to 3-4 deployments per day, with confidence."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You know the **steps of a pipeline** (lint → test → build → deploy)
- You can explain the **before/after** (the concrete improvement)
- You understand why each step exists (fail fast)

**Possible follow-ups:**
- "Why GitHub Actions and not GitLab CI?" → The code was on GitHub, no reason to migrate. GitLab CI is great too, it's just an ecosystem choice.
- "How long did the pipeline take?" → ~4 minutes (lint 30s, tests 1min, build 2min, push 30s)

</details>

---

### 4. "What do you do if a production deployment goes wrong?"

> Think: on a Friday, a deployment breaks payments. How do you react? What's your rollback plan?

<details>
<summary>💡 Hints</summary>

- How do you detect the problem? (monitoring, Grafana alerts)
- How do you rollback? (Docker images tagged by commit)
- How long does it take? (a few minutes if well prepared)
- What do you do AFTER? (identify the bug, add a test, post-mortem)
- Mention the deployment strategy (rolling update, health checks)

</details>

<details>
<summary>✅ Model answer</summary>

"We had this case — a deployment on a Friday that broke payments. The Grafana alert detected a spike of 500s on the `/api/checkout` endpoint in 2 minutes.

**The rollback:**
1. We immediately redeployed the **previous** Docker image (that's why we tag images with the commit hash — we can go back to any version)
2. On ECS, it takes ~30 seconds: you change the image tag in the task definition and ECS redeploys
3. Total downtime: ~5 minutes

**Afterward:**
- We identified the bug in the PR
- We added a test that covers this specific case
- We added a rule: no deployment on Friday after 4 PM (culture, not technical)

**In general, our rollback strategy:**
- Every Docker image is tagged with the commit hash → we can go back to any version
- Monitoring detects problems within minutes (5xx error rate)
- We do **rolling updates** on ECS → if the new container doesn't pass the health check, ECS keeps the old one"

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You have a **rollback plan** (not "we pray")
- You react **fast** (monitoring + alerts)
- You learn from your mistakes (adding tests, team rules)
- You know about **deployment strategies** (rolling update, blue-green, canary)

</details>

---

### 5. "What type of deployment did you set up and why?"

> Think: in **Month 6**, we migrate to ECS. What deployment type do we choose? Why not the others?

<details>
<summary>💡 Hints</summary>

- There are 3 main strategies: rolling update, blue-green, canary
- Think about the QuickBite context: small team (2 DevOps), limited budget
- The recruiter wants you to know all 3 AND justify your choice
- Also say what you'd do with more resources

</details>

<details>
<summary>✅ Model answer</summary>

"We used a **rolling update** on ECS Fargate. That means when we deploy a new version, ECS replaces containers one by one — it launches a new container with the new image, verifies it responds to the health check, then deletes the old one. During the transition, both versions coexist.

**Why rolling update and not something else:**
- **Not blue-green**: it requires double the infrastructure (two complete environments). For our size and budget, it was overkill.
- **Not canary**: it requires a traffic routing system (send 5% to v2, 95% to v1). We didn't have the tooling and it was complex for a team of 2 DevOps.
- **Rolling update**: native in ECS, no additional cost, automatic rollback if the health check fails. It's the right compromise for our size.

If we had more traffic and a larger DevOps team, I would have explored canary deployment to test new versions on a small percentage of users before deploying to everyone."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You know **multiple strategies** (rolling, blue-green, canary)
- You can **justify a choice** based on context (budget, team size, complexity)
- You don't suggest the most complex solution just to impress
- You know what you'd do with **more resources**

</details>

---

### 6. "What would you have done differently?"

> Think: look at the timeline. Some things should have been done earlier. Which ones? Why didn't we do it? (startup context, moving fast)

<details>
<summary>💡 Hints</summary>

- Monitoring came in Month 4 — that was too late (after the incident)
- DB in Docker — risk of data loss
- Infra created by hand before Terraform — painful to import afterward
- These aren't "mistakes" — they're startup compromises. Explain that.

</details>

<details>
<summary>✅ Model answer</summary>

"Looking back, 3 things:

1. **Monitoring from day 1.** We added it in month 4, after an incident. If we'd had it from the start, we would have seen performance problems before they became incidents. It's a 2-3 day investment that saves weeks of debugging.

2. **RDS right away instead of PostgreSQL in Docker.** A DB in a container without backup is a ticking time bomb. We were lucky not to lose data before the migration. In production, the database must be managed (RDS, Cloud SQL, etc.).

3. **Terraform before creating resources by hand.** We first created everything in the AWS console, then had to import everything into Terraform in month 5. It was painful. If I had to do it again, I'd start with Terraform from the first EC2.

These three choices were 'move fast to ship' choices, which makes sense in a startup. But the time lost catching up is always greater than the time invested in doing it right from the start."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You have **hindsight** on your own decisions
- You can tell the difference between "acceptable technical debt" and "avoidable mistake"
- You don't blame others ("it was like that when I arrived" → OK, but what would YOU have done?)
- You propose **concrete improvements**, not just "redo everything from scratch"

</details>

---

### 7. "How do you manage secrets?"

> Think: in **Month 2**, a dev commits a `.env` with Stripe keys. What do you do urgently? What do you set up so it doesn't happen again?

<details>
<summary>💡 Hints</summary>

- The immediate reaction: change the compromised secrets (don't just delete the commit — Git history keeps everything)
- Preventive measures: .gitignore, pre-commit hooks (gitleaks), GitHub Secrets
- Where to store secrets in production: environment variables, not in files
- Regular rotation of secrets

</details>

<details>
<summary>✅ Model answer</summary>

"We had an incident where a dev committed a `.env` with Stripe API keys to a public repo. That forced us to change all secrets urgently.

**What we set up afterward:**
1. **`.gitignore` verified** — `.env` is in the `.gitignore` of all repos
2. **Pre-commit hook** with `gitleaks` — scans commits BEFORE they're pushed, blocks if a secret is detected
3. **GitHub Secrets** for CI/CD — secrets are never in the code, they're injected by the pipeline
4. **Environment variables on the server** — secrets are in the ECS config (task definition), not in files
5. **Regular rotation** — we change DB passwords and API tokens every 3 months

The rule: a secret must **never** appear in the code or in Git. Even in a private repo — a private repo can become public, an employee can leave, etc."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You have a **secret management policy** (not just "we're careful")
- You know the **tools** (gitleaks, GitHub Secrets, Vault)
- You know how to react to a **security incident** (change secrets urgently, not just delete the commit)
- You take **preventive measures** (pre-commit hooks, rotation)

</details>

---

### 8. "Describe your typical day as a DevOps"

> Think: with everything you know about QuickBite (monitoring, CI/CD, helping devs, incidents), how does a day go?

<details>
<summary>💡 Hints</summary>

- Morning: what do you check first? (dashboards, alerts)
- During the day: what types of tasks? (PRs, helping devs, improving infra, automation)
- When things go wrong: what's your method? (diagnose, fix, communicate, post-mortem)
- What ratio of reactive (incidents, help) vs proactive (improvement, automation)?

</details>

<details>
<summary>✅ Model answer</summary>

"My typical day at QuickBite:

**Morning (30 min):**
- Check the **Grafana dashboards** — is everything running well? Any errors overnight?
- Review **alerts** received during the night (Slack + email) — sort between noise and real problems
- Read the **Pull Requests** waiting — especially those touching the Dockerfile, docker-compose, CI/CD pipeline, or Terraform config

**During the day:**
- **Help the devs** — "my container crashes", "the pipeline fails", "how do I configure this env variable in staging?"
- **Improve the infra** — optimize the CI pipeline (the build was too slow → added Docker cache), add a missing alert, update a version
- **Write infra code** — Terraform for a new service, modify the docker-compose, write a new GitHub Actions workflow
- **Automate** — anything done by hand more than twice should be scripted

**When things go wrong (incident):**
- Diagnose: logs, metrics, traces
- Fix urgently (rollback, restart, scale up)
- Communicate with the team (Slack, status page)
- Write a **post-mortem** after the incident

I'd say it's 40% reactive (helping devs, incidents) and 60% proactive (improving infra, automating, anticipating)."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You have a **routine** (monitoring in the morning, no surprises)
- You know how to **prioritize** (incidents > helping devs > continuous improvement)
- You're **proactive** (you don't wait for things to break)
- You're a **facilitator** for the devs (you unblock them, you don't block them)
- You automate (the DevOps philosophy)

</details>

---

### 9. "Have you ever had to put a temporary fix in production?"

> Think: in the timeline, we had a full disk and a memory leak. In both cases, we put a band-aid first. Which one? And then, what was the real solution?

<details>
<summary>💡 Hints</summary>

- Full disk: what do you do urgently to free space? And then, how do you prevent it from happening again?
- Memory leak: the container crashes every 12h. How do you keep production alive while finding the bug? And then, how do you find the leak?
- The recruiter wants to see that you know the difference between "putting out the fire" and "installing a smoke detector"

</details>

<details>
<summary>✅ Model answer</summary>

"Yes, several times. The most memorable was the memory leak we had on the backend. The container crashed every 12 hours or so — RAM would climb progressively until it hit the limit, and the container was killed by Docker (OOM kill, exit code 137).

**The quickfix (10 minutes):**
We configured Docker to restart the container automatically (`restart: always`), and added a health check that verifies the API responds. Since memory took ~12h to saturate, a restart every 8h was enough to keep production stable. It's ugly, but users no longer saw outages.

**The permanent fix (3 days):**
With a dev, we profiled the application. We found that an in-memory list was storing the request history for debugging — it grew with every request and was never cleared. The dev fixed the code (limit the list to the last 1,000 entries), and memory consumption became stable.

**The other case: full disk.** At 3 AM, alert: the EC2 server is unresponsive. The disk was full — Docker images were piling up after each deployment (we had a new image on every commit, never cleaned up).

Quickfix: `docker system prune -a` via SSH → 8 GB freed → server is back.
Permanent fix: a cron job that runs `docker system prune` every day at 4 AM. And in month 6, the migration to ECS eliminated the problem completely (no more local image management).

**What I take away from it:** A quickfix isn't shameful — it's a necessity when production is down. But you must ALWAYS plan the permanent fix right after. The danger is when the quickfix becomes the permanent solution and everyone forgets there's a real problem underneath."

</details>

<details>
<summary>What the recruiter wants to hear</summary>

- You know the difference between **urgency** (get production back up) and **correction** (solve the root cause)
- You don't look down on quickfixes — you understand they're necessary
- You don't stop at the quickfix — you always plan the real fix
- You know how to **diagnose** (memory profiling, disk checking) and not just "restart and pray"
- You know the warning signs (exit code 137 = OOM, disk at 100%)

**Possible follow-ups:**
- "How long did the quickfix last before the real fix?" → The memory leak: 1 week (time for the devs to profile and fix the code). The disk: the cron held for 2 months until the ECS migration.
- "How do you know the real fix worked?" → Monitoring (Grafana): we watch the memory curve after the fix. If it's stable → it's fixed.

</details>

---

## Recap — Which question shows what

| Question | What the recruiter evaluates |
|----------|--------------------------|
| Biggest production problem | Your diagnostic method + crisis management |
| Performance issues | Your ability to measure, diagnose, and resolve |
| Production deployment | Your concrete CI/CD knowledge |
| If it goes wrong | Your rollback plan + your reactivity |
| Type of deployment | Your technical choices justified by context |
| What you'd do differently | Your hindsight + your maturity |
| Secret management | Your security rigor |
| Typical day | Your day-to-day vision of the job |
| Temporary fix in production | Your urgency management + quickfix vs permanent fix |

---

## Final tips

- **Structure your answers**: Context → Problem → What you did → Result. This is the STAR method (Situation, Task, Action, Result).
- **Be concrete**: "I enabled slow query logs, identified the problematic query, and deployed a Redis for caching" is better than "I optimized the database."
- **Admit what you don't know**: "I haven't had the chance to use Kubernetes in production, but I practiced with minikube and I understand the concepts" → that's a good answer.
- **Adapt the context**: If you have real experience (even a personal project), use it. The recruiter will sense it's authentic.
- **Don't make things up**: If the recruiter digs and you don't know, say so. "I don't know, but here's how I would look for the answer" is always better than making something up.
