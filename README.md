# 📚 DevOps Cheat Sheets

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Markdown](https://img.shields.io/badge/Format-Markdown-blue)](https://en.wikipedia.org/wiki/Markdown)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-green)](https://github.com/PoissonChevre/devops_cheat_sheets)

*Comprehensive collection of cheat sheets for DevOps tools, infrastructure, automation, and programming.*

---

## 🚀 Quick Start

```bash
git clone git@github.com:PoissonChevre/devops_cheat_sheets.git
cd devops_cheat_sheets
```

---

## 📊 Collection Stats

> 📝 **30 Markdown files** · 📄 **18 PDFs** · 🗂 **21 directories** · 📦 **48 total resources**

---

## 📋 Index by Category

### 🐳 **Containers & Orchestration**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Docker | Markdown | [docker/docker-cheatsheet.md](./docker/docker-cheatsheet.md) | Container management: images, containers, volumes, networks, compose, resource limits, logs |
| Docker | PDF | [docker/docker-cheatsheet.pdf](./docker/docker-cheatsheet.pdf) | Docker commands and container best practices |
| Docker CLI | Markdown | [docker/cli.md](./docker/cli.md) | Docker command-line interface reference |
| Kubernetes | Markdown | [k8s/kubernetes-cheatsheet.md](./k8s/kubernetes-cheatsheet.md) | Container orchestration: contexts, pods, deployments, services, configmaps, RBAC, scaling, helm |
| Kubernetes | PDF | [k8s/kubernetes-made-easy.pdf](./k8s/kubernetes-made-easy.pdf) | Kubernetes orchestration and cluster management |
| Helm | Markdown | [helm/helm-cheatsheet.md](./helm/helm-cheatsheet.md) | Kubernetes package manager: repos, install/upgrade, rollback, values, templating, OCI registries |
| Incus | Markdown | [incus/incus-cheatsheet.md](./incus/incus-cheatsheet.md) | Container & VM: instance management, images, profiles, networking, storage, snapshots |
| Proxmox | Markdown | [proxmox/proxmox-cheatsheet.md](./proxmox/proxmox-cheatsheet.md) | Virtualization: VMs, LXC containers, storage, networking, backup, cluster, CLI tools |
| Vagrant | Markdown | [vagrant/README.md](./vagrant/README.md) | Infrastructure provisioning and VM management |

---

### 🏗️ **Infrastructure as Code**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Terraform | Markdown | [terraform/terraform-cheatsheet.md](./terraform/terraform-cheatsheet.md) | Infrastructure as Code: providers, variables, resources, state, modules, workspaces |
| Terraform + Incus | Markdown | [terraform/terraform-incus-cheatsheet.md](./terraform/terraform-incus-cheatsheet.md) | Incus provider: instances, networks, storage, profiles, multi-remote management |
| Ansible | Markdown | [ansible/ansible-cheatsheet.md](./ansible/ansible-cheatsheet.md) | Infrastructure automation: inventory, playbooks, roles, vault, variables, common modules |
| Ansible | PDF | [ansible/ansible-cheatsheet.pdf](./ansible/ansible-cheatsheet.pdf) | Infrastructure automation and configuration management |

---

### 🐧 **Linux & System Administration**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Linux CLI (LFCS) | Markdown | [linux_cli/lfcs-essential-commands.md](./linux_cli/lfcs-essential-commands.md) | System administration: LFCS reference (5 domains), user mgmt, services |
| LFCS Commands (FR) | Markdown | [linux_cli/LFCS_commandes.md](./linux_cli/LFCS_commandes.md) | Commandes LFCS en français |
| LFCS Cheatsheet | PDF | [linux_cli/lfcs-cheatsheet.pdf](./linux_cli/lfcs-cheatsheet.pdf) | LFCS certification reference |
| Linux Cheatsheet | PDF | [linux_cli/linux-cheatsheet.pdf](./linux_cli/linux-cheatsheet.pdf) | Linux commands reference |
| RHCSA | PDF | [linux_cli/RHCSA.pdf](./linux_cli/RHCSA.pdf) | Red Hat Certified System Administrator reference |
| Essential Commands | PDF | [linux_cli/essential-commands-recap.pdf](./linux_cli/essential-commands-recap.pdf) | Linux essential commands recap |
| Commands Recap | PDF | [linux_cli/Commands-Recap.pdf](./linux_cli/Commands-Recap.pdf) | Commands quick reference |
| Essential Commands | PDF | [linux_cli/Essential-Commands-1-1.pdf](./linux_cli/Essential-Commands-1-1.pdf) | Essential Linux commands guide |
| Terminal Commands | PDF | [linux_cli/glossary-terminal-commands.pdf](./linux_cli/glossary-terminal-commands.pdf) | Terminal commands glossary |
| Ubuntu Server Tips | PDF | [linux_cli/ubuntu-server-cli-tips.pdf](./linux_cli/ubuntu-server-cli-tips.pdf) | Ubuntu server command-line tips |
| Systemd | Markdown | [systemd/systemd-cheatsheet.md](./systemd/systemd-cheatsheet.md) | System manager: services, timers, targets, journals, unit files, socket activation |
| Iptables / Nftables | Markdown | [iptables/iptables-cheatsheet.md](./iptables/iptables-cheatsheet.md) | Linux firewalls: chains, rules, NAT, masquerade, state management, nftables migration |
| SSH | Markdown | [ssh/ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Secure shell: keys, connections, port forwarding, agent, hardening |

---

### 🛠️ **Development & Tools**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Bash | Markdown | [bash/bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Shell scripting: variables, quoting, conditionals, loops, functions, arrays, I/O redirection |
| Git | Markdown | [git/git-cheatsheet.md](./git/git-cheatsheet.md) | Version control: setup, branching, merging, remotes, advanced operations |
| Vim | Markdown | [vim/vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Text editor: modes, navigation, editing, search/replace, macros, splits |
| Tmux | Markdown | [tmux/tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Terminal multiplexer: sessions, windows, panes, copy mode, config |
| Make | Markdown | [make/make-cheatsheet.md](./make/make-cheatsheet.md) | Build automation: Makefiles, variables, targets, dependencies, pattern rules, recursive make |
| Python | Markdown | [python/python-cheatsheet.md](./python/python-cheatsheet.md) | Programming: data types, strings, collections, control flow, functions, file I/O, stdlib |
| Regex | Markdown | [regex/regex-cheatsheet.md](./regex/regex-cheatsheet.md) | Pattern matching: anchors, quantifiers, character classes, groups, lookahead/behind, usage in tools |

---

### 🔌 **Networking & Utilities**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| Linux CLI Networking | Markdown | [linux_cli/linux-cli-networking.md](./linux_cli/linux-cli-networking.md) | Network tools: nmap, dig, tcpdump, network diagnostics |
| Networking | PDF | [linux_cli/Networking.pdf](./linux_cli/Networking.pdf) | Network configuration and tools reference |
| Tools | Markdown | [tools/tools-cheatsheet.md](./tools/tools-cheatsheet.md) | Essential CLI: curl, wget, jq, rsync, netcat, nmap, htop, strace, lsof, fzf |

---

### 💾 **Databases**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| MySQL / SQL | Markdown | [sql/mysql-cheatsheet.md](./sql/mysql-cheatsheet.md) | Database management: DDL/DML, user/permissions, joins, indexes, transactions, backup/restore |
| MySQL / SQL | PDF | [sql/mysql-cheat-sheet-a4.pdf](./sql/mysql-cheat-sheet-a4.pdf) | Database administration and SQL reference |

---

### 💻 **Cloud & Windows**

| Tool | Format | File | Description |
|------|--------|------|-------------|
| WSL | Markdown | [wsl/wsl-cheatsheet.md](./wsl/wsl-cheatsheet.md) | Windows Subsystem for Linux: installation, distributions, file access, networking, interop |
| PowerShell | Markdown | [wsl/powershell-cheatsheet.md](./wsl/powershell-cheatsheet.md) | Windows automation: variables, strings, arrays, functions, file/process management |

---

### 📚 **Additional Linux References**

| Resource | PDF | File | Description |
|----------|-----|------|-------------|
| Operations & Deployment | PDF | [linux_cli/Operations-Deployment.pdf](./linux_cli/Operations-Deployment.pdf) | Deployment and operations reference |
| Storage Management | PDF | [linux_cli/Storage.pdf](./linux_cli/Storage.pdf) | Linux storage and filesystem management |
| Users & Groups | PDF | [linux_cli/Users-and-Groups.pdf](./linux_cli/Users-and-Groups.pdf) | User and group management reference |
| RHEL Cheatsheet | PDF | [linux_cli/rhel-5-6-7-cheatsheet.pdf](./linux_cli/rhel-5-6-7-cheatsheet.pdf) | RHEL 5, 6, 7 reference |

---

## 📁 Directory Structure

```
devops_cheat_sheets/
├── ansible/              - Infrastructure automation (Markdown & PDF)
├── bash/                 - Shell scripting and command-line
├── docker/               - Container management (Markdown, PDF & CLI)
├── git/                  - Version control system
├── helm/                 - Kubernetes Helm package manager
├── incus/                - Container and VM management
├── iptables/             - Linux firewall and netfilter
├── k8s/                  - Kubernetes orchestration (Markdown & PDF)
├── linux_cli/            - Linux system administration and CLI tools (10+ PDFs)
├── make/                 - Build automation and compilation
├── proxmox/              - Virtualization and hypervisor
├── python/               - Python programming language
├── regex/                - Regular expressions for text matching
├── sql/                  - Database administration (Markdown & PDF)
├── ssh/                  - Secure Shell protocol
├── systemd/              - Linux system and service manager
├── terraform/            - Infrastructure as Code provisioning
├── tmux/                 - Terminal multiplexer
├── tools/                - Essential command-line utilities
├── vagrant/              - Infrastructure provisioning
├── vim/                  - Text editor
├── wsl/                  - Windows Subsystem for Linux & PowerShell
└── README.md
```

---

## 💡 Features & Format

✅ **Consistent formatting** - All markdown files follow the same structure with emoji titles, dividers, and organized sections
✅ **Inline comments** - Each command includes a short `#` comment explaining what it does
✅ **Alternative options** - Important options and alternatives noted with `##` comments
✅ **Quick reference** - Sub-categories organized for quick lookup and learning
✅ **Practical examples** - Verified, real-world usage examples
✅ **Multiple formats** - Markdown for editing + PDFs for offline viewing

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on:
- Adding new cheat sheets
- Formatting standards
- Submitting pull requests
- Reporting issues

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

## 🔗 External Resources & References

- [DOCKER cheat sheet](https://github.com/wsargent/docker-cheat-sheet)
- [GIT cheat sheet](https://github.com/arslanbilal/git-cheat-sheet)
- [LINUX CLI cheat sheets](https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/)
  - [Advanced #1](https://github.com/JREAM/ubuntu-cheatsheet?tab=readme-ov-file#table-of-contents)
  - [Advanced #2](https://www.geeksforgeeks.org/linux-commands-cheat-sheet/)
- [PROXMOX CLI cheat sheet](https://sweworld.net/cheatsheets/proxmox/)
- [TMUX cheat sheet](https://gist.github.com/michaellihs/b6d46fa460fa5e429ea7ee5ff8794b96)
- [VIM cheat sheet](https://github.com/hackjutsu/vim-cheatsheet)
- [VSCode cheat sheet](https://quickref.me/vscode.html)

---

**Last updated:** 2026-04-28  
**Maintainer:** [@PoissonChevre](https://github.com/PoissonChevre)
