# Module 7: Ansible (Optional)

> **Prerequisites:** [Module 5](05-aws.md) (AWS — having an EC2) or [Module 6](06-terraform.md) (Terraform — having created an EC2 with Terraform)

> **In a nutshell:** Terraform creates the servers, Ansible configures them. You learn to automate Docker installation, project cloning, and app launch on a remote server — all with a single YAML file and one command.

## What is Ansible and why does it exist?

**The problem:** Terraform creates the infra (the server exists). But who installs Docker on it? Who configures nginx? Who copies the config files? Who makes sure everything is up to date? You could do it over SSH, but what if you have 10 servers? 50?

**Ansible configures and maintains what runs ON the servers.** Terraform builds the house, Ansible furnishes it.

**The analogies:**
- **Inventory** = the list of houses to visit
- **Playbook** = the task checklist to complete in each house
- **Module** = a specific action (install software, copy a file, start a service)
- **Idempotence** = you can re-run the checklist 10 times, the result will be the same (if the paint is already done, we don't repaint)

**The key thing:** Ansible is **agentless** — no need to install anything on the target servers. Other similar tools (Chef, Puppet) require installing a program ("agent") on each server you want to manage. Ansible doesn't: it simply connects via SSH (the remote connection covered in [Module 1](01-linux-basics.md)) and runs the tasks. That's what makes it easy to get started with.

## Installation

```bash
sudo apt update && sudo apt install -y ansible

ansible --version
# ansible [core 2.x.x]
```

## Inventory — The server list

The inventory tells Ansible which machines to manage.

Create the file with `nano inventory.ini` and paste this content:
```ini
[web]
<YOUR_EC2_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/devops-key.pem
# Replace <YOUR_EC2_IP> with the public IP of your EC2 instance (e.g., 13.38.42.100)
# ansible_user = which user to connect as via SSH
# ansible_ssh_private_key_file = the SSH key file downloaded when creating the EC2 (Module 5)
```

Verify the connection:
```bash
ansible -i inventory.ini web -m ping
# -i = which inventory file to use
# web = the targeted group (defined between [brackets] in inventory.ini)
# -m ping = use the "ping" module (tests the SSH connection)
# 13.38.x.x | SUCCESS => {
#     "ping": "pong"
# }
```

## Playbook — The checklist

A playbook is a YAML file that describes the tasks to run.

Create the file with `nano setup.yml` and paste this content:

```yaml
# setup.yml
---
- name: Configure the web server
  hosts: web              # The targeted server group (defined in inventory.ini)
  become: true            # Run as admin (sudo)

  tasks:
    - name: Update packages
      apt:
        update_cache: true   # = apt update (refresh the package list)
        upgrade: dist        # = apt upgrade (update installed packages)

    - name: Install Docker
      apt:
        name:
          - docker.io
          - docker-compose-v2
        state: present       # "present" = make sure it's installed (if already there, do nothing)

    - name: Add ubuntu to the docker group
      user:
        name: ubuntu
        groups: docker
        append: true         # Add to docker group WITHOUT removing from other groups

    - name: Start Docker
      service:
        name: docker
        state: started       # Make sure Docker is running
        enabled: true        # Start automatically on server boot
```

Run the playbook:
```bash
ansible-playbook -i inventory.ini setup.yml
# -i = which inventory to use
# setup.yml = the playbook to run
```

You should see something like:
```
PLAY [Configure the web server] ***
TASK [Update packages] ***
changed: [13.38.x.x]           <- this task modified something on the server
TASK [Install Docker] ***
changed: [13.38.x.x]
...
PLAY RECAP ***
13.38.x.x : ok=4  changed=4  unreachable=0  failed=0
```

**What each line means:**
- `PLAY [...]` = start of a group of tasks
- `TASK [...]` = an individual task
- `changed` = the task modified something on the server
- `ok` = the task checked but nothing to change (already done)
- `ok=4 changed=4` = 4 tasks executed, 4 modified something
- `failed=0` = no errors

## Useful modules

| Module | What it does | Example |
|--------|-------------|---------|
| `apt` | Install/remove packages | `apt: name=nginx state=present` |
| `copy` | Copy a file to the server | `copy: src=app.conf dest=/etc/nginx/` |
| `template` | Copy a file with variables | `template: src=app.conf.j2 dest=/etc/nginx/` |
| `service` | Manage a service (start/stop/restart) | `service: name=nginx state=started` |
| `file` | Create directories, change permissions | `file: path=/app state=directory` |
| `command` | Run a command | `command: docker compose up -d` |

## Idempotence — The key concept

You run the playbook for the first time: Ansible installs Docker, copies files, starts services. You run it again: Ansible checks that everything is already done and does nothing. **Same result, no side effects.**

```bash
# First run
ansible-playbook -i inventory.ini setup.yml
# changed=4

# Second run (nothing changes)
ansible-playbook -i inventory.ini setup.yml
# changed=0  <- idempotent!
```

## Variables and Roles (concepts)

**Variables:** You can parameterize your playbooks.
```yaml
vars:
  app_port: 8000
  docker_image: "mon-user/devops-backend:latest"
```

**Roles:** Reusable and organized playbooks. Like functions. We won't create any in this course, but know that they exist (and Ansible Galaxy provides thousands ready to use).

## Hands-on Project: Provision the EC2 server

We take the server created in [Module 5](05-aws.md) or [Module 6](06-terraform.md), and automate its configuration.

### 1. Structure

```bash
mkdir -p ~/devops-ansible
cd ~/devops-ansible
```

### 2. Inventory

Create the file with `nano inventory.ini`:
```ini
[web]
<YOUR_EC2_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/devops-key.pem
# Replace <YOUR_EC2_IP> with the public IP of your EC2
```

### 3. Complete playbook

Create the file with `nano deploy.yml` and paste this content:

> **The `{{ variable }}`** syntax is how Ansible inserts a variable's value. It's like `$variable` in bash or `${var}` in Terraform — each tool has its own syntax.

```yaml
---
- name: Deploy the DevOps project
  hosts: web
  become: true                  # Run as admin (sudo)

  vars:                         # Reusable variables in the tasks below
    github_repo: "https://github.com/<YOUR_GITHUB_USER>/devops-project.git"
    app_dir: /home/ubuntu/devops-project

  tasks:
    - name: Install dependencies
      apt:
        update_cache: true
        name:
          - docker.io
          - docker-compose-v2
          - git
        state: present

    - name: Add ubuntu to the docker group
      user:
        name: ubuntu
        groups: docker
        append: true

    - name: Start Docker
      service:
        name: docker
        state: started
        enabled: true

    - name: Clone the project
      git:
        repo: "{{ github_repo }}"    # Uses the variable defined in "vars" above
        dest: "{{ app_dir }}"        # Where to clone on the server
        version: main                # The branch to clone
        force: true                  # Overwrite if the directory already exists
      become_user: ubuntu            # Run as "ubuntu" (not root) so the files belong to that user

    - name: Run docker compose
      command: docker compose up -d --build
      args:
        chdir: "{{ app_dir }}"       # Move to this directory before running the command
      become_user: ubuntu
```

### 4. Run it

```bash
ansible-playbook -i inventory.ini deploy.yml
# PLAY RECAP ***
# IP : ok=6  changed=6  unreachable=0  failed=0
```

Open `http://YOUR_EC2_IP` — the app is running.

💡 **If "unreachable"**: check that the IP is correct, that the Security Group allows SSH (22), and that the `.pem` key is correct.

## Interview Corner

**Q: What is Ansible?**
A: A configuration management tool. It configures servers (installing software, copying files, starting services) in an automated and reproducible way.

**Q: Ansible vs Terraform?**
A: Terraform creates infrastructure (servers, networks). Ansible configures what runs on them (software, files). They are complementary.

**Q: What is idempotence?**
A: The ability to execute an operation multiple times with the same result. If Docker is already installed, Ansible won't reinstall it.

**Q: Why is Ansible "agentless"?**
A: No need to install software on the target servers. Ansible connects via SSH. This simplifies setup compared to Chef/Puppet which require an agent.

**Q: What is a playbook?**
A: A YAML file that describes a list of tasks to execute on servers. It's the main file you write and run.

**Q: What is an Ansible inventory?**
A: The file that lists the servers Ansible will act on. It contains IP addresses or hostnames, organized in groups (web, db, etc.). Ansible connects via SSH to each machine in the inventory to execute tasks.

**Q: What is an Ansible role?**
A: A way to organize a playbook into reusable components. A role bundles tasks, files, templates, and variables related to a function (e.g., a "docker" role that installs and configures Docker). You can reuse the same role across multiple playbooks.

## Best practices

- **Use Ansible modules, not `command`/`shell`.** Modules (`apt`, `service`, `copy`) are idempotent. `command: apt install nginx` is not — it will reinstall on every run.
- **Test with `--check` first.** `ansible-playbook --check` simulates execution without modifying anything (dry run). Like `terraform plan`.
- **Encrypt secrets with Ansible Vault.** Passwords, API keys -> `ansible-vault encrypt secrets.yml`. Never commit secrets in plain text.
- **Organize into roles as things grow.** A 500-line playbook is unmaintainable. Roles break things into reusable blocks.

## Common mistakes

- **"Permission denied"** -> Wrong SSH key or wrong user in the inventory.
- **Forgetting `become: true`** -> Tasks that require sudo will fail.
- **`command` module not idempotent** -> Prefer dedicated Ansible modules (`apt`, `service`, etc.) which handle idempotence.
- **Incorrect YAML indentation** -> YAML is strict about indentation (spaces, no tabs).

## Going further

- **Ansible Vault**: encrypt secrets in playbooks — essential as soon as you have passwords in your Ansible files
- **Ansible Roles**: organize your playbooks into reusable modules — essential when managing more than 2-3 servers
- **Ansible Galaxy**: community role library — instead of writing everything yourself, reuse existing roles

## You can move on to the next module if...

- [ ] You know the difference between Terraform (creates infra) and Ansible (configures infra)
- [ ] You know how to write a basic inventory and playbook
- [ ] You understand idempotence (re-run = same result)
- [ ] You know why Ansible is "agentless" (SSH, no agent to install)
- [ ] You have provisioned an EC2 with the `deploy.yml` playbook
