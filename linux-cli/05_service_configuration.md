# LFCS — Service Configuration (20%)

> Web servers (Apache/Nginx), SSH, NFS, Samba, mail/DNS/DB overview, logging, containers, build from source.

---

## systemd — Service Management Refresher

```bash
systemctl start <svc>                # Start now
systemctl stop <svc>
systemctl restart <svc>
systemctl reload <svc>               # Config reload (if ExecReload= defined)
systemctl status <svc>
systemctl enable --now <svc>         # Enable + start
systemctl disable --now <svc>        # Disable + stop
systemctl is-active <svc>
systemctl is-enabled <svc>
systemctl daemon-reload              # MANDATORY after editing unit files
```

See `02_operation_running_systems.md` for full systemd reference.

---

## Web Server — Nginx

### Install & start

```bash
sudo apt install nginx               # Debian/Ubuntu
sudo yum install nginx               # RHEL/CentOS

systemctl enable --now nginx
nginx -t                             # Test config syntax (CRITICAL!)
nginx -T                             # Show full effective config
systemctl reload nginx               # Apply config without dropping connections
```

### Config layout

```
/etc/nginx/nginx.conf                # Main config
/etc/nginx/sites-available/          # All vhosts (Debian)
/etc/nginx/sites-enabled/            # Enabled vhosts (symlinks)
/etc/nginx/conf.d/                   # Drop-in configs (RHEL & generic)
/var/log/nginx/access.log
/var/log/nginx/error.log
```

### Enable / disable a site (Debian style)

```bash
ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/    # Enable
rm /etc/nginx/sites-enabled/mysite                                   # Disable
nginx -t && systemctl reload nginx                                   # Apply
```

### Basic vhost

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    root /var/www/example.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/example.access.log;
    error_log  /var/log/nginx/example.error.log;
}
```

### Reverse Proxy (single backend)

```nginx
server {
    listen 8001;

    location / {
        proxy_pass http://192.168.10.60:2222/special;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

`proxy_pass URL` = forward incoming requests to URL.

### Load Balancer (multiple backends)

```nginx
upstream backend {
    # Default: Round Robin
    server 192.168.10.60:1111;
    server 192.168.10.60:2222;

    # Variants:
    # least_conn;                     # Send to least busy
    # ip_hash;                        # Sticky sessions by client IP
    # server x weight=3;              # Weighted distribution
    # server x backup;                # Only used if others down
}

server {
    listen 8000;

    location / {
        proxy_pass http://backend;     # MUST match upstream name
    }
}
```

**Pitfall:** `backend` is YOUR chosen upstream name. Both `upstream <name>` and `proxy_pass http://<name>` must match exactly.

### Critical reflex

```bash
nginx -t && systemctl reload nginx
# Always test BEFORE applying. Bad config + restart = service down.
```

---

## Web Server — Apache (httpd / apache2)

### Install & start

```bash
sudo apt install apache2             # Debian/Ubuntu
sudo yum install httpd               # RHEL/CentOS

systemctl enable --now apache2       # Ubuntu
systemctl enable --now httpd         # RHEL

apachectl -t                         # Test config (universal)
apache2ctl configtest                # Same (Debian)
apachectl -S                         # Show vhost config

systemctl reload apache2             # or httpd
```

### Config layout

```
# Debian/Ubuntu
/etc/apache2/apache2.conf
/etc/apache2/sites-available/
/etc/apache2/sites-enabled/
/etc/apache2/mods-available/
/etc/apache2/mods-enabled/

# RHEL/CentOS
/etc/httpd/conf/httpd.conf
/etc/httpd/conf.d/
/etc/httpd/conf.modules.d/
```

### Site / module management (Debian)

```bash
a2ensite mysite                      # Enable a vhost
a2dissite mysite                     # Disable a vhost
a2enmod ssl                          # Enable a module
a2dismod ssl                         # Disable a module
systemctl reload apache2
```

### Basic vhost

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/example.com

    <Directory /var/www/example.com>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/example_error.log
    CustomLog ${APACHE_LOG_DIR}/example_access.log combined
</VirtualHost>
```

---

## SSH Server (sshd)

```bash
systemctl enable --now sshd
sshd -t                              # Test config
sshd -T                              # Effective config
sshd -T -C user=alice                # Effective for specific user
systemctl reload sshd
```

### Key settings (`/etc/ssh/sshd_config`)

```
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers alice bob
AllowGroups admins
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
Banner /etc/ssh/banner

# Match blocks ALWAYS at the END of the file (or in 99-*.conf drop-in)
Match User alice
    PasswordAuthentication yes
    Banner /etc/ssh/banner

Match Group developers
    AllowAgentForwarding yes
```

### Drop-in configs

```
/etc/ssh/sshd_config.d/*.conf        # Loaded in lexical order
# Use 99-*.conf for files containing Match blocks
```

**Critical pitfall:** Once a `Match` block starts, all following lines are part of it until another `Match` or end of file. Misplaced settings = unintended scope.

---

## NFS Server

```bash
sudo apt install nfs-kernel-server   # Debian/Ubuntu
sudo yum install nfs-utils           # RHEL/CentOS

systemctl enable --now nfs-server
```

### `/etc/exports` syntax

```
# Format:  <directory>  <client>(options)

/srv/share     192.168.1.0/24(rw,sync,no_subtree_check)
/srv/public    *(ro,sync)
/srv/secure    host1(rw,sync,no_root_squash)
/data          *.example.com(rw,sync)
```

### Common options

| Option | Meaning |
|---|---|
| rw / ro | Read-write / read-only |
| sync / async | Sync writes (safer) / async (faster) |
| no_subtree_check | Recommended (avoids overhead) |
| root_squash | Remote root → nobody (default, safer) |
| no_root_squash | Remote root keeps root powers (dangerous) |
| all_squash | Map all users to nobody |

### Apply changes

```bash
exportfs -ra                         # Re-export everything
exportfs -a                          # Export all
exportfs -v                          # List active exports
exportfs -u 192.168.1.0/24:/srv/share    # Unexport specific
showmount -e localhost               # Show what we export
showmount -e <server>                # Show what server exports
```

**Pitfall:** After modifying `/etc/exports`, run `exportfs -ra`, NOT `systemctl restart nfs`.

### Client side

```bash
sudo apt install nfs-common          # Debian/Ubuntu
mkdir /mnt/share
mount -t nfs server:/srv/share /mnt/share

# Test before mounting
nc -zv server 2049

# Persistent in /etc/fstab:
# server:/srv/share  /mnt/share  nfs  defaults,_netdev  0  0
```

---

## File Sharing — Samba (SMB/CIFS)

```bash
sudo apt install samba
systemctl enable --now smbd nmbd
```

### Config (`/etc/samba/smb.conf`)

```ini
[global]
    workgroup = WORKGROUP
    server string = Samba Server

[share]
    path = /srv/share
    read only = no
    valid users = alice bob
    create mask = 0664
    directory mask = 0775
```

### Manage users / verify

```bash
testparm                             # Validate smb.conf
smbpasswd -a alice                   # Add Samba user (must already exist as Linux user)
smbpasswd -x alice                   # Delete Samba user
pdbedit -L                           # List Samba users

systemctl reload smbd
```

### Client

```bash
smbclient -L //server -U alice       # List shares
smbclient //server/share -U alice    # Interactive
mount -t cifs //server/share /mnt -o user=alice,password=pwd
mount -t cifs //server/share /mnt -o credentials=/root/smb.creds

# /root/smb.creds:
# username=alice
# password=secret
```

---

## DNS Server (BIND)

```bash
# Install
sudo apt install bind9 bind9utils    # Debian
sudo yum install bind                # RHEL

# Service
systemctl enable --now named         # RHEL: named
systemctl enable --now bind9         # Debian: bind9

# Validate
named-checkconf                      # Main config
named-checkzone example.com /var/named/example.com.zone

# Config locations
/etc/named.conf                      # RHEL
/etc/bind/named.conf                 # Debian
/var/named/                          # RHEL zones
/var/lib/bind/                       # Debian zones
```

---

## Mail (overview)

```bash
systemctl status postfix
mail user                            # Send mail interactively
mail -s "subject" user < body.txt    # Send with subject

# Queue
mailq                                # Show queue
postqueue -p                         # Same
postqueue -f                         # Flush queue
postsuper -d ALL                     # Delete all queued mail
```

---

## Database (MariaDB / MySQL — overview)

```bash
systemctl enable --now mariadb       # or mysql
mysql_secure_installation            # Initial hardening
mysql -u root -p                     # Open client

# Inside mysql shell:
# CREATE DATABASE mydb;
# CREATE USER 'user'@'localhost' IDENTIFIED BY 'pwd';
# GRANT ALL ON mydb.* TO 'user'@'localhost';
# FLUSH PRIVILEGES;
```

---

## Logging Service — rsyslog

```bash
systemctl status rsyslog
# Config: /etc/rsyslog.conf  +  /etc/rsyslog.d/*.conf
```

### Common selectors

```
*.info;mail.none;authpriv.none;cron.none    /var/log/messages
authpriv.*                                  /var/log/secure
mail.*                                      -/var/log/maillog
cron.*                                      /var/log/cron
*.emerg                                     :omusrmsg:*
```

### Remote logging

```
# Sender side
*.* @192.168.1.10:514                       # UDP
*.* @@192.168.1.10:514                      # TCP

# Receiver side (uncomment in rsyslog.conf)
# module(load="imudp")
# input(type="imudp" port="514")
```

---

## auditd (Security Auditing)

```bash
systemctl enable --now auditd

auditctl -l                          # List active rules
auditctl -w /etc/passwd -p wa -k passwd-watch   # Watch writes/attribute changes
auditctl -w /etc/shadow -p rwa -k shadow-watch
auditctl -D                          # Delete all rules

ausearch -k passwd-watch             # Search by key
ausearch -m AVC -ts recent           # Recent SELinux denials
ausearch -ua alice                   # By user

aureport --summary                   # Summary
aureport -au                         # Authentication report
aureport -f                          # File access report

# Persistent rules
/etc/audit/audit.rules
/etc/audit/auditd.conf
```

---

## Container & Virtualization

### Docker

```bash
systemctl enable --now docker

docker ps                            # Running containers
docker ps -a                         # All containers
docker images                        # Images
docker logs <container>              # Logs
docker logs -f <container>           # Follow logs
docker exec -it <container> bash     # Shell into container
docker inspect <container>           # Full JSON info

# Run
docker run -d --name web nginx:alpine
docker run -d --name web -p 8080:80 nginx:alpine            # Port mapping
docker run -d --name web --memory 30m nginx:alpine          # Memory limit
docker run -d --name web -v /data:/srv nginx:alpine         # Volume mount
docker run --rm -it ubuntu bash                              # Interactive, auto-remove

docker stop <container>
docker start <container>
docker rm <container>                # Remove stopped
docker rm -f <container>             # Force remove running
docker rmi <image>                   # Remove image
```

### Podman (RHEL preferred)

```bash
podman ps -a
podman images
podman run ...                       # Same syntax as docker
```

### libvirt / KVM

```bash
systemctl enable --now libvirtd
virsh list --all                     # All VMs
virsh start <vm>
virsh shutdown <vm>
virsh destroy <vm>                   # Force stop
virsh autostart <vm>
```

### LXD / LXC (Ubuntu)

```bash
lxd init                             # First-time setup
lxc launch ubuntu:22.04 mycontainer
lxc list
lxc exec mycontainer bash            # Shell inside
lxc file push file.txt mycontainer/path/
lxc file pull mycontainer/path/file.txt ./
lxc stop mycontainer
lxc delete mycontainer

# Launch as VM (not container)
lxc launch images:ubuntu/22.04 myvm --vm
```

### Multipass (Ubuntu VMs)

```bash
sudo snap install multipass
multipass launch --name myvm
multipass list
multipass shell myvm
multipass stop myvm
multipass delete myvm
multipass purge                      # Permanently remove deleted VMs
```

### Kubernetes — MicroK8s (Ubuntu)

```bash
sudo snap install microk8s --classic
microk8s status --wait-ready
microk8s enable dns ingress storage
microk8s kubectl get nodes
microk8s kubectl get pods -A
```

---

## Build & Install from Source

Standard process:

```bash
# 1. Extract
tar xjf links-2.14.tar.bz2
cd links-2.14

# 2. Configure (see all options)
./configure --help
./configure --prefix=/usr --without-ipv6
# --prefix    install location (binary → $prefix/bin)
# --enable-X  / --disable-X
# --with-X    / --without-X

# 3. Compile
make
make -j$(nproc)                      # Parallel build (faster)

# 4. Install (often needs root)
sudo make install

# 5. Verify
which mybinary
mybinary --version
```

**Pitfall:** Without `--prefix`, default install location is usually `/usr/local/`. Use `--prefix=/usr` to install in `/usr/bin` instead.

---

## SELinux Service Contexts

```bash
ls -Z /var/www/html/                          # SELinux labels on files
ps -eZ | grep nginx                           # Process contexts

chcon -t httpd_sys_content_t /var/web/index.html       # Temporary label
restorecon -R /var/web/                                 # Restore default labels

semanage fcontext -a -t httpd_sys_content_t '/web(/.*)?'    # Persistent rule
restorecon -Rv /web/                                          # Apply

semanage port -a -t http_port_t -p tcp 8080                 # Allow Apache on 8080
semanage port -l | grep http                                # List HTTP ports

getsebool -a | grep httpd                                   # Booleans for httpd
setsebool -P httpd_can_network_connect on                   # Persistent boolean
```

---

## Service Configuration Quick Verify

```bash
# 1. Service running?
systemctl status <svc>

# 2. Listening on expected port?
ss -tulpn | grep <port>

# 3. Firewall allowing?
ufw status               # or firewall-cmd --list-all

# 4. Config syntax valid?
nginx -t                 # Nginx
apachectl -t             # Apache
sshd -t                  # SSH
testparm                 # Samba
named-checkconf          # BIND

# 5. Logs?
journalctl -u <svc> -f
tail -f /var/log/<svc>/error.log
```

---

## Pitfalls Summary

```bash
# 1. ALWAYS test config before reload/restart:
#    nginx -t   apachectl -t   sshd -t   testparm   named-checkconf

# 2. After editing systemd unit:  systemctl daemon-reload

# 3. systemctl edit creates a drop-in override.
#    --full edits the full unit (lost on package upgrade!).

# 4. mask = symlink to /dev/null. Service can't start.

# 5. reload only works if ExecReload= is defined; otherwise restart.

# 6. After /etc/exports change → exportfs -ra (NOT systemctl restart).

# 7. SELinux can silently block services.
#    Check /var/log/audit/audit.log + ausearch -m AVC -ts recent.

# 8. Match blocks in sshd_config must be at END (or 99-*.conf).

# 9. Don't forget firewall — service runs but port is blocked.
#    Test with ss -tulpn (running) AND ufw/firewall-cmd.

# 10. Build from source: --prefix=/usr puts binary in /usr/bin.
#     Without --prefix, default is /usr/local/bin.
```
