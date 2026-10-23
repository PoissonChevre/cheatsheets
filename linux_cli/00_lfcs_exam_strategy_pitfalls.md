# LFCS — Exam Strategy & Key Pitfalls

> Quick reference for exam day. Built from today's drill session.

---

## Exam Day Reflexes

### Before each question

1. **Read the full question** before typing anything
2. **Check which server** to work on (terminal, web-srv1, app-srv1, data-001, data-002)
3. **Check if it's `/opt/course/*`** → always on main terminal

### Standard verification after every action

```bash
ss -tulpn                            # Service listening?
systemctl status <svc>               # Service running?
mount -a                             # /etc/fstab still valid?
sudo -l -U <user>                    # Sudoers correct?
id <user>                            # User/group correct?
lsblk -f                             # Storage layout correct?
ip a                                 # Network correct?
journalctl -u <svc> -e               # Logs?
```

### When stuck

```bash
command --help                       # Quick reference (10 sec)
man -k keyword                       # Find the right command
apropos keyword                      # Same
man command                          # Full doc, /pattern to search inside
```

**Tab completion works.** Use it systematically — saves typos and time.

---

## Time Management Strategy

### Suggested 2-hour pass strategy

**First pass (30-40 min) — easy wins:**
- Kernel info, timezone, hostname (`uname -r`, `timedatectl`)
- User creation/modification (`useradd`, `usermod -aG`)
- Permissions (`chmod`, `chown`)
- Basic redirections, archives
- systemctl start/enable/status

**Second pass (30 min) — medium:**
- LVM (pvcreate → vgcreate → lvcreate)
- find with conditions and -exec
- Cron jobs
- SSH config / sshd_config
- Basic firewall (ufw allow / firewall-cmd --add-service)

**Third pass (30 min) — harder:**
- iptables with multiple rules
- Nginx reverse proxy / LB
- Regex with grep + sed
- Network bonding
- LUKS encryption

**Skip if blocked > 5 min, come back later.** A 30% question costs the same time as a 70% question.

---

## Top 20 Pitfalls (drilled today)

### 1. usermod groups
```bash
usermod -G dev jane                  # ❌ REPLACES all supplementary groups
usermod -aG dev jane                 # ✅ APPEND to supplementary groups
usermod -g dev jane                  # → PRIMARY group (lowercase!)
```

### 2. useradd vs adduser
```bash
useradd -m -s /bin/bash -G dev,ops user   # ✅ Scriptable, predictable
adduser user                              # Interactive Debian wrapper (avoid at exam)
```

### 3. Sudoers (ALL) vs (root)
```bash
user ALL=(ALL)  NOPASSWD: /bin/bash /script.sh    # Run as ANY user
user ALL=(root) NOPASSWD: /bin/bash /script.sh    # ✅ Only as root (safer, principle of least privilege)
```

### 4. visudo, never vim /etc/sudoers
```bash
visudo                               # ✅ Syntax check on save
visudo -f /etc/sudoers.d/myrule      # ✅ Drop-in file, also safe
vim /etc/sudoers                     # ❌ Typo = system unusable
```

### 5. cron: /etc/crontab vs crontab -e
```bash
# /etc/crontab — REQUIRES username field:
30 2 * * * root /backup.sh

# crontab -e (user) — NO username field:
30 2 * * * /backup.sh                # ✅ user already known
```

### 6. tar compression level
```bash
GZIP=-9 tar czf archive.tar.gz dir/         # ❌ DEPRECATED (warning)
tar -I 'gzip -9' -cf archive.tar.gz dir/    # ✅ Modern way
tar czf archive.tar.gz dir/                 # ✅ Default level (6) — usually enough
```

### 7. iptables ACCEPT/DROP order
```bash
iptables -A INPUT -i eth0 -p tcp --dport 6002 -s 192.168.10.80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 6002 -j DROP
# ✅ ACCEPT BEFORE DROP. Top-down evaluation, first match wins.
```

### 8. REDIRECT vs DNAT
```bash
# REDIRECT — local same-machine port redirection (simpler)
iptables -t nat -A PREROUTING -p tcp --dport 6000 -j REDIRECT --to-port 6001

# DNAT — to another machine or different IP (more powerful)
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:8080
```

### 9. ufw enable can lock out SSH
```bash
ufw allow 22/tcp                     # ✅ ALWAYS first
ufw enable                           # Then this
# Without /tcp → ufw allow 22 opens TCP AND UDP (don't!)
```

### 10. firewalld --permanent + --reload
```bash
firewall-cmd --permanent --add-service=http   # Without --permanent: lost at reboot
firewall-cmd --reload                          # Without --reload: not active in runtime
# Combo: --permanent ... && firewall-cmd --reload
```

### 11. resize2fs vs xfs_growfs
```bash
resize2fs /dev/vg/lv                 # ✅ ext4: takes DEVICE
resize2fs /mnt/data                  # ❌ Won't work

xfs_growfs /mnt/data                 # ✅ XFS: takes MOUNTPOINT
xfs_growfs /dev/vg/lv                # ❌ Won't work

lvextend -L +5G -r /dev/vg/lv        # ✅ Best: extend LV + resize FS in one shot
```

### 12. XFS cannot shrink
```bash
# XFS only grows. To "shrink": backup → mkfs smaller → restore
# ext4 can shrink (after umount + e2fsck -f)
```

### 13. fsck.xfs is fake
```bash
xfs_repair /dev/sdb1                 # ✅ Real XFS repair tool
fsck.xfs /dev/sdb1                   # ❌ Exists but does NOTHING
e2fsck -f /dev/sdb1                  # ✅ ext4 (must be unmounted)
```

### 14. /etc/fstab errors = unbootable
```bash
# After editing /etc/fstab:
mount -a                             # ✅ MUST test before reboot
findmnt --verify                     # Validate syntax
# Use `nofail` for non-critical mounts to prevent boot failure
```

### 15. Match blocks in sshd_config
```bash
# Match blocks must be at the END of the file
# OR in a 99-*.conf drop-in (loads last)

# /etc/ssh/sshd_config.d/99-match-users.conf:
Match User alice
    PasswordAuthentication yes
    Banner /etc/ssh/banner
```

### 16. systemctl daemon-reload
```bash
# After editing ANY unit file:
systemctl daemon-reload              # ✅ MANDATORY
# Otherwise systemd uses cached old version
```

### 17. enable ≠ start
```bash
systemctl enable nginx               # At boot only
systemctl start nginx                # Now only
systemctl enable --now nginx         # ✅ Both at once
```

### 18. nginx -t before reload
```bash
nginx -t && systemctl reload nginx   # ✅ Test then apply
# Bad config + restart = service down
# Same for: apachectl -t, sshd -t, testparm, named-checkconf
```

### 19. $? overwritten by every command
```bash
output-generator
echo $? > /var/output-generator/4.out    # ✅ Capture immediately

# OR
output-generator
EXIT=$?                              # Save in variable
echo "anything"                      # Doesn't matter now
echo $EXIT > /var/output-generator/4.out
```

### 20. find -maxdepth placement
```bash
find . -maxdepth 1 -size +10k -type f    # ✅ -maxdepth before other filters
# Without -maxdepth, find recurses into subfolders (e.g. small/, large/)
# and risks moving already-sorted files
```

---

## Cheatsheet for the 20 Killer.sh-style Questions

| Topic | Killer.sh Q | Key command |
|---|---|---|
| Kernel info | Q1 | `uname -r > file` |
| Cron migration | Q2 | `crontab -e -u user` (no user field!) |
| NTP / timesyncd | Q3 | `/etc/systemd/timesyncd.conf` + restart |
| Env variables | Q4 | `export VAR=val` (children) vs `VAR=val` (local) |
| tar bzip2 → gzip | Q5 | `bunzip2 -k` then `gzip --best` |
| User mgmt + sudo | Q6 | `useradd -G ... -d ... -s ...` + visudo |
| iptables 4 rules | Q7 | INPUT DROP, PREROUTING REDIRECT, ACCEPT+DROP, OUTPUT DROP |
| Disk + memory | Q8 | `lsblk`, `mkfs.ext4`, `df -h`, `ps aux`, `lsof` |
| find with actions | Q9 | `find -maxdepth 1 -size +10k -type f -exec mv {} ./ \;` |
| SSHFS + NFS | Q10 | `sshfs -o allow_other,rw`, `/etc/exports` + `exportfs -ra` |
| Docker | Q11 | `docker run -d --name X --memory 30m -p 1234:80 nginx:alpine` |
| Git workflow | Q12 | `git clone`, `git checkout`, `git merge`, `.keep` for empty dir |
| strace syscalls | Q13 | `strace -e kill -p PID` |
| Output redirection | Q14 | `>` `2>` `2>&1` `$?` |
| Build from source | Q15 | `./configure --prefix=/usr --without-X && make && make install` |
| Nginx LB | Q16 | `upstream backend {}` + `proxy_pass http://backend;` |
| sshd_config | Q17 | `Match User X` at end of file or in 99-*.conf |
| LVM | Q18 | `vgreduce` → `vgcreate` → `lvcreate -L 50M -n p1 vol2` → `mkfs.ext4` |
| Regex grep + sed | Q19 | `grep -E "regex"` + `sed -i 's/regex/new/g'` |
| limits.conf | Q20 | `/etc/security/limits.conf`: `user hard nproc 1024` |

---

## Final Pre-Exam Mental Checklist

**Tonight:**
- [ ] Re-read the 20 Killer.sh questions WITH answers (recognize patterns)
- [ ] Sleep early — fresh brain > extra drill
- [ ] Don't try a new mock exam (overload risk)

**Tomorrow morning:**
- [ ] Light breakfast, no caffeine overload
- [ ] Check terminal works, ID ready
- [ ] Browser tabs for `man` pages NOT allowed — use the in-exam terminal `man`

**During the exam:**
- [ ] Use `Tab` for autocompletion ALWAYS (avoids typos)
- [ ] Use `man -k` and `--help` without hesitation
- [ ] Skip blocked questions — come back at the end
- [ ] Verify each answer with `ss`, `systemctl status`, `mount -a`, `id`, etc.
- [ ] Pass target: 66%. Aim for 80%, settle happily for 70%.

---

## Mantra

> The Killer.sh is harder than the real exam.
> The real exam tests basics under time pressure.
> You have CKA — you know how to work in a terminal under stress.
> `man -k`, `--help`, `Tab` are your survival kit.
> Don't aim for perfect. Aim for 66%.
