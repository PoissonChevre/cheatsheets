# DevOps Cheat Sheets

My cheat sheets for the DevOps, Linux and cloud tools I use. I built them while
preparing the CKA and LFCS, drafting with an AI assistant (Claude) and keeping
only commands I have tested and use. They are updated as I go. Each command comes
with a short comment explaining what it does.

## Containers and virtualisation

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Docker | [docker-cheatsheet.md](./docker/docker-cheatsheet.md) · [networking](./docker/docker-networking.md) | Images, containers, volumes, Compose, network drivers |
| Kubernetes | [k8s/](./k8s/README.md) | kubectl, manifests, JSONPath, troubleshooting |
| Helm | [helm.md](./k8s/helm.md) | Repos, install/upgrade, values, rollback, writing charts, OCI |
| Kustomize | [kustomize.md](./k8s/kustomize.md) | Base and overlays, patches, generators, Helm vs Kustomize |
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
| Linux | [linux/](./linux/README.md) | Essentials, users, storage, networking, services, LFCS exam |
| systemd | [systemd.md](./linux/systemd.md) | Services, unit files, timers, targets, journal |
| GRUB and boot | [grub.md](./linux/grub.md) | Boot process, kernel parameters, rescue, root password reset |
| SELinux | [selinux.md](./linux/selinux.md) | Contexts, labels, ports, booleans, troubleshooting |
| Firewall | [firewall.md](./linux/firewall.md) · [iptables-nftables.md](./linux/iptables-nftables.md) | ufw, firewalld, iptables, nftables, NAT |
| SSH | [ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Keys, port forwarding, agent, hardening |
| Tailscale | [tailscale-cheatsheet.md](./tailscale/tailscale-cheatsheet.md) | Subnet router, exit node, Tailscale SSH |

## Scripting and tools

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Bash | [bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Variables, quoting, conditionals, loops, functions, redirection |
| Python | [python-cheatsheet.md](./python/python-cheatsheet.md) | Data types, collections, functions, file I/O, stdlib |
| Git | [git-cheatsheet.md](./git/git-cheatsheet.md) | Branching, merging, remotes, history |
| Make | [make-cheatsheet.md](./make/make-cheatsheet.md) | Task runner, variables, help target, DevOps Makefile template |
| Regex | [regex.md](./linux/regex.md) | Flavors (BRE/ERE/PCRE), groups, lookarounds, grep/sed/awk examples |
| jq and JSONPath | [utilities.md](./linux/utilities.md#jq) · [kubectl-jsonpath.md](./k8s/kubectl-jsonpath.md) | jq filters, kubectl JSONPath, az/aws + jq |
| MySQL | [mysql-cheatsheet.md](./sql/mysql-cheatsheet.md) | DDL/DML, users, joins, indexes, backup |
| Vim | [vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Modes, navigation, search/replace, macros |
| tmux | [tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Sessions, windows, panes, copy mode |
| VS Code | [vscode-cheatsheet.md](./vscode/vscode-cheatsheet.md) | Shortcuts, multi-cursor, Remote-SSH |
| CLI tools | [utilities.md](./linux/utilities.md) | curl, wget, jq, rsync, netcat, nmap, strace, lsof, fzf |

## Windows

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| WSL | [wsl-cheatsheet.md](./wsl/wsl-cheatsheet.md) | Distributions, file access, networking, interop |
| PowerShell | [powershell-cheatsheet.md](./powershell/powershell-cheatsheet.md) | Variables, functions, files, processes |

## References

- [Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)
- [Git cheat sheet](https://github.com/arslanbilal/git-cheat-sheet)
- [Linux commands cheat sheet](https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/)
- [Proxmox CLI cheat sheet](https://sweworld.net/cheatsheets/proxmox/)
- [tmux cheat sheet](https://gist.github.com/michaellihs/b6d46fa460fa5e429ea7ee5ff8794b96)
- [Vim cheat sheet](https://github.com/hackjutsu/vim-cheatsheet)

## License

[MIT](./LICENSE)
