# Windows — Cheat Sheets

Windows tools for a Linux/DevOps admin: PowerShell and WSL.

| File | Content |
|---|---|
| [powershell-cheatsheet.md](./powershell-cheatsheet.md) | Variables, functions, files, processes, services, remoting |
| [wsl-cheatsheet.md](./wsl-cheatsheet.md) | Distributions, file access, networking, interop |

## Scripts

| Script | Use |
|---|---|
| [wsl.ps1](./scripts/wsl.ps1) | `wsl` CLI commands (install, list, run, stop distributions) |
| [wsl_port_forwarding.ps1](./scripts/wsl_port_forwarding.ps1) | Manual port forwarding to WSL 2 (`netsh portproxy` + firewall rule) |
| [wsl_port_forwarding_auto.ps1](./scripts/wsl_port_forwarding_auto.ps1) | Same, automatic: finds the WSL IP and recreates the rules (run after each reboot) |

## Related

- [Linux](../linux/README.md)
- [Bash](../bash/bash-cheatsheet.md)
