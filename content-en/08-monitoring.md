# Module 8: Monitoring (Awareness)

> **Prerequisites:** [Module 3](03-docker.md) (Docker — docker-compose to run Prometheus/Grafana)

> **In a nutshell:** You learn to monitor your application in production with Prometheus (metrics collection) and Grafana (dashboards). Without monitoring, you don't know if your app works — you find out when a user complains.

## What is monitoring and why does it exist?

**The problem:** Your app is running in prod. How do you know if it's working well? If it's slow? If it's going to crash in 10 minutes because the disk is full? Without monitoring, you only find out when a user complains. Or worse, when your boss calls you on a Sunday morning.

It's like **driving a car without a dashboard** — no speedometer, no fuel gauge, no warning lights. You're driving blind.

**The analogies:**
- **Prometheus** = the car's sensors (collects data)
- **Grafana** = the dashboard (displays gauges and graphs)
- **Alerts** = the warning lights (notify you when things go wrong)

## The 3 pillars of observability

| Pillar | What it is | Example | Tool |
|--------|-----------|---------|------|
| **Metrics** | Numbers about your app (how many requests, response time, CPU) | "95% of requests in <200ms" | Prometheus |
| **Logs** | Text messages from your app ("user X did Y", "error Z") | "ERROR: connection refused to DB" | ELK/EFK stack |
| **Traces** | The path of a request through your services | "Request -> API -> DB -> Cache -> Response (350ms)" | Jaeger, Zipkin |

For this module, we focus on **metrics** with Prometheus + Grafana.

### The 4 Golden Signals

Before diving into the tools, you need to know **what** to measure. Google defined 4 essential metrics (the "Golden Signals") that are enough to monitor any application:

| Signal | Question | Example |
|--------|----------|---------|
| **Latency** | Is it fast? | "95% of requests in <200ms" |
| **Traffic** | How many people? | "150 requests per second" |
| **Errors** | Does it work? | "0.5% of error responses (5xx)" |
| **Saturation** | Is it full? | "CPU at 70%, disk at 45%" |

These 4 numbers are worth more than 200 metrics nobody looks at. Start with these.

## Prometheus — The collector

A **metric** is a number that measures something: number of requests, response time, CPU usage percentage. Prometheus collects these metrics by **fetching** data from your applications (this is the **pull model** — Prometheus fetches, instead of the app sending). Concretely, your app exposes a special page at the `/metrics` endpoint with all its numbers, and Prometheus checks it (**scrape** = go fetch the data) every 15 seconds. It stores everything in a **time series database** — a database optimized for storing numbers that change over time (like a temperature history).

How it works:
1. Your app exposes `http://localhost:8000/metrics`
2. Prometheus scrapes this endpoint every 15 seconds
3. Prometheus stores the data in its internal database
4. You query Prometheus to see the data

## Grafana — The display

Grafana connects to Prometheus (and other sources) and displays data as graphs, gauges, and dashboards.

## ELK / EFK Stack (just the names)

For logs, the industry often uses:
- **E**lasticsearch: stores and indexes logs
- **L**ogstash / **F**luentd: collects and transforms logs
- **K**ibana: interface for searching through logs

We won't set it up in this course, but remember the names for interviews.

## Structured Logs vs Plain Text Logs

In production, the format of your logs makes a huge difference. Compare:

**Plain text (what we often do in dev):**
```
2024-01-15 14:32:01 ERROR Failed to create task: database connection refused
```

**Structured log / JSON (what we do in prod):**
```json
{
  "timestamp": "2024-01-15T14:32:01Z",
  "level": "error",
  "message": "Failed to create task",
  "error": "database connection refused",
  "service": "backend",
  "endpoint": "/api/tasks",
  "method": "POST",
  "request_id": "abc-123",
  "duration_ms": 1502
}
```

**Why it matters:**
- A plain text log, you can read it by eye. But when you have **10,000 logs per minute** across 5 services, you can't just `grep`. You need to filter by `service`, `level`, `endpoint`, etc.
- Structured logs (JSON) are **machine-parsable**: Elasticsearch, Loki, Datadog can index, filter, and aggregate them automatically.
- The `request_id` lets you **trace a request** across multiple services (this is the beginning of tracing).

**In practice:** Most frameworks have a JSON mode for logs. For FastAPI/Python: the `structlog` or `python-json-logger` library. For Node.js: `pino` or `winston` in JSON mode.

**The rule:** Locally, readable logs (plain text) are fine. In production, always use structured JSON.

## Alerting

Monitoring without alerts is useless. Nobody watches dashboards 24/7.

**Best practices:**
- Alert on symptoms, not causes (alert "the site is slow", not "CPU at 80%")
- Every alert must be actionable (if you can't do anything about it -> it's not an alert)
- Not too many alerts (alert fatigue = you end up ignoring everything)

**Alerting tools:** Prometheus Alertmanager, PagerDuty, OpsGenie.

## SaaS tools (just the names)

| Tool | What it is |
|------|-----------|
| **Datadog** | All-in-one SaaS monitoring (metrics, logs, traces) |
| **CloudWatch** | AWS native monitoring |
| **New Relic** | SaaS monitoring, popular for APM (Application Performance Monitoring) |

These tools do the same thing as Prometheus + Grafana, but as a hosted version (no need to manage the monitoring infra).

## Hands-on Project: Monitor the project

### 1. Add instrumentation to the backend

**Instrumenting** an application = adding code that automatically measures what's happening (number of requests, response time, etc.) and exposes those numbers for Prometheus. The `prometheus-fastapi-instrumentator` library does this automatically for FastAPI — it's already in the project dependencies (`pyproject.toml`, added during initial setup). If it's not, add it: `uv add prometheus-fastapi-instrumentator`. You just need to activate it in the code.

Add these two lines to `backend/main.py`:

1. The import at the top of the file (with the other imports):
```python
from prometheus_fastapi_instrumentator import Instrumentator
# Import the library that automatically measures HTTP requests
```

2. Right after the `app.add_middleware(...)` block, add:
```python
Instrumentator().instrument(app).expose(app)
# Instrumentator() = create the measurement tool
# .instrument(app) = tell it to monitor our FastAPI app
# .expose(app)     = add the /metrics endpoint to our app (this is the page Prometheus will read)
```

The complete `main.py` file with instrumentation:
```python
import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator  # <- added

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Expose /metrics for Prometheus
Instrumentator().instrument(app).expose(app)  # <- added

# ... the rest of the code (storage, routes) doesn't change
```

Verify:
```bash
cd ~/devops-project/backend
uv run uvicorn main:app --reload &
curl http://localhost:8000/metrics
# # HELP http_requests_total Total number of HTTP requests
# # TYPE http_requests_total counter
# http_requests_total{method="GET",path="/api/tasks",status="2xx"} 5.0
# ...
```

### 2. Docker Compose with Prometheus + Grafana

Create the file with `nano ~/devops-project/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s          # Check metrics every 15 seconds

scrape_configs:                  # List of applications to monitor
  - job_name: "backend"          # Name of this target (you choose the name)
    static_configs:              # Fixed addresses (no automatic discovery)
      - targets: ["backend:8000"]
        # "backend" = service name in docker-compose.yml
        # 8000 = the backend port
        # Prometheus will read http://backend:8000/metrics every 15s
```

Add the Prometheus and Grafana services to your `docker-compose.yml` (in addition to the existing backend, frontend, db services):
```yaml
  # ... (keep the existing backend, frontend, db services)

  prometheus:
    image: prom/prometheus:latest          # Official Prometheus image
    ports:
      - "9090:9090"                        # Port 9090 = Prometheus convention
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      # Copy our config file into the container
      # ./prometheus.yml = the file we just created
      # /etc/prometheus/prometheus.yml = where Prometheus expects to find its config
    depends_on:
      - backend                            # Wait for the backend to start

  grafana:
    image: grafana/grafana:latest          # Official Grafana image
    ports:
      - "3001:3000"                        # 3001 on your machine -> 3000 in the container
      # We use 3001 because port 3000 might already be taken by the frontend in dev
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin   # Admin password (login: admin / admin)
    depends_on:
      - prometheus
```

### 3. Run it

```bash
cd ~/devops-project
docker compose up -d --build

# Verify
docker compose ps
# 5 services running (backend, frontend, db, prometheus, grafana)
```

### 4. Verify Prometheus

Open `http://localhost:9090` in your browser.
- Go to **Status** -> **Targets**: you should see `backend:8000` with state `UP`
- In the search bar, type `http_requests_total` and click **Execute**

### 5. Create a Grafana dashboard

1. Open `http://localhost:3001` (login: admin / admin)
2. **Connections** -> **Data sources** -> **Add data source** -> **Prometheus**
3. URL: `http://prometheus:9090` -> **Save & Test**
4. **Dashboards** -> **New** -> **New Dashboard** -> **Add visualization**
5. Choose the Prometheus source, and enter a PromQL query:

**PromQL — Prometheus query language.** It's like SQL but for metrics. Here are the basics:
- `http_requests_total` = the name of a metric (the total number of requests received)
- `[1m]` = "over the last 1 minute"
- `rate()` = calculate the per-second rate (how many requests per second)
- `histogram_quantile(0.95, ...)` = the 95th percentile (95% of requests are faster than this value)

   Try these queries:
   - `rate(http_requests_total[1m])` -> number of requests per second
   - Click **Run queries** -> you see a graph
6. Add another panel:
   - `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` -> response time at the 95th percentile
7. **Save dashboard** -> Name it "DevOps Project"

### 6. Generate traffic and observe

> **Type these commands in your terminal:**

```bash
# Generate traffic to see metrics in Grafana
# This loop sends 100 requests to the backend
for i in $(seq 1 100); do
  curl -s http://localhost:8000/api/tasks > /dev/null
done
# $(seq 1 100) = create numbers from 1 to 100
# curl -s = send a request silently (no progress bar)
# > /dev/null = discard the response (we just want to send the request, not see the result)
```

Go back to Grafana — you'll see the graphs moving.

💡 **If Prometheus isn't scraping:** check that the target is `backend:8000` (the Docker service name, not localhost).

## Interview Corner

**Q: Why is monitoring important?**
A: Without monitoring, you don't know if your app is working correctly. You detect problems before users do, identify bottlenecks, and have data to make decisions.

**Q: What are the 3 pillars of observability?**
A: Metrics (numbers — CPU, response time), Logs (text messages from apps), Traces (path of a request through services).

**Q: What is Prometheus?**
A: A metrics collection system using the pull model. It scrapes `/metrics` endpoints from applications at regular intervals and stores the data in time series.

**Q: What is Grafana?**
A: A visualization tool. It connects to data sources (Prometheus, etc.) and creates dashboards with graphs and alerts.

**Q: Difference between pull and push model?**
A: Pull = Prometheus fetches the data (scrape). Push = applications send the data. Pull is simpler to manage and debug.

**Q: What makes a good alert?**
A: Actionable (you can do something about it), based on symptoms (not causes), and not too frequent (otherwise you ignore it).

**Q: What are SLI, SLO, and SLA?**
A: **SLI** (Service Level Indicator) = the measured metric (e.g., 99.2% of requests respond in under 200ms). **SLO** (Service Level Objective) = the internal target (e.g., we aim for 99.5%). **SLA** (Service Level Agreement) = the contractual commitment with the client (e.g., if we drop below 99%, we refund). SLI measures, SLO guides, SLA commits.

## Best practices

- **Start small.** 4 metrics are enough — these are the **Golden Signals** (Google's 4 golden signals): **latency** (response time), **traffic** (number of requests), **errors** (error rate), **saturation** (are resources full — CPU, memory, disk). These 4 numbers are worth more than 200 metrics nobody looks at.
- **Alert on symptoms, not causes.** "The site is slow for users" (symptom) is more useful than "CPU at 80%" (possible cause). CPU at 80% might be normal.
- **Every alert must have an action.** If you receive an alert and your reaction is "meh, that's normal", delete the alert. Alert fatigue is the biggest risk: you end up ignoring all alerts, including the real ones.
- **Dashboard for each audience.** Devs want to see latency per endpoint. The CTO wants to see the number of active users. Not the same dashboard.
- **Data retention.** Don't keep per-second metrics indefinitely — it costs disk space. 15 days at high resolution, 1 year at reduced resolution is a good default.

## Common mistakes

- **Prometheus not scraping** -> Check that the target is correct and that the port is accessible.
- **Grafana "No data"** -> Check the data source (correct Prometheus URL?).
- **Too many alerts** -> Alert fatigue. Start with few critical alerts.
- **Monitoring the wrong things** -> Monitor what impacts the user (latency, errors), not CPU.

## Going further

- **PromQL**: Prometheus query language — go deeper with `rate()`, `histogram_quantile()`, aggregations. You'll need it as soon as you create dashboards
- **Loki**: log system by Grafana Labs — centralize logs from all your services in one place
- **PagerDuty / OpsGenie**: alerting and on-call platforms — who's on call tonight, how to escalate incidents
- **SRE practices**: SLI (indicators), SLO (objectives), SLA (agreements) — the vocabulary of SRE teams, more organizational than technical

## You can move on to the next module if...

- [ ] You know the 3 pillars of observability (metrics, logs, traces)
- [ ] You know what Prometheus (collection) and Grafana (display) do
- [ ] You understand the difference between pull and push model
- [ ] You've seen the `/metrics` endpoint of your backend return data
- [ ] You've created a basic Grafana dashboard
- [ ] You know what makes a good alert (actionable, symptom-based, not too frequent)
