# Module 2: Networking

> **Prerequisites:** Module 1 (Linux — being comfortable with the terminal)

> **In a nutshell:** You understand how machines communicate with each other — IP, ports, DNS, HTTP, firewalls. These concepts come back in every following module: Docker (port mapping, service discovery), AWS (VPC, Security Groups), Kubernetes (Services, load balancing).

## What is networking and why does it matter?

**The problem:** Everything in DevOps goes through the network. Docker, AWS, Kubernetes — it's all machines communicating with each other. If you don't understand how two machines talk to each other, you'll be stuck at every step. It's like trying to send mail without knowing how the postal system works.

**The analogies:**
- **IP address** = your home address
- **Port** = apartment number in the building
- **DNS** = phone book (translates "google.com" into an IP address)
- **HTTP** = the language you speak when you knock on the door
- **Firewall** = the security guard at the building entrance

## Installation

These tools are used to test networking. Install them now:

```bash
sudo apt install -y dnsutils net-tools curl wget
# dnsutils = contains "dig", to query DNS servers
# net-tools = classic networking commands
# curl = send HTTP requests from the terminal
# wget = download files from a URL
```

## IP Addresses

An IP address identifies a machine on the network. There are two types:

| Type | Example | What it is |
|------|---------|-----------|
| **Public** | `203.0.113.42` | Your address on the Internet (visible to everyone) |
| **Private** | `192.168.1.15` | Your local address (visible only on your network) |

```bash
# See your private IP
ip addr show
# or
hostname -I
# 192.168.1.15

# See your public IP
curl ifconfig.me
# 203.0.113.42
```

**Analogy:** The public IP = your building's address. The private IP = your apartment number inside.

## Ports

A port = a number between 1 and 65535 that identifies a service on a machine. An IP without a port is like an address without an apartment number.

| Port | Service |
|------|---------|
| 22 | SSH (remote connection) |
| 80 | HTTP (unsecured web) |
| 443 | HTTPS (secured web) |
| 8080 | Alternative HTTP (often used for dev) |
| 3000 | Often React/Node in dev |
| 5432 | PostgreSQL |
| 8000 | Often FastAPI/Django in dev |

```bash
# See the open ports on your machine
ss -tlnp
# -t = TCP only, -l = listening ports, -n = show numbers, -p = show process
# State   Recv-Q  Send-Q   Local Address:Port   ...
# LISTEN  0       128      0.0.0.0:22            ...  sshd
# LISTEN  0       128      0.0.0.0:8000          ...  uvicorn
```

## Port Mapping (crucial for Docker)

When you launch a Docker container (Module 3), you'll often see `-p 3000:80` or `-p 8000:8000`. This is **port mapping** (port forwarding).

```
-p PORT_ON_YOUR_MACHINE:PORT_IN_THE_CONTAINER
```

**Concrete example:**

```
docker run -p 3000:80 mon-frontend
```

> (We'll cover this command in Module 3 — Docker. For now, just remember the port mapping syntax.)

This means: "requests arriving on **port 3000 of my machine** are forwarded to **port 80 of the container**."

```
Your browser                   Your machine                Container
http://localhost:3000  ──▶  port 3000 (your machine)  ──▶  port 80 (nginx)
```

| Command | What happens |
|----------|----------------|
| `-p 8000:8000` | Port 8000 → Port 8000 (same port, the simplest) |
| `-p 3000:80` | Port 3000 on your machine → Port 80 in the container |
| `-p 80:80` | Port 80 → Port 80 (standard HTTP) |

**Why is this useful?** Multiple containers can use the same internal port (80) because they are isolated. You differentiate them by the port on your machine: the frontend on 3000, the backend on 8000.

Just remember: **left = your machine, right = the container.**

## DNS

DNS translates a domain name (`google.com`) into an IP address (`142.250.74.206`). Without DNS, you'd have to memorize the IP of every website.

```bash
dig google.com
# ;; ANSWER SECTION:
# google.com.     300     IN      A       142.250.74.206

# Simplified version (+short = show only the IP, without the technical details)
dig +short google.com
# 142.250.74.206

# See which DNS server you're using
# This file contains the DNS servers your machine uses to resolve names
cat /etc/resolv.conf
```

## HTTP / HTTPS and Status Codes

A **protocol** is a set of rules that two machines follow to communicate — like a common language. If you speak French and the other speaks English, you won't understand each other. HTTP is the protocol (the language) your browser uses to talk to web servers. HTTPS = the same thing, but encrypted (the padlock in your browser — nobody can read the exchanges between you and the server).

The important status codes:

| Code | Meaning | Analogy |
|------|--------------|----------|
| **200** | OK, everything is fine | "Here's your order" |
| **301** | Permanent redirect | "We've moved, go over there" |
| **404** | Not found | "That doesn't exist here" |
| **500** | Server error | "We have a problem in the kitchen" |
| **502** | Bad Gateway | "The server behind is down" |

```bash
# Make an HTTP request
curl http://localhost:8000/api/tasks
# [{"id":1,"title":"Apprendre Docker","done":false}]

# See the headers (including the status code)
# -I = show only the headers (response metadata, not the content)
curl -I https://google.com
# HTTP/2 301
# location: https://www.google.com/

# Download a file
wget https://example.com/fichier.txt
```

## TCP vs UDP

- **TCP**: reliable, verifies that everything arrives in order (HTTP, SSH, email). Like a registered letter with acknowledgment of receipt.
- **UDP**: fast, doesn't verify anything (video streaming, DNS, online games). Like a postcard — faster but no guarantee.

## Subnets / CIDR

A subnet divides a network into smaller pieces.

The CIDR notation `/24` means: the first 24 bits of the address are fixed, the rest varies.

| CIDR | Number of addresses | Example |
|------|-------------------|---------|
| `/32` | 1 address | A single machine |
| `/24` | 256 addresses | A small network (the most common) |
| `/16` | 65,536 addresses | A large network |
| `/0` | All of the Internet | Everyone |

**Example:** `192.168.1.0/24` = all addresses from `192.168.1.0` to `192.168.1.255`.

That's all you need to know. In interviews, remember `/24 = 256 addresses`.

## Reverse Proxy and Load Balancer

These two terms come up all the time in DevOps. They're related but different.

### Reverse Proxy

A **proxy** is an intermediary between two machines. A **reverse proxy** sits **in front of** your application and receives all requests on its behalf.

```
User → Reverse Proxy (nginx) → Your app (port 8000)
```

**Why?** Your app isn't designed to handle HTTPS, compression, static files, or 10,000 simultaneous connections. The reverse proxy does all of that for it.

**Analogy:** The receptionist at a hotel. Guests don't go directly to the rooms — they go through the receptionist who directs them.

**The most common tool:** nginx. You'll see it in Module 3 (Docker) in front of our frontend.

### Load Balancer

A load balancer distributes traffic across **multiple identical servers**.

```
                    ┌── Server 1 (your app)
User → LB ──┼── Server 2 (your app)
                    └── Server 3 (your app)
```

**Why?** A single server can't handle unlimited traffic. With a load balancer, you add servers to absorb more traffic. And if one server goes down, the others pick up the slack.

**Analogy:** The host at a restaurant who seats customers across different tables. If one waiter is overwhelmed, they send customers to the others.

**On AWS:** Application Load Balancer (ALB). You'll see it in Modules 5 and 8.

> In practice, a reverse proxy and a load balancer are often the same tool (nginx, ALB). The difference is the role: proxy = 1 server behind, load balancer = N servers behind.

## Firewall (ufw)

A firewall controls who can get in and out of your machine. `ufw` (Uncomplicated Firewall) is Ubuntu's simple firewall.

```bash
# Enable the firewall
sudo ufw enable

# See the rules
sudo ufw status

# Allow SSH (otherwise you'll lock yourself out!)
sudo ufw allow 22

# Allow port 80 (HTTP)
sudo ufw allow 80

# Allow a specific port
sudo ufw allow 8000

# Block a port
sudo ufw deny 3306

# Delete a rule
sudo ufw delete allow 8000
```

⚠️ **Always allow SSH (port 22) BEFORE enabling the firewall on a remote server.** Otherwise you'll lock yourself out.

> **WSL note:** `ufw` may not work correctly in WSL because networking is managed by Windows. The commands above are mostly useful on a real Linux server (EC2 in Module 5). In WSL, you can read and understand them without running them.

## Useful Networking Commands

```bash
# Check if a machine is reachable
ping google.com
# PING google.com (142.250.74.206): 56 data bytes
# 64 bytes from 142.250.74.206: icmp_seq=0 ttl=117 time=12.3 ms

# See the network path to a machine
traceroute google.com

# See connections and open ports
ss -tlnp

# Resolve a DNS name
dig +short example.com

# Make an HTTP request
curl http://localhost:8000/api/health
# {"status":"ok"}
```

> **Some commands below (like `ufw`) may not work on WSL.** That's normal — read and understand the commands even if you can't test them all.

## Hands-on Project

### 1. Query a public API

```bash
curl https://httpbin.org/ip
# {"origin": "your.public.ip"}

curl https://httpbin.org/status/404
# (returns a 404)

curl -I https://httpbin.org/status/200
# HTTP/2 200
```

### 2. Resolve DNS names

```bash
dig +short google.com
dig +short github.com
dig +short amazon.com
```

### 3. Check the ports of your project

Launch the Hands-on Project backend, then:
```bash
cd ~/devops-project/backend
uv run uvicorn main:app --reload &

ss -tlnp | grep 8000
# LISTEN  0  128  0.0.0.0:8000  ...  uvicorn

curl http://localhost:8000/api/health
# {"status":"ok"}
```

### 4. Configure ufw

```bash
sudo ufw allow 22
sudo ufw allow 8000
sudo ufw allow 3000
sudo ufw enable
sudo ufw status
# Status: active
# To                         Action      From
# --                         ------      ----
# 22                         ALLOW       Anywhere
# 8000                       ALLOW       Anywhere
# 3000                       ALLOW       Anywhere
```

## Interview Corner

> The first question is a classic interview staple. It tests whether you can connect all the concepts from this module (DNS, IP, HTTP, request/response) into a concrete scenario.

**Q: What happens when you type a URL in your browser?**
A: Let's take the example of `instagram.com`:
1. **DNS resolution** — Your browser doesn't know `instagram.com`. It asks a **DNS** (the Internet's phone book) to give it the server's IP address (e.g., `157.240.1.174`). It's like looking up a phone number from a name in a directory.
2. **Sending the request** — Your browser sends an HTTP request to the server at that IP address: "send me the homepage".
3. **Server-side processing** — Instagram's server receives the request, fetches the necessary data (your posts, your stories...) and prepares the response.
4. **Server response** — The server sends back an HTTP response containing the page content (HTML for structure, CSS for styling, JavaScript for interactions) and data (in JSON).
5. **Rendering** — Your browser receives all of this, assembles the HTML/CSS/JavaScript, and displays the page on screen.

In short: your browser → DNS → server → response → display. The entire round trip typically takes a few hundred milliseconds.

**Q: What is an IP address?**
A: A unique identifier for a machine on a network. Two types: public (visible on the Internet) and private (visible only locally).

**Q: What is a port?**
A: A number (1-65535) that identifies a service on a machine. Example: 80 = HTTP, 443 = HTTPS, 22 = SSH.

**Q: What is DNS?**
A: The system that translates domain names (google.com) into IP addresses (142.250.74.206). Without DNS, you'd have to memorize IPs.

**Q: Difference between TCP and UDP?**
A: TCP is reliable (verifies everything arrives), UDP is fast (doesn't verify). HTTP uses TCP, streaming often uses UDP.

**Q: What is a CIDR /24?**
A: A subnet of 256 IP addresses. Example: 10.0.1.0/24 = 10.0.1.0 to 10.0.1.255.

**Q: What is a firewall?**
A: A filter that controls incoming and outgoing network traffic. It allows or blocks traffic based on rules (port, source IP, etc.).

**Q: What does a 502 code mean?**
A: Bad Gateway — the proxy/load balancer server can't reach the server behind it. Usually the application server has crashed.

**Q: Difference between HTTP and HTTPS?**
A: HTTPS = HTTP + encryption (TLS/SSL). Data is encrypted between your browser and the server — nobody can read it in transit. The padlock in the browser = HTTPS. Today, every serious site must use HTTPS.

**Q: What is a reverse proxy?**
A: A server that sits in front of your application and receives requests on its behalf. It can distribute traffic between multiple servers, handle HTTPS, cache content, etc. Nginx is the most common reverse proxy.

**Q: What is a load balancer?**
A: A tool that distributes traffic across multiple servers. If you have 3 backend servers, the load balancer sends each request to a different server to spread the load. If a server goes down, the load balancer stops sending traffic to it.

## Common Mistakes

- **Forgetting to allow SSH before enabling ufw** → You lock yourself out of the remote server.
- **Confusing public and private IP** → A private IP (192.168.x.x) is not reachable from the Internet.
- **"Connection refused"** → The service isn't listening on that port, or the firewall is blocking it.
- **"Could not resolve host"** → DNS problem. Check `/etc/resolv.conf` or try with the IP directly.

## Best Practices

- **Never expose a database to the Internet.** The DB should only be accessible from the internal network (private subnet, restricted Security Group).
- **HTTPS everywhere.** Even in dev. Let's Encrypt provides free certificates. In production, there's no excuse for HTTP.
- **Only open the ports you need.** Every open port is an attack surface. SSH (22) + HTTP(S) (80/443) is enough for most cases.
- **Change the default SSH port** on servers exposed to the Internet (from 22 to a custom port). This reduces automated attacks.

## Going Further

- **VPN / Tunneling**: creating secure connections between networks — very common in companies to access internal infrastructure
- **Wireshark**: inspecting network traffic in real time — useful for debugging complex networking issues
- **mTLS**: mutual certificate authentication between services — increasingly required in microservices

## You can move on to the next module if...

- [ ] You know the difference between a public and private IP
- [ ] You know what a port is and you know the common ports (22, 80, 443, 8000)
- [ ] You understand port mapping (`-p 3000:80` = left is the machine, right is the container)
- [ ] You know what DNS does (translates a name into an IP)
- [ ] You know the important HTTP codes (200, 404, 500, 502)
- [ ] You know how to use `curl` to test an API
- [ ] You know what a firewall and a reverse proxy are
