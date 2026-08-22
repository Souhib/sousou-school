# Module 1: Linux Basics

> **Prerequisites:** [Module 0](00-prerequisites.md) (Git, WSL installed)

> **In a nutshell:** You learn to navigate a Linux terminal — files, permissions, processes, environment variables. This is the foundation for everything that follows: Docker, AWS, Ansible, Kubernetes all run on Linux.

## What is Linux and why does it exist?

**The problem:** 90%+ of servers worldwide run Linux. Not Windows, not macOS — Linux. If you want to do DevOps, you MUST know how to navigate a Linux terminal. It's like wanting to be a chef without knowing how to use a knife.

**What is DevOps?** It's a job (and a way of working) that bridges the gap between developers (those who write the code) and operations (those who manage the servers). DevOps automates everything between "the code is written" and "the app is running in production for users": testing, deployment, monitoring, infrastructure.

The only thing to remember: on Linux, everything is organized in folders starting from `/` (the root). Your personal folder is `/home/your_user` (or `~` as a shortcut). The rest, you'll discover as you go.

## Navigation

> **Try these commands in your terminal.** Type them one by one and look at the result.

```bash
pwd
# /home/your_user  ← where you currently are

ls
# Documents  Downloads  devops-project

ls -la
# Shows EVERYTHING, even hidden files (those starting with .)
# "-l" = detailed format, "-a" = include hidden files

cd Documents
# You move into Documents

pwd
# /home/your_user/Documents  ← you changed folders

cd ..
# You go up one level

pwd
# /home/your_user  ← you're back

cd ~
# You go back to your home folder (~ = shortcut for /home/your_user)
```

## Files and folders

> **These are examples to try.** You can type them in your terminal to see what they do. The files created here are just for practice — you can delete them afterwards.

```bash
# Create an empty file
touch my_file.txt

ls
# my_file.txt appeared

# Create a folder
mkdir my_folder

# Create a folder + subfolders at once
mkdir -p projects/frontend/src
# -p = create parent folders if they don't exist

# Read a file (displays everything at once)
cat my_file.txt
# (nothing — the file is empty, we just created it with touch)

# Read a long file (page by page)
less my_file.txt
# Up/down arrows to navigate, "q" to quit
# Useful for log files that are thousands of lines long

# Copy
cp my_file.txt copy.txt
cp -r my_folder/ copy_folder/
# -r = recursive (copies the folder AND everything inside it)

# Rename a file
mv copy.txt new_name.txt

# Move a file into another folder
mv new_name.txt my_folder/
# The file is now at my_folder/new_name.txt
# It's the same "mv" command for both renaming AND moving

# Delete
rm new_name.txt
rm -r my_folder/
# -r = recursive (deletes the folder AND everything inside it)
# ⚠️ No recycle bin on Linux. rm = permanently deleted.

# Edit a file in the terminal
nano my_file.txt
# Type some text, then Ctrl+O → Enter to save, Ctrl+X to quit
```

## Permissions

Each file has 3 types of permissions for 3 categories of people:

| Permission | Letter | Number | What it allows |
|-----------|--------|--------|---------------|
| Read | r | 4 | Read the file |
| Write | w | 2 | Modify the file |
| Execute | x | 1 | Execute the file (run a script) |

The 3 categories: **owner** (= you), **group** (= your team), **others** (= everyone else).

The number `755` is a shorthand: `7` for the owner (4+2+1 = rwx), `5` for the group (4+0+1 = r-x), `5` for others (4+0+1 = r-x).

```bash
# View a file's permissions
ls -la my_file.txt
# -rw-r--r-- 1 user user 0 jan 1 12:00 my_file.txt
#  ^^^         → owner: rw- (read + write)
#     ^^^      → group: r-- (read only)
#        ^^^   → others: r-- (read only)

# Change permissions (these commands are examples, no need to type them)
chmod 755 my_file.txt    # owner=rwx, group=rx, others=rx
chmod 644 my_file.txt    # owner=rw, group=r, others=r
```

**In a nutshell:** Read = the right to look. Write = the right to modify. Execute = the right to run.

## Users and sudo

```bash
whoami
# your_user

# sudo = "do this as administrator"
sudo apt update
# Asks for your password, then runs the command in admin mode
```

`sudo` is like administrator mode on Windows. You need it to install software, modify system files, etc. Without `sudo`, you can only do things within your own folder.

## Package management (software)

We saw in [Module 0](00-prerequisites.md) that each language has its own package manager (uv for Python, bun for JS). **Linux also has its own: `apt`.** Here, a package = a piece of software ready to install (curl, git, docker, etc.). `apt` will download and install it in a single command.

```bash
# Update the list of available software
sudo apt update

# Install software
sudo apt install -y curl wget git

# Search for a package
apt search software_name

# Remove software
sudo apt remove software_name
```

## Processes

A process = a program that's currently running.

```bash
# View all processes
ps aux
# USER       PID  %CPU %MEM  ...  COMMAND
# root         1   0.0  0.0  ...  init
# user      1234   0.1  0.5  ...  python3 main.py
# PID = the unique identifier of the process (a number)

# View processes in real time (like Task Manager on Windows)
top
# Press q to quit

# Kill a process (if a program is stuck, for example)
kill 1234        # Politely asks the process to stop (replace 1234 with the actual PID)
kill -9 1234     # Forces immediate stop (last resort, if normal kill doesn't work)
```

## Environment variables

An environment variable = a value stored in the system, accessible by all running programs. Imagine a sticky note on the fridge that everyone in the house can read. They're used to pass configuration to applications (database address, passwords, operating modes) without putting it directly in the code.

```bash
# View all environment variables
printenv
# HOME=/home/user
# PATH=/usr/local/bin:/usr/bin:/bin
# ... (there are many, that's normal)

# View a specific variable
echo $HOME
# /home/user

# Create a variable (available in the current terminal only)
MY_VAR="hello"
echo $MY_VAR
# hello

# Export a variable (available to programs launched from this terminal)
export DATABASE_URL="postgresql://user:pass@localhost:5432/mydb"

# Verify
echo $DATABASE_URL
# postgresql://user:pass@localhost:5432/mydb
```

### The `.env` file

In practice, we put variables in a `.env` file so we don't have to type them every time:

```
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
API_KEY=abc123
DEBUG=true
```

> This file doesn't need to be created now — it's an example to understand the concept. You'll see it again in Docker ([Module 3](03-docker.md)).

⚠️ **NEVER commit a `.env` file to Git.** It often contains secrets. We put it in `.gitignore`.

You'll encounter environment variables everywhere in this course: Docker (`-e`, `environment:`), CI/CD (`secrets`), Terraform (`TF_VAR_`), etc.

## Environments (dev / staging / prod)

A cross-cutting concept you'll find in every module of this course:

| Environment | What it is | Who uses it |
|------------|-----------|-------------|
| **dev** (local) | Your machine. You develop, test, break things — that's what it's for. | You |
| **staging** | A copy of prod. We test there before going to production. | The team |
| **prod** (production) | The real site, real users. If it breaks here, everyone sees it. | The users |

**The golden rule:** The same code runs everywhere. What changes between environments are the **environment variables** (seen just above): database URL, API keys, debug mode...

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| `DATABASE_URL` | (absent → in-memory) | `postgresql://staging-db:5432/tasks` | `postgresql://prod-db:5432/tasks` |
| `DEBUG` | `true` | `true` | `false` |

You'll see this concept again in Docker (environment), CI/CD (secrets per environment), Terraform (`.tfvars` per environment), and Kubernetes (namespaces).

## Pipes and redirections

The pipe `|` sends the output of one command to another. It's like an assembly line.

```bash
# Search for the word "error" in a file
cat my_file.txt | grep "error"
# cat displays the file → grep filters lines containing "error"

# Count the number of files in a folder
ls | wc -l
# ls lists the files → wc -l counts the number of lines

# Redirect output to a file
echo "hello" > file.txt     # Overwrites the file (or creates it if it doesn't exist)
echo "world" >> file.txt    # Appends to the end of the file

cat file.txt
# hello
# world
```

## Search

```bash
# Search for text in files
grep "error" my_file.txt
grep -r "TODO" ~/devops-project/     # -r = recursive (searches in subfolders too)
grep -i "error" my_file.txt      # -i = case insensitive (Error, ERROR, error → all found)

# Search for files by name
find ~/devops-project -name "*.py"
# /home/user/devops-project/backend/main.py
# /home/user/devops-project/backend/test_main.py
```

## Reading an error message

Knowing how to read an error message is 50% of the DevOps job. Most beginners panic when they see a wall of red text. In reality, the error tells you exactly what's wrong — you just need to know where to look.

### The method: read from bottom to top

Python errors (and most languages) display a **stacktrace** — the stack of calls that led to the error. The most important line is **the last one**:

```bash
uv run uvicorn main:app
# Traceback (most recent call last):
#   File "main.py", line 3, in <module>
#     from fastapi import FastAPI
# ModuleNotFoundError: No module named 'fastapi'
#                      ^^^^^^^^^^^^^^^^^^^^^^^^
#                      ← THIS IS IT: fastapi is not installed
```

**Translation:** Python is trying to import `fastapi` but can't find it. Fix: `uv sync` (to install the dependencies).

### The most common errors

| Message | What it means | Fix |
|---------|--------------|-----|
| `ModuleNotFoundError: No module named 'X'` | Dependency X is not installed | `uv sync` or `bun install` |
| `FileNotFoundError: No such file or directory` | The file/folder doesn't exist | Check the path, `ls` to see what exists |
| `PermissionError: Permission denied` | You don't have the rights | `sudo` or `chmod` |
| `Connection refused` | Nothing is listening on that port | The server isn't running, or wrong port |
| `Address already in use` | The port is already taken | Another process is using that port (`ss -tlnp`) |
| `command not found` | The command is not installed | `sudo apt install ...` or check the PATH |
| `YAML syntax error` | Indentation error in a YAML file | Check spaces vs tabs, consistent indentation |

### The reflex: copy-paste the error into Google

When you don't understand an error message:
1. Copy **the last line** of the message (without paths specific to your machine)
2. Paste it into Google
3. The first Stack Overflow result has the answer 90% of the time

That's what all developers do, even senior ones. It's not cheating.

## SSH

SSH (Secure Shell) lets you connect to a remote server — you'll use it in [Module 5](05-aws.md) (AWS) to connect to your EC2.

```bash
ssh user@192.168.1.100
# You're now "inside" the remote server. All commands run over there.
# Ctrl+D or "exit" to disconnect.
```

> You don't need to use SSH right now — this is just so you know it exists. You'll do it for real in [Module 5](05-aws.md).

## Services (systemctl)

A service = a program that runs in the background (web server, database...).

> **These commands are examples.** You don't need to type them now — nginx is probably not installed on your machine. You'll use `systemctl` in the following modules.

```bash
sudo systemctl start nginx      # Start
sudo systemctl stop nginx       # Stop
sudo systemctl restart nginx    # Restart
sudo systemctl status nginx     # Check status
sudo systemctl enable nginx     # Start automatically on boot
```

> **WSL note:** `systemctl` doesn't work by default in WSL (no systemd). You can enable it by adding `[boot] systemd=true` in `/etc/wsl.conf` then restarting WSL (`wsl --shutdown` from PowerShell). Otherwise, start services manually (`sudo service nginx start`).

## YAML — The universal config format

You'll write YAML in almost every following module: Docker Compose, GitHub Actions, Ansible, Kubernetes. It's THE configuration format in DevOps. You need to understand its rules before getting started.

**What is YAML?** A text format for writing configuration. More readable than JSON, but strict about indentation.

### The 3 basic types

```yaml
# 1. Key-value (like a variable)
name: "devops-project"
port: 8000
debug: true

# 2. List (like an array)
services:
  - backend
  - frontend
  - database

# 3. Nested object (like a folder with subfolders)
backend:
  image: "python:3.12"
  port: 8000
  environment:
    - DATABASE_URL=postgresql://...
```

### The golden rules

| Rule | Good | Bad |
|------|------|-----|
| Indentation = **spaces** (2 or 4) | `  port: 8000` | `\tport: 8000` (tab) |
| No tabs | Spaces only | Tab = silent error |
| Indentation = hierarchy | 2 spaces = one level | Inconsistent indentation = crash |
| `:` is followed by a space | `port: 8000` | `port:8000` |

### The most common error

```yaml
# Correct (2-space indentation)
services:
  backend:
    port: 8000

# Incorrect (mixing 2 and 3 spaces)
services:
  backend:
     port: 8000    # ← 3 spaces instead of 4, YAML doesn't understand
```

If you have a mysterious error in a YAML file, it's almost always an indentation problem. Check that you're using **spaces** (not tabs) and that each level has the **same number of spaces**.

> **VS Code tip:** at the bottom right of the editor, you see "Spaces: 2" or "Tab Size: 4". Click on it to make sure you're using spaces, not tabs.

## Hands-on Project: Bash script

> **This project is optional.** It's a good exercise to practice the commands covered in this module, but you can skip to the next module if you're in a hurry.

We're going to create a small script that automates setting up a project.

### 1. Create the script

```bash
nano ~/setup-project.sh
```

`nano` opens a text editor in the terminal. Type the following content:

```bash
#!/bin/bash
# ↑ This line tells Linux "run this file with bash"

# Get the project name passed as argument
# When you type: ./setup-project.sh my-project
# "my-project" is the 1st argument, accessible via $1
PROJECT_NAME=$1

# Check that a name was given
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./setup-project.sh project_name"
    exit 1
fi

echo "Creating project $PROJECT_NAME..."

# Create the folder structure
mkdir -p "$PROJECT_NAME"/src
mkdir -p "$PROJECT_NAME"/tests
mkdir -p "$PROJECT_NAME"/docs

# Create base files
touch "$PROJECT_NAME"/src/main.py
touch "$PROJECT_NAME"/tests/test_main.py

# Write content to the files
echo "# $PROJECT_NAME" > "$PROJECT_NAME"/README.md
echo "print('Hello from $PROJECT_NAME')" > "$PROJECT_NAME"/src/main.py

echo "Project created! Structure:"
ls -la "$PROJECT_NAME"/
```

Save with `Ctrl+O` → `Enter`, then quit with `Ctrl+X`.

### 2. Make it executable and run it

```bash
chmod +x ~/setup-project.sh
# chmod +x = add the "execute" permission to the file
# Without this, Linux refuses to run it (permission denied)

~/setup-project.sh my-awesome-project
# Creating project my-awesome-project...
# Project created! Structure:
# (you see the list of created files)

ls my-awesome-project/
# README.md  docs  src  tests

cat my-awesome-project/src/main.py
# print('Hello from my-awesome-project')
```

### 3. Clean up

```bash
# Delete the test project (it was just an exercise)
rm -r my-awesome-project
rm ~/setup-project.sh
```

## Interview Corner

**Q: Explain Linux permissions (rwx, 755, etc.)**
A: Each file has 3 permission blocks (owner, group, others). Each block = read (4) + write (2) + execute (1). Example: 755 = owner can do everything (7), group and others can read and execute (5).

**Q: What is a pipe (`|`)?**
A: It sends the output of one command as the input to the next. Example: `ps aux | grep python` lists processes then filters those containing "python".

**Q: Difference between `>` and `>>`?**
A: `>` overwrites the file. `>>` appends to the end.

**Q: What is sudo?**
A: Running a command as administrator (root). Required for installing software, modifying system configuration, etc.

**Q: How do you view the logs of a service?**
A: `journalctl -u service_name` or look in `/var/log/`.

**Q: What is a process?**
A: A program currently running. When you run `python3 main.py`, it creates a process. Each process has a unique number (PID). You can see them with `ps aux` or `top`.

**Q: What is the PATH?**
A: An environment variable containing the list of directories where the system looks for programs. When you type `python3`, Linux searches through PATH directories to find the `python3` file. If you get "command not found", it's often because the program isn't in the PATH.

## Common mistakes

- **"Permission denied"** → You're missing the rights. Try with `sudo` or check permissions (`ls -la`).
- **`rm -rf /`** → The problem here is the `/` at the end. `/` is the system root (the entire hard drive). This command says "recursively delete everything from the root" — it's like formatting your disk. The `rm -rf` command itself isn't dangerous (you'll use it often to delete folders), it's targeting `/` that's catastrophic. Modern systems have a safety measure that blocks `rm -rf /` without the `--no-preserve-root` flag, but always be careful about WHAT you're deleting — check the path before pressing Enter.
- **Forgetting `sudo apt update` before `apt install`** → The package list isn't up to date, the package may not be found.
- **Editing a file without the rights** → `nano /etc/config` won't work, you need `sudo nano /etc/config`.

## Best practices

- **Never work as root.** Use `sudo` only when necessary. If everything runs as root, one mistake or hack = the entire system is compromised.
- **Read before you paste.** Never copy-paste a command from the Internet without understanding what it does. Especially with `sudo`, `rm`, `curl | bash`.
- **Use `ls` and `pwd` often.** Always know where you are and what's around you. It prevents deleting the wrong folder.
- **Put comments in your scripts.** You in 3 months won't remember why you wrote `chmod 600`.

## Going further

- **journalctl**: read system logs in detail — essential for debugging crashing services
- **cron jobs**: schedule automatic tasks (`crontab -e`) — you'll see this in the workplace for cleanup scripts, backups, etc.
- **sed / awk**: text manipulation tools — useful for transforming config files in bulk

## You can move on to the next module if...

- [ ] You can navigate the filesystem (`cd`, `ls`, `pwd`, `mkdir`, `cp`, `mv`, `rm`)
- [ ] You understand permissions (`chmod 755` = owner rwx, group rx, others rx)
- [ ] You know how to use `sudo` and you know why we don't work as root
- [ ] You can create and export an environment variable (`export MY_VAR="value"`)
- [ ] You know how to use a pipe (`|`) and a redirection (`>`, `>>`)
- [ ] You can read an error message (last line = the important part)
- [ ] You understand the structure of a YAML file (key-value, lists, indentation = spaces)
