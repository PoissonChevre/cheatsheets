# LFCS — Exam Strategy

Method, checks and top pitfalls for the Linux Foundation Certified System Administrator exam. Pass score: 66%.

[← Back to index](./README.md)

---

## For each question

1. Read the **whole** question before typing.
2. Check **which server** to use (ssh to it). Files in `/opt/course/*` = main terminal.
3. Do the task.
4. **Check** the result.

```bash
systemctl status SVC     # Service running?
ss -tulpn                # Listening?
journalctl -u SVC -e     # Logs?
id USER                  # User and groups?
sudo -l -U USER          # Sudo rights?
lsblk -f                 # Disks?
mount -a                 # fstab OK?
ip a                     # Network?
```

## When stuck

```bash
cmd --help               # 10 seconds
man -k keyword           # Find the command (= apropos)
man cmd                  # Then /option to search
```

Use `Tab` completion all the time: fewer typos.

---

## Time: three passes

| Pass | Time | Topics |
|---|---|---|
| 1 — easy | 30-40 min | Kernel, hostname, timezone, users, permissions, redirections, archives, systemctl |
| 2 — medium | 30 min | LVM, find + exec, cron, sshd_config, simple firewall rules |
| 3 — hard | 30 min | iptables with several rules, Nginx proxy/LB, regex, bonding, LUKS |

Blocked more than 5 minutes? Skip and come back.

---

## Top pitfalls

| # | Pitfall | Details |
|---|---|---|
| 1 | `usermod -G` replaces groups → use `-aG` | [users](./users.md) |
| 2 | Use `useradd -m`, not the interactive `adduser` | [users](./users.md) |
| 3 | sudoers: `(root)` is stricter than `(ALL)` | [users](./users.md#sudo) |
| 4 | Always `visudo`, never edit `/etc/sudoers` directly | [users](./users.md#sudo) |
| 5 | `/etc/crontab` needs a username, `crontab -e` does not | [system](./system.md#cron) |
| 6 | `tar -I 'gzip -9'`, not `GZIP=-9` | [essentials](./essentials.md#archives-and-compression) |
| 7 | iptables: ACCEPT before DROP, first match wins | [firewall](./firewall.md#iptables) |
| 8 | REDIRECT = local port, DNAT = other machine | [firewall](./firewall.md#port-forwarding) |
| 9 | `ufw allow 22/tcp` BEFORE `ufw enable` | [firewall](./firewall.md#ufw-ubuntu) |
| 10 | firewalld: `--permanent` then `--reload` | [firewall](./firewall.md#firewalld-rhel-fedora) |
| 11 | `resize2fs DEVICE`, `xfs_growfs MOUNTPOINT` (or `lvextend -r`) | [storage](./storage.md#grow) |
| 12 | XFS cannot shrink | [storage](./storage.md#filesystems) |
| 13 | `fsck.xfs` does nothing → `xfs_repair` | [storage](./storage.md#check-and-repair-unmounted) |
| 14 | `mount -a` after editing fstab | [storage](./storage.md#etcfstab) |
| 15 | sshd `Match` blocks at the end of the file | [networking](./networking.md#server) |
| 16 | `systemctl daemon-reload` after editing a unit | [system](./system.md#systemd) |
| 17 | `enable` ≠ `start` → `enable --now` | [system](./system.md#systemd) |
| 18 | `nginx -t` before reload (same: `sshd -t`, `apachectl -t`) | [services](./services.md#check-a-service) |
| 19 | Save `$?` right away | [essentials](./essentials.md#exit-code) |
| 20 | `find -maxdepth 1` to avoid recursion | [essentials](./essentials.md#find--by-name-size-date-owner) |

---

## Killer.sh practice topics

| Topic | Key command |
|---|---|
| Kernel version | `uname -r > file` |
| Move a cron job to a user | `crontab -e -u user` (remove the username field) |
| NTP | `/etc/systemd/timesyncd.conf` + restart |
| Environment | `export VAR=val` (children) vs `VAR=val` (this shell) |
| bzip2 → gzip | `bunzip2 -k` then `gzip --best` |
| User + sudo | `useradd -m -G ... -s ...` + `visudo -f /etc/sudoers.d/user` |
| iptables | INPUT DROP, PREROUTING REDIRECT, ACCEPT + DROP, OUTPUT DROP |
| Disk + memory | `lsblk`, `mkfs.ext4`, `df -h`, `ps aux --sort=-%mem`, `lsof` |
| find + action | `find . -maxdepth 1 -size +10k -type f -exec mv {} dir/ \;` |
| SSHFS + NFS | `sshfs -o allow_other`, `/etc/exports` + `exportfs -ra` |
| Docker | `docker run -d --name X --memory 30m -p 1234:80 nginx:alpine` |
| Git | `git clone`, `git checkout`, `git merge`, `.keep` file for an empty folder |
| strace | `strace -e kill -p PID` |
| Redirection | `>`, `2>`, `2>&1`, `$?` |
| Build from source | `./configure --prefix=/usr && make && make install` |
| Nginx LB | `upstream backend {}` + `proxy_pass http://backend;` |
| sshd_config | `Match User X` at the end or in `99-*.conf` |
| LVM | `vgreduce` → `vgcreate` → `lvcreate -L 50M -n p1 vol2` → `mkfs.ext4` |
| Regex | `grep -E "regex"`, `sed -i 's/regex/new/g'` |
| Limits | `/etc/security/limits.conf`: `user hard nproc 1024` |

Killer.sh is harder than the real exam. The real exam tests the basics under time pressure.
