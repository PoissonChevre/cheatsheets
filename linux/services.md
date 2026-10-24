# Services

Web servers, file sharing (NFS, Samba, SSHFS), DNS, mail, database, logging, audit, virtualization, build from source.

[← Back to index](./README.md) · systemd and SELinux: [system.md](./system.md) · SSH: [networking.md](./networking.md#ssh)

---

## Nginx

```bash
apt install nginx        # RHEL: dnf install nginx
systemctl enable --now nginx
nginx -t                 # Test config — ALWAYS before reload
nginx -T                 # Full effective config
nginx -t && systemctl reload nginx
```

| Path | Content |
|---|---|
| `/etc/nginx/nginx.conf` | Main config |
| `/etc/nginx/conf.d/*.conf` | Drop-ins (all distributions) |
| `/etc/nginx/sites-available/` + `sites-enabled/` | Virtual hosts (Debian) |
| `/var/log/nginx/` | access.log, error.log |

Enable a site (Debian): `ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/`

### Static site

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Reverse proxy

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

### Load balancer

```nginx
upstream backend {               # Your name — must match proxy_pass
    server 192.168.10.60:1111;
    server 192.168.10.60:2222;
    # least_conn;                # Least busy server
    # ip_hash;                   # Same client → same server
    # server x weight=3;         # More traffic
    # server x backup;           # Only if the others are down
}

server {
    listen 8000;
    location / {
        proxy_pass http://backend;
    }
}
```

---

## Apache

```bash
apt install apache2      # RHEL: dnf install httpd (service "httpd")
apachectl -t             # Test config
apachectl -S             # Show virtual hosts
systemctl reload apache2

a2ensite mysite ; a2dissite mysite    # Debian: sites
a2enmod ssl ; a2dismod ssl            # Debian: modules
```

| Debian | RHEL |
|---|---|
| `/etc/apache2/apache2.conf` | `/etc/httpd/conf/httpd.conf` |
| `/etc/apache2/sites-available/` | `/etc/httpd/conf.d/` |
| `/var/log/apache2/` | `/var/log/httpd/` |

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

## NFS

### Server

```bash
apt install nfs-kernel-server    # RHEL: dnf install nfs-utils
systemctl enable --now nfs-server
```

```
# /etc/exports — <directory>  <client>(<options>)   no space before "("!
/srv/share     192.168.1.0/24(rw,sync,no_subtree_check)
/srv/public    *(ro,sync)
/srv/secure    host1(rw,sync,no_root_squash)
```

```bash
exportfs -ra             # Apply /etc/exports (no restart needed)
exportfs -v              # Active exports
showmount -e localhost
```

| Option | Meaning |
|---|---|
| rw / ro | Read-write / read-only |
| sync / async | Safe writes / faster writes |
| no_subtree_check | Recommended |
| root_squash | Remote root becomes nobody (default) |
| no_root_squash | Remote root stays root (dangerous) |
| all_squash | Everybody becomes nobody |

### Client

```bash
apt install nfs-common           # RHEL: nfs-utils
showmount -e server
nc -zv server 2049               # Port open?
mount -t nfs server:/srv/share /mnt/share
# fstab: server:/srv/share  /mnt/share  nfs  defaults,_netdev  0 0
```

---

## Samba

```bash
apt install samba                # RHEL: dnf install samba (service "smb")
systemctl enable --now smbd
```

```ini
# /etc/samba/smb.conf
[global]
    workgroup = WORKGROUP

[share]
    path = /srv/share
    read only = no
    valid users = alice bob
    create mask = 0664
    directory mask = 0775
```

```bash
testparm                 # Test config
smbpasswd -a alice       # Samba password (the Linux user must exist)
pdbedit -L               # List Samba users
systemctl reload smbd
```

### Client

```bash
smbclient -L //server -U alice
smbclient //server/share -U alice
mount -t cifs //server/share /mnt -o credentials=/root/.smbcred   # Package cifs-utils
# /root/.smbcred (chmod 600):  username=alice  password=secret
```

---

## SSHFS

```bash
sshfs -o allow_other user@host:/remote/dir /mnt/remote   # allow_other: for all users
fusermount -u /mnt/remote
```

---

## DNS server (BIND)

```bash
apt install bind9        # RHEL: dnf install bind (service "named")
named-checkconf
named-checkzone example.com /var/named/example.com.zone
```

| Debian | RHEL |
|---|---|
| `/etc/bind/named.conf` | `/etc/named.conf` |
| `/var/lib/bind/` (zones) | `/var/named/` |

---

## Mail (Postfix)

```bash
systemctl status postfix
echo "body" | mail -s "subject" user    # Package mailutils or s-nail
mailq                    # Queue (same as postqueue -p)
postqueue -f             # Send the queue now
postsuper -d ALL         # Delete the queue
```

---

## Database (MariaDB)

```bash
systemctl enable --now mariadb
mariadb-secure-installation      # Older: mysql_secure_installation
mariadb -u root -p
```

```sql
CREATE DATABASE mydb;
CREATE USER 'user'@'localhost' IDENTIFIED BY 'pwd';
GRANT ALL ON mydb.* TO 'user'@'localhost';
```

---

## Logging — rsyslog

Config: `/etc/rsyslog.conf` + `/etc/rsyslog.d/*.conf`

```
# <facility>.<priority>                     <destination>
authpriv.*                                  /var/log/secure
mail.*                                      -/var/log/maillog
*.info;mail.none;authpriv.none              /var/log/messages
*.emerg                                     :omusrmsg:*

# Send to a remote server
*.* @192.168.1.10:514                       # UDP
*.* @@192.168.1.10:514                      # TCP
```

```
# Receive (server side)
module(load="imudp")
input(type="imudp" port="514")
```

```bash
systemctl restart rsyslog
logger "test message"    # Write a test line
```

---

## auditd

```bash
systemctl enable --now auditd
auditctl -w /etc/passwd -p wa -k passwd-watch    # Watch writes + attribute changes
auditctl -l              # List rules
auditctl -D              # Delete rules (runtime)

ausearch -k passwd-watch
ausearch -ua alice       # By user
aureport --summary ; aureport -au ; aureport -f
```

Persistent rules: write them in `/etc/audit/rules.d/*.rules`, then `augenrules --load`.

---

## Containers and VMs

Docker: see the [Docker cheat sheet](../docker/README.md). Exam example:

```bash
docker run -d --name web --memory 30m -p 1234:80 nginx:alpine
```

Podman (RHEL): same commands as Docker (`podman run`, `podman ps -a`...).

### libvirt / KVM

```bash
virsh list --all
virsh start VM ; virsh shutdown VM ; virsh destroy VM   # destroy = force off
virsh autostart VM
virsh dominfo VM
```

### LXD (Ubuntu)

```bash
lxd init --auto
lxc launch ubuntu:24.04 c1               # Container (add --vm for a VM)
lxc list
lxc exec c1 -- bash
lxc file push file.txt c1/root/ ; lxc file pull c1/root/file.txt ./
lxc stop c1 ; lxc delete c1
```

### Multipass (Ubuntu VMs)

```bash
multipass launch --name vm1
multipass list ; multipass shell vm1
multipass delete vm1 && multipass purge
```

---

## Build from source

```bash
tar xjf app-2.14.tar.bz2 && cd app-2.14
./configure --help                       # Options
./configure --prefix=/usr --without-ipv6 # Default prefix: /usr/local
make -j"$(nproc)"
sudo make install
which app && app --version
```

---

## Check a service

```bash
systemctl status SVC             # 1. Running?
ss -tulpn | grep PORT            # 2. Listening?
firewall-cmd --list-all          # 3. Firewall? (ufw status)
journalctl -u SVC -e             # 4. Logs?
```

| Service | Test config |
|---|---|
| Nginx | `nginx -t` |
| Apache | `apachectl -t` |
| SSH | `sshd -t` |
| Samba | `testparm` |
| BIND | `named-checkconf` |

---

## Pitfalls

- Test the config before reload: a bad config + restart = service down.
- `/etc/exports` changed → `exportfs -ra`, not a restart.
- `upstream` name and `proxy_pass http://name` must match.
- The service runs but nobody can connect: check the firewall and SELinux.
- `./configure` without `--prefix` installs in `/usr/local`.
