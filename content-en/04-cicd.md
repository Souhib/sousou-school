# Module 4: CI/CD (GitHub Actions)

> **Prerequisites:** Module 0 (Git, GitHub), Module 3 (Docker -- build, images)

> **In a nutshell:** You automate the verification and deployment of your code with GitHub Actions. On every push, a pipeline checks the code (lint), runs the tests, builds Docker images and pushes them to Docker Hub -- without any human intervention.

> In Module 3, you learned how to build Docker images and run them with `docker compose`. But who builds those images when you push your code? Who checks that the tests pass? Who pushes the images to Docker Hub? That's the role of CI/CD -- automating all of that.

## What is CI/CD and why does it exist?

**The problem:** Without CI/CD, every deployment is manual. Someone runs the tests on their machine, someone else does the build, a third person deploys via SSH. It's slow, risky, and a source of human error. "I forgot to run the tests before deploying" -- boom, production is broken.

It's the difference between baking each pizza by hand and having an automated oven with a conveyor belt.

**CI (Continuous Integration):** On every push, we automatically check that the code is clean (lint) and that it works (tests). We don't wait until the night before delivery to find out it's broken.

**CD (Continuous Delivery / Deployment):**
- **Delivery** = the code is ready to be deployed (manual button)
- **Deployment** = the code is deployed automatically if everything is green

**The analogy:** An assembly line in a factory. You push the raw material (the code) onto the conveyor belt. Station 1 = quality control (lint). Station 2 = taste test (tests). Station 3 = packaging (build). Station 4 = delivery (deploy). If a defect is detected at any station, the line stops. This is the "fail fast" principle.

## The 4 classic stages of a pipeline

| Stage | What it does | Analogy | Tools (for us) |
|-------|-------------|---------|----------------|
| **Lint** | Checks code style and quality (syntax errors, unused variables, bad practices) -- like a spell checker for code | Spell checker | Ruff (Python), Oxlint (JS) |
| **Test** | Checks that the code does what it should | Tasting the dish | Pytest |
| **Build** | Compiles/packages the application | Packaging the dish | Docker build |
| **Deploy** | Puts it in production | Delivering to the customer | Docker push |

These stages run in sequence. If lint fails, no tests. If tests fail, no build. Fail fast.

## GitHub Actions -- The basics

GitHub Actions runs workflows (pipelines) defined in YAML files in `.github/workflows/`.

### Vocabulary

| Term | What it is |
|------|-----------|
| **Workflow** | The complete pipeline (the YAML file) |
| **Trigger** | What triggers the workflow (`on: push`) |
| **Job** | A group of steps that run on the same machine |
| **Step** | An individual action within a job |
| **Runner** | The machine (a remote server) that runs the job. GitHub provides them for free -- you don't need to install anything. |

### Structure of a workflow

A YAML file in `.github/workflows/` describes the pipeline. Here's a minimal example with each line explained:

```yaml
# .github/workflows/ci.yml          <- the file must be in this exact folder
name: CI Pipeline                    # The name shown in GitHub's Actions tab

on:                                  # "on" = WHEN does this pipeline trigger?
  push:                              #   -> when someone pushes code
    branches: [main]                 #   -> but only on the "main" branch
  pull_request:                      #   -> OR when a Pull Request is created/updated
    branches: [main]                 #   -> targeting the "main" branch

jobs:                                # The list of jobs (groups of steps) to run
  lint:                              # The job name (you choose whatever name you want)
    runs-on: ubuntu-latest           # On which machine to run? -> an Ubuntu server provided by GitHub
    steps:                           # The list of steps for this job

      - uses: actions/checkout@v4    # "uses" = use a pre-made action by someone else
                                     # "actions/checkout" = an official GitHub action that downloads
                                     # your code onto the runner (otherwise the runner is empty, it doesn't have your code)
                                     # "@v4" = version 4 of this action

      - name: Setup uv               # "name" = a readable name for this step (shown in the UI)
        uses: astral-sh/setup-uv@v4  # Installs uv on the runner (like you did on your machine)

      - run: cd backend && uv run ruff check .
                                     # "run" = execute a bash command directly
                                     # (unlike "uses" which calls a pre-made action)
```

**In a nutshell -- the 4 keywords to remember:**

| Keyword | What it does | Example |
|---------|-------------|---------|
| `on:` | When the pipeline triggers | `on: push` = on every push |
| `runs-on:` | On which machine | `ubuntu-latest` = a free Ubuntu server from GitHub |
| `uses:` | Use a pre-made action | `actions/checkout@v4` = download the code |
| `run:` | Execute a bash command | `run: uv run pytest` = run the tests |

> **`uses` vs `run`:** `uses` calls a "plugin" (a ready-to-use action written by someone else -- install Python, log in to Docker Hub, etc.). `run` executes a bash command that YOU write. If an action exists for what you want to do, use `uses`. Otherwise, `run`.

## Hands-on Project: Complete CI/CD Pipeline

### 1. Configure linting in the project

The backend uses **Ruff** (ultra-fast Python linter) and the frontend uses **Oxlint** (fast JS linter).

Check that the configs exist:

**`backend/pyproject.toml`** (already created):
```toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "W"]
```

**`frontend/oxlintrc.json`** (already created):
```json
{
  "rules": {
    "no-unused-vars": "warn",
    "no-console": "off",
    "eqeqeq": "warn"
  }
}
```

Test locally:
```bash
# Backend
cd ~/devops-project/backend
uv run ruff check .
# All checks passed!

# Frontend
cd ~/devops-project/frontend
bunx oxlint .
# Finished in xxxms
```

### 2. Verify the tests

```bash
cd ~/devops-project/backend
uv run pytest
# ===== 7 passed, 4 deselected in 0.5s =====
```

**What does "4 deselected" mean?** The project contains two families of tests, and `pytest` only runs one of them by default.

| | **Unit** tests | **Integration** tests |
|---|---|---|
| They test | Your code on its own | Your code **together with** the services it talks to |
| They need | Nothing | A database, a server, an external service... |
| Duration | Milliseconds | Seconds |
| When | On every save, continuously | On every push, in CI |

**Why both?** Remember Module 3: your `main.py` has **two modes**. Without `DATABASE_URL` it stores tasks in a Python list; with `DATABASE_URL` it talks to PostgreSQL.

But `uv run pytest` runs without `DATABASE_URL`. **So all the PostgreSQL code — half of `main.py` — is never executed by the tests.** If it contained a typo in a SQL query, no test would catch it: it would only break in production.

That's exactly the hole the rest of this module fills.

> Integration tests carry a **marker** (`@pytest.mark.integration`), and `pyproject.toml` asks pytest to skip them by default. That's deliberate: **fast tests must be runnable with nothing installed**, otherwise developers stop running them.
>
> The ones in `test_integration.py` need cloud services — we'll switch them on in [Module 5](05-aws.md). Nothing to do with them for now.

### 3. The GitHub Actions pipeline

The project already provides the `.github/workflows/ci.yml` file. Before reading it, here are the syntaxes you'll encounter:

**Syntaxes to know for reading the file:**

| Syntax | What it means | Example |
|--------|-------------|---------|
| `needs: lint` | "This job waits for the `lint` job to finish before starting" -- this is how you create the order lint -> test -> build -> push | The `test` job waits for `lint` |
| `run: |` | The `|` after `run:` lets you write **multiple lines** of commands (otherwise `run:` only accepts a single line) | `run: |` then `cd backend` then `uv run pytest` |
| `${{ ... }}` | Insert a GitHub Actions **variable**. It's like `$VARIABLE` in bash but with the `${{ }}` syntax specific to GitHub Actions | `${{ github.sha }}` = the commit hash |
| `${{ secrets.NAME }}` | Access a **secret** stored in GitHub (Settings -> Secrets). The secret never appears in the logs | `${{ secrets.DOCKERHUB_TOKEN }}` |
| `with:` | Pass **parameters** to a `uses:` action. It's like passing arguments to a function | `with: username: ...` for the Docker login action |
| `if:` | Run this job **only if** the condition is true. `==` means "is equal to", `&&` means "AND" | `if: github.ref == 'refs/heads/main'` = only on the main branch |

Here's the complete file with comments:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # --- JOB 1: LINT (check code quality) ---
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4          # Download the repo's code onto the runner

      - name: Setup uv
        uses: astral-sh/setup-uv@v4       # Install uv (Python manager)

      - name: Lint backend (Ruff)
        run: |                             # | = multiple lines of commands
          cd backend
          uv run ruff check .

      - name: Setup Bun
        uses: oven-sh/setup-bun@v2        # Install Bun (JS runtime)

      - name: Lint frontend (Oxlint)
        run: |
          cd frontend
          bunx oxlint .

  # --- JOB 2: TEST (check that the code works) ---
  test:
    name: Test
    runs-on: ubuntu-latest
    needs: lint                            # Wait for the "lint" job to finish
    steps:
      - uses: actions/checkout@v4

      - name: Setup uv
        uses: astral-sh/setup-uv@v4

      - name: Run tests
        run: |
          cd backend
          uv run pytest

  # --- JOB 3: BUILD (build Docker images) ---
  build:
    name: Build Docker Images
    runs-on: ubuntu-latest
    needs: test                            # Wait for the "test" job to finish
    steps:
      - uses: actions/checkout@v4

      - name: Build backend image
        run: docker build -t devops-backend:${{ github.sha }} ./backend
        # ${{ github.sha }} = the unique commit hash (e.g.: a1b2c3d)
        # We use it as the image tag to know which commit it came from

      - name: Build frontend image
        run: docker build -t devops-frontend:${{ github.sha }} ./frontend

  # --- JOB 4: PUSH (send images to Docker Hub) ---
  push:
    name: Push to Docker Hub
    runs-on: ubuntu-latest
    needs: build                           # Wait for the "build" job to finish
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    # ^ This job only runs IF:
    #   - we're on the main branch (refs/heads/main)
    #   - AND it's a push (not a pull request)
    #   No need to push images for a PR -- we just want to verify it builds
    steps:
      - uses: actions/checkout@v4

      - name: Login to Docker Hub
        uses: docker/login-action@v3       # Pre-made action to log in to Docker Hub
        with:                              # "with" = the action's parameters
          username: ${{ secrets.DOCKERHUB_USERNAME }}   # Your Docker Hub username (stored in GitHub secrets)
          password: ${{ secrets.DOCKERHUB_TOKEN }}      # Your Docker Hub token (stored in GitHub secrets)

      # Note: we rebuild the images here even though the "build" job already built them.
      # Why? Each job runs on a different runner (a separate machine).
      # The images built in the "build" job no longer exist here.
      # The "build" job was to VERIFY that the build passes. Here, we build AND push.
      - name: Build and push backend
        run: |
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/devops-backend:latest ./backend
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/devops-backend:latest
          # Image format: username/image-name:tag
          # "latest" = the most recent version

      - name: Build and push frontend
        run: |
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/devops-frontend:latest ./frontend
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/devops-frontend:latest
```

### 4. Running integration tests in CI

The pipeline above has the blind spot we just identified: the `test` job only runs unit tests, so **the code that talks to PostgreSQL is never executed**.

#### The problem to solve

To test that code you need a database. But a GitHub runner is a blank machine: there's no PostgreSQL on it. The three classic wrong answers:

| Bad idea | Why it's bad |
|---|---|
| "We'll point CI at the dev database" | The tests write and delete data. They'll destroy the team's work. And two pipelines running at once collide |
| "We'll mock the database" | You then test your own imitation of PostgreSQL, not PostgreSQL. A typo in a SQL query slips straight through |
| "We won't test that code" | That's the default choice of many teams… and the cause of many incidents |

**The right answer: start a real database next to the test, for the duration of the test.** GitHub Actions calls these **service containers**.

#### Service containers

A service container is a container GitHub starts **before** your steps, that runs alongside them, and that it stops afterwards. Your tests reach it on `localhost`. It's the equivalent of Module 3's `docker compose up`, but managed by GitHub — and thrown away at the end of the job.

Here is the `integration-test` job from the provided `.github/workflows/ci.yml`:

```yaml
  integration-test:
    name: Integration Test
    runs-on: ubuntu-latest
    needs: lint

    services:
      # A real PostgreSQL database, for the duration of the job
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: user
          POSTGRES_PASSWORD: pass
          POSTGRES_DB: tasks
        ports:
          - 5432:5432
        # Without health-cmd, the tests would start BEFORE PostgreSQL is
        # ready to answer, and fail for the wrong reason.
        options: >-
          --health-cmd "pg_isready -U user -d tasks"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 10

    steps:
      - uses: actions/checkout@v4
      - name: Setup uv
        uses: astral-sh/setup-uv@v4

      # The SAME tests as the `test` job, but against a real database.
      # The application code doesn't change: only DATABASE_URL appears.
      - name: Tests against a real PostgreSQL
        env:
          DATABASE_URL: postgresql://user:pass@localhost:5432/tasks
        run: |
          cd backend
          uv run pytest
```

And the `build` job waits for **all** test jobs to pass before building the images:

```yaml
  build:
    needs: [test, integration-test, aws-test]
```

> You see three names although we've only explained two: the third, `aws-test`, comes in [Module 5](05-aws.md). That's expected — leave it as is.

#### You can check it locally

No need to wait for CI to see the effect: reproduce it on your machine with what you already know from Module 3.

```bash
# Start a throwaway database.
# We publish it on port 55432 rather than 5432: if Module 3's docker compose
# is still running, it already occupies 5432 and this would fail with
# "port is already allocated" (see Module 2 — a port can only be used by
# one program at a time).
docker run -d --rm --name pgtest \
  -e POSTGRES_USER=user -e POSTGRES_PASSWORD=pass -e POSTGRES_DB=tasks \
  -p 55432:5432 postgres:16

# Wait for it to answer: this is the manual equivalent of --health-cmd.
# We loop at most 30 times. A loop with NO limit (`until ...; do`) would spin
# forever if the container failed to start — a classic reason for scripts
# that "hang" without printing anything.
for i in $(seq 1 30); do
  docker exec pgtest pg_isready -U user -d tasks >/dev/null 2>&1 && break
  sleep 1
done

# The SAME tests, against the real database
cd ~/devops-project/backend
DATABASE_URL="postgresql://user:pass@localhost:55432/tasks" uv run pytest
# ===== 7 passed =====

docker rm -f pgtest
```

💡 **If `docker run` prints `port is already allocated`**: another program holds the port you picked. Choose a different one (`-p 55433:5432`) and adjust the `DATABASE_URL` accordingly.

The same 7 tests pass in both modes. **The code didn't change by a single line** — only an environment variable appeared.

#### What this job actually teaches you

**1. `--health-cmd` isn't decoration.** "The container is started" ≠ "the service answers". PostgreSQL takes one to three seconds to boot. Without a health check, your tests start too early and fail one time in three — the worst kind of test, the one that fails at random (a *flaky* test). It's a very common source of CI incidents.

**2. The same code, two configurations.** The `test` job runs the tests in memory; `integration-test` runs **exactly the same ones** against PostgreSQL. That's what proves a codebase is properly configurable — the same idea as Module 3's `depends_on`: the configuration changes, the code doesn't.

**3. A throwaway environment on every run.** The database is created empty at the start of the job and destroyed at the end. No test can pollute the next one, and no pipeline can disturb another.

**4. Jobs run in parallel.** `test` and `integration-test` both depend on `lint`, but not on each other: GitHub runs them at the same time. A pipeline isn't necessarily a straight line — anything independent should run simultaneously.

> **There's a third job in the file, called `aws-test`.** It applies exactly the same principle, but to cloud services (S3, SQS) instead of a database. We'll switch it on in [Module 5](05-aws.md), once we've seen what AWS is — no need to worry about it now.

### 5. Configure the secrets

On GitHub -> your repo -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**:
- `DOCKERHUB_USERNAME`: your Docker Hub username
- `DOCKERHUB_TOKEN`: an access token (not your password!) created at [hub.docker.com/settings/security](https://hub.docker.com/settings/security)

### 6. Push and watch

The `ci.yml` file is already in the project. If you've pushed everything, the pipeline runs automatically.

```bash
cd ~/devops-project
git add .
git commit -m "ci: pipeline GitHub Actions"
git push
```

Go to the **Actions** tab of your GitHub repo. You'll see the pipeline running: Lint -> Test -> Build -> Push.

💡 **If the Docker Hub push fails:** check that the secrets are properly configured. The `push` job only runs on the `main` branch (not on pull requests).

## Secrets and environment variables

**NEVER put passwords or tokens in the code.** Use GitHub secrets.

```yaml
# In the workflow, access a secret:
${{ secrets.MY_SECRET }}

# Environment variables (non-sensitive):
env:
  NODE_ENV: production
```

## Other CI/CD tools

| Tool | Specifics |
|------|----------|
| **GitLab CI** | Very popular in France, built into GitLab |
| **Jenkins** | The dinosaur -- old but still everywhere |
| **CircleCI** | SaaS, easy to configure |

## Interview Corner

**Q: What is CI/CD?**
A: CI = automatically checking code on every push (lint, tests). CD = automatically deploying if everything passes. It reduces human errors and speeds up deliveries.

**Q: What are the stages of a typical CI/CD pipeline?**
A: Lint (code quality) -> Tests -> Build (artifact construction) -> Deploy. Each stage blocks the next one if it fails.

**Q: What is "fail fast"?**
A: If a stage fails, everything stops immediately. No need to build if the tests don't pass. It saves time and resources.

**Q: Where should you store secrets in a pipeline?**
A: In the CI/CD secrets (GitHub Secrets, GitLab Variables, etc.). Never in the code, never in committed YAML files.

**Q: Difference between Continuous Delivery and Continuous Deployment?**
A: Delivery = ready to deploy but manual button. Deployment = automatic deployment. Most companies do Delivery.

**Q: What is a runner?**
A: The machine (server) that runs the pipeline's jobs. GitHub provides free runners (ubuntu-latest). You can also use your own runners.

**Q: What is a blue/green deployment?**
A: A deployment strategy with two identical environments. "Blue" serves production, you deploy the new version to "green", test it, then switch the traffic. If it breaks, you switch back in seconds. Advantage: instant rollback.

**Q: What is a canary deployment?**
A: You deploy the new version to a small percentage of servers (e.g., 5%). You monitor the metrics. If everything's fine, you gradually increase (25% → 50% → 100%). If it breaks, only 5% of users are impacted.

## Best practices

- **The pipeline must be fast.** If the CI takes 20 min, devs stop using it. Parallelize independent jobs (lint backend || lint frontend), use caching (dependencies, Docker images).
- **Fail fast.** Put the fastest stages first (lint < tests < build < deploy). No need to build for 5 min if lint fails in 10 seconds.
- **Never put secrets in the code.** Use CI secrets (GitHub Secrets, GitLab Variables). If a secret was committed by mistake, change it immediately -- a `git rm` is not enough (the history keeps everything).
- **A pipeline per branch, not just main.** Run CI on Pull Requests too. The goal is to know if the code is broken BEFORE merging.
- **Reproducibility.** Pin your action versions (`actions/checkout@v4`, not `@latest`). A pipeline that breaks on its own because a dependency was updated is a nightmare.
- **No `git push --force` from CI.** CI should never destructively modify the source branch.

## Common mistakes

- **Forgetting `actions/checkout@v4`** -> The runner doesn't have the code, everything fails.
- **Misspelled secrets** -> `${{ secrets.DOCKER_HUB }}` != `${{ secrets.DOCKERHUB_TOKEN }}`. The name must match exactly.
- **Tests that pass locally but not in CI** -> Often a dependency issue or missing environment variables.
- **Pipeline too slow** -> Parallelize independent jobs (lint backend and lint frontend in parallel).
- **Committing secrets** -> If it happens, change them IMMEDIATELY. Git keeps the history.

## Going further

- **Deployment strategies**: blue-green (two environments), canary (progressive deployment) -- beyond the rolling update covered in the curriculum
- **Quality gates**: test coverage thresholds, automated security analysis (SonarQube, Snyk) -- increasingly required
- **ArgoCD**: GitOps -- the Git repo IS the source of truth for deployment. You push YAML, ArgoCD deploys automatically on K8s (requires having done Module 9 -- Kubernetes)

## You can move on to the next module if...

- [ ] You can explain CI (automatic verification) and CD (automatic deployment)
- [ ] You know the 4 stages of a pipeline (lint -> test -> build -> deploy)
- [ ] You understand the "fail fast" concept
- [ ] The GitHub Actions pipeline runs on your repo (Actions tab)
- [ ] You know how to configure secrets in GitHub (Settings -> Secrets)
- [ ] You know what a runner is
- [ ] You know the difference between a unit test and an integration test
- [ ] You know what a service container is, and why `--health-cmd` is essential
- [ ] You've seen the same tests pass in memory AND against a real PostgreSQL
- [ ] You know what a *flaky* test is and why it's dangerous
