# Module 3: Docker

> **Prerequisites:** [Module 0](00-prerequisites.md) (Git), [Module 1](01-linux-basics.md) (Linux — basic commands), [Module 2](02-networking.md) (Networking — ports, IP)

> **In a nutshell:** You learn to package your application into Docker containers so it runs the same way everywhere. This is THE crossroads module of the curriculum — Docker is used in CI/CD, AWS deployment, Kubernetes, and monitoring.

## What is Docker and why does it exist?

**The problem:** "It works on my machine!" — the most frustrating sentence in tech. You develop on Ubuntu 22, your coworker is on macOS, the production server is on Debian 11. Everyone has different versions of Python, Node, everything. Result: it breaks in production.

**Docker packages your application with EVERYTHING it needs** (code, dependencies, configuration, OS) into a "container" that runs the same way everywhere. It's like a vacuum-sealed meal: same taste whether you heat it up in Paris or Tokyo.

**The analogies:**
- **Image** = recipe (the instructions to prepare the dish)
- **Container** = cooked dish (an instance of the recipe, currently running)
- **Dockerfile** = recipe card (the text file that describes how to build the image)
- **Docker Hub** = recipe library (public registry of images)
- **Docker Compose** = full menu (multiple dishes/services together)

## Installation

```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
# usermod = modify a user
# -aG docker = add (-a) to the group (-G) "docker"
# $USER = your username (automatic Linux variable)
# Without this, you'd need to type "sudo" before every docker command
# ⚠️ Log out and log back in for the change to take effect
# (close and reopen your WSL terminal)

docker --version
# Docker version 24.x.x
```

Verify it works:
```bash
docker run hello-world
# Hello from Docker!
# This message shows that your installation appears to be working correctly.
```

## Images vs Containers

| Concept | What it is | Analogy |
|---------|-----------|----------|
| **Image** | A read-only template | The recipe |
| **Container** | A running instance | The cooked dish |

One image can spawn many containers, just like one recipe can make many dishes.

```bash
# Example: run a Python command in a container
docker run python:3.12-slim python3 -c "print('hello docker')"
# Docker downloads the python image (first time takes ~30 seconds)
# then launches a container and executes the Python command
# hello docker
```

You just downloaded an **image** (`python:3.12-slim`) and launched a **container** from that image.

## The Dockerfile

A Dockerfile describes how to build an image. Each line = one step. Here's the simplest possible version:

### Basic version (to understand the concept)

```dockerfile
FROM python:3.12          # Start from an image that already contains Python
WORKDIR /app              # Move to the /app directory in the container
COPY . .                  # Copy all your code into the container
RUN pip install fastapi uvicorn  # Install the dependencies
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
                          # The command that launches the app when the container starts
```

5 lines, that's it. It works. But in production, we can do better — lighter image, better dependency management, etc.

**The instructions:**

| Instruction | What it does |
|------------|---------------|
| `FROM` | Base image (always first) |
| `WORKDIR` | Sets the working directory in the container |
| `COPY` | Copies files from your machine into the container |
| `RUN` | Executes a command during image build |
| `CMD` | The command that runs when the container starts |

### Best practices version (what we use in the project)

The project uses an improved version. Here are the differences and why:

```dockerfile
# "slim" = lightweight version of Python (150 MB instead of 900 MB)
# Fewer pre-installed packages, but enough for our app
FROM python:3.12-slim

# Install uv (the fast dependency manager, covered in Module 0)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Best practice: copy dependency files BEFORE the code
# Why? Docker "caches" each step — meaning it stores the result
# of each step. If a step hasn't changed since last time,
# Docker reuses the result instead of redoing everything.
# If you change your code but not your dependencies, Docker won't reinstall
# the dependencies → much faster builds (seconds instead of minutes)
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
# --frozen = use the uv.lock file as-is (exact versions, no surprises)
# --no-dev = don't install pytest, ruff, etc. (useless in production)

# Now we copy the code (after dependencies, for caching)
COPY . .

# --host 0.0.0.0 = listen on all network interfaces
# Without this, the app only listens on localhost INSIDE the container → impossible to access from outside
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

| Basic | Best practices | Why |
|---------|-----------------|----------|
| `python:3.12` (900 MB) | `python:3.12-slim` (150 MB) | Image 6x lighter |
| `pip install` (Python's built-in package manager) | `uv sync --frozen` (the fast package manager used in this curriculum, covered in [Module 0](00-prerequisites.md)) | Faster, locked versions. Both install dependencies — `pip` comes with Python, `uv` is a more modern external tool |
| `COPY . .` all at once | Dependencies first, code second | Docker cache = faster builds |
| All dependencies | `--no-dev` | No pytest/ruff in production |

## Essential Docker Commands

> **These commands are examples** to understand the syntax. You'll use them for real in the "Hands-on Project" section below. No need to type them now.

**"Build"** = transforming your source code into something ready to run. For Docker, `docker build` reads your Dockerfile and creates an image from the instructions.

```bash
# Build an image
docker build -t mon-app:1.0 .
# -t = tag (name:version) — the name you give to the image
# . = the "context" — the directory Docker uses to find files
#     when your Dockerfile does COPY, it copies from THIS directory
#     the "." means "the directory I'm currently in"

# Run a container
docker run -d -p 8000:8000 --name mon-backend mon-app:1.0
# -d = detached (runs in the background, you get your terminal back)
# -p 8000:8000 = host port:container port (covered in Module 2)
# --name = give the container a name (optional but handy)

# List running containers
docker ps

# See ALL containers (even stopped ones)
docker ps -a

# See a container's logs
docker logs mon-backend

# Follow logs in real time (Ctrl+C to stop)
docker logs -f mon-backend

# Stop a container
docker stop mon-backend

# Remove a container (it must be stopped first)
docker rm mon-backend

# Enter a running container
docker exec -it mon-backend bash
# -i = interactive (you can type commands)
# -t = terminal (displays a prompt)
# bash = open a bash terminal inside the container
# You're now "inside" the container — type "exit" to leave
```

## Volumes

A container is ephemeral — when you delete it, its data is gone. A **volume** persists data even after the container is removed. Essential for databases.

> **This example is to understand the concept.** In the project, we use Docker Compose which manages volumes automatically — no need to type this command.

```bash
docker run -d -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  --name ma-db \
  postgres:16
# The "\" at the end of each line = the command continues on the next line
#   (it's just for readability, it's a single command)
# -v postgres_data:/var/lib/postgresql/data = create a named volume "postgres_data"
#   that points to the PostgreSQL data directory INSIDE the container
# postgres_data = volume name (Docker manages it, you don't need to know where it's stored)
```

## How Containers Communicate with Each Other

When you use Docker Compose, a network is automatically created. Each container is accessible by **its service name** in the `docker-compose.yml` file.

In our project:
- The backend accesses PostgreSQL via `db:5432` (not `localhost:5432`)
- The frontend (nginx) accesses the backend via `backend:8000` (not `localhost:8000`)

**Why not `localhost`?** Each container is isolated. `localhost` inside the backend container refers to the backend itself — not the database. To talk to another container, you use its **service name** (`db`, `backend`, `frontend`).

Docker runs an internal DNS server (like the Internet DNS covered in [Module 2](02-networking.md)) that translates the service name into the container's IP address.

## Docker Compose

Docker Compose manages multiple containers together in a single YAML file. Instead of launching each container one by one with `docker run`, you describe everything in a `docker-compose.yml` file and launch it all at once.

The main commands:

```bash
docker compose up -d          # Launch all services (-d = in the background)
docker compose up -d --build  # Launch + rebuild images (after a code change)
docker compose ps             # See the status of all services
docker compose logs -f        # See logs in real time (Ctrl+C to stop)
docker compose down           # Stop everything and remove containers
```

We'll look at the project's `docker-compose.yml` file in the hands-on section just below.

## `.dockerignore` — Don't Copy Everything

When you do `COPY . .` in a Dockerfile, Docker copies **everything** from the directory into the image. Including `.git/` (Git history, can be 100+ MB), `node_modules/`, `.venv/`, `.env` (secrets!)...

The `.dockerignore` file works exactly like `.gitignore` (covered in [Module 0](00-prerequisites.md)): it tells Docker which files **not to copy**. The project already has one in each directory:

```
# backend/.dockerignore (already in the project)
.venv/
__pycache__/
.git/
.env
test_main.py
```

```
# frontend/.dockerignore (already in the project)
node_modules/
dist/
.git/
.env
```

Without `.dockerignore`, your images will be unnecessarily heavy and potentially dangerous (secrets in the image).

## Debugging a Crashing Container

This is 50% of the daily DevOps job. A container won't start or keeps crash-looping. Here's the method:

### Step 1 — Check the container status

```bash
docker ps -a
# CONTAINER ID  IMAGE       STATUS                     NAMES
# abc123        mon-app     Exited (1) 30 seconds ago  backend
#                           ^^^^^^ the exit code (1 = error)
```

### Step 2 — Read the logs

```bash
docker logs backend
# Traceback (most recent call last):
#   File "main.py", line 2, in <module>
#     from fastapi import FastAPI
# ModuleNotFoundError: No module named 'fastapi'
# ← The dependencies aren't installed in the image!
```

### Step 3 — Enter the container to investigate

If the container is still running:
```bash
docker exec -it backend bash
# You're now inside the container, you can explore
ls /app/
cat /app/pyproject.toml
```

If the container has crashed (can't `exec`), launch a new container with bash instead of the app:
```bash
docker run -it --entrypoint bash mon-app:1.0
# --entrypoint bash = instead of launching the app, open a bash terminal
# You're inside the container, the app hasn't started
# You can explore, test commands, understand what's wrong
# Type "exit" to leave
```

### The Most Common Errors

| Symptom | Likely cause | Fix |
|----------|---------------|-----|
| `Exited (1)` | Error in the app (bug, missing dependency) | `docker logs` to read the error |
| `Exited (137)` | Container killed (Out Of Memory) | Increase memory or optimize the app |
| Container restart loop | App crashes at startup | Logs + check CMD/ENTRYPOINT |
| `port already in use` | Another container/process is using that port | `docker ps` or `ss -tlnp` |

## Multi-stage Builds

A Dockerfile can have **multiple stages**. The idea: use a large image to build the app (with all the tools), then copy only the result into a small, lightweight image.

This is what we do for the frontend: we need Bun to build the React code, but in production we only need nginx to serve the generated HTML/JS/CSS files.

```dockerfile
# Stage 1: Build the frontend (heavy image with Bun)
FROM oven/bun:latest AS build
# "AS build" = give this stage a name to reference it later
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
# --frozen-lockfile = use the exact versions from the bun.lock file (same idea as --frozen for uv)
COPY . .
RUN bun run build
# This generates a "dist/" folder with the HTML/JS/CSS files ready to serve

# Stage 2: Serve in production (lightweight image with nginx)
FROM nginx:alpine
# "alpine" = ultra-lightweight Linux version (~5 MB)
COPY --from=build /app/dist /usr/share/nginx/html
# --from=build = copy from stage 1 (not from your machine)
# We only copy the build result, not Bun or node_modules
EXPOSE 80
```

**Result:** The final image only contains nginx (~20 MB) + the built files (~2 MB). No Bun, no node_modules (300+ MB). Much lighter and more secure.

## Hands-on Project: Dockerize the Hands-on Project

### 1. Dockerfile for the backend

The project already provides the Dockerfiles. Here's the backend one (`backend/Dockerfile`):
```dockerfile
FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
COPY . .
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 2. Dockerfile for the frontend

The frontend uses a **multi-stage build** (explained above). Here's the commented `frontend/Dockerfile`:
```dockerfile
# ─── Stage 1: Build the React code with Bun ───
FROM oven/bun:latest AS build
# oven/bun = official Bun image (the JS runtime, covered in Module 0)
# AS build = we name this stage "build" to reference it later

WORKDIR /app

# Same best practice as the backend: dependencies first, code second (for caching)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
# --frozen-lockfile = use the exact versions from the bun.lock file
#   (same idea as --frozen for uv: no surprises, everyone has the same versions)

COPY . .
RUN bun run build
# "bun run build" executes the "build" script defined in package.json
# It transforms the React code (JSX) into optimized HTML/JS/CSS files in a "dist/" folder

# ─── Stage 2: Serve the files with nginx (lightweight image) ───
FROM nginx:alpine
# We start from a clean image — nginx only, no Bun, no node_modules
# "alpine" = ultra-lightweight Linux version (~5 MB instead of ~100 MB)

COPY --from=build /app/dist /usr/share/nginx/html
# --from=build = copy from stage 1 (the one we named "build")
# We ONLY copy the dist/ folder (the built files) into the directory nginx serves

COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy our nginx config (explained just below)

EXPOSE 80
```

The `frontend/nginx.conf` file configures nginx (the web server):
```nginx
server {
    listen 80;                              # Listen on port 80 (HTTP)

    location / {                            # When someone accesses "/"
        root /usr/share/nginx/html;         # Serve the built files (HTML/JS/CSS)
        try_files $uri /index.html;         # If the requested file doesn't exist, return index.html
                                            # (needed for React which manages its own URLs)
    }

    location /api {                         # When someone accesses "/api/..."
        proxy_pass http://backend:8000;     # Forward to the backend container on port 8000
                                            # "backend" = the service name in docker-compose.yml
    }
}
```

In a nutshell: nginx serves the frontend AND forwards `/api` calls to the backend. This is the **reverse proxy** (covered in [Module 2](02-networking.md)).

### 3. Docker Compose

The project already provides a `docker-compose.yml` with backend + frontend + PostgreSQL:
```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/tasks

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=tasks
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

What's new compared to the previous examples:
- **`db`**: a PostgreSQL service. **PostgreSQL** is a database software — it stores data permanently (our app's tasks). The `postgres:16` image comes from Docker Hub (a website that hosts ready-to-use Docker images, like a catalog), no Dockerfile needed.
- **`environment`**: environment variables passed to the container. The backend uses `DATABASE_URL` to connect to PostgreSQL instead of in-memory storage.

> **The "environment variable" pattern**: In DevOps, you never modify code to switch environments. The same code runs in local, staging, and production. What changes are the environment variables. Here, `DATABASE_URL` is absent locally (→ in-memory) and present with Docker Compose (→ PostgreSQL). You'll see this pattern in every following module.

> Environment variables are explained in [Module 1](01-linux-basics.md) (Linux). Docker passes them to containers via `environment:` or `-e`.

- **`volumes`**: `postgres_data` persists the database data. Without it, data disappears when you run `docker compose down`.
- **`depends_on`**: Docker launches the backend after the database. **Warning:** `depends_on` guarantees the DB container is **started**, not that PostgreSQL is **ready to accept connections**. In practice, the DB takes a few seconds to start up. If the backend crashes on first launch because the DB isn't ready, a `docker compose restart backend` is enough. In production, you add a retry script or a health check on the DB.

> **Why `/api/health`?** The health check endpoint (`GET /api/health → {"status": "ok"}`) doesn't do anything business-related. It's for the tools that monitor the application: Docker checks if the container responds, Kubernetes decides if the pod is ready to receive traffic ([Module 9](09-kubernetes.md)), the load balancer removes a server that stops responding ([Module 5](05-aws.md)). It's a standard — virtually every app in production exposes a `/health`.

### How the backend switches from in-memory to PostgreSQL

In local (without Docker), the backend stores tasks in a simple Python list in memory. That's enough for development and testing.

With Docker Compose, we pass the `DATABASE_URL` variable to the backend. The `main.py` code checks if this variable exists:
- **`DATABASE_URL` absent** → in-memory storage (Python list)
- **`DATABASE_URL` present** → PostgreSQL connection

It's the same code, the same `main.py` file. Only the environment variable changes the behavior. This pattern is very common in DevOps: you don't modify code between environments, you change the configuration.

### 4. Launch everything

```bash
cd ~/devops-project
docker compose up -d --build
# [+] Building ...
# [+] Running 3/3
# ✔ Container devops-project-db-1        Started
# ✔ Container devops-project-backend-1   Started
# ✔ Container devops-project-frontend-1  Started

# Verify
docker compose ps
# 3 services running

curl http://localhost:8000/api/tasks
# [{"id":1,"title":"Apprendre Docker","done":false}, ...]

# Open http://localhost in your browser
```

💡 **If the build fails:** check that the Dockerfile is in the right directory and that the referenced files exist.

### 5. Test data persistence

Now is the time to verify that PostgreSQL volumes actually work. We'll add a task, stop everything, restart, and check it's still there.

```bash
# 1. Add a task via curl
curl -X POST http://localhost:8000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Cette tâche survit au redémarrage"}'
# {"id":3,"title":"Cette tâche survit au redémarrage","done":false}

# 2. Verify it exists
curl http://localhost:8000/api/tasks
# [..., {"id":3,"title":"Cette tâche survit au redémarrage","done":false}]

# 3. Stop everything (containers are removed)
docker compose down
# [+] Running 3/3
# ✔ Container devops-project-frontend-1  Removed
# ✔ Container devops-project-backend-1   Removed
# ✔ Container devops-project-db-1        Removed

# 4. Restart everything
docker compose up -d
# Containers are recreated, but the postgres_data volume is still there

# 5. Verify the task is still there
curl http://localhost:8000/api/tasks
# [..., {"id":3,"title":"Cette tâche survit au redémarrage","done":false}]
# ✅ It's still there! The volume persisted the data.
```

**Why it works:** `docker compose down` removes containers but **not volumes**. PostgreSQL stores its data in the `postgres_data` volume, which survives restarts.

**Now, compare with in-memory mode:**

```bash
# Stop Docker Compose
docker compose down

# Launch the backend without Docker (= without DATABASE_URL = in-memory mode)
cd ~/devops-project/backend
uv run uvicorn main:app --reload &

# You see the 2 demo tasks, but NOT the one you added
curl http://localhost:8000/api/tasks
# [{"id":1,"title":"Apprendre Docker","done":false},{"id":2,"title":"Configurer CI/CD","done":false}]
# The added task is gone — in-memory storage doesn't persist anything

# Stop the server
kill %1
```

This is concretely the difference between a database (data survives) and in-memory storage (everything disappears on restart). In production, you always use a database with a volume.

## Debug Exercise: Find the 3 Errors

The following `docker-compose.yml` contains 3 errors. Find them before looking at the hints.

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@localhost:5432/tasks

  frontend:
    build: ./frontend
    ports:
      - "8000:80"
    depends_on:
      - backend

  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=tasks
```

<details>
<summary>💡 Hint 1</summary>

Look at the ports exposed by the backend and the frontend. Can two services use the same port on your machine?

</details>

<details>
<summary>💡 Hint 2</summary>

Look at the backend's `DATABASE_URL`. What machine does `localhost` refer to inside a Docker container?

</details>

<details>
<summary>💡 Hint 3</summary>

If you run `docker compose down` then `docker compose up`, does the PostgreSQL data survive?

</details>

<details>
<summary>✅ Solution</summary>

**Error 1 — Port conflict:** Both the backend AND the frontend use port `8000` on the host side. The frontend should be on a different port, for example `"80:80"` or `"3000:80"`.

**Error 2 — `localhost` instead of the service name:** Inside a container, `localhost` refers to the container itself, not the host machine. The backend must connect to `db:5432` (the Docker Compose service name), not `localhost:5432`. Fix: `DATABASE_URL=postgresql://user:pass@db:5432/tasks`.

**Error 3 — No volume for PostgreSQL:** Without a volume, data disappears when the container is removed. You need to add:
```yaml
  db:
    # ...
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

</details>

## Interview Corner

**Q: What is Docker?**
A: A tool that packages an application with all its dependencies into an isolated container. The container runs the same way everywhere.

**Q: Difference between image and container?**
A: The image is a read-only template (the recipe). The container is a running instance (the cooked dish). One image can create multiple containers.

**Q: What is a Dockerfile?**
A: A text file that describes step by step how to build a Docker image. FROM for the base, COPY for files, RUN for commands, CMD for startup.

**Q: What is Docker Compose?**
A: A tool for managing multiple containers together with a YAML file. You define your services, networks, and volumes, then `docker compose up` launches everything.

**Q: How do containers communicate with each other?**
A: Via a Docker network. Docker Compose automatically creates a network. Containers find each other by their service name (e.g., `http://backend:8000`).

**Q: What is a Docker volume?**
A: Persistent storage. Without a volume, data disappears when the container is removed. Essential for databases.

**Q: What is a multi-stage build?**
A: A Dockerfile with multiple stages. You build in a heavy image, then copy only the result into a lightweight image. This reduces the final size.

**Q: Difference between CMD and ENTRYPOINT?**
A: `CMD` = the default command, replaceable at launch (`docker run mon-app echo "something else"` replaces the CMD). `ENTRYPOINT` = the fixed command, `docker run` arguments are appended after it. In practice, `CMD` is enough in 90% of cases. You use `ENTRYPOINT` when the container has a single role and you don't want someone to be able to replace the command.

**Q: Difference between COPY and ADD in a Dockerfile?**
A: Both copy files into the image. `COPY` does a simple copy. `ADD` can also decompress archives (.tar.gz) and download from a URL. In practice, always use `COPY` unless you need decompression — it's more explicit.

**Q: What is a Docker registry?**
A: A server that stores Docker images. Docker Hub is the default public registry (like GitHub but for Docker images). In the workplace, private registries (AWS ECR, GitHub Container Registry) are often used to store your own images.

**Q: Why does the order of instructions in a Dockerfile matter?**
A: Because of caching. Docker executes each instruction as a layer. If a layer hasn't changed, Docker reuses the cache. If you put `COPY . .` before `RUN pip install`, every code change invalidates the cache and reinstalls all dependencies. By putting `COPY requirements.txt` then `RUN pip install` BEFORE `COPY . .`, dependencies are only reinstalled when they actually change.

## Best Practices

- **Always have a `.dockerignore`.** Without it, `COPY . .` bundles `.git/`, `node_modules/`, `.env` (secrets) into your image.
- **Lightweight images.** Use `python:3.12-slim` instead of `python:3.12` (900 MB vs 150 MB). Use multi-stage builds for the frontend.
- **One process per container.** Don't put the API and the DB in the same container. Separate responsibilities.
- **Don't run as root in the container.** Add `USER appuser` in the Dockerfile. If the container is compromised, the attacker has less power.
- **Copy dependencies before the code.** `COPY pyproject.toml .` then `RUN uv sync`, then `COPY . .`. This way Docker caches the dependencies and only reinstalls them if the dependency file changes.
- **Tag your images.** Don't rely on `:latest`. Use explicit tags (`:v1.2`, `:abc123` with the commit hash).
- **Clean up regularly.** `docker system prune` removes orphaned images, containers, and volumes. Without this, your disk fills up in a few days.

```bash
# See the space used by Docker
docker system df
# TYPE           TOTAL   ACTIVE   SIZE      RECLAIMABLE
# Images         15      3        4.2GB     3.1GB (73%)

# Clean up everything that's not in use
docker system prune -a
# WARNING! This will remove all stopped containers, unused networks, unused images...
# Total reclaimed space: 3.1GB
```

## Common Mistakes

- **"Permission denied" with docker** → You didn't run `usermod -aG docker $USER` or you didn't log back in.
- **"Port already in use"** → Another process is using that port. `docker ps` to check or `ss -tlnp | grep PORT`.
- **Forgetting `-p` in `docker run`** → The container runs but you can't access it from your machine.
- **Modifying code without rebuilding** → `docker compose up -d --build` to rebuild after a change.
- **Disk full** → `docker system prune -a` to clean up. Docker images accumulate fast.
- **Large images** → `.dockerignore` + `-slim`/`-alpine` images + multi-stage builds.

## Going Further

- **Docker in production**: advanced health checks, restart policies, resource limits (CPU/RAM) — what you'll configure from your first deployment
- **Image optimization**: layer ordering, multi-stage caching, `alpine` vs `slim` images — makes builds faster
- **Docker security**: don't run as root in the container, scan for vulnerabilities (Trivy) — increasingly required

## You can move on to the next module if...

- [ ] You know the difference between an image and a container
- [ ] You can read a Dockerfile (FROM, COPY, RUN, CMD)
- [ ] You know how to `docker build`, `docker run -d -p`, `docker ps`, `docker logs`
- [ ] You can write a `docker-compose.yml` and run `docker compose up -d`
- [ ] The Hands-on Project runs with `docker compose up -d --build` (backend + frontend + PostgreSQL)
- [ ] You understand service discovery (containers find each other by their service name)
- [ ] You understand why volumes are necessary to persist data

> **What Docker has just unlocked.** Now that you can run a container, you can run an **AWS emulator** on your machine — a program that imitates AWS locally. That's what will let you practise S3, EC2, RDS or Lambda for free in [Module 5](05-aws.md), with no AWS account and no credit card. See [AWS Locally](floci-aws-local.md).
