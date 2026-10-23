# DevOps Cheat Sheets

My personal cheat sheets for the DevOps, Linux and cloud tools I use, written while learning and kept up to date as I go. Each command comes with a short comment explaining what it does.

## Containers and virtualisation

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Docker | [docker-cheatsheet.md](./docker/docker-cheatsheet.md) | Images, containers, volumes, networks, Compose, logs |
| Kubernetes | [kubernetes-cheatsheet.md](./k8s/kubernetes-cheatsheet.md) | Contexts, pods, deployments, services, ConfigMaps, RBAC, scaling |
| Helm | [helm-cheatsheet.md](./helm/helm-cheatsheet.md) | Repos, install/upgrade, rollback, values, templating |
| Incus | [incus-cheatsheet.md](./incus/incus-cheatsheet.md) | Instances, images, profiles, networking, storage, snapshots |
| Proxmox VE | [proxmox-cheatsheet.md](./proxmox/proxmox-cheatsheet.md) | VMs, LXC containers, storage, networking, backup, cluster |
| Vagrant | [vagrant-cheatsheet.md](./vagrant/vagrant-cheatsheet.md) | Vagrantfile, boxes, networking, provisioning |

## Cloud

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Azure CLI | [azure-cheatsheet.md](./azure/azure-cheatsheet.md) | Resource groups, VMs, networking, storage, RBAC, ARM/Bicep |
| AWS CLI | [aws-cheatsheet.md](./aws/aws-cheatsheet.md) | Profiles/SSO, EC2, VPC, S3, IAM, CloudFormation |

## Infrastructure as code

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Ansible | [ansible-cheatsheet.md](./ansible/ansible-cheatsheet.md) | Inventory, playbooks, roles, Vault, variables, modules |
| Terraform | [terraform-cheatsheet.md](./terraform/terraform-cheatsheet.md) | Providers, variables, state, modules, workspaces |
| Terraform + Incus | [terraform-incus-cheatsheet.md](./terraform/terraform-incus-cheatsheet.md) | Incus provider: instances, networks, storage, profiles |

## Linux and system

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| LFCS notes | [linux_cli/](./linux_cli/) | The five LFCS domains, exam strategy, disks, firewall |
| systemd | [systemd-cheatsheet.md](./systemd/systemd-cheatsheet.md) | Services, timers, targets, journal, unit files |
| iptables / nftables | [iptables-cheatsheet.md](./iptables/iptables-cheatsheet.md) | Chains, rules, NAT, state, nftables migration |
| SSH | [ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Keys, port forwarding, agent, hardening |
| Tailscale | [tailscale-cheatsheet.md](./tailscale/tailscale-cheatsheet.md) | Subnet router, exit node, Tailscale SSH |

## Scripting and tools

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Bash | [bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Variables, quoting, conditionals, loops, functions, redirection |
| Python | [python-cheatsheet.md](./python/python-cheatsheet.md) | Data types, collections, functions, file I/O, stdlib |
| Git | [git-cheatsheet.md](./git/git-cheatsheet.md) | Branching, merging, remotes, history |
| Make | [make-cheatsheet.md](./make/make-cheatsheet.md) | Targets, variables, dependencies, pattern rules |
| Regex | [regex-cheatsheet.md](./regex/regex-cheatsheet.md) | Anchors, quantifiers, groups, lookarounds |
| jq and JSONPath | [jq-cheatsheet.md](./jq/jq-cheatsheet.md) | jq filters, kubectl JSONPath, az/aws + jq |
| MySQL | [mysql-cheatsheet.md](./sql/mysql-cheatsheet.md) | DDL/DML, users, joins, indexes, backup |
| Vim | [vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Modes, navigation, search/replace, macros |
| tmux | [tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Sessions, windows, panes, copy mode |
| VS Code | [vscode-cheatsheet.md](./vscode/vscode-cheatsheet.md) | Shortcuts, multi-cursor, Remote-SSH |
| CLI tools | [tools-cheatsheet.md](./tools/tools-cheatsheet.md) | curl, rsync, netcat, nmap, strace, lsof, fzf |

## Windows

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| WSL | [wsl-cheatsheet.md](./wsl/wsl-cheatsheet.md) | Distributions, file access, networking, interop |
| PowerShell | [powershell-cheatsheet.md](./wsl/powershell-cheatsheet.md) | Variables, functions, files, processes |

## References

- [Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)
- [Git cheat sheet](https://github.com/arslanbilal/git-cheat-sheet)
- [Linux commands cheat sheet](https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/)
- [Proxmox CLI cheat sheet](https://sweworld.net/cheatsheets/proxmox/)
- [tmux cheat sheet](https://gist.github.com/michaellihs/b6d46fa460fa5e429ea7ee5ff8794b96)
- [Vim cheat sheet](https://github.com/hackjutsu/vim-cheatsheet)

## License

[MIT](./LICENSE)
