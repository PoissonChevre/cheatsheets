# LFCS — Service Configuration (20%)

## systemd — Service Lifecycle

```bash
systemctl start <service>            # Start a service now
systemctl stop <service>             # Stop a running service
systemctl restart <service>          # Stop + start
systemctl reload <service>           # Reload config without restart (if supported)
systemctl status <service>           # Detailed service status (active, PID, recent logs)

systemctl enable <service>           # Enable service at boot
systemctl disable <service>          # Disable service at boot
systemctl enable --now <service>     # Enable + start in one command
systemctl disable --now <service>    # Disable + stop in one command
systemctl mask <service>             # Prevent service from being started (manually or by dep)
systemctl unmask <service>           # Reverse mask

systemctl is-active <service>        # Is service running? (active/inactive)
systemctl is-enabled <service>       # Is service enabled at boot?
systemctl is-failed <service>        # Has service failed?
```

## Listing Services & Units

```bash
systemctl list-units                       # All loaded units (current state)
systemctl list-units --type=service        # All service units
systemctl list-units --state=running       # All running units
systemctl --state running                  # Same — short form (running)
systemctl list-units --state=failed        # All failed units
systemctl --state failed                   # Get all failing services
systemctl list-unit-files                  # All installed units + enable state
systemctl list-unit-files --type=service   # Services and their enable state

# Legacy SysV (RHEL 5/6)
service --status-all              # Status of every service
chkconfig --list                  # Runlevel enable status (RHEL 5)
chkconfig <name> on               # Enable service at boot (RHEL 5/6)
chkconfig <name> off              # Disable
```

## Editing & Reloading Unit Files

```bash
systemctl cat <service>            # Show full unit file (incl. drop-ins / overrides)
systemctl edit <service>           # Edit drop-in override (creates *.d/override.conf)
systemctl edit --full <service>    # Edit the full unit file (avoid — package upgrade overwrites)

systemctl daemon-reload            # MUST RUN after editing any unit file
systemctl daemon-reexec            # Re-exec systemd itself (rarely needed)

# Unit file locations (precedence top → bottom)
/etc/systemd/system/               # Local admin overrides (highest)
/run/systemd/system/               # Runtime
/lib/systemd/system/               # Distribution defaults (Debian)
/usr/lib/systemd/system/           # Distribution defaults (RHEL)
```

## Unit File Skeleton

```ini
[Unit]
Description=My App
After=network-online.target
Wants=network-online.target

[Service]
Type=simple                              # simple | forking | oneshot | notify | dbus
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
WantedBy=multi-user.target               # When `systemctl enable` is run
```

## systemd Timers (cron alternative)

```bash
systemctl list-timers --all                 # List all timers
systemctl status <name>.timer               # Inspect one timer
systemctl enable --now <name>.timer         # Enable + start a timer

# Timer unit example: /etc/systemd/system/backup.timer
# [Timer]
# OnCalendar=*-*-* 02:30:00     # Daily 02:30
# Persistent=true
# Unit=backup.service
#
# [Install]
# WantedBy=timers.target
```

## Logging & Diagnosis

```bash
journalctl                                  # All logs since first boot
journalctl --boot 0                         # Logs from current boot
journalctl -u nginx                         # Logs for specific unit
journalctl -u nginx --since now -f          # Follow new logs for unit
journalctl -u nginx --since "1 hour ago"    # Time-bounded
journalctl -p err -b                        # Errors only since boot
journalctl --vacuum-size=200M               # Trim journal disk usage
```

## Web Server — Apache (httpd / apache2)

```bash
sudo apt install apache2                    # Install on Debian/Ubuntu
sudo yum install httpd                      # Install on RHEL/CentOS

systemctl enable --now apache2              # Ubuntu
systemctl enable --now httpd                # RHEL

# Config
/etc/apache2/                               # Debian/Ubuntu
/etc/httpd/                                 # RHEL/CentOS
apache2ctl configtest                       # Validate config (Debian)
apachectl -t                                # Validate config (universal)
a2ensite <site>     /  a2dissite <site>     # Enable/disable vhost (Debian)
a2enmod <mod>       /  a2dismod <mod>       # Enable/disable module (Debian)
```

## Web Server — Nginx

```bash
sudo apt install nginx
systemctl enable --now nginx
nginx -t                                    # Test config syntax
systemctl reload nginx                      # Apply config without dropping connections

# Config
/etc/nginx/nginx.conf                       # Main config
/etc/nginx/sites-available/                 # All vhosts (Debian)
/etc/nginx/sites-enabled/                   # Enabled vhosts (symlinks)
/etc/nginx/conf.d/                          # Drop-in configs
```

## SSH Server (sshd)

```bash
systemctl enable --now sshd
sshd -t                                     # Test sshd config
systemctl reload sshd                       # Reload config without dropping sessions

# Key options in /etc/ssh/sshd_config
# Port 22
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# AllowUsers alice bob
```

## File Sharing — NFS Server

```bash
sudo apt install nfs-kernel-server          # Debian/Ubuntu
sudo yum install nfs-utils                  # RHEL/CentOS

# /etc/exports format:
# <directory>   <client>(<options>)
# /srv/share    192.168.1.0/24(rw,sync,no_subtree_check)
# /srv/public   *(ro,sync)

exportfs -r                                 # Reexport /etc/exports configuration
exportfs -a                                 # Export all
exportfs -v                                 # List active exports
showmount -e localhost                      # Show what we are exporting
showmount -e <server>                       # Show what a remote NFS server exports

systemctl enable --now nfs-server           # Start NFS server
```

### NFS Client

```bash
sudo apt install nfs-common                 # Debian/Ubuntu
mount -t nfs server:/srv/share /mnt         # Mount NFS share
# Persistent in /etc/fstab:
# server:/srv/share  /mnt/share  nfs  defaults  0  0
```

## File Sharing — Samba (SMB/CIFS)

```bash
sudo apt install samba                      # Install Samba
systemctl enable --now smbd nmbd            # Start services

# Config: /etc/samba/smb.conf
# [share]
#   path = /srv/share
#   read only = no
#   valid users = alice bob

testparm                                    # Validate smb.conf
smbpasswd -a alice                          # Add Samba user
smbclient -L //server -U alice              # List shares on server
mount -t cifs //server/share /mnt -o user=alice
```

## Mail / DNS / Database (overview)

```bash
# Mail (overview only)
systemctl status postfix
mail user                                   # Send mail interactively
mail -s "subject" user < body.txt           # Send with subject

# DNS server (BIND)
systemctl enable --now named                # RHEL: named  | Debian: bind9
named-checkconf                             # Validate config
named-checkzone <zone> <file>               # Validate zone file

# MariaDB / MySQL
systemctl enable --now mariadb
mysql_secure_installation                   # Initial hardening
mysql -u root -p                            # Open client
```

## Logging Service (rsyslog)

```bash
systemctl status rsyslog
# Config: /etc/rsyslog.conf  +  /etc/rsyslog.d/*.conf

# Common selectors in rsyslog.conf:
# *.info;mail.none;authpriv.none;cron.none    /var/log/messages
# authpriv.*                                  /var/log/secure
# mail.*                                      -/var/log/maillog
# cron.*                                      /var/log/cron
```

## Auditd (security auditing)

```bash
systemctl enable --now auditd
auditctl -l                                 # List active audit rules
auditctl -w /etc/passwd -p wa -k passwd-watch    # Watch for writes/attribute changes
ausearch -k passwd-watch                    # Search by key
aureport --summary                          # Audit summary report
# Module entries:
#   add audit=1 to kernel cmdline
#   /etc/audit/auditd.conf
#   /etc/audit/audit.rules
#   /etc/pam.d/system-auth → enable pam_tty_audit
```

## Container & Virtualization Services (overview)

```bash
# Docker
systemctl enable --now docker
docker ps -a                                # All containers
docker images                               # Images
docker logs <container>                     # Container logs

# Podman (RHEL preferred)
podman ps -a
podman images

# libvirt / KVM
systemctl enable --now libvirtd
virsh list --all                            # All VMs
virsh start <vm>  /  virsh shutdown <vm>

# LXD / LXC containers (Ubuntu)
lxd init
lxc launch ubuntu:18.04 <container_name>
lxc launch images/centos/8/amd64 <container_name>
lxc exec <name> bash                        # Shell inside container
lxc file push <file> <container>:/<path>    # Push file into container
lxc file pull <container>:/<file> <dest>    # Pull file from container
lxc launch images:ubuntu/20.04 <vm_name> --vm    # Launch as full VM

# Multipass (Ubuntu VMs)
sudo snap install multipass
multipass launch <image> --name <vm>        # Launch VM (omit image = latest LTS)
multipass find                              # List available images
multipass list                              # List existing VMs
multipass shell <vm>                        # Shell inside VM

# Kubernetes — MicroK8s (Ubuntu)
sudo snap install microk8s --classic
microk8s.status --wait-ready
microk8s enable <addon>                     # Enable add-ons (dns, ingress...)
microk8s.kubectl get nodes
microk8s.kubectl get services
```

## SELinux Service Contexts

```bash
ls -Z /var/www/html/                                # Show SELinux labels
ps -eZ | grep nginx                                 # Show context of running service
chcon -t httpd_sys_content_t /var/index.html       # Temporary label change
restorecon -R /var/www/html/                        # Restore default labels (recursive)
semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'   # Persistent rule
semanage port -a -t http_port_t -p tcp 8080         # Allow Apache to bind port 8080
getsebool -a | grep httpd                           # SELinux booleans for Apache
setsebool -P httpd_can_network_connect on           # Persistent boolean change
```

## Common Pitfalls (Pièges LFCS)

```bash
# 1. After editing ANY unit file → systemctl daemon-reload
#    Otherwise systemd uses the cached old version.

# 2. systemctl edit <svc>  creates an OVERRIDE in /etc/systemd/system/<svc>.d/.
#    DO NOT use --full unless you understand it gets overwritten on package upgrade.

# 3. systemctl enable ≠ start. Enable = at boot. Start = now.
#    Use `enable --now` to do both.

# 4. systemctl mask <svc> creates a symlink to /dev/null — service CANNOT start
#    (even by dependency). Forgot why a service won't start? Check `is-enabled` for "masked".

# 5. systemctl reload only works if the unit defines ExecReload=.
#    Otherwise use restart.

# 6. After modifying /etc/exports → `exportfs -r` (NOT systemctl restart nfs).

# 7. SELinux blocks services silently. Check /var/log/audit/audit.log + ausearch
#    when a service starts but can't read/write its files.

# 8. Apache / Nginx config errors: ALWAYS validate before reload
#    `apachectl -t` and `nginx -t` — bad config + restart = service down.

# 9. Don't forget: ufw / firewalld may block your service even if it runs.
#    Test with `ss -tulpn` (running + listening) AND firewall.
```
