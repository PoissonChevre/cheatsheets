ar# LFCS — Operation of Running Systems (26%)

> Boot, services, processes, logs, kernel, scheduling, packages, system info, troubleshooting.

---

## System Information

```bash
uname -a                             # Kernel + arch + hostname (everything)
uname -r                             # Kernel release ONLY
uname -m                             # Machine architecture (x86_64)
arch                                 # Architecture only

hostname                             # Show hostname
hostname -I                          # All IP addresses
hostnamectl                          # Hostname + OS + kernel info
hostnamectl set-hostname srv01       # Set hostname (persistent)

uptime                               # Uptime + load averages (1/5/15 min)
w                                    # Logged-in users + activity
who                                  # Logged-in users
whoami                               # Current user
id                                   # Current user UID/GID/groups
users                                # Just usernames

date                                 # Current date/time
date -u                              # UTC
cal                                  # Calendar

dmesg                                # Kernel ring buffer (boot/hardware)
dmesg -T                             # Human-readable timestamps
dmidecode                            # Hardware info (DMI/SMBIOS)
lscpu                                # CPU info
lsmem                                # Memory info
lspci                                # PCI devices
lsusb                                # USB devices
lshw                                 # All hardware (verbose)
```

---

## Process Monitoring

```bash
ps                                   # Current shell processes
ps aux                               # All processes, all users (BSD style)
ps -ef                               # All processes (System V style)
ps -ef --forest                      # Process tree
ps lax                               # Include nice values
ps u <PID>                           # Detailed info for one PID
ps -u username                       # Processes for a user

top                                  # Interactive monitor (q to quit)
htop                                 # Enhanced top (if installed)

pgrep nginx                          # Find PID by process name
pgrep -a nginx                       # + show full command line
pgrep -u john                        # All PIDs of user john

pidof nginx                          # PIDs of processes by name (older tool)

lsof -p <PID>                        # Files opened by PID
lsof -i :80                          # Processes using port 80
lsof /var/log/syslog                 # Process holding this file
lsof -u john                         # Files opened by user

fuser -vm /mnt/data                  # Processes using a mount point
fuser -k /mnt/data                   # Kill processes using mount point
```

---

## Process Control & Signals

```bash
kill <PID>                           # Send SIGTERM (graceful, signal 15)
kill -9 <PID>                        # Send SIGKILL (force, signal 9)
kill -SIGHUP <PID>                   # Reload config (signal 1)
kill -l                              # List all signals

killall nginx                        # Kill ALL processes by name (caution)
pkill -u john                        # Kill all processes of user john
pkill -f "pattern"                   # Kill by command line pattern
```

### Common signals

| Signal | Number | Purpose |
|---|---|---|
| SIGHUP | 1 | Reload config |
| SIGINT | 2 | Ctrl+C interrupt |
| SIGKILL | 9 | Force kill (no cleanup, last resort) |
| SIGTERM | 15 | Graceful termination (default) |
| SIGSTOP | 19 | Pause process |
| SIGCONT | 18 | Resume paused process |

**Pitfall:** `kill -9` skips signal handlers — no cleanup, no logs flushed. Use only as last resort.

---

## Job Control

```bash
command &                            # Run in background
jobs                                 # List background jobs
jobs -l                              # + show PIDs

bg                                   # Resume stopped job in background
bg %1                                # Resume job #1 in background
fg                                   # Bring last job to foreground
fg %2                                # Bring job #2 to foreground

# Ctrl+Z              suspend foreground job (then bg or fg)
# Ctrl+C              interrupt (SIGINT)
# Ctrl+\              quit (SIGQUIT)

nohup command &                      # Immune to terminal hangup
nohup command >> log.out 2>&1 &      # + log everything

disown %1                            # Remove job from shell tracking
sleep 60 &                           # Useful filler in scripts/tests
```

---

## Process Priority

```bash
nice -n 10 command                   # Start with niceness 10 (lower priority)
nice -n -5 command                   # Higher priority (root only)

renice 9 -p <PID>                    # Change niceness of running process
renice -10 -p <PID>                  # Higher priority (root only)

# Niceness range: -20 (highest priority) → 19 (lowest)

taskset -c 0,1 command               # Pin to CPU cores 0 and 1
taskset -p <PID>                     # Show CPU affinity of PID
ionice -c 3 command                  # I/O priority (3 = idle)
```

---

## Boot, Reboot, Shutdown

```bash
shutdown -h now                      # Halt now
shutdown -h +10                      # Halt in 10 minutes
shutdown -h 23:00                    # Halt at specific time
shutdown +120 "Maintenance"          # With broadcast message
shutdown -r now                      # Reboot now
shutdown -c                          # Cancel scheduled shutdown

reboot                               # Reboot
halt                                 # Halt (no power off)
poweroff                             # Power off
```

---

## systemd Targets (Runlevels)

```bash
systemctl get-default                            # Current default target
systemctl set-default multi-user.target          # CLI default (no GUI)
systemctl set-default graphical.target           # GUI default
systemctl isolate rescue.target                  # Switch to rescue NOW
systemctl isolate emergency.target               # Switch to emergency NOW
systemctl list-units --type=target               # All loaded targets
```

| Target | Purpose |
|---|---|
| poweroff.target | Halt |
| rescue.target | Single-user, basic services |
| multi-user.target | CLI multi-user (no GUI) |
| graphical.target | Multi-user + GUI |
| reboot.target | Reboot |
| emergency.target | Read-only root, minimal shell |

---

## Boot Loader (GRUB)

```bash
grub-install /dev/sda                # Install GRUB to disk

# Regenerate config:
update-grub                          # Debian/Ubuntu
grub2-mkconfig -o /boot/grub2/grub.cfg    # RHEL/CentOS

# Single-user / rescue at boot:
# Edit kernel cmdline, append:  rd.break  or  init=/bin/bash

# Kernel parameters used at last boot:
cat /proc/cmdline
```

---

## systemd — Service Management

### Lifecycle

```bash
systemctl start <svc>                # Start now
systemctl stop <svc>                 # Stop
systemctl restart <svc>              # Stop + start
systemctl reload <svc>               # Reload config (no restart, if supported)
systemctl status <svc>               # Detailed status + recent logs
systemctl kill <svc>                 # Send signal

systemctl enable <svc>               # Enable at boot
systemctl disable <svc>              # Disable at boot
systemctl enable --now <svc>         # Enable + start (single command)
systemctl disable --now <svc>        # Disable + stop
systemctl mask <svc>                 # Prevent ANY start (symlink to /dev/null)
systemctl unmask <svc>               # Reverse mask

systemctl is-active <svc>            # active / inactive
systemctl is-enabled <svc>           # enabled / disabled / masked
systemctl is-failed <svc>            # failed?
```

### Listing

```bash
systemctl list-units                         # Loaded units, current state
systemctl list-units --type=service          # Only services
systemctl list-units --state=running         # Only running
systemctl list-units --state=failed          # Only failed
systemctl --state failed                     # Same, shorter
systemctl list-unit-files                    # All installed + enable state
systemctl list-unit-files --type=service
```

### Editing Units

```bash
systemctl cat <svc>                  # Show full unit (incl. drop-ins)
systemctl edit <svc>                 # Edit drop-in override (recommended)
systemctl edit --full <svc>          # Edit full unit (lost on package upgrade)

systemctl daemon-reload              # MANDATORY after editing any unit file
systemctl daemon-reexec              # Re-exec systemd (rare)
```

### Unit File Locations (precedence top → bottom)

```
/etc/systemd/system/                 # Local admin overrides (highest)
/run/systemd/system/                 # Runtime
/usr/lib/systemd/system/             # Distribution defaults (RHEL)
/lib/systemd/system/                 # Distribution defaults (Debian)
```

### Unit File Skeleton

```ini
[Unit]
Description=My Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple                          # simple | forking | oneshot | notify | dbus
ExecStart=/usr/local/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5
User=myapp
Group=myapp
Environment="LOG_LEVEL=info"
EnvironmentFile=/etc/myapp/env
WorkingDirectory=/var/lib/myapp

[Install]
WantedBy=multi-user.target
```

**Pitfalls:**
- After editing any unit file → **always** `systemctl daemon-reload`
- `enable` ≠ `start`. Use `enable --now` to do both
- `mask` blocks even dependency-triggered starts; check `is-enabled` if a service won't start
- `reload` only works if `ExecReload=` is defined; otherwise use `restart`

---

## systemd Timers (cron alternative)

```bash
systemctl list-timers --all          # List all timers
systemctl status mytimer.timer       # One timer status
systemctl enable --now mytimer.timer # Enable + start
```

### Timer Unit Example

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily backup

[Timer]
OnCalendar=*-*-* 02:30:00            # Every day at 02:30
Persistent=true                      # Run if missed (e.g. shutdown at scheduled time)
Unit=backup.service

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/backup.service (the actual job)
[Unit]
Description=Backup script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

---

## Logs

### journalctl

```bash
journalctl                           # All logs since first boot
journalctl -e                        # Jump to end (most recent)
journalctl -f                        # Follow (like tail -f)
journalctl --boot 0                  # Current boot
journalctl --boot -1                 # Previous boot
journalctl -u nginx                  # One service
journalctl -u nginx -f               # Follow one service
journalctl -u nginx --since "1 hour ago"
journalctl --since "2024-01-01" --until "2024-01-02"
journalctl -p err                    # Errors and above
journalctl -p err -b                 # Errors since boot
journalctl --disk-usage              # Journal disk usage
journalctl --vacuum-size=200M        # Trim to 200M
journalctl --vacuum-time=7d          # Keep only last 7 days
journalctl _PID=1234                 # By PID
journalctl _UID=1000                 # By user ID
```

### Priority levels (numeric or name)

```
0 emerg    1 alert    2 crit     3 err
4 warning  5 notice   6 info     7 debug
```

### Traditional log files

```bash
/var/log/syslog                      # Debian/Ubuntu — system messages
/var/log/messages                    # RHEL/CentOS — system messages
/var/log/auth.log                    # Debian — authentication
/var/log/secure                      # RHEL — authentication
/var/log/kern.log                    # Kernel messages
/var/log/dmesg                       # Boot messages
/var/log/cron                        # Cron jobs (RHEL)
/var/log/mail.log                    # Mail server
/var/log/nginx/                      # Nginx logs
/var/log/apache2/ or httpd/          # Apache logs
/var/log/audit/audit.log             # auditd

last                                 # Recent login history
last -F                              # Full dates
lastb                                # Failed login attempts (root only)
lastlog                              # Last login per user
```

### Log rotation

```bash
logrotate -f /etc/logrotate.conf     # Force rotation
# Config: /etc/logrotate.conf + /etc/logrotate.d/*
```

---

## Resource Usage

### Memory

```bash
free                                 # Memory + swap
free -m                              # In MB
free -h                              # Human-readable
free -h --giga                       # In GB
cat /proc/meminfo                    # Detailed
vmstat 2                             # Virtual memory every 2s
```

### CPU

```bash
nproc                                # Number of CPUs
cat /proc/cpuinfo                    # CPU details
mpstat -P ALL 1                      # Per-CPU usage every 1s
top                                  # Interactive
htop                                 # Better top
```

### I/O

```bash
iostat                               # CPU + I/O stats
iostat -xz 2                         # Extended every 2s
iotop                                # Like top for I/O
```

### Disk

```bash
df                                   # Filesystem usage
df -h                                # Human-readable
df -hT                               # + filesystem types
df -i                                # Inode usage (often forgotten!)

du -sh dir/                          # Total size of directory
du -h --max-depth=1 /var             # Top-level breakdown
du -sh * | sort -h                   # Sort by size
ncdu /var                            # Interactive disk usage (if installed)
```

---

## Kernel & Modules

```bash
uname -r                             # Running kernel version
cat /proc/cmdline                    # Kernel boot parameters
cat /proc/version                    # Detailed kernel info

lsmod                                # Loaded modules
modprobe <module>                    # Load module + dependencies
modprobe -r <module>                 # Unload module
modprobe -n -v <module>              # Dry-run (show what would happen)
modinfo <module>                     # Module details

# Persistent module loading:
echo "module_name" > /etc/modules-load.d/mymodule.conf
echo "options module_name param=value" > /etc/modprobe.d/mymodule.conf

# Blacklist a module:
echo "blacklist module_name" > /etc/modprobe.d/blacklist.conf

# Kernel runtime parameters:
sysctl -a                            # Show all
sysctl net.ipv4.ip_forward           # Show one
sysctl -w net.ipv4.ip_forward=1      # Set temporarily
sysctl -p                            # Reload from /etc/sysctl.conf

# Persistent settings:
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-forward.conf
sysctl -p /etc/sysctl.d/99-forward.conf

# Quick read/write:
cat /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/ip_forward
```

---

## Task Scheduling

### cron

```bash
crontab -e                           # Edit current user crontab
crontab -l                           # List current user crontab
crontab -r                           # Remove crontab (careful!)
crontab -e -u john                   # Edit another user (root)
crontab -l -u john                   # List another user

# System cron files (always include username field!)
/etc/crontab
/etc/cron.d/
/etc/cron.hourly/
/etc/cron.daily/
/etc/cron.weekly/
/etc/cron.monthly/

# User crontabs stored at /var/spool/cron/crontabs/
```

### Cron syntax

```
* * * * *  command
│ │ │ │ └─ day of week  (0-7, 0 and 7 = Sunday, or sun/mon/tue...)
│ │ │ └─── month        (1-12, or jan/feb...)
│ │ └───── day of month (1-31)
│ └─────── hour         (0-23)
└───────── minute       (0-59)

# Examples:
30 2 * * 1        Mondays at 02:30
0 */4 * * *       Every 4 hours
*/15 * * * *      Every 15 minutes
15 11 * * 1,4     Mon and Thu at 11:15
0 0 1 * *         First of every month at midnight
@reboot script    Run once at boot
@daily script     Run once per day
```

### `/etc/crontab` vs `crontab -e`

```bash
# /etc/crontab — system-wide, REQUIRES username field:
30 2 * * * root /backup.sh

# crontab -e (user) — NO username field:
30 2 * * * /backup.sh
```

**Pitfall:** Migrating a job from `/etc/crontab` to a user crontab → **remove** the username field. Otherwise the username is interpreted as the command.

### at — one-shot scheduling

```bash
at 02:30 tomorrow                    # Interactive (Ctrl+D to finish)
at now + 2 hours
at 23:00
echo "command" | at 23:00
atq                                  # List scheduled jobs
atrm <jobid>                         # Remove job
at -c <jobid>                        # Show what job will run
```

### anacron (run jobs missed while powered off)

```bash
anacron -n -f                        # Force rerun of all jobs now
# Config: /etc/anacrontab
```

---

## Package Management

### Debian / Ubuntu (apt / dpkg)

```bash
apt update                           # Refresh package index
apt upgrade                          # Upgrade installed packages
apt full-upgrade                     # + remove obsolete deps
apt install pkg                      # Install
apt install -y pkg                   # Non-interactive
apt remove pkg                       # Remove (keep config)
apt purge pkg                        # Remove + config
apt autoremove                       # Remove orphaned deps
apt search "string"                  # Search packages
apt show pkg                         # Package info
apt list --installed                 # All installed
apt list --upgradable                # Pending upgrades

dpkg -i pkg.deb                      # Install local .deb
dpkg -r pkg                          # Remove
dpkg -l                              # List installed
dpkg -l | grep pkg                   # Search installed
dpkg -L pkg                          # Files installed by pkg
dpkg -S /path/to/file                # Which package owns this file
dpkg -s pkg                          # Package status

apt-cache policy pkg                 # Available versions
apt-cache depends pkg                # Dependencies
```

### RHEL / CentOS / Fedora (dnf / yum / rpm)

```bash
dnf install pkg                      # Install (yum on older)
dnf update                           # Update all
dnf remove pkg                       # Remove
dnf info pkg                         # Package info
dnf search "string"                  # Search
dnf list installed                   # Installed packages
dnf grouplist                        # Available groups
dnf groupinstall "Group Name"        # Install group
dnf repolist                         # Enabled repos
dnf history                          # Transaction history
dnf history undo <id>                # Rollback transaction

rpm -qa                              # All installed
rpm -qa | grep pkg                   # Search installed
rpm -qi pkg                          # Package info
rpm -ql pkg                          # Files in package
rpm -qf /path/to/file                # Which package owns
rpm -ivh pkg.rpm                     # Install local .rpm
rpm -Uvh pkg.rpm                     # Upgrade
rpm -e pkg                           # Remove
rpm -V pkg                           # Verify package integrity
```

### Snap (Ubuntu)

```bash
snap find string                     # Search
snap install pkg                     # Install
snap install pkg --classic           # With full system access
snap list                            # Installed snaps
snap remove pkg                      # Remove
```

---

## SELinux (RHEL/CentOS)

```bash
getenforce                           # Current mode
sestatus                             # Detailed status
setenforce 0                         # Permissive (temporary)
setenforce 1                         # Enforcing (temporary)
# Persistent: edit /etc/selinux/config

ls -Z file                           # Show SELinux context
ps -eZ                               # Process contexts
id -Z                                # User context

chcon -t httpd_sys_content_t /var/web/index.html    # Temporary context
restorecon -R /var/web/                              # Restore default
restorecon -Rv /var/web/                             # + verbose

semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'    # Persistent rule
semanage port -a -t http_port_t -p tcp 8080                  # Allow custom port
semanage user -l                                              # User mappings

getsebool -a                         # All booleans
getsebool -a | grep httpd            # Service-specific
setsebool -P httpd_can_network_connect on    # Persistent boolean

# Check denials:
ausearch -m AVC -ts recent
journalctl -t setroubleshoot
```

---

## Diagnostics & Tracing

```bash
strace command                       # Trace syscalls of new command
strace -p <PID>                      # Attach to running process
strace -f command                    # Follow forks
strace -c command                    # Summary statistics
strace -e trace=file command         # Filter file syscalls
strace -e trace=network command      # Filter network syscalls
strace -e kill -p <PID>              # Filter specific syscall

ltrace command                       # Trace library calls (libc)

sosreport                            # Collect diagnostic bundle (RHEL)
script /tmp/session.log              # Record terminal session
```

---

## Misc Useful

```bash
alias ll='ls -la'                    # Create alias
alias                                # List aliases
unalias ll                           # Remove alias

history                              # Command history
history 20                           # Last 20 commands
!!                                   # Repeat last command
!42                                  # Repeat command #42
!grep                                # Repeat last command starting with "grep"
Ctrl+R                               # Reverse search history

clear                                # Clear screen (or Ctrl+L)
exit                                 # Exit shell (or Ctrl+D)
```

---

## Pitfalls Summary

```bash
# 1. After editing ANY systemd unit:  systemctl daemon-reload
# 2. enable ≠ start. Use enable --now to do both.
# 3. mask = symlink to /dev/null. Service won't start even via dependencies.
# 4. systemctl reload only if ExecReload= is defined; else restart.
# 5. /etc/crontab needs a USERNAME field; user crontabs do NOT.
# 6. Cron PATH is minimal — use absolute paths in commands.
# 7. kill -9 = no cleanup, no signal handlers. Last resort only.
# 8. journalctl --vacuum-* trims journal (irreversible).
# 9. SELinux can silently block services — check audit.log if puzzled.
# 10. After modprobe, persist via /etc/modules-load.d/ for boot.
```
