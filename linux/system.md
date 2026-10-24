# Running Systems

System info, processes, boot, systemd, logs, resources, kernel, scheduling, packages, SELinux.

[← Back to index](./README.md)

---

## System information

```bash
uname -r                 # Kernel version (-a = everything, -m = architecture)
hostnamectl              # Hostname, OS, kernel
hostnamectl set-hostname srv01
uptime                   # Uptime + load average (1, 5, 15 min)
date ; date -u           # Local time, UTC
cat /etc/os-release      # Distribution

lscpu ; nproc            # CPU
lsmem ; free -h          # Memory
lspci ; lsusb            # Devices
lshw -short              # All hardware
dmidecode -t system      # Hardware vendor, model, serial (root)
dmesg -T                 # Kernel messages with readable time
```

---

## Processes

```bash
ps aux                   # All processes
ps -ef --forest          # Tree
ps -u john               # Processes of a user
pgrep -a nginx           # PID + command line
pidof nginx
top ; htop               # Interactive
```

Which process uses a file, a port or a mount point: `lsof` and `fuser`, see [tools.md](./tools.md#lsof).

### Signals

```bash
kill PID                 # SIGTERM (15): ask to stop
kill -9 PID              # SIGKILL: force (no cleanup) — last resort
kill -HUP PID            # SIGHUP (1): often reloads the config
kill -l                  # List signals
pkill -u john            # By user
pkill -f "pattern"       # By command line
killall nginx            # All processes with this name
```

| Signal | No. | Use |
|---|---|---|
| SIGHUP | 1 | Reload config |
| SIGINT | 2 | Ctrl+C |
| SIGKILL | 9 | Force kill |
| SIGTERM | 15 | Stop cleanly (default) |
| SIGCONT | 18 | Continue |
| SIGSTOP | 19 | Pause |

### Jobs

```bash
cmd &                    # Run in background
jobs -l                  # List jobs
fg %1 ; bg %1            # Foreground, background
# Ctrl+Z = pause the current job
nohup cmd >> log.out 2>&1 &   # Keep running after logout
disown %1                # Detach a job from the shell
```

### Priority

```bash
nice -n 10 cmd           # Start with lower priority
renice -n 5 -p PID       # Change priority
# -20 = highest, 19 = lowest. Only root can go below 0.
taskset -c 0,1 cmd       # Run on CPU 0 and 1 only
ionice -c 3 cmd          # Disk priority: idle
```

---

## Boot and shutdown

```bash
shutdown -r now          # Reboot
shutdown -h +10 "Maintenance"   # Halt in 10 min with a message
shutdown -h 23:00
shutdown -c              # Cancel
reboot ; poweroff
```

### Targets

```bash
systemctl get-default
systemctl set-default multi-user.target    # Text mode
systemctl set-default graphical.target     # Desktop
systemctl isolate rescue.target            # Switch now
```

| Target | Use |
|---|---|
| emergency.target | Read-only root, minimal shell |
| rescue.target | Single user, basic services |
| multi-user.target | Multi-user, no GUI |
| graphical.target | Multi-user + GUI |

### GRUB

```bash
update-grub                                  # Debian/Ubuntu: regenerate config
grub2-mkconfig -o /boot/grub2/grub.cfg       # RHEL
grubby --update-kernel=ALL --args="quiet"    # RHEL: change kernel parameters
cat /proc/cmdline                            # Parameters of the current boot
```

Rescue at boot: press `e` in GRUB, add `rd.break` (RHEL) or `init=/bin/bash` at the end of the `linux` line.

---

## systemd

```bash
systemctl start|stop|restart|reload SVC
systemctl status SVC
systemctl enable --now SVC     # Enable at boot + start now
systemctl disable --now SVC
systemctl mask SVC             # Block every start, even by dependencies
systemctl unmask SVC
systemctl is-active|is-enabled|is-failed SVC

systemctl list-units --type=service --state=running
systemctl --failed
systemctl list-unit-files --type=service

systemctl cat SVC              # Unit + drop-ins
systemctl edit SVC             # Create a drop-in override (recommended)
systemctl edit --full SVC      # Edit the full unit
systemctl daemon-reload        # REQUIRED after editing a unit file
```

### Unit file locations (highest priority first)

```
/etc/systemd/system/           # Your files and overrides
/run/systemd/system/           # Runtime
/usr/lib/systemd/system/       # Packages
```

### Unit template

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5
User=myapp
Environment="LOG_LEVEL=info"
EnvironmentFile=/etc/myapp/env
WorkingDirectory=/var/lib/myapp

[Install]
WantedBy=multi-user.target
```

### Timers (cron alternative)

```ini
# /etc/systemd/system/backup.timer
[Timer]
OnCalendar=*-*-* 02:30:00     # Every day at 02:30
Persistent=true               # Run later if the machine was off
Unit=backup.service

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/backup.service
[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

```bash
systemctl enable --now backup.timer
systemctl list-timers --all
```

---

## Logs

```bash
journalctl -e                  # Jump to the end
journalctl -f                  # Follow
journalctl -u nginx -f         # One service
journalctl -b ; journalctl -b -1   # Current boot, previous boot
journalctl -p err -b           # Errors since boot
journalctl --since "1 hour ago"
journalctl --since "2026-01-01" --until "2026-01-02"
journalctl _PID=1234 ; journalctl _UID=1000
journalctl --disk-usage
journalctl --vacuum-time=7d    # Keep 7 days (--vacuum-size=200M)
```

Priorities: 0 emerg, 1 alert, 2 crit, 3 err, 4 warning, 5 notice, 6 info, 7 debug.

| Debian/Ubuntu | RHEL | Content |
|---|---|---|
| /var/log/syslog | /var/log/messages | System |
| /var/log/auth.log | /var/log/secure | Authentication |
| /var/log/kern.log | — | Kernel |
| — | /var/log/cron | Cron |

```bash
logrotate -f /etc/logrotate.conf   # Force rotation (config: /etc/logrotate.d/)
```

Configure rsyslog and auditd: see [services.md](./services.md#logging--rsyslog).

---

## Resources

```bash
free -h                  # RAM + swap
vmstat 2                 # Memory, CPU, IO every 2 s
mpstat -P ALL 1          # Per CPU (sysstat)
iostat -xz 2             # Disk IO (sysstat)
iotop                    # Top for disk IO

df -hT                   # Disk usage + filesystem type
df -i                    # Inodes (often forgotten!)
du -sh /var/*            # Size of each folder
du -h --max-depth=1 /var | sort -h
ncdu /var                # Interactive
```

---

## Kernel

```bash
lsmod                    # Loaded modules
modinfo MOD
modprobe MOD             # Load (with dependencies)
modprobe -r MOD          # Unload

echo "MOD" > /etc/modules-load.d/MOD.conf              # Load at boot
echo "options MOD param=value" > /etc/modprobe.d/MOD.conf
echo "blacklist MOD" > /etc/modprobe.d/blacklist-MOD.conf
```

### sysctl

```bash
sysctl net.ipv4.ip_forward           # Read
sysctl -w net.ipv4.ip_forward=1      # Set (until reboot)
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-forward.conf   # Persistent
sysctl --system                      # Reload all config files
```

---

## Scheduling

### cron

```bash
crontab -e               # Edit your crontab
crontab -l               # List
crontab -e -u john       # Another user (root)
crontab -r               # Delete everything — careful
```

```
*  *  *  *  *  command
│  │  │  │  └─ day of week (0-7, 0 and 7 = Sunday)
│  │  │  └──── month (1-12)
│  │  └─────── day of month (1-31)
│  └────────── hour (0-23)
└───────────── minute (0-59)

30 2 * * 1      Monday 02:30
*/15 * * * *    Every 15 minutes
0 */4 * * *     Every 4 hours
15 11 * * 1,4   Monday and Thursday 11:15
0 0 1 * *       First day of the month
@reboot         At boot
```

| File | Username field? |
|---|---|
| `crontab -e` | **No** |
| `/etc/crontab`, `/etc/cron.d/*` | **Yes**: `30 2 * * * root /backup.sh` |

Scripts in `/etc/cron.daily/`, `weekly/`, `monthly/` run automatically (via anacron).

### at

```bash
echo "cmd" | at 23:00
at now + 2 hours         # Type commands, then Ctrl+D
atq ; atrm ID ; at -c ID
```

---

## Packages

### Debian / Ubuntu

```bash
apt update && apt upgrade
apt install -y PKG
apt remove PKG           # Keep config (purge = remove config too)
apt autoremove
apt search TEXT ; apt show PKG
apt list --installed | grep PKG
apt-cache policy PKG     # Available versions

dpkg -i file.deb
dpkg -L PKG              # Files of a package
dpkg -S /path/file       # Which package owns this file
```

### RHEL / Fedora

```bash
dnf upgrade
dnf install -y PKG ; dnf remove PKG
dnf search TEXT ; dnf info PKG
dnf provides /path/file  # Which package gives this file
dnf group list ; dnf group install "NAME"
dnf repolist
dnf history ; dnf history undo ID

rpm -qa | grep PKG
rpm -ql PKG              # Files of a package
rpm -qf /path/file       # Which package owns this file
rpm -ivh file.rpm
rpm -V PKG               # Check package files
```

---

## SELinux (RHEL)

```bash
getenforce ; sestatus
setenforce 0             # Permissive until reboot (1 = enforcing)
# Persistent: SELINUX= in /etc/selinux/config

ls -Z file ; ps -eZ      # Contexts
restorecon -Rv /var/www/                                 # Restore default contexts
semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?' # Persistent rule...
restorecon -Rv /web/                                     # ...then apply it
chcon -t httpd_sys_content_t file                        # Temporary (lost on relabel)

semanage port -l | grep http
semanage port -a -t http_port_t -p tcp 8080              # Allow a new port
getsebool -a | grep httpd
setsebool -P httpd_can_network_connect on                # -P = persistent

ausearch -m AVC -ts recent                               # Recent denials
```

---

## Shell tricks

```bash
alias ll='ls -la' ; unalias ll
history ; !! ; !42 ; !grep
# Ctrl+R = search history, Ctrl+L = clear
script /tmp/session.log  # Record a terminal session
```

---

## Pitfalls

- After editing a unit file: `systemctl daemon-reload`.
- `enable` ≠ `start`: use `enable --now`.
- `mask` blocks even starts by dependencies: check `is-enabled` if a service won't start.
- `reload` works only if the unit has `ExecReload=`; otherwise `restart`.
- `/etc/crontab` needs a username, `crontab -e` does not.
- cron has a minimal `PATH`: use absolute paths.
- `kill -9` gives no chance to clean up.
- After `modprobe`, add the module to `/etc/modules-load.d/` to keep it after reboot.
- SELinux can block a service silently: check `ausearch -m AVC`.
