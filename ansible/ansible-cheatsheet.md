# 🔧 Ansible — Cheat Sheet
*Infrastructure automation and configuration management using agentless push-based orchestration.*

---

## 📋 Inventory
*Define hosts, groups, and variables for target systems.*

```ini
[webservers]  # Group definition
web1.example.com
web2.example.com

[dbservers]  # Another group
db1.example.com ansible_user=dbadmin

[all:vars]  # Group variables
ansible_port=22
ansible_become_user=root

# Inventory in YAML format
---
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11
    dbservers:
      hosts:
        db1:
          ansible_host: 192.168.1.20
```

## Host patterns
[Learn more in playbooks: use patterns to target specific groups or hosts]

```bash
ansible webservers -i inventory.ini -m ping  # Target specific group
ansible 'web*' -i inventory.ini -m ping  # Wildcard pattern
ansible '*' -i inventory.ini -m ping  # All hosts
ansible '!web1' -i inventory.ini -m ping  # All except web1
```

---

## ⚡ Ad-hoc Commands
*Run single tasks directly without playbooks.*

```bash
ansible all -i inventory.ini -m ping  # Test connectivity to all hosts
## Requires SSH key or password authentication

ansible webservers -i inventory.ini -m command -a "uptime"  # Execute shell command
## command module doesn't support pipes or redirects; use shell module instead

ansible webservers -i inventory.ini -m shell -a "ps aux | grep nginx"  # Shell commands with pipes
## shell module runs in /bin/sh; has slight overhead vs command

ansible webservers -i inventory.ini -m apt -a "name=nginx state=present"  # Install package (Debian)
## Uses Debian-style package manager; use yum for RedHat systems

ansible webservers -i inventory.ini -m service -a "name=nginx state=started enabled=yes"  # Manage services
## state: started, stopped, restarted, reloaded

ansible webservers -i inventory.ini -m copy -a "src=file.txt dest=/tmp/file.txt"  # Copy files
## src and dest can be files or directories

ansible webservers -i inventory.ini -m user -a "name=testuser state=present"  # Create user
## Use state=absent to remove user

ansible webservers -i inventory.ini -m debug -a "msg='Hello'"  # Print debug message
## Useful for ad-hoc testing and variable inspection

ansible webservers -i inventory.ini --become -m shell -a "whoami"  # Run with sudo/root
## Requires become_user in inventory or --become-user flag
```

---

## 📝 Playbooks
*Structured automation using YAML syntax.*

```yaml
---
- name: Deploy web application  # Playbook name (descriptive)
  hosts: webservers  # Target host group
  become: yes  # Run tasks with sudo
  gather_facts: yes  # Collect system info (set to no to skip)
  vars:  # Define playbook variables
    nginx_port: 80
    app_version: "1.2.3"

  tasks:
    - name: Update apt cache  # Task name (required, must be descriptive)
      apt:
        update_cache: yes  # Update package list

    - name: Install nginx  # Another task
      apt:
        name: nginx
        state: present

    - name: Copy nginx config  # Use template module for dynamic files
      template:
        src: nginx.conf.j2  # Local Jinja2 template
        dest: /etc/nginx/nginx.conf  # Remote destination
        owner: root
        group: root
        mode: '0644'  # File permissions

    - name: Start and enable nginx  # Ensure service runs
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Wait for port 80  # Wait for service readiness
      wait_for:
        port: 80
        state: started
        timeout: 30

  handlers:  # Run only if triggered by notify
    - name: Restart nginx  # Handler that reloads service
      service:
        name: nginx
        state: restarted
```

## Playbook execution
[Run playbooks with ansible-playbook command]

```bash
ansible-playbook playbook.yml  # Run playbook with default inventory
## Default inventory: /etc/ansible/hosts

ansible-playbook playbook.yml -i inventory.ini  # Use specific inventory file
ansible-playbook playbook.yml -l webservers  # Limit to specific group
ansible-playbook playbook.yml --check  # Dry-run mode (show what would change)
ansible-playbook playbook.yml -v  # Verbose output
ansible-playbook playbook.yml -vv  # More verbose (show var values)
ansible-playbook playbook.yml --start-at-task "Install nginx"  # Resume from task
```

---

## 🔀 Variables & Facts
*Define and use variables; access system facts.*

```yaml
---
- name: Variable example
  hosts: localhost
  gather_facts: yes  # Collect system facts

  vars:
    app_name: myapp  # Simple variable
    app_version: "2.0"  # Version as string (to avoid parsing)
    port: 8080  # Number variable
    users:  # List variable
      - alice
      - bob
      - charlie
    config:  # Dictionary variable
      debug: yes
      timeout: 30
      env: production

  tasks:
    - name: Print variable  # Access variables with {{ }}
      debug:
        msg: "Application {{ app_name }} version {{ app_version }}"

    - name: Use list variable
      debug:
        msg: "User {{ item }}"  # Loop through list
      loop: "{{ users }}"

    - name: Access fact
      debug:
        msg: "Hostname is {{ ansible_hostname }}"  # Facts from gather_facts
      ## Common facts: ansible_distribution, ansible_os_family, ansible_processor_count

    - name: Set fact
      set_fact:
        deployment_date: "{{ ansible_date_time.iso8601_basic }}"  # Dynamically set fact

    - name: Use dict variable
      debug:
        msg: "Debug mode: {{ config.debug }}, Timeout: {{ config.timeout }}"

    - name: Conditional based on fact
      debug:
        msg: "CentOS detected"
      when: ansible_os_family == "RedHat"  # Skip task if condition false
```

## Variable precedence
[Higher precedence overrides lower: CLI args > vars_files > vars > defaults]

```yaml
---
- name: Variable precedence demo
  hosts: localhost
  vars_files:  # Load variables from file (higher precedence than vars)
    - secrets.yml
    - defaults.yml

  vars:  # Playbook variables (lower precedence than vars_files)
    env: staging

  roles:
    - { role: webserver, env: production }  # Role variables (highest in role context)
```

---

## 🎭 Roles
*Organize tasks, handlers, vars, and templates in reusable packages.*

```bash
ansible-galaxy role init webserver  # Create role directory structure
## Creates: defaults/, files/, handlers/, meta/, tasks/, templates/, vars/
```

```
webserver/
├── tasks/
│   └── main.yml  # Main task list
├── handlers/
│   └── main.yml  # Handlers for service restarts
├── templates/
│   └── nginx.conf.j2  # Jinja2 templates
├── files/
│   └── config.txt  # Static files to copy
├── defaults/
│   └── main.yml  # Default variables (lowest precedence)
└── meta/
    └── main.yml  # Role dependencies
```

```yaml
---
- name: Deploy with roles
  hosts: webservers

  roles:
    - webserver  # Apply role (looks in roles/ directory)
    - { role: database, db_user: "admin" }  # Role with variables

  pre_tasks:  # Run before roles
    - name: Pre-deploy tasks
      debug:
        msg: "Preparing..."

  post_tasks:  # Run after roles
    - name: Post-deploy tasks
      debug:
        msg: "Cleanup complete"
```

---

## 🔐 Vault
*Encrypt sensitive data like passwords and keys.*

```bash
ansible-vault create secrets.yml  # Create encrypted file (prompts for password)
ansible-vault edit secrets.yml  # Edit encrypted file
ansible-vault view secrets.yml  # View encrypted file contents
ansible-vault encrypt existing_file.yml  # Encrypt existing file
ansible-vault decrypt secrets.yml  # Decrypt to plaintext (careful!)
ansible-vault rekey secrets.yml  # Change encryption password

ansible-playbook playbook.yml --ask-vault-pass  # Prompt for vault password at runtime
ansible-playbook playbook.yml --vault-password-file=.vault_pass  # Use password file
## Store .vault_pass in secure location with restricted permissions
```

```yaml
---
# Inside encrypted file
db_password: "super_secret"
api_key: "sk-1234567890"
```

---

## 🏷️ Tags
*Run only specific tasks or skip groups of tasks.*

```yaml
---
- name: Playbook with tags
  hosts: webservers

  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
      tags:
        - install
        - packages

    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      tags:
        - configure
        - nginx

    - name: Restart nginx
      service:
        name: nginx
        state: restarted
      tags:
        - never  # Skip unless explicitly requested
        - restart
```

## Tag usage
[Control which tasks run via --tags and --skip-tags]

```bash
ansible-playbook playbook.yml --tags install  # Run only tagged tasks
ansible-playbook playbook.yml --tags "install,configure"  # Multiple tags
ansible-playbook playbook.yml --skip-tags packages  # Skip specific tag
ansible-playbook playbook.yml --tags never --tags restart  # Force never-run tag
```

---

## 🔔 Handlers
*Run tasks only when notified by other tasks (usually for service restarts).*

```yaml
---
- name: Handlers example
  hosts: webservers

  tasks:
    - name: Update config file
      template:
        src: app.conf.j2
        dest: /etc/app/app.conf
      notify: Restart app  # Trigger handler by name
      ## Handler runs once at end of play, even if triggered multiple times

    - name: Install package
      apt:
        name: nginx
      notify:
        - Reload nginx  # Multiple handlers
        - Restart nginx

  handlers:
    - name: Restart app  # Handler definition
      service:
        name: app
        state: restarted

    - name: Reload nginx
      service:
        name: nginx
        state: reloaded

    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

---

## 📦 Common Modules
*Essential modules for configuration management.*

### copy
*Copy files to remote hosts.*

```yaml
- name: Copy static file
  copy:
    src: /local/path/file.txt  # Source on control node
    dest: /remote/path/file.txt  # Destination on target
    owner: root  # File owner
    group: root  # File group
    mode: '0644'  # Permissions (octal)

- name: Copy with content
  copy:
    content: "config content"  # Embed content directly
    dest: /etc/app/config.txt
```

### template
*Process Jinja2 templates and copy to remote hosts.*

```yaml
- name: Deploy nginx config
  template:
    src: nginx.conf.j2  # Local template with variables
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes  # Keep backup of original
```

### service / systemd
*Manage services and daemons.*

```yaml
- name: Manage service
  service:
    name: nginx  # Service name
    state: started  # started, stopped, restarted, reloaded
    enabled: yes  # Start on boot
    daemon_reload: yes  # Reload systemd config

- name: Modern systemd module
  systemd:
    name: nginx
    state: restarted
    enabled: yes
    daemon_reload: yes
```

### apt
*Manage packages on Debian/Ubuntu.*

```yaml
- name: Install package
  apt:
    name: nginx  # Package name (or list)
    state: present  # present, absent, latest

- name: Install multiple packages
  apt:
    name:
      - nginx
      - python3-pip
    state: present

- name: Update all packages
  apt:
    upgrade: dist  # Full distribution upgrade
    update_cache: yes
```

### yum
*Manage packages on RedHat/CentOS.*

```yaml
- name: Install package
  yum:
    name: nginx
    state: present

- name: Install from URL
  yum:
    name: https://example.com/package.rpm
    state: present
```

### shell
*Execute shell commands with pipes and redirects.*

```yaml
- name: Run shell command
  shell: |
    ps aux | grep nginx
    echo "Checking nginx status"
  ## Runs in /bin/sh; slower than command module but more flexible
```

### command
*Execute commands without shell processing.*

```yaml
- name: Run command
  command: /usr/bin/uptime
  ## No pipes, redirects, or variables; faster but limited
```

### user
*Manage user accounts.*

```yaml
- name: Create user
  user:
    name: appuser  # Username
    state: present  # present, absent
    home: /home/appuser  # Home directory
    shell: /bin/bash  # Login shell
    groups: sudo  # Secondary groups
    append: yes  # Append groups (don't replace)

- name: Remove user
  user:
    name: appuser
    state: absent
    remove: yes  # Remove home directory
```

### lineinfile
*Modify single lines in files.*

```yaml
- name: Add line to file
  lineinfile:
    path: /etc/hosts
    line: "192.168.1.1 example.com"  # Line to add
    state: present  # present, absent

- name: Replace line
  lineinfile:
    path: /etc/sysctl.conf
    regexp: "^#net.ipv4.ip_forward"  # Match pattern
    line: "net.ipv4.ip_forward=1"  # Replacement
    state: present
```

### debug
*Print debug messages.*

```yaml
- name: Simple message
  debug:
    msg: "Variable value: {{ variable_name }}"

- name: Debug with registered output
  debug:
    var: command_output  # Print entire variable
```
