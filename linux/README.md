# Linux — Cheat Sheets

Linux system administration commands, organized by topic. Tested on Ubuntu and RHEL-based distributions. Built while preparing the LFCS exam.

| File | Content | LFCS domain |
|---|---|---|
| [essentials.md](./essentials.md) | Files, find, grep, sed, regex, redirection, archives, permissions, ACLs, help, vim | Essential Commands |
| [system.md](./system.md) | System info, processes, shutdown, logs, resources, kernel, cron, packages | Operation of Running Systems |
| [systemd.md](./systemd.md) | Services, unit files, dependencies, timers, sockets, targets, journalctl, user services | Operation of Running Systems |
| [grub.md](./grub.md) | Boot process, GRUB config, kernel parameters, initramfs, rescue modes, root password reset, boot troubleshooting | Operation of Running Systems |
| [selinux.md](./selinux.md) | Modes, contexts, file labels, ports, booleans, troubleshooting, common scenarios | Operation of Running Systems |
| [users.md](./users.md) | Users, groups, passwords, sudo, environment, limits | Users and Groups |
| [networking.md](./networking.md) | Interfaces, routing, DNS, Netplan, nmcli, bonding, NTP, SSH | Networking |
| [firewall.md](./firewall.md) | ufw, firewalld (zones, rich rules, NAT), tool comparison | Networking |
| [iptables-nftables.md](./iptables-nftables.md) | Tables, chains, rules, NAT, sets, persistence, migration | Networking |
| [fail2ban.md](./fail2ban.md) | Jails, jail.local, ban and unban, logs, custom filter | — |
| [storage.md](./storage.md) | Partitions, filesystems, fstab, LVM, swap, RAID, quotas, LUKS | Storage |
| [services.md](./services.md) | Nginx, Apache, NFS, Samba, BIND, rsyslog, auditd, VMs, build from source | Service Configuration |
| [utilities.md](./utilities.md) | curl, wget, jq, rsync, nc, nmap, lsof, strace, htop, fzf | — |
| [lfcs-exam.md](./lfcs-exam.md) | Exam method, checks, top 20 pitfalls, practice topics | — |

Each topic file ends with a **Pitfalls** section.

## Conventions

- `SVC`, `PKG`, `PID`, `USER` = replace with your value.
- Commands that change the system need root (`sudo`).
- Debian/Ubuntu and RHEL differences are shown side by side when they matter.

## Related

- [LFCS exam page](https://training.linuxfoundation.org/certification/linux-foundation-certified-sysadmin-lfcs/)
