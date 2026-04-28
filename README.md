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

> 📝 **25 Markdown files** · 🗂 **21 directories**

---

## 📋 Index by Category

> **Note:** PDFs are available locally but not tracked in Git. Only Markdown files are listed here.

---

### 🐳 **Containers & Virtualisation**

| Tool | File | Description |
|------|------|-------------|
| Docker | [docker/docker-cheatsheet.md](./docker/docker-cheatsheet.md) | Container management: images, containers, volumes, networks, compose, resource limits, logs |
| Kubernetes | [k8s/kubernetes-cheatsheet.md](./k8s/kubernetes-cheatsheet.md) | Container orchestration: contexts, pods, deployments, services, configmaps, RBAC, scaling, helm |
| Helm | [helm/helm-cheatsheet.md](./helm/helm-cheatsheet.md) | Kubernetes package manager: repos, install/upgrade, rollback, values, templating, OCI registries |
| Incus | [incus/incus-cheatsheet.md](./incus/incus-cheatsheet.md) | Container & VM: instance management, images, profiles, networking, storage, snapshots |
| Proxmox | [proxmox/proxmox-cheatsheet.md](./proxmox/proxmox-cheatsheet.md) | Virtualization: VMs, LXC containers, storage, networking, backup, cluster, CLI tools |
| Vagrant | [vagrant/vagrant-cheatsheet.md](./vagrant/vagrant-cheatsheet.md) | Infrastructure provisioning and VM management |

---

### 🏗️ **Infrastructure & IaC**

| Tool | File | Description |
|------|------|-------------|
| Ansible | [ansible/ansible-cheatsheet.md](./ansible/ansible-cheatsheet.md) | Infrastructure automation: inventory, playbooks, roles, vault, variables, common modules |
| Terraform | [terraform/terraform-cheatsheet.md](./terraform/terraform-cheatsheet.md) | Infrastructure as Code: providers, variables, resources, state, modules, workspaces |
| Terraform + Incus | [terraform/terraform-incus-cheatsheet.md](./terraform/terraform-incus-cheatsheet.md) | Incus provider: instances, networks, storage, profiles, multi-remote management |

---

### 🐧 **Linux & System**

| Tool | File | Description |
|------|------|-------------|
| Linux CLI (LFCS) | [linux_cli/lfcs-essential-commands.md](./linux_cli/lfcs-essential-commands.md) | System administration: LFCS reference (5 domains), user mgmt, services |
| Linux CLI Networking | [linux_cli/linux-cli-networking.md](./linux_cli/linux-cli-networking.md) | Network tools: nmap, dig, tcpdump, network diagnostics |
| Systemd | [systemd/systemd-cheatsheet.md](./systemd/systemd-cheatsheet.md) | System manager: services, timers, targets, journals, unit files, socket activation |
| Iptables / Nftables | [iptables/iptables-cheatsheet.md](./iptables/iptables-cheatsheet.md) | Linux firewalls: chains, rules, NAT, masquerade, state management, nftables migration |
| SSH | [ssh/ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Secure shell: keys, connections, port forwarding, agent, hardening |

---

### 🛠️ **Development & Scripting**

| Tool | File | Description |
|------|------|-------------|
| Bash | [bash/bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Shell scripting: variables, quoting, conditionals, loops, functions, arrays, I/O redirection |
| Git | [git/git-cheatsheet.md](./git/git-cheatsheet.md) | Version control: setup, branching, merging, remotes, advanced operations |
| Make | [make/make-cheatsheet.md](./make/make-cheatsheet.md) | Build automation: Makefiles, variables, targets, dependencies, pattern rules, recursive make |
| Python | [python/python-cheatsheet.md](./python/python-cheatsheet.md) | Programming: data types, strings, collections, control flow, functions, file I/O, stdlib |
| Regex | [regex/regex-cheatsheet.md](./regex/regex-cheatsheet.md) | Pattern matching: anchors, quantifiers, character classes, groups, lookahead/behind, usage in tools |
| Vim | [vim/vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Text editor: modes, navigation, editing, search/replace, macros, splits |
| Tmux | [tmux/tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Terminal multiplexer: sessions, windows, panes, copy mode, config |
| Tools | [tools/tools-cheatsheet.md](./tools/tools-cheatsheet.md) | Essential CLI: curl, wget, jq, rsync, netcat, nmap, htop, strace, lsof, fzf |

---

### 🗄️ **Databases**

| Tool | File | Description |
|------|------|-------------|
| MySQL / SQL | [sql/mysql-cheatsheet.md](./sql/mysql-cheatsheet.md) | Database management: DDL/DML, user/permissions, joins, indexes, transactions, backup/restore |

---

### 💻 **Windows & WSL**

| Tool | File | Description |
|------|------|-------------|
| WSL | [wsl/wsl-cheatsheet.md](./wsl/wsl-cheatsheet.md) | Windows Subsystem for Linux: installation, distributions, file access, networking, interop |
| PowerShell | [wsl/powershell-cheatsheet.md](./wsl/powershell-cheatsheet.md) | Windows automation: variables, strings, arrays, functions, file/process management |

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
