# 📚 DevOps Cheat Sheets
*Comprehensive collection of cheat sheets for DevOps tools, infrastructure, automation, and programming.*

---

## 📋 Complete Index

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Ansible | Markdown | [ansible/ansible-cheatsheet.md](./ansible/ansible-cheatsheet.md) | Infrastructure automation: inventory, playbooks, roles, vault, variables, common modules |
| Ansible (PDF) | PDF | [ansible/ansible-cheatsheet.pdf](./ansible/ansible-cheatsheet.pdf) | Infrastructure automation and configuration management |
| Bash | Markdown | [bash/bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Shell scripting: variables, quoting, conditionals, loops, functions, arrays, I/O redirection |
| Docker | Markdown | [docker/docker-cheatsheet.md](./docker/docker-cheatsheet.md) | Container management: images, containers, volumes, networks, compose, resource limits, logs |
| Docker (PDF) | PDF | [docker/docker-cheatsheet.pdf](./docker/docker-cheatsheet.pdf) | Container management and Docker commands |
| Git | Markdown | [git/git-cheatsheet.md](./git/git-cheatsheet.md) | Version control: setup, branching, merging, remotes, advanced operations |
| Helm | Markdown | [helm/helm-cheatsheet.md](./helm/helm-cheatsheet.md) | Kubernetes package manager: repos, install/upgrade, rollback, values, templating, OCI registries |
| Incus | Markdown | [incus/incus-cheatsheet.md](./incus/incus-cheatsheet.md) | Container & VM: instance management, images, profiles, networking, storage, snapshots |
| Iptables / Nftables | Markdown | [iptables/iptables-cheatsheet.md](./iptables/iptables-cheatsheet.md) | Linux firewalls: chains, rules, NAT, masquerade, state management, nftables migration |
| Kubernetes | Markdown | [k8s/kubernetes-cheatsheet.md](./k8s/kubernetes-cheatsheet.md) | Container orchestration: contexts, pods, deployments, services, configmaps, RBAC, scaling, helm |
| Kubernetes (PDF) | PDF | [k8s/kubernetes-made-easy.pdf](./k8s/kubernetes-made-easy.pdf) | Kubernetes orchestration and cluster management |
| Linux CLI | Markdown | [linux_cli/lfcs-essential-commands.md](./linux_cli/lfcs-essential-commands.md) | System administration: LFCS reference (5 domains), user mgmt, services |
| Linux Networking | Markdown | [linux_cli/linux-cli-networking.md](./linux_cli/linux-cli-networking.md) | Network tools: nmap, dig, tcpdump, network diagnostics |
| Make | Markdown | [make/make-cheatsheet.md](./make/make-cheatsheet.md) | Build automation: Makefiles, variables, targets, dependencies, pattern rules, recursive make |
| MySQL / SQL | Markdown | [sql/mysql-cheatsheet.md](./sql/mysql-cheatsheet.md) | Database management: DDL/DML, user/permissions, joins, indexes, transactions, backup/restore |
| MySQL / SQL (PDF) | PDF | [sql/mysql-cheat-sheet-a4.pdf](./sql/mysql-cheat-sheet-a4.pdf) | Database administration and SQL reference |
| PowerShell | Markdown | [wsl/powershell-cheatsheet.md](./wsl/powershell-cheatsheet.md) | Windows automation: variables, strings, arrays, functions, file/process management, error handling |
| Proxmox | Markdown | [proxmox/proxmox-cheatsheet.md](./proxmox/proxmox-cheatsheet.md) | Virtualization: VMs, LXC containers, storage, networking, backup, cluster, CLI tools |
| Python | Markdown | [python/python-cheatsheet.md](./python/python-cheatsheet.md) | Programming: data types, strings, collections, control flow, functions, file I/O, stdlib |
| Regex | Markdown | [regex/regex-cheatsheet.md](./regex/regex-cheatsheet.md) | Pattern matching: anchors, quantifiers, character classes, groups, lookahead/behind, usage in tools |
| SSH | Markdown | [ssh/ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Secure shell: keys, connections, port forwarding, agent, hardening |
| Systemd | Markdown | [systemd/systemd-cheatsheet.md](./systemd/systemd-cheatsheet.md) | System manager: services, timers, targets, journals, unit files, socket activation |
| Terraform | Markdown | [terraform/terraform-cheatsheet.md](./terraform/terraform-cheatsheet.md) | Infrastructure as Code: providers, variables, resources, state, modules, workspaces |
| Terraform + Incus | Markdown | [terraform/terraform-incus-cheatsheet.md](./terraform/terraform-incus-cheatsheet.md) | Incus provider: instances, networks, storage, profiles, multi-remote management |
| Tmux | Markdown | [tmux/tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Terminal multiplexer: sessions, windows, panes, copy mode, config |
| Tools | Markdown | [tools/tools-cheatsheet.md](./tools/tools-cheatsheet.md) | Essential CLI: curl, wget, jq, rsync, netcat, nmap, htop, strace, lsof, fzf |
| Vim | Markdown | [vim/vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Text editor: modes, navigation, editing, search/replace, macros, splits |
| WSL | Markdown | [wsl/wsl-cheatsheet.md](./wsl/wsl-cheatsheet.md) | Windows Subsystem for Linux: installation, distributions, file access, networking, interop, PowerShell basics |

## 📁 Directory Structure

- **ansible/** - Infrastructure automation (PDF)
- **bash/** - Shell scripting and command-line
- **docker/** - Container management (PDF)
- **git/** - Version control system
- **helm/** - Kubernetes Helm package manager
- **incus/** - Container and VM management
- **iptables/** - Linux firewall and netfilter
- **k8s/** - Kubernetes orchestration (PDF)
- **linux_cli/** - Linux system administration
- **make/** - Build automation and compilation
- **proxmox/** - Virtualization and hypervisor
- **python/** - Python programming language
- **regex/** - Regular expressions for text matching
- **sql/** - Database administration (PDF)
- **ssh/** - Secure Shell protocol
- **systemd/** - Linux system and service manager
- **terraform/** - Infrastructure as Code provisioning
  - terraform-cheatsheet.md
  - terraform-incus-cheatsheet.md
- **tmux/** - Terminal multiplexer
- **tools/** - Essential command-line utilities
- **vim/** - Text editor
- **windows/** - Windows PowerShell automation
- **wsl/** - Windows Subsystem for Linux & PowerShell
  - wsl-cheatsheet.md
  - powershell-cheatsheet.md
  - scripts/ (wsl.conf, .wslconfig, PowerShell/bash scripts)

---

## 💡 Notes

- All markdown files follow consistent formatting with emoji titles, dividers, and sections with descriptions
- Each command includes a short inline `#` comment explaining what it does
- Important options and alternatives are noted with `##` comment lines
- Organized by sub-categories for quick reference and learning
- Content is practical, verified, and English-only
- PDFs provide comprehensive visual and detailed references

**Last updated:** 2026-04-28
