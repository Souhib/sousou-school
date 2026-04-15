# Module 9: Kubernetes (Optional)

> **Prerequisites:** Module 3 (Docker — containers, images), Module 2 (Networking — services, ports)

> **In a nutshell:** You go from "1 server with docker-compose" to an orchestrator that manages dozens of containers automatically. Kubernetes restarts containers that crash, distributes traffic, and lets you scale with a single command.

> **Alternative path:** This module is optional. The main course path is Modules 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6. Kubernetes is a parallel branch starting from Module 3 (Docker). You don't need to have completed Modules 5-7 to follow it. If you're just getting started, focus on the main path and come back here later.

## What is Kubernetes and why does it exist?

**The problem:** You have 1 server with docker-compose, it works. But what if you have 50 containers on 10 servers? Who restarts a container that crashes at 3 AM? Who distributes traffic between containers? Who does a deployment with zero downtime?

**Kubernetes (K8s)** is an **orchestrator** — a program that coordinates and automatically manages a large number of containers across multiple machines. You tell it "I want 3 copies of my backend running at all times", and it handles the rest: where to place them, restart them if they crash (**self-healing**), distribute traffic between them.

**The analogies (restaurant):**
- **Pod** = a chef at their station
- **Deployment** = "always keep 3 pasta chefs on duty"
- **Service** = the waiter who routes orders to the right chefs
- **Node** = a kitchen (a physical/virtual server)
- A chef gets sick? The manager hires a new one automatically.

## Architecture (simplified)

```
┌─── Control Plane (the brain) ─────────────────┐
│  API Server    = the receptionist              │
│  Scheduler     = the one who assigns tasks     │
│  etcd          = the address book              │
│  Controller    = the one who checks everything │
└─────────────────────────────────────────────────┘
        │
        ├── Node 1 (a machine)
        │   ├── Pod (backend)
        │   └── Pod (frontend)
        │
        └── Node 2 (a machine)
            ├── Pod (backend)
            └── Pod (backend)
```

- **Control Plane**: decides WHERE to place pods, monitors everything
- **Node**: a machine that runs pods
- **kubelet**: the agent on each node that communicates with the control plane

## Installation (minikube)

Minikube creates a local Kubernetes cluster (a single node) for learning.

```bash
# Install kubectl (the client)
# -L = follow redirects, -O = save with the original file name
# $(...) = execute the command in parentheses and use the result (gets the latest version)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# install = copy the file with the right permissions (executable by all)
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
# Client Version: v1.x.x

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start the cluster
minikube start
# 🎉  minikube v1.x.x
# ✅  Using the docker driver
# 🏄  Done! kubectl is now configured to use "minikube"

kubectl get nodes
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   1m    v1.x.x
```

## Kubernetes objects

### Pod

The basic unit. A pod = one or more containers running together. In practice, 1 pod = 1 container.

> Each Kubernetes object is described in YAML with 4 sections: `apiVersion` (K8s API version), `kind` (the object type), `metadata` (name and labels), `spec` (the configuration).

```yaml
# pod.yml (you almost never create these directly — you use a Deployment)
apiVersion: v1              # Kubernetes API version (v1 = the most basic)
kind: Pod                   # Object type: a Pod
metadata:
  name: mon-backend         # The pod name
spec:
  containers:               # List of containers in this pod (often just 1)
    - name: backend
      image: mon-user/devops-backend:latest
      ports:
        - containerPort: 8000   # The port the container listens on
```

### Deployment

Manages a group of identical pods. A **replica** = a copy of your app. If you want 2 replicas, K8s maintains 2 running copies at all times. If a pod crashes -> it recreates one. If you want 3 replicas -> it maintains 3.

```yaml
# backend-deployment.yml
apiVersion: apps/v1          # apps/v1 = the API for Deployments (different from v1 for Pods)
kind: Deployment
metadata:
  name: backend
spec:                        # Deployment spec (how many replicas, how to find them)
  replicas: 2                # Number of copies of your app to run
  selector:
    matchLabels:
      app: backend           # "Find pods that have the label app=backend"
                             # Must EXACTLY match the labels in the template below
  template:                  # Template for creating each pod
    metadata:
      labels:
        app: backend         # This label is used by the selector above to find the pods
    spec:                    # Pod spec (which containers, which ports)
                             # Note: there are 2 "spec" — the Deployment's and the Pod's
      containers:
        - name: backend
          image: mon-user/devops-backend:latest
          ports:
            - containerPort: 8000
```

### Service

Exposes pods on the network. Even if pods die and get recreated (with new IPs), the Service keeps a stable address.

```yaml
# backend-service.yml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend          # Find pods with the label app=backend (from the Deployment above)
  ports:
    - port: 8000          # The port to access the Service
      targetPort: 8000    # The container port traffic is forwarded to
                          # (often the same, but you could map 80 -> 8000 for example)
  type: ClusterIP         # Accessible only within the cluster (not from outside)
```

| Service type | What it is |
|-------------|-----------|
| **ClusterIP** | Accessible only within the cluster (default) |
| **NodePort** | Accessible from outside via a port on the node |
| **LoadBalancer** | Creates an external load balancer (cloud) |

> The load balancer concept comes from Module 2 (Networking). Kubernetes Services do the same thing: distribute traffic across pods.

### ConfigMap and Secret

```yaml
# ConfigMap = non-sensitive config
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"

# Secret = sensitive config (base64 encoded)
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_PASSWORD: bW9ucGFzcw==  # base64 of "monpass"
```

## Essential kubectl commands

```bash
# Apply a YAML file
kubectl apply -f backend-deployment.yml

# View pods
kubectl get pods
# NAME                       READY   STATUS    RESTARTS   AGE
# backend-6d4f5b7c9d-abc12   1/1     Running   0          1m
# backend-6d4f5b7c9d-def34   1/1     Running   0          1m

# View deployments
kubectl get deployments

# View services
kubectl get services

# Details about a pod
kubectl describe pod backend-6d4f5b7c9d-abc12

# View logs
kubectl logs backend-6d4f5b7c9d-abc12

# Delete
kubectl delete -f backend-deployment.yml

# Scale
kubectl scale deployment backend --replicas=5
```

## Namespaces

A namespace isolates resources within the cluster (like folders). By default, everything is in the `default` namespace.

```bash
kubectl get namespaces
kubectl get pods -n kube-system  # View system pods
```

## Hands-on Project: Deploy on minikube

### 1. Create the files

```bash
mkdir -p ~/devops-k8s
cd ~/devops-k8s
```

### 2. Backend Deployment + Service

Create `backend.yml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: mon-user/devops-backend:latest
          ports:
            - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
    - port: 8000
      targetPort: 8000
  type: NodePort
```

### 3. Frontend Deployment + Service

Create `frontend.yml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: mon-user/devops-frontend:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
  type: NodePort
```

### 4. Load images into minikube

Minikube has its own image registry, separate from your local Docker. If your images aren't on Docker Hub, you need to load them manually:

```bash
# Option A: load local images
docker build -t mon-user/devops-backend:latest ~/devops-project/backend
docker build -t mon-user/devops-frontend:latest ~/devops-project/frontend
minikube image load mon-user/devops-backend:latest
minikube image load mon-user/devops-frontend:latest

# Option B: if your images are on Docker Hub, K8s downloads them automatically
# (the name in the YAML must match the image on Docker Hub)
```

### 5. Deploy

```bash
kubectl apply -f backend.yml
kubectl apply -f frontend.yml

kubectl get pods
# NAME                        READY   STATUS    RESTARTS   AGE
# backend-xxx-abc12           1/1     Running   0          30s
# backend-xxx-def34           1/1     Running   0          30s
# frontend-xxx-ghi56          1/1     Running   0          25s
# frontend-xxx-jkl78          1/1     Running   0          25s

kubectl get services
# NAME               TYPE       CLUSTER-IP      PORT(S)
# backend-service    NodePort   10.96.x.x       8000:3xxxx/TCP
# frontend-service   NodePort   10.96.x.x       80:3yyyy/TCP
```

### 6. Access the app

```bash
minikube service frontend-service --url
# http://192.168.49.2:3yyyy
# Open this URL in your browser
```

### 7. Scale and observe

```bash
# Go from 2 to 5 replicas
kubectl scale deployment backend --replicas=5
kubectl get pods
# 5 backend pods!

# Delete a pod (K8s recreates one automatically)
kubectl delete pod backend-xxx-abc12
kubectl get pods
# Still 5 pods — K8s recreated the missing pod

# Rolling update = progressive update (change the image without downtime)
# K8s replaces pods one by one: it creates a new pod with v2,
# waits for it to be ready, then deletes an old v1 pod, and so on.
kubectl set image deployment/backend backend=mon-user/devops-backend:v2
kubectl rollout status deployment/backend
# Waiting for deployment "backend" rollout to finish...
# deployment "backend" successfully rolled out
```

### 8. Clean up

```bash
kubectl delete -f backend.yml
kubectl delete -f frontend.yml
minikube stop
```

## Debug exercise: Why won't the pod start?

You deploy the backend and see this:

```bash
kubectl get pods
# NAME                       READY   STATUS             RESTARTS   AGE
# backend-6d4f5b7c9d-abc12   0/1     ImagePullBackOff   0          2m
```

And when you run `kubectl describe pod backend-6d4f5b7c9d-abc12`, you see:

```
Events:
  Warning  Failed     2m    kubelet  Failed to pull image "mon-user/devops-backend:latest":
           rpc error: code = Unknown desc = Error response from daemon: pull access denied
  Warning  Failed     2m    kubelet  Error: ImagePullBackOff
```

What's happening and how do you fix it?

<details>
<summary>💡 Hint 1</summary>

The message says "pull access denied". K8s is trying to download the image from Docker Hub but can't.

</details>

<details>
<summary>💡 Hint 2</summary>

With minikube, local Docker images are not automatically available in the cluster.

</details>

<details>
<summary>✅ Solution</summary>

**The problem:** Kubernetes is trying to download (`pull`) the image from Docker Hub, but it doesn't exist on Docker Hub (either the name is wrong, the repo is private, or the image is only local).

**3 possible solutions:**

1. **Load the local image into minikube** (most common in dev):
```bash
minikube image load mon-user/devops-backend:latest
```

2. **Push the image to Docker Hub** (if you want K8s to download it):
```bash
docker push mon-user/devops-backend:latest
```

3. **Check the image name** in the YAML — a typo in `image:` causes this problem.

After the fix, force K8s to retry:
```bash
kubectl rollout restart deployment backend
```

</details>

## Interview Corner

**Q: What is Kubernetes?**
A: A container orchestrator. It manages deployment, scaling, and high availability of containerized applications on a cluster of machines.

**Q: Difference between Docker and Kubernetes?**
A: Docker runs ONE container. Kubernetes orchestrates DOZENS/HUNDREDS of containers across multiple machines (scheduling, scaling, self-healing).

**Q: What is a Pod?**
A: The basic unit in K8s. A pod contains one or more containers that share the same network and storage. In practice, 1 pod = 1 container.

**Q: What is a Deployment?**
A: An object that manages a group of identical pods. It maintains the desired number of replicas, handles updates (rolling update), and recreates pods that crash.

**Q: What is a Service?**
A: A stable network access point to a group of pods. Pods have ephemeral IPs, the Service has a fixed IP and distributes traffic.

**Q: How does K8s handle a pod that crashes?**
A: The Controller detects that the number of replicas no longer matches the desired count, and automatically recreates a pod to compensate (self-healing).

**Q: What is a Namespace?**
A: A way to isolate resources within a cluster. Useful for separating environments (dev, staging, prod) or teams.

**Q: What is an Ingress?**
A: A K8s object that manages HTTP(S) routing to Services. It lets you say "requests to `api.mysite.com` go to the backend Service" and "requests to `mysite.com` go to the frontend Service". It's the HTTP entry point of the cluster.

**Q: What is a ConfigMap and a Secret?**
A: K8s objects for storing configuration. A **ConfigMap** stores non-sensitive data (URLs, feature flags). A **Secret** stores sensitive data (passwords, API keys) encoded in base64. Both are injected into pods as environment variables or files.

**Q: What is a liveness probe and a readiness probe?**
A: Health checks that K8s runs on your pods. The **liveness probe** checks if the pod is alive — if it fails, K8s restarts the pod. The **readiness probe** checks if the pod is ready to receive traffic — if it fails, K8s stops sending requests to it without restarting it.

**Q: Difference between ClusterIP, NodePort, and LoadBalancer?**
A: Three types of K8s Services. **ClusterIP** (default) = accessible only from inside the cluster. **NodePort** = accessible from outside via a port on each node (e.g., `node-ip:30080`). **LoadBalancer** = creates an external load balancer (cloud provider) that redirects to the Service. In production, you typically use an Ingress in front of a ClusterIP Service.

## Best practices

- **Declare resources (CPU/RAM).** Without `resources.requests` and `resources.limits`, a pod can consume the entire node and crash the others. Always define limits.
- **Use health checks.** `readinessProbe` (is the pod ready to receive traffic?) and `livenessProbe` (is the pod still alive?). This is the `/api/health` endpoint we added in Module 3 (Docker). Without this, K8s sends traffic to pods that aren't ready.
- **Never deploy `:latest`.** Tag your images with a commit hash or version number. `:latest` changes without warning, and you can't do a clean rollback.
- **One namespace per environment.** `dev`, `staging`, `prod`. This isolates resources and prevents accidentally deleting prod.
- **Store your YAML in Git.** K8s deployment files are code — they should be versioned, reviewed in PRs, and never applied manually in prod.

## Common mistakes

- **Image not found** -> Check the image name in the YAML. If it's a local image, use `minikube image load`.
- **CrashLoopBackOff** -> The container is crash-looping. `kubectl logs POD` to see the error.
- **Pending** -> Not enough resources on the node. Reduce replicas or resource requests.
- **Forgetting the selector** -> The Service can't find the pods. Labels in the Deployment must match the Service's selector.

## Going further

- **Ingress**: HTTP routing — a single entry point for multiple services, with domain names. This is the first thing you'll configure to expose your services
- **Helm**: package manager for K8s — you describe your app in a reusable "chart" instead of 10 separate YAML files
- **Horizontal Pod Autoscaler (HPA)**: automatically scale the number of pods based on CPU/RAM — essential in production
- **RBAC**: access control in K8s — who has the right to do what in which namespace. More governance than technical

## You can move on to the next module if...

- [ ] You know the difference between Docker (1 container) and Kubernetes (orchestration of N containers)
- [ ] You know the basic objects: Pod, Deployment, Service
- [ ] You know how to use `kubectl get`, `kubectl apply`, `kubectl logs`, `kubectl scale`
- [ ] You've deployed the project on minikube with 2 replicas
- [ ] You've tested self-healing (delete a pod -> K8s recreates it)
- [ ] You've cleaned up with `minikube stop`
