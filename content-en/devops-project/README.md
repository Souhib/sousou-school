# DevOps Project — Task List

A simple application (React frontend + FastAPI backend) used throughout the DevOps course.

> In the workplace, the frontend and backend are typically in separate repositories (repos), each with its own CI/CD pipeline. Here, we put them in the same repo to simplify learning.

## Architecture

```
┌──────────────┐     HTTP      ┌───────────────────┐     SQL       ┌──────────────┐
│              │   /api/...    │                   │               │              │
│   Frontend   │──────────────▶│     Backend       │──────────────▶│  PostgreSQL   │
│  (React +    │               │   (FastAPI +      │               │  (data)      │
│   nginx)     │◀──────────────│    Python)        │◀──────────────│              │
│              │     JSON      │                   │    rows       │              │
│   port 80    │               │    port 8000      │               │   port 5432  │
└──────────────┘               └───────────────────┘               └──────────────┘
       │                              │                                   │
       └──────────────────────────────┴───────────────────────────────────┘
                            Docker Compose (a shared network)
```

- The **frontend** is a web page (React) served by **nginx**. The user sees the task list.
- **nginx** acts as a **reverse proxy**: `/api` requests are forwarded to the backend.
- The **backend** is a Python API (FastAPI). It manages tasks (create, list, toggle, delete).
- **PostgreSQL** stores the data. Without Docker (no `DATABASE_URL`), the backend uses an in-memory list.

## Structure

```
.github/workflows/
  ci.yml                    → CI/CD Pipeline (lint → test/integration → build → push)
frontend/                   → Vite + React (managed by Bun)
  Dockerfile                → Multi-stage build (Bun → nginx)
  nginx.conf                → Reverse proxy to the backend
backend/                    → Python FastAPI (managed by uv)
  Dockerfile                → Python image with uv
  main.py                   → The API (routes + storage)
  aws_client.py             → The code that talks to AWS (S3, SQS)
  test_main.py              → Unit tests
  test_integration.py       → Integration tests (require Floci)
floci/                      → Local AWS (emulator, see below)
  docker-compose.yml        → Starts Floci
  init/ready.d/             → Scripts run when Floci starts
docker-compose.yml          → Backend + Frontend + PostgreSQL
docker-compose.floci.yml    → Override: connects the backend to local AWS
```

## Run locally (without Docker)

**Backend:**
```bash
cd backend
uv sync
uv run uvicorn main:app --reload
# The API runs on http://localhost:8000
# Without DATABASE_URL → in-memory storage (no PostgreSQL needed)
```

**Frontend:**
```bash
cd frontend
bun install
bun run dev
# The frontend runs on http://localhost:3000
# /api calls are proxied to the backend
```

## Run with Docker Compose

```bash
docker compose up -d --build
# Frontend: http://localhost (port 80)
# Backend:  http://localhost:8000
# PostgreSQL: port 5432 (only accessible from the backend)
```

## Run local AWS (Floci)

**Floci** is an AWS emulator: it imitates AWS on your machine. No account, no credit
card, no bill. It's what lets you practise S3, SQS, DynamoDB, Lambda, RDS, EC2 and
Terraform without paying anything.

```bash
cd floci
docker compose up -d

# Check it's ready (should print 200)
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4566/health

# Every AWS command targets the emulator with --endpoint-url
aws --endpoint-url http://localhost:4566 s3 ls
```

To connect the application to it:

```bash
docker compose -f docker-compose.yml -f docker-compose.floci.yml up -d --build
```

Full guide: [AWS Locally](../floci-aws-local.md).

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| `GET` | `/api/tasks` | List tasks |
| `POST` | `/api/tasks` | Create a task (`{"title": "..."}`) |
| `PATCH` | `/api/tasks/{id}` | Toggle done/not done |
| `DELETE` | `/api/tasks/{id}` | Delete a task |
| `GET` | `/api/health` | Health check |

## Linting

```bash
# Backend (Ruff)
cd backend && uv run ruff check .

# Frontend (Oxlint)
cd frontend && bunx oxlint .
```

## Tests

There are two families of tests, and they aren't launched the same way.

**Unit tests** — fast, no dependencies:

```bash
cd backend && uv run pytest
# 7 tests: GET, POST, PATCH, PATCH 404, DELETE, DELETE 404, health
```

**Integration tests** — they really talk to S3 and SQS, so Floci is required:

```bash
cd floci && docker compose up -d && cd ../backend

AWS_ENDPOINT_URL=http://localhost:4566 uv run pytest -m integration
# 4 tests: S3 upload/read, missing file, SQS message, endpoint guard
```

By default, `uv run pytest` **skips** the integration tests (configured in
`pyproject.toml`). That's deliberate: fast tests must be runnable with nothing
installed.

**The same unit tests against a real PostgreSQL** — the code doesn't change, only
the environment variable appears:

```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/tasks uv run pytest
```
