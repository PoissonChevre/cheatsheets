# LFCS — Linux Foundation Certified SysAdmin: Essential Commands Reference

> **Linux Foundation Certified SysAdmin**
> Structured cheat sheet by exam domain

---

## Domain 1 — Essential Commands

### Navigation & Files

| Command | Description |
|---------|-------------|
| `ls -lahZ` | List with size, permissions, SELinux context |
| `find / -name "*.conf" -type f` | Recursive file search |
| `find / -perm /4000` | Find SUID files (security concern) |
| `locate <file>` | Fast search via database (requires updatedb) |
| `updatedb` | Update locate database |
| `stat <file>` | Detailed file metadata (timestamps, permissions) |
| `file <file>` | Identify file type |
| `which / whereis` | Locate binaries in PATH |

### File Manipulation

| Command | Description |
|---------|-------------|
| `cp -a` | Copy preserving all attributes |
| `mv`, `rm -rf` | Move / delete |
| `ln -s <target> <link>` | Create symbolic link |
| `tar -czvf archive.tar.gz <dir>` | Create compressed archive |
| `tar -xzvf archive.tar.gz` | Extract archive |
| `gzip / gunzip / bzip2 / xz` | File compression tools |
| `dd if=/dev/sda of=/dev/sdb` | Block-by-block device copy |
| `rsync -avz src/ dest/` | File synchronization (smart copy) |

### Text Search & Filtering

| Command | Description |
|---------|-------------|
| `grep -rn "pattern" /etc/` | Recursive search with line numbers |
| `grep -v / -i / -E` | Invert / case-insensitive / extended regex |
| `sed 's/old/new/g' file` | Text substitution |
| `awk '{print $1, $3}' file` | Extract columns |
| `cut -d: -f1 /etc/passwd` | Cut fields by delimiter |
| `sort -k2 -n / uniq -c` | Sort / deduplicate with count |
| `wc -l / head -n / tail -f` | Count lines / head / tail (follow) |
| `diff file1 file2` | Compare files |

### Permissions & Ownership

| Command | Description |
|---------|-------------|
| `chmod 755 / chmod u+x` | Modify permissions (numeric/symbolic) |
| `chown user:group file` | Change owner |
| `chgrp group file` | Change group |
| `umask 022` | Default permission mask |
| `getfacl / setfacl -m u:user:rwx` | ACL (Access Control Lists) |
| `chattr +i file` | Make file immutable |
| `lsattr file` | Read extended attributes |

### Getting Help

```bash
man -k <keyword>      # Search man pages by keyword
apropos <keyword>     # Equivalent to man -k
man 5 passwd          # Specific section (5=file formats)
info <command>        # GNU documentation
```

---

## Domain 2 — Users & Groups

### User Management

| Command | Description |
|---------|-------------|
| `useradd -m -s /bin/bash -G sudo user` | Create user with home & shell |
| `usermod -aG group user` | Add to group (without removing others) |
| `userdel -r user` | Delete user and home directory |
| `passwd user` | Change password |
| `chage -l user` | Show password expiration info |
| `chage -E 2025-12-31 user` | Set expiration date |
| `chage -M 90 user` | Max days before password renewal |
| `id user` | Show UID, GID, and groups |
| `who / w / last` | Active sessions / login history |

### Group Management

| Command | Description |
|---------|-------------|
| `groupadd <group>` | Create group |
| `groupmod -n new old` | Rename group |
| `groupdel <group>` | Delete group |
| `gpasswd -a user group` | Add member to group |
| `gpasswd -d user group` | Remove member from group |
| `groups user` | List groups for user |
| `newgrp <group>` | Switch primary group temporarily |

### Key Files

```
/etc/passwd     — User information
/etc/shadow     — Hashed passwords
/etc/group      — Group definitions
/etc/sudoers    — Sudo rules (edit with visudo!)
/etc/login.defs — Default parameters (UID_MIN, PASS_MAX_DAYS…)
/etc/skel/      — Files copied to each new home directory
```

### Privilege Escalation

| Command | Description |
|---------|-------------|
| `sudo -l` | List user's sudo permissions |
| `sudo -u user command` | Run as another user |
| `su - user` | Open full shell as user |
| `visudo` | Edit `/etc/sudoers` safely |

---

## Domain 3 — Storage

### Partitions & Disks

| Command | Description |
|---------|-------------|
| `lsblk -f` | Block device tree with filesystems |
| `fdisk /dev/sdb` | Partition tool (MBR/DOS) |
| `gdisk /dev/sdb` | Partition tool (GPT) |
| `parted /dev/sdb` | Interactive partitioning (MBR & GPT) |
| `blkid` | UUIDs and partition types |
| `df -hT` | Disk space by mount point + FS type |
| `du -sh /var/*` | Directory sizes |

### Filesystems

| Command | Description |
|---------|-------------|
| `mkfs.ext4 /dev/sdb1` | Format as ext4 |
| `mkfs.xfs /dev/sdb1` | Format as XFS |
| `mkswap / swapon / swapoff` | Create and activate swap |
| `tune2fs -l /dev/sdb1` | Info on ext2/3/4 filesystem |
| `xfs_info /dev/sdb1` | Info on XFS filesystem |
| `fsck /dev/sdb1` | Check/repair ext2/3/4 |
| `xfs_repair /dev/sdb1` | Check/repair XFS |
| `e2label / xfs_admin -L` | Set filesystem label |

### Mounting

| Command | Description |
|---------|-------------|
| `mount /dev/sdb1 /mnt/data` | Manual mount |
| `mount -o ro,noexec /dev/sdb1 /mnt` | Mount with options |
| `umount /mnt/data` | Unmount |
| `mount -a` | Mount all in `/etc/fstab` |

**Example `/etc/fstab` entry:**
```
UUID=xxxx  /mnt/data  ext4  defaults,nofail  0  2
```

### LVM (Logical Volume Management)

| Command | Description |
|---------|-------------|
| `pvcreate /dev/sdb` | Initialize physical volume |
| `vgcreate vg_data /dev/sdb` | Create volume group |
| `lvcreate -L 10G -n lv_data vg_data` | Create logical volume |
| `lvextend -L +5G /dev/vg_data/lv_data` | Extend logical volume |
| `resize2fs / xfs_growfs` | Grow filesystem after lvextend |
| `pvs / vgs / lvs` | Summary of PV / VG / LV |
| `pvdisplay / vgdisplay / lvdisplay` | Detailed information |

---

## Domain 4 — Networking

### Network Configuration

| Command | Description |
|---------|-------------|
| `ip addr show` | Show interfaces and IP addresses |
| `ip link set eth0 up/down` | Enable/disable interface |
| `ip addr add 192.168.1.10/24 dev eth0` | Add temporary IP |
| `ip route show` | Show routing table |
| `ip route add default via 192.168.1.1` | Add route |
| `nmcli device status` | Interface status (NetworkManager) |
| `nmcli con show` | List connections |
| `nmcli con mod <name> ipv4.addresses 10.0.0.5/24` | Modify connection |
| `nmtui` | NetworkManager text UI |
| `ss -tulnp` | Listening ports + processes |
| `netstat -tulnp` | Legacy equivalent |

### DNS & Connectivity

| Command | Description |
|---------|-------------|
| `ping -c 4 <host>` | Test connectivity |
| `traceroute / tracepath` | Show network path |
| `dig <domain>` | Detailed DNS lookup |
| `nslookup <domain>` | Simple DNS lookup |
| `host <domain>` | Fast DNS lookup |
| `curl -I <url>` | Test HTTP endpoint |
| `wget <url>` | Download file |

### Key Network Files

```
/etc/hosts               — Local hostname resolution
/etc/resolv.conf         — DNS servers
/etc/hostname            — Machine hostname
/etc/nsswitch.conf       — Name service switch configuration
/etc/network/interfaces  — Network config (Debian)
/etc/sysconfig/network-scripts/  — Network config (RHEL)
```

### Firewall

| Command | Description |
|---------|-------------|
| `firewall-cmd --list-all` | List active rules (firewalld) |
| `firewall-cmd --permanent --add-service=http` | Open HTTP |
| `firewall-cmd --permanent --add-port=8080/tcp` | Open specific port |
| `firewall-cmd --reload` | Apply changes |
| `ufw status verbose` | Firewall status (Ubuntu) |
| `ufw allow 22/tcp` | Allow SSH |
| `iptables -L -n -v` | Raw iptables rules |

---

## Domain 5 — Operations & Deployment

### Service Management (systemd)

| Command | Description |
|---------|-------------|
| `systemctl start/stop/restart <service>` | Control service |
| `systemctl enable/disable <service>` | Boot startup control |
| `systemctl status <service>` | Service status |
| `systemctl is-active / is-enabled` | Quick checks |
| `systemctl list-units --type=service` | List all services |
| `systemctl daemon-reload` | Reload modified units |
| `journalctl -u <service> -f` | Service logs (real-time) |
| `journalctl --since "1 hour ago"` | Logs by time range |
| `journalctl -p err` | Filter by priority |

### Package Management

**Debian / Ubuntu**
```bash
apt update && apt upgrade
apt install / remove / purge <package>
dpkg -l | grep <name>
dpkg -i <package>.deb
```

**RHEL / CentOS / Fedora**
```bash
dnf update
dnf install / remove <package>
rpm -qa | grep <name>
rpm -ivh <package>.rpm
```

### Task Scheduling

| Command | Description |
|---------|-------------|
| `crontab -e` | Edit current user's cron |
| `crontab -l -u user` | List user's cron jobs |
| `crontab -r` | Delete user's cron |
| `at now + 1 hour` | Schedule one-time task |
| `atq / atrm` | List / remove `at` jobs |

**Cron syntax:**
```
* * * * *  command
│ │ │ │ └─ day of week (0-7, 0=Sunday)
│ │ │ └─── month (1-12)
│ │ └───── day of month (1-31)
│ └─────── hour (0-23)
└───────── minute (0-59)
```

**System cron files:**
```
/etc/crontab
/etc/cron.d/
/etc/cron.daily/ /etc/cron.weekly/ /etc/cron.monthly/
```

### Process & System Monitoring

| Command | Description |
|---------|-------------|
| `top / htop` | Real-time processes |
| `ps aux / ps -ef` | List all processes |
| `pgrep / pkill <name>` | Find / kill by name |
| `kill -9 <PID>` | Force kill process (SIGKILL) |
| `nice -n 10 command` | Launch with modified priority |
| `renice -n 5 -p <PID>` | Change process priority |
| `vmstat 1` | Memory/CPU/IO statistics |
| `iostat -xz 1` | Disk I/O statistics |
| `free -h` | Memory available |
| `uptime / w` | System load |

### Kernel & Boot

| Command | Description |
|---------|-------------|
| `uname -r` | Kernel version |
| `dmesg \| tail -50` | Recent kernel messages |
| `lsmod` | Loaded kernel modules |
| `modprobe <module>` | Load module |
| `modprobe -r <module>` | Unload module |
| `sysctl -a` | Active kernel parameters |
| `sysctl -w net.ipv4.ip_forward=1` | Modify parameter (temporary) |
| `grub2-mkconfig -o /boot/grub2/grub.cfg` | Regenerate GRUB (RHEL) |
| `update-grub` | Regenerate GRUB (Debian) |

### Logs

| Command | Description |
|---------|-------------|
| `journalctl -xe` | Recent logs with error context |
| `tail -f /var/log/syslog` | System logs (Debian) |
| `tail -f /var/log/messages` | System logs (RHEL) |
| `logrotate -f /etc/logrotate.conf` | Force log rotation |

### SSH & Remote Access

| Command | Description |
|---------|-------------|
| `ssh user@host` | SSH connection |
| `ssh -i ~/.ssh/id_rsa user@host` | SSH with private key |
| `ssh-keygen -t ed25519` | Generate key pair |
| `ssh-copy-id user@host` | Copy public key to host |
| `scp file user@host:/dest` | Secure copy |
| `sftp user@host` | Secure FTP (interactive) |
| `rsync -avz -e ssh src/ user@host:/dest/` | Sync via SSH |

---

## Exam Tips

> 💡 **Unsure about a command?** Use `man -k <keyword>` or `apropos <keyword>`
>
> 💡 **Reading man pages quickly:** Press `/` to search, `n` for next match, `q` to quit
>
> 💡 **Test before applying:** Use `--dry-run` or `-n` flags when available
>
> 💡 **Verify after each action:** Run `systemctl status`, `df -h`, `ip addr show`, etc.

---

*Reference compiled for LFCS — Linux Foundation Certified SysAdmin preparation*
