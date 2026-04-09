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
  ci.yml              → CI/CD Pipeline (lint → test → build → push)
frontend/             → Vite + React (managed by Bun)
  Dockerfile          → Multi-stage build (Bun → nginx)
  nginx.conf          → Reverse proxy to the backend
backend/              → Python FastAPI (managed by uv)
  Dockerfile          → Python image with uv
docker-compose.yml    → Backend + Frontend + PostgreSQL
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

```bash
cd backend && uv run pytest
# 7 tests: GET, POST, PATCH, PATCH 404, DELETE, DELETE 404, health
```
