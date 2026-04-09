# Module 0: Prerequisites

> **Prerequisites:** None — this is the starting point!

> **In a nutshell:** You install your work environment (WSL + VS Code + tools) and learn Git — the save and collaboration system you'll use in ALL subsequent modules. You also set up the Hands-on Project (React + FastAPI) that you'll build upon throughout the course.

## What is it and why?

Before doing DevOps, you need two things: a **Linux environment** (because 90% of servers run on Linux) and **Git** (because all code lives in Git).

**What is a server?** A server is just a computer that runs 24/7 and responds to requests from other computers. When you type `google.com`, your browser sends a request to a Google server, which responds with the web page. Your application's server is the computer where your app runs and waits for user requests.

**Git** is like a **video game save system**. Each commit = a save point. You can go back in time, create branches (parallel universes), and merge everything together. Without Git, it's `project_final_v2_FINAL_really_final.zip`.

**WSL** (Windows Subsystem for Linux) lets you run real Linux inside Windows, without a heavy virtual machine.

> **Already on Linux or macOS?** You already have a native Unix terminal. Skip the "WSL2 + Ubuntu Installation" and "VS Code + Remote WSL Installation" sections — they're only for Windows users. Jump straight to "Installing Python, uv and Bun".

## WSL2 + Ubuntu Installation (Windows only)

You have two ways to do this — the result is exactly the same:

**Option A — Command line:** open **PowerShell as administrator** and type:

```powershell
wsl --install
```

**Option B — From the Microsoft Store:** open the Microsoft Store, search for "Ubuntu", and click **Install**. It's the same thing as the command above, just the graphical version.

In both cases, restart your PC. On reboot, Ubuntu opens and asks you for a username and password.

Verify it works:
```bash
wsl --list --verbose
# You should see: Ubuntu    Running    2
```

## VS Code + Remote WSL Installation (Windows only)

1. Install [VS Code](https://code.visualstudio.com/)
   - ⚠️ **During installation, make sure to check the box "Add to PATH"**. Without this, the `code .` command won't work in the terminal.
2. Install the **WSL** extension (search for "WSL" in the extensions)
3. In Ubuntu, type `code .` in any folder — it opens VS Code connected to WSL

> **Linux / macOS:** just install VS Code normally, no need for the WSL extension. On macOS, open VS Code then `Cmd+Shift+P` → "Shell Command: Install 'code' command in PATH" to enable `code .` in the terminal.

## Installing Python, uv and Bun (project tools)

> **You don't need to learn Python or Bun for this course.** We install them because the Hands-on Project needs them (backend in Python, frontend in JavaScript). You'll just copy-paste commands to install and run the app. The goal of this course is DevOps, not development.

Before we begin, here are some terms you'll see everywhere:

| Term | Simple explanation |
|------|-------------------|
| **Application (app)** | A program that does something. Our app = a task list. |
| **Dependency (= package)** | A piece of code written by someone else that your app uses. Instead of coding everything yourself, you reuse existing work. Like ready-made ingredients instead of making everything from scratch. We also call it a **package** because it's code packaged up and ready to install. FastAPI is a package. Pytest is a package. |
| **Package manager** | A tool that downloads, installs, and updates packages (dependencies) automatically. You tell it "I need FastAPI" and it goes and fetches it from the Internet, installs it, and handles updates. Each language has its own: **pip/uv** for Python, **npm/bun** for JavaScript, **apt** for Linux. |
| **Framework** | A set of ready-to-use tools for building a specific type of application. FastAPI is a framework for creating APIs in Python. React is a framework for creating web interfaces. |
| **API** | Application Programming Interface — a way for two programs to talk to each other. Concretely, it's a set of URLs (like `/api/tasks`) that you can send requests to and receive responses from (in JSON). |
| **Endpoint** | A specific URL in an API that performs an action. `GET /api/tasks` is an endpoint that returns the list of tasks. |

### Python — The backend

Python is a very popular programming language. Our backend (FastAPI API) is written in Python. You just need to install it:

```bash
sudo apt update && sudo apt install -y python3
python3 --version
# Python 3.x.x
```

**Let's break down this command** — it's the first "real" Linux command of the course, so let's understand it:

**`sudo`** = "Super User DO". On Linux, certain actions are reserved for the administrator (installing software, modifying system configuration...). By default, you're a regular user — you don't have permission to do everything. `sudo` before a command means "run this as administrator". It's exactly like on Windows when you do **right-click → Run as administrator**. Linux will ask for your password the first time.

**`apt`** = the package manager for **Ubuntu and Debian**. It's like a **command-line app store**. Instead of searching for software on the Internet, downloading an `.exe` and installing it manually, you type `apt install software_name` and apt goes and fetches it, downloads it, and installs it for you. It also handles updates and uninstallation. You saw in the table above that each language has its own package manager (uv for Python, bun for JS) — `apt` is the one for your **operating system**, for installing system software (git, curl, docker, python3...). Each Linux family has its own:

| Distribution | Package manager | Installation example |
|-------------|----------------|---------------------|
| **Ubuntu / Debian** | `apt` | `sudo apt install git` |
| **Fedora** | `dnf` | `sudo dnf install git` |
| **Arch Linux** | `pacman` | `sudo pacman -S git` |
| **Alpine** | `apk` | `apk add git` |

In this course we use Ubuntu (via WSL), so we use `apt`. If you see `dnf` or `pacman` elsewhere, it's the same concept, just for a different distribution.

Now the full command:

```
sudo apt update          &&  sudo apt install -y python3
│    │   │                │  │    │   │       │  │
│    │   │                │  │    │   │       │  └── the package to install (python3, not python2 — nobody uses that anymore)
│    │   │                │  │    │   │       └── "-y" = answer "yes" automatically (otherwise apt asks for confirmation)
│    │   │                │  │    │   └── install = install a package
│    │   │                │  │    └── apt
│    │   │                │  └── sudo
│    │   │                └── && = "AND then" — runs the 2nd command only if the 1st succeeded
│    │   └── update = update the list of available packages (not the packages themselves, just the catalog)
│    └── apt
└── sudo
```

In plain English: "As admin, update the catalog of available software, **then** as admin, install python3 (and answer yes automatically)."

You'll see `sudo apt install -y <package>` throughout the entire course. It's THE command for installing software on Linux.

### uv — The Python dependency manager

Historically, to manage Python dependencies, we used **pip** (Python's package manager — it downloads and installs dependencies) + **venv** (a tool that creates an isolated folder for each project, so that one project's dependencies don't interfere with another's — imagine separate boxes for each recipe). It works, but it's slow and verbose.

**uv** is a recent alternative that replaces pip + venv in a single tool, much faster and simpler to use. Same concept, just a better tool.

| | pip + venv (old way) | uv (what we use) |
|--|---------------------|-------------------|
| Create an environment | `python3 -m venv venv && source venv/bin/activate` | `uv sync` (automatic) |
| Install dependencies | `pip install -r requirements.txt` | `uv sync` |
| Add a dependency | Edit `requirements.txt` manually + `pip install` | `uv add fastapi` |
| Run a command | `source venv/bin/activate && pytest` | `uv run pytest` |

> **In the workplace**, you'll still see a lot of `pip` + `requirements.txt`. uv is newer but gaining ground fast. The concepts are the same, only the tools change.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# Restart your terminal, then:
uv --version
# uv 0.x.x
```

**What's this `curl ... | sh` command?** It's a common pattern for installing tools. Let's break it down:
- `curl` = a tool that downloads content from the Internet (like a browser, but in the command line)
- `-L` = follow redirects (if the URL redirects to another one, curl follows automatically)
- `-s` = silent (no progress bar)
- `-S` = but still show errors (otherwise `-s` hides everything, even errors)
- `-f` = fail cleanly if the server responds with an error (instead of downloading the error page)
- `https://astral.sh/uv/install.sh` = the URL of the installation script
- `| sh` = the pipe `|` sends the downloaded content to `sh` (the shell) which executes it as a script

In one sentence: "download the installation script and run it".

### Bun — The frontend

To run JavaScript, we historically need **Node.js** (a program that lets you run JavaScript code outside the browser) and **npm** (the JavaScript package manager — like pip for Python, it installs dependencies). **Bun** is a recent alternative that does both in a single tool, much faster.

In a nutshell: Bun = Node.js + npm, but faster and simpler. That's why we use it here.

```bash
# Bun needs "unzip" to install — let's install that first
sudo apt install -y unzip

curl -fsSL https://bun.sh/install | bash
# Same idea as for uv: download and run the installation script
# Restart your terminal, then:
bun --version
# 1.x.x
```

> **In the workplace**, you'll often see `npm install` / `npm run dev` instead of `bun install` / `bun run dev`. It's the same thing, just a different tool.

## Navigating the terminal

Before touching Git, you need to know how to navigate the terminal. When you open a terminal, you're in a folder (by default, your home folder). Two essential commands:

```bash
pwd
# /home/jean
# "Print Working Directory" = shows the folder you're currently in
# It's your compass — if you're lost, type pwd

cd ~/devops-project
# "Change Directory" = move into a folder
# ~ = shortcut for your home folder (/home/jean)

cd ..
# Go up one level (go to the parent folder)
# If you're in /home/jean/devops-project, cd .. brings you back to /home/jean

cd ..
# One more level up: now you're in /home

cd ~/devops-project
# Go back directly to the project folder (no matter where you were)
```

You'll use `cd` and `pwd` constantly. More details in Module 1.

## Git — The 7 essential commands

### Configuring Git (one time only)
```bash
# Replace with YOUR real name and YOUR real email (the one on your GitHub account)
git config --global user.name "Jean Dupont"
git config --global user.email "jean.dupont@gmail.com"
```

This info appears in every commit you make — that's how people know who wrote what.

### The commands

| Command | What it does | Analogy |
|---------|-------------|---------|
| `git init` | Creates a new repo | Starting a new game |
| `git add file` | Stages a file for commit | Putting items in a box |
| `git commit -m "message"` | Saves | Save point |
| `git push` | Sends to GitHub | Uploading your save to the cloud |
| `git pull` | Fetches from GitHub | Downloading the latest save |
| `git branch name` | Creates a branch | Opening a parallel universe |
| `git merge name` | Merges a branch | Combining two universes |

### Basic workflow

```bash
# See the current state
git status

# Add modified files
git add main.py
# Or add everything at once:
git add .

# Save
git commit -m "add GET /tasks endpoint"

# Send to GitHub
git push
```

### Branches

```bash
# Create and switch to a branch
git checkout -b my-feature

# Work, commit, etc.
git add .
git commit -m "add feature X"

# Go back to main and merge
git checkout main
git merge my-feature
```

## Create a GitHub account

1. Go to [github.com](https://github.com) and create an account
2. Create a new repository: **+** button → **New repository**
3. Name it `devops-project`, leave it public, **check "Add a README file"**
4. Click **Create repository**

## Hands-on Project: Setting up the project

### 1. Clone your repo and copy the project code into it

First, clone YOUR GitHub repo (the one you just created):

```bash
cd ~
# ~ = your home folder (/home/your_user)

ls
# You see your personal folders (Documents, Downloads, etc.)

git clone git@github.com:YOUR_USER/devops-project.git
# Replace YOUR_USER with your GitHub username
# This creates a ~/devops-project/ folder with the README inside

ls
# devops-project   Documents   Downloads   ...
# ↑ the new folder appeared

cd devops-project
pwd
# /home/your_user/devops-project

ls
# README.md
# For now there's only the README — we'll add the code right after
```

> **If you get a "Permission denied (publickey)" error**, it means you haven't set up your SSH key yet. Go to step 5 first, then come back here.

Next, we'll get the application code from the course repo and copy it into your project:

```bash
# Go back to your home folder
cd ~
pwd
# /home/your_user

# Clone the course repo (this creates a "devops-from-zero" folder here)
git clone https://github.com/Souhib/devops-from-zero.git

ls
# devops-from-zero   devops-project   Documents   ...
# ↑ the course repo appeared next to your project

# Copy the project code into your repo
cp -r devops-from-zero/devops-project/* devops-project/
cp -r devops-from-zero/devops-project/.gitignore devops-project/

# Delete the course repo (we don't need it anymore)
rm -rf devops-from-zero

ls
# devops-project   Documents   Downloads   ...
# ↑ devops-from-zero is gone, that's normal

# Verify the code is in your project
cd devops-project
ls
# backend  docker-compose.yml  frontend  README.md
# ↑ everything's there!
```

You should have this structure:
```
~/devops-project/
├── docker-compose.yml
├── frontend/
│   ├── Dockerfile, nginx.conf, package.json, src/App.jsx, ...
└── backend/
    ├── Dockerfile, main.py, test_main.py, pyproject.toml, uv.lock
```

> **What's frontend/backend?** The **backend** is the invisible part — the program that runs on the server, manages data, and responds to requests. Here, it's written in Python with FastAPI. The **frontend** is the visible part — the web page the user sees in their browser. Here, it's written in JavaScript with React. The frontend calls the backend via HTTP requests (`GET /api/tasks`, `POST /api/tasks`, etc.) and displays the responses. You don't need to understand the React or FastAPI code for this course — just know that the frontend calls the backend.

### 2. Run the backend

```bash
cd ~/devops-project/backend
uv sync
# Resolved X packages in X.Xs  (the exact number may vary)
# Installed X packages in X.Xs

uv run uvicorn main:app --reload
# INFO:     Uvicorn running on http://127.0.0.1:8000
```

`uv sync` automatically creates an isolated environment and installs all the dependencies listed in the `pyproject.toml` file (the file that says "this project needs FastAPI, Pytest, etc."). `uv run` executes a command in that environment.

**What are `localhost` and `127.0.0.1`?** They're the same thing — it's the address of **your own machine**. When you type `http://localhost:8000` in your browser, you're saying "connect to myself on port 8000". `localhost` is just an alias for the IP address `127.0.0.1`.

**What is a port?** A machine can run multiple programs at the same time (a backend, a frontend, a database...). The **port** is a number that identifies which program you want to reach. It's like an apartment number in a building: the IP address is the building, the port is the apartment. Here, the backend is on port `8000`, the frontend will be on port `3000`.

**Try it in your browser:** Open `http://localhost:8000` — you should see a JSON message saying "L'API Task List fonctionne !" (The Task List API is working!). That's a response sent by the backend that you're seeing directly.

You can also open `http://localhost:8000/docs` — it's an interactive page generated **automatically** by FastAPI. Normally a backend doesn't have a visual interface (that's the frontend's job), but FastAPI generates this documentation page to help you test the endpoints without writing code. You can click on each endpoint, try "Try it out", and see the responses.

Also test from the terminal:
```bash
curl http://localhost:8000/api/tasks
# [{"id":1,"title":"Apprendre Docker","done":false}, ...]
```

### 3. Run the frontend

```bash
cd ~/devops-project/frontend
bun install
bun run dev
# VITE v6.x.x  ready in xxx ms
# ➜  Local:   http://localhost:3000/
```

### 4. Check the `.gitignore`

Before committing, you need a `.gitignore` file at the project root. This file tells Git **which files to ignore** — not include them in commits.

**Why it matters:** Without `.gitignore`, you'll commit `node_modules/` (thousands of JS dependency files), `.venv/` (the Python environment), and potentially `.env` files containing passwords. Your repo would be huge and you'd expose secrets.

The project already provides one (it was copied in step 1). Check that it's there:

```bash
cd ~/devops-project
cat .gitignore
```

You should see something like:

```
__pycache__/
.venv/
node_modules/
dist/
.env
```

**What each line means:** Each line is a file or folder that Git will ignore. One line = one pattern.

| Line | What Git ignores | Why ignore it |
|------|-----------------|---------------|
| `__pycache__/` | Python compiled files | Regenerated automatically, useless in Git |
| `.venv/` | Python virtual environment | Each dev recreates it with `uv sync` |
| `node_modules/` | JavaScript dependencies | Each dev recreates them with `bun install` |
| `dist/` | Built frontend files | Regenerated by `bun run build` |
| `.env` | Environment variables | Contains secrets (passwords, API keys) |

> **Note:** in a `.gitignore`, each line must be the file/folder name **alone**, without a comment next to it. Comments go on separate lines starting with `#`:
> ```
> # This is a comment
> node_modules/
> ```

> **If the file doesn't exist**, create it with `nano` (the text editor in the terminal):
> ```bash
> nano .gitignore
> ```
> Type the 5 lines from the table above (one per line), then `Ctrl+O` → `Enter` to save and `Ctrl+X` to quit.

### 5. Configure GitHub authentication (before pushing)

Since 2021, GitHub no longer accepts regular passwords for `git push`. We use an **SSH key** — set it up now, before your first push.

An **SSH key** is a pair of two files: a **private** key (your secret, it stays on your machine) and a **public** key (you give it to GitHub). When you push, Git proves to GitHub that you own the private key that matches the public key — without ever sending a password. It's like a lock (public key on GitHub) and its key (private key on your machine).

```bash
# 1. Generate the key
ssh-keygen
# It will ask you 3 questions:
#   "Enter file in which to save the key" → press Enter (default location)
#   "Enter passphrase" → press Enter (no password)
#   "Enter same passphrase again" → press Enter
# This creates two files:
#   ~/.ssh/id_ed25519       ← private key (NEVER SHARE THIS)
#   ~/.ssh/id_ed25519.pub   ← public key (the one we give to GitHub)

# 2. Copy the public key
cat ~/.ssh/id_ed25519.pub
# Copy all the displayed content (it starts with "ssh-ed25519 ...")
```

3. Go to [github.com/settings/keys](https://github.com/settings/keys) → **New SSH key**
4. Title: "My PC" (or whatever you want), paste the public key, **Add SSH key**

```bash
# 5. Test the connection
ssh -T git@github.com
# Hi YOUR_USER! You've been authenticated, but GitHub does not provide shell access.
# ← If you see this, you're good! You can now push to GitHub.
```

### 6. First commit and push

Now that SSH authentication is configured, you can send your code to GitHub:

```bash
cd ~/devops-project
git add .
git status
# Check that you do NOT see node_modules/, .venv/, .env in the list

git commit -m "init: projet task list (React + FastAPI)"

# No need for "git remote add origin" — the remote is already configured
# because you cloned your repo in step 1 (git clone sets up the link automatically)

git push
# "push" = send your commits to GitHub
# Git already knows where to send them because the repo was cloned from GitHub
```

> **Note:** In the workplace, the frontend and backend are usually in separate repositories (repos), each with its own CI/CD pipeline. Here, we put them in the same repo to simplify learning.

### 7. The Pull Request workflow (how teams work together)

So far we've been pushing directly to `main`. **In the workplace, nobody does that.** We go through Pull Requests (PR) so someone reviews the code before it gets merged.

The real workflow:

```bash
# 1. Create a branch for your feature
git checkout -b feat/add-delete-endpoint

# 2. Work, commit
git add .
git commit -m "feat: add DELETE /api/tasks/{id} endpoint"

# 3. Push the branch to GitHub
git push -u origin feat/add-delete-endpoint
```

Then, on GitHub:
1. You'll see a **"Compare & pull request"** button
2. You describe what you did and why
3. A colleague reviews your code (code review)
4. If it's good → **Merge** the PR into `main`
5. The branch is deleted

**Why it matters:**
- Someone else checks your code before it reaches production
- You keep a history of WHY each change was made
- The CI/CD pipeline runs on the PR → you know if it breaks BEFORE merging

> In this course, you can keep pushing directly to main to keep things simple. But know that the PR workflow is the standard in the workplace.

### Exercise: Make your first PR

We're going to add a real feature to the app: an endpoint to retrieve a task by its ID (`GET /api/tasks/{task_id}`). You don't need to understand the Python code — just copy it, test it, and create the PR.

**Step 1 — Create a branch**

```bash
cd ~/devops-project
git checkout -b feat/get-single-task
```

**Step 2 — Add the code**

Open `backend/main.py` in VS Code (`code backend/main.py` from the terminal) and add the new block. Here's what it should look like — the existing code is commented out, **the block to add is between the arrows**:

```python
# ... (the code above doesn't change)

@app.delete("/api/tasks/{task_id}")
def delete_task(task_id: int):
    # ... (this code already exists)

# ↓↓↓ ADD THIS BLOCK HERE ↓↓↓

@app.get("/api/tasks/{task_id}")
def get_task(task_id: int):
    tasks = _list_tasks()
    for t in tasks:
        if t["id"] == task_id:
            return t
    raise HTTPException(status_code=404, detail="Task not found")

# ↑↑↑ END OF BLOCK TO ADD ↑↑↑

@app.get("/api/health")
def health():
    # ... (this code already exists, don't modify it)
```

**Step 3 — Test locally**

```bash
cd ~/devops-project/backend
uv run uvicorn main:app --reload &

curl http://localhost:8000/api/tasks/1
# {"id":1,"title":"Apprendre Docker","done":false}

curl http://localhost:8000/api/tasks/99999
# {"detail":"Task not found"} (with a 404 status code)

# Stop the server
kill %1
```

**Step 4 — Commit and push**

```bash
git add backend/main.py
git commit -m "feat: add GET endpoint to retrieve single task by ID"
git push -u origin feat/get-single-task
```

**Step 5 — Create the PR on GitHub**

1. Go to your GitHub repo — you'll see a yellow banner **"Compare & pull request"**
2. Title: `feat: add GET endpoint to retrieve single task by ID`
3. Description: explain what you added and how to test it
4. Click **Create pull request**
5. Look at the PR, then click **Merge pull request**
6. Come back to your local machine and update:

```bash
git checkout main
git pull
```

This is exactly the workflow you'll follow hundreds of times in the workplace. The difference is that in real life, a colleague reviews your PR before the merge.

### Bonus: understanding the frontend (optional, just for context)

> **You don't need to understand this section for the rest of the course.** The frontend and backend are here as support for the DevOps modules. The function names (`useEffect`, `addTask`, etc.) are JavaScript/React — you don't need to learn or remember them. This is just to show you how frontend and backend communicate.

The frontend (`frontend/src/App.jsx`) is the web page the user sees. The only thing to remember: **the frontend calls the backend via HTTP requests**.

Here's what actually happens when the user interacts with the page:

| What the user does | HTTP call | What it does |
|-------------------|-----------|-------------|
| The page loads | `GET /api/tasks` | **Read** the task list |
| Click on "Add" | `POST /api/tasks` | **Create** a new task |
| Click on a task | `PATCH /api/tasks/{id}` | **Update** the task (check/uncheck) |
| Click on "✕" | `DELETE /api/tasks/{id}` | **Delete** the task |

> **GET, POST, PATCH, DELETE** — these are the 4 HTTP "verbs". GET = read, POST = create, PATCH = update, DELETE = delete. You'll also see **PUT** which also serves to update — to keep it simple, PATCH and PUT are the same idea (modifying existing data). We use PATCH in this project.

Run the frontend and backend at the same time to see the result:

```bash
# Terminal 1 — Backend
cd ~/devops-project/backend
uv run uvicorn main:app --reload

# Terminal 2 — Frontend
cd ~/devops-project/frontend
bun run dev
# Open http://localhost:3000
```

You should see the task list. Try:
- Adding a task → it appears at the bottom of the list
- Clicking on a task → it gets crossed out (done)
- Clicking on ✕ → it disappears

That's the frontend ↔ backend connection. The frontend sends HTTP requests, the backend responds with JSON, and the frontend displays the result.

## Interview Corner

**Q: What is Git and why do we use it?**
A: Git is a versioning system. It keeps the history of all code changes. You can go back in time, work with multiple people without overwriting each other's work, and create branches to develop features in parallel.

**Q: What's the difference between `git add` and `git commit`?**
A: `git add` stages files (staging area), `git commit` saves them in the history. It's like putting items in a box (add) then sealing and labeling the box (commit).

**Q: What is a branch?**
A: A parallel copy of the code. You develop on it without touching the main branch (main). When it's ready, you merge.

**Q: Difference between `git pull` and `git fetch`?**
A: `git fetch` downloads remote changes without applying them. `git pull` = `git fetch` + `git merge`. Pull applies the changes directly.

## Best practices

- **Small, frequent commits.** One commit = one logical change. Not "I worked for 3 days and commit everything at once". That's impossible to review and rollback.
- **Clear commit messages.** "fix bug" says nothing. "fix: POST /tasks endpoint returned 500 when title was empty" says everything. The message explains **why**, not **what** (the diff shows the what).
- **Never commit secrets.** Passwords, API keys, tokens → `.env` file + `.gitignore`. If you committed a secret by mistake, change it immediately.
- **A `.gitignore` from the very first commit.** Before committing anything. It's the first thing to do in a project.
- **Pull before you push.** `git pull` before `git push` to avoid conflicts. Especially if you're working with others.

## Common mistakes

- **"fatal: not a git repository"** → You're not in a folder with `git init`. Run `git init` or `cd` to the right folder.
- **"Permission denied (publickey)"** → Your SSH isn't configured for GitHub. Follow step 5 "Configure GitHub authentication" above to set up your SSH key.
- **Forgetting `git add` before `git commit`** → The commit will be empty. Always check with `git status` before committing.
- **Merge conflicts** → Two people modified the same line. Git shows you both versions, you choose which one to keep.

## Going further

- **Git stash**: set aside your current changes without committing them — useful when you need to switch branches urgently
- **Conventional Commits**: a convention for writing commit messages (`feat:`, `fix:`, `docs:`) — adopted by many teams
- **Git rebase**: rewrite the history to make it cleaner — more advanced, you'll encounter it in the workplace

## Using AI as a learning tool

When you're stuck on an error, don't understand a command, or a concept isn't clear — ask an AI. That's what all developers and DevOps engineers do every day. It's not cheating, it's a tool.

### Available tools

| Tool | What it is | When to use it |
|------|-----------|---------------|
| [ChatGPT](https://chat.openai.com) | AI chatbot in the browser | Ask questions, understand a concept |
| [Claude](https://claude.ai) | AI chatbot in the browser (Anthropic) | Same use as ChatGPT |
| [opencode](https://github.com/opencode-ai/opencode) | AI **in the terminal** (open-source, free) | Debug right where you work |

### Why use opencode in the terminal

In DevOps, you live in the terminal. When you have an error, you're in the terminal. When you want to understand a file, you're in the terminal. Switching to a browser, copying the error, pasting it into ChatGPT, waiting for the response, going back to the terminal — that's slow.

**opencode** is an AI assistant that runs **directly in your terminal**. It can:
- Read your files (Dockerfile, docker-compose.yml, main.tf) and explain them
- See the error you just got and explain it
- Run commands for you and explain the result
- Guide you step by step to solve a problem

It's open-source and free — you launch it in your terminal and talk to it like a colleague.

```bash
# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Launch opencode in your project
cd ~/devops-project
opencode
# You can now ask it questions:
# "Explain the backend Dockerfile to me"
# "Why is docker compose up failing?"
# "What's this error?"
```

> **opencode takes over the entire terminal window** — you can't type other commands in it anymore. That's normal. To keep working, **open another terminal** alongside it (right-click the Ubuntu icon in the taskbar → "Ubuntu", or in VS Code: Terminal → New Terminal).
>
> **As a general habit, get used to having multiple terminals open at the same time.** That's very common in DevOps: one terminal for the backend, one for the frontend, one for Docker commands, one for opencode... It's like having multiple tabs in a browser.

### How to use AI effectively for learning

**Good habits:**
- "Explain this error to me" → the AI translates the message into plain English
- "What's a Docker volume?" → explanation with an analogy
- "Why isn't this command working?" → it diagnoses the problem

**What to avoid:**
- "Write the Dockerfile for me" → you learn nothing. Try it yourself first, then ask for help on what's blocking you
- Copy-pasting an answer without reading it → if you don't understand what you paste, you won't be able to debug it when it breaks
- Blindly trusting it → the AI can be wrong, especially on specific configurations. Always verify by testing

**The golden rule:** Use AI to **understand**, not to **avoid understanding**.

## You can move on to the next module if...

- [ ] WSL2 + Ubuntu are working (you can open an Ubuntu terminal)
- [ ] VS Code opens with `code .` from WSL
- [ ] `python3 --version`, `uv --version` and `bun --version` return something
- [ ] You know how to do `git add`, `git commit`, `git push`
- [ ] The Hands-on Project is cloned and pushed to your GitHub
- [ ] You can run the backend (`uv run uvicorn main:app --reload`) and see the response from `curl localhost:8000/api/tasks`
