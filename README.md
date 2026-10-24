# Cheat Sheets

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
| Argo CD | [argocd-cheatsheet.md](./argocd/argocd-cheatsheet.md) | Applications, sync, Helm/Kustomize sources, app of apps, ApplicationSet |
| Talos Linux | [talos-cheatsheet.md](./talos/talos-cheatsheet.md) | talosctl, config patches, upgrades, etcd backup, troubleshooting |
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
| Fail2ban | [fail2ban.md](./linux/fail2ban.md) | Jails, ban and unban, custom filters |
| SSH | [ssh-cheatsheet.md](./ssh/ssh-cheatsheet.md) | Keys, port forwarding, agent, hardening |
| OpenSSL | [openssl-cheatsheet.md](./openssl/openssl-cheatsheet.md) | Inspect certs, test TLS servers, CSR, self-signed, small CA, convert |
| Tailscale | [tailscale-cheatsheet.md](./tailscale/tailscale-cheatsheet.md) | Subnet router, exit node, Tailscale SSH |

## Monitoring

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Monitoring | [monitoring/](./monitoring/README.md) | Checks vs metrics, vocabulary |
| Nagios | [nagios-cheatsheet.md](./monitoring/nagios-cheatsheet.md) | Plugins, states, hosts and services, NRPE, custom check |

## Scripting and tools

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| Bash | [bash-cheatsheet.md](./bash/bash-cheatsheet.md) | Variables, quoting, conditionals, loops, functions, redirection |
| Python | [python-cheatsheet.md](./python/python-cheatsheet.md) | Data types, collections, functions, file I/O, stdlib |
| Git | [git-cheatsheet.md](./git/git-cheatsheet.md) | Branching, merging, remotes, history |
| Make | [make-cheatsheet.md](./make/make-cheatsheet.md) | Task runner, variables, help target, DevOps Makefile template |
| Markdown | [markdown-cheatsheet.md](./markdown/markdown-cheatsheet.md) | Syntax, links and anchors, tables, GitHub alerts, Mermaid, README structure |
| Regex | [regex.md](./linux/regex.md) | Flavors (BRE/ERE/PCRE), groups, lookarounds, grep/sed/awk examples |
| jq and JSONPath | [utilities.md](./linux/utilities.md#jq) · [kubectl-jsonpath.md](./k8s/kubectl-jsonpath.md) | jq filters, kubectl JSONPath, az/aws + jq |
| YAML | [yaml-cheatsheet.md](./yaml/yaml-cheatsheet.md) | Syntax, quoting traps, multi-line, anchors, yamllint, yq |
| SQL (MySQL, PostgreSQL) | [sql-cheatsheet.md](./sql/sql-cheatsheet.md) | Connect, users and rights, backup/restore, monitoring, remote access |
| Vim | [vim-cheatsheet.md](./vim/vim-cheatsheet.md) | Modes, navigation, search/replace, macros |
| tmux | [tmux-cheatsheet.md](./tmux/tmux-cheatsheet.md) | Sessions, windows, panes, copy mode |
| VS Code | [vscode-cheatsheet.md](./vscode/vscode-cheatsheet.md) | Shortcuts, multi-cursor, Remote-SSH |
| CLI tools | [utilities.md](./linux/utilities.md) | curl, wget, jq, rsync, netcat, nmap, strace, lsof, fzf |

## Windows

Scripts and index: [windows/](./windows/README.md)

| Tool | Cheat sheet | Covers |
|------|-------------|--------|
| WSL | [wsl-cheatsheet.md](./windows/wsl-cheatsheet.md) | Distributions, file access, networking, interop |
| PowerShell | [powershell-cheatsheet.md](./windows/powershell-cheatsheet.md) | Variables, functions, files, processes |

## References

- [Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)
- [Git cheat sheet](https://github.com/arslanbilal/git-cheat-sheet)
- [Linux commands cheat sheet](https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/)
- [Proxmox CLI cheat sheet](https://sweworld.net/cheatsheets/proxmox/)
- [tmux cheat sheet](https://gist.github.com/michaellihs/b6d46fa460fa5e429ea7ee5ff8794b96)
- [Vim cheat sheet](https://github.com/hackjutsu/vim-cheatsheet)

## License

[MIT](./LICENSE)
