# LFCS — Operation of Running Systems (26%)

## Process Monitoring

```bash
ps                          # Currently active processes (current shell)
ps aux                      # All processes, full details, all users
ps lax                      # All processes including their nice values
ps u 1                      # CPU and Memory usage of the process with PID 1
ps -ef                      # All processes, BSD-style full listing

top                         # Interactive real-time process viewer
htop                        # Enhanced interactive process viewer (if installed)

pgrep -a rpcbind            # Identify the PID of the process named rpcbind (with cmdline)
pgrep -u john               # PIDs of all processes owned by user john

lsof -p 1                   # List all files opened by process with PID 1
lsof -i :80                 # List processes using port 80
lsof /var/log/syslog        # Identify which process holds this file
```

## Process Control & Signals

```bash
kill <pid>                       # Send SIGTERM (graceful termination)
kill -9 <pid>                    # Send SIGKILL (force, no cleanup)
kill -SIGHUP <pid>               # Send SIGHUP — usually = reload config
killall <process_name>           # Kill ALL processes named process_name *use with caution*
pkill <process_name>             # Kill processes by name pattern

# Common signals: SIGTERM(15) graceful | SIGKILL(9) force | SIGHUP(1) reload | SIGINT(2) Ctrl+C
```

## Job Control & Background Execution

```bash
command &                                # Run command in background
jobs                                     # List background/stopped jobs
bg                                       # Resume stopped job in background
bg %1                                    # Resume job 1 in background
fg                                       # Bring most recent job to foreground
fg %2                                    # Bring job 2 to foreground

nohup <command> >> /var/log/cmd.log 2>&1 &
# Run command immune to terminal hangup; log stdout/stderr to file

sleep 10                                 # Sleep for 10 seconds (useful in scripts)
```

## Process Priority (nice / renice)

```bash
nice -n 10 command               # Launch command with niceness 10 (lower priority)
renice 9 -p <PID>                # Change niceness of running process to 9
renice -10 -p <PID>              # Increase priority (negative = higher; root only)
# Niceness range: -20 (highest priority) → 19 (lowest)

taskset -c 0,1 command           # Pin command to CPU cores 0 and 1
```

## Boot, Reboot & Shutdown

```bash
shutdown -h +10                  # Halt the system in 10 minutes
shutdown +120 "Maintenance"      # Schedule shutdown in 2 hours with message
shutdown -r now                  # Reboot immediately
shutdown -c                      # Cancel the scheduled shutdown
reboot                           # Reboot the system
halt                             # Halt the system immediately
poweroff                         # Power off the system
init <runlevel>                  # Switch to runlevel (legacy SysV)
```

## Boot Loader (GRUB)

```bash
grub-install /dev/vda            # Install GRUB to /dev/vda
update-grub                      # Regenerate /boot/grub/grub.cfg (Debian/Ubuntu)
grub2-mkconfig -o /boot/grub2/grub.cfg     # RHEL/CentOS equivalent

# Single-user / rescue: append `1` or `init=/bin/bash` to kernel cmdline (RHEL5)
# Or append `rd.break` or `init=/bin/bash` (RHEL7+)
```

## systemd Targets (runlevels)

```bash
systemctl get-default                       # Show current default boot target
systemctl set-default multi-user.target     # Set default target (no GUI)
systemctl set-default graphical.target      # Default with GUI
systemctl isolate rescue.target             # Switch to rescue mode now
systemctl isolate emergency.target          # Switch to emergency mode

# Common targets: poweroff | rescue | multi-user | graphical | reboot
```

## Logs & journald

```bash
journalctl                              # All logs since first boot
journalctl --boot 0                     # Logs from current boot
journalctl --boot -1                    # Logs from previous boot
journalctl -u nginx                     # Logs for a specific unit
journalctl -u nginx --since now -f      # Follow new logs for unit
journalctl --since "2024-01-01"         # Logs since a date
journalctl -p err                       # Errors and above only (priority filter)
journalctl --disk-usage                 # Show how much disk journal uses

# Traditional log files
/var/log/syslog          # Ubuntu/Debian system messages
/var/log/messages        # RHEL/CentOS system messages
/var/log/auth.log        # Authentication logs (Debian)
/var/log/secure          # Authentication logs (RHEL)

last                     # History of recent logins
```

## System Information

```bash
uname -a                  # Kernel name, version, hostname, arch
uname -r                  # Kernel release version only
hostname                  # Show machine hostname
arch                      # Show system architecture (32 or 64 bit)
hostnamectl               # Manage / query hostname (systemd)
hostnamectl set-hostname host01     # Change static hostname

uptime                    # System uptime + 1/5/15 min load averages
w                         # Who is logged on and what they are doing
who                       # Who is currently logged in
whoami                    # Current user name
id                        # UID, GID and groups of current user
users                     # Usernames of users currently logged in

date                      # Display date and time
cal                       # Calendar
dmesg                     # Kernel ring buffer (boot/hardware messages)
dmidecode                 # System hardware info (DMI/SMBIOS)
```

## Resource & Memory Usage

```bash
free                      # Memory and swap usage
free -m                   # In megabytes
free --mega               # In megabytes (SI units)
free -h                   # Human readable (G/M/K)
cat /proc/meminfo         # Detailed memory information

lscpu                     # Show CPU architecture information from sysfs
cat /proc/cpuinfo         # CPU details
nproc                     # Number of processing units available

iostat                    # CPU and I/O statistics
iostat -xz 2              # Extended stats every 2 seconds
vmstat 2                  # Virtual memory stats every 2 seconds
mpstat -P ALL             # Per-CPU usage stats
```

## Disk & Filesystem Usage

```bash
df                        # File system disk space usage
df -h                     # Human readable
df / -lostat              # Disk usage of root (RHEL/CentOS variation)
du -sh /bin/              # Total disk usage of /bin/ directory
du -h /var/log            # Disk usage tree, human readable
```

## Kernel & Modules

```bash
lsmod                              # List loaded kernel modules
modprobe <module>                  # Load kernel module + dependencies
modprobe -r <module>               # Unload module
modinfo <module>                   # Module information

sysctl -a                          # Display all kernel runtime parameters
sysctl -w kernel.modules_disabled=1     # Set kernel runtime parameter (temporary)
sysctl -p                          # Reload /etc/sysctl.conf
# Persist: write into /etc/sysctl.conf or /etc/sysctl.d/*.conf

cat /proc/cmdline                  # Kernel command line used at boot
rpm -q kernel                      # Show kernel version (RHEL)
uname -r                           # Running kernel version
```

## Scheduling Tasks

### cron
```bash
crontab -e                  # Edit current user's crontab
crontab -l                  # List current user's crontab (e.g. crontab for root)
crontab -r                  # Remove crontab
crontab -u john -l          # List crontab for another user (root only)

# Format:  min  hour  day  month  weekday  command
# Example: 30 2 * * 1 /backup.sh   → Mondays at 02:30
# System cron files: /etc/crontab  /etc/cron.d/  /etc/cron.{hourly,daily,weekly,monthly}/
```

### anacron
```bash
anacron -n -f               # Force anacron to rerun all jobs immediately
# Config: /etc/anacrontab — runs jobs missed while machine was off
```

### at
```bash
at 02:30 tomorrow           # Schedule one-shot job for 02:30 tomorrow (interactive)
at now + 2 hours            # Schedule 2 hours from now
atq                         # List currently scheduled at jobs for current user
atrm <jobid>                # Remove the at job with JOBID
```

## Package Management

### Debian / Ubuntu (apt / dpkg)
```bash
apt update                              # Refresh package index
apt upgrade                             # Upgrade installed packages
sudo apt update && sudo apt upgrade     # One-liner: refresh + upgrade
apt install <package>                   # Install package (e.g. apt install apache2)
apt remove <package>                    # Remove package, keep config
apt purge <package>                     # Remove package + configs
apt autoremove                          # Remove orphaned dependencies
apt search "apache http server"         # Search for packages
apt-cache policy <package>              # Available versions for package
apt list --upgradable                   # Packages with pending upgrades
apt install -f --reinstall <package>    # Repair / reinstall broken package

apt-get remove --auto-remove -y ziptool # Uninstall package + its dependencies non-interactively

dpkg -i package.deb                     # Install local .deb package
dpkg --search /bin/ls                   # Find which package owns /bin/ls
dpkg --listfiles coreutils | grep ^/bin # List files of package matching /bin
dpkg-query -L <package>                 # Files installed by package
dpkg-query -S <path>                    # Which package provides this file
```

### Snap
```bash
snap find <string>                      # Search for snap packages
sudo snap install <package>             # Install from Snap Store
```

### RHEL / CentOS (yum / dnf / rpm)
```bash
yum install <package>                   # Install package
yum update                              # Update all packages
yum info <package>                      # Package info
yum groupinstall "Group"                # Install a package group
yum repolist                            # List enabled repos
createrepo /repo/path                   # Build a local YUM repository

rpm -qa                                 # List all installed packages
rpm -qf /bin/ls                         # Which package owns /bin/ls
rpm -qi <package>                       # Package information
rpm -ql <package>                       # Files in package
rpm -Uvh package.rpm                    # Install or upgrade an RPM file
rpm -e <package>                        # Remove a package
```

## SELinux

```bash
getenforce                                          # Show current SELinux mode
sestatus                                            # Detailed SELinux status
setenforce 0                                        # Set Permissive (temporary)
setenforce 1                                        # Set Enforcing (temporary)
# Permanent change in /etc/selinux/config

ls -Z /bin/sudo                                     # Show SELinux label of file
ps -eZ                                              # Show SELinux contexts of processes
chcon -t httpd_sys_content_t /var/index.html        # Change SELinux context (temporary)
restorecon -R /var/log/                             # Restore default labels recursively
semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'   # Persistent label rule
semanage user -l                                    # List SELinux user mappings (e.g. staff_u)
```

## Diagnostics / Support

```bash
sosreport               # Collect diagnostic data (RHEL)
strace <command>        # Trace system calls of process
strace -p <PID>         # Attach strace to running PID
ltrace <command>        # Trace library calls
script /tmp/session.log # Record terminal session
```

## Background Tools / Misc

```bash
alias ll='ls -la'           # Create alias
history                     # Show command history
!!                          # Repeat last command
!<num>                      # Repeat command N from history
clear                       # Clear screen
exit                        # Log out / close session
```

## Common Pitfalls

```bash
# ALWAYS reload systemd after editing a unit file:
systemctl daemon-reload

# ALWAYS verify before destructive partition / RAID / LVM commands:
lsblk ; pvs ; vgs ; lvs ; cat /proc/mdstat

# Use absolute paths in cron jobs (PATH is minimal under cron)

# kill -9 should be a LAST resort — no cleanup, no signal handlers run
```
