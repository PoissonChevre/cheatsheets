# SELinux

Modes, contexts, file labels, ports, booleans, troubleshooting, common scenarios. Default on RHEL, CentOS, Rocky, Alma and Fedora.

[← Back to index](./README.md) · Root password reset and relabel at boot: [grub.md](./grub.md#reset-the-root-password-rhel--centos--rocky--alma)

---

## How it works

SELinux adds a second check **after** normal permissions (chmod, chown, ACL). Both must say yes.

- Every process and every file has a **context** (label).
- The policy says which process **type** can do what on which file or port **type**.
- Everything not allowed is denied, and logged as an **AVC denial**.

Example: the Apache process runs as `httpd_t`. It can read files labeled `httpd_sys_content_t`, but not `user_home_t`. Even with `chmod 777`, Apache cannot read a file with the wrong label.

### Context

```
system_u:object_r:httpd_sys_content_t:s0
   │         │            │            └─ level (MLS/MCS)
   │         │            └─ TYPE — what matters 99% of the time
   │         └─ role
   └─ SELinux user
```

```bash
ls -Z /var/www/html          # Files
ps -eZ | grep httpd          # Processes (or ps auxZ)
id -Z                        # My context
ss -tlpZ                     # Listening sockets + process context
```

---

## Modes

| Mode | Policy loaded | Denies | Logs |
|---|---|---|---|
| **enforcing** | Yes | Yes | Yes |
| **permissive** | Yes | No | Yes (to test what would be denied) |
| **disabled** | No | No | No |

```bash
getenforce
sestatus                     # Mode, policy, config file mode
setenforce 0                 # Permissive until reboot
setenforce 1                 # Enforcing
```

```bash
# /etc/selinux/config — after reboot
SELINUX=enforcing            # enforcing | permissive | disabled
SELINUXTYPE=targeted
```

- Going from **disabled** to enabled needs a full relabel (`touch /.autorelabel`, reboot). Files created while disabled have no label.
- RHEL 9: to really disable, use `grubby --update-kernel ALL --args selinux=0`. Prefer permissive.
- One domain only in permissive: `semanage permissive -a httpd_t` (`-d` to remove).

---

## File labels

### Where labels come from

- A **new file** gets the label of its parent directory.
- `cp` creates a new file → label of the destination folder.
- `mv` keeps the **old** label → frequent problem (file moved from `/home` to `/var/www`).
- The policy has a list of **default labels** by path: `semanage fcontext -l`.

```bash
matchpathcon /var/www/html/index.html    # Default label for this path
semanage fcontext -l | grep /var/www     # Rules for a path
semanage fcontext -l -C                  # Only your custom rules
```

### Fix labels

```bash
restorecon -Rv /var/www/                 # Reset to the default label (-n = dry run)
```

### Change the default label (persistent)

```bash
semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'   # Add a rule
restorecon -Rv /srv/web                                         # Apply it

semanage fcontext -a -e /var/www /srv/web    # /srv/web = same labels as /var/www
semanage fcontext -m -t TYPE '/path(/.*)?'   # Modify a rule
semanage fcontext -d '/srv/web(/.*)?'        # Delete a rule
```

`'(/.*)?'` = the folder and everything inside it.

### Temporary change

```bash
chcon -t httpd_sys_content_t file            # Lost at next restorecon or relabel
chcon -R --reference=/var/www/html /srv/web  # Copy the label of another path
```

Use `semanage fcontext` + `restorecon`, not `chcon`, when it must last.

### Full relabel

```bash
touch /.autorelabel && reboot                # Or: fixfiles -F onboot
```

### Common file types

| Type | Use |
|---|---|
| `httpd_sys_content_t` | Web content, read-only |
| `httpd_sys_rw_content_t` | Web content the app can write (uploads, cache) |
| `httpd_log_t` | Web logs |
| `public_content_t` | Read by Apache, FTP, Samba, rsync |
| `public_content_rw_t` | Same, writable (needs a boolean) |
| `samba_share_t` | Samba shares |
| `nfs_t` | NFS mounts |
| `user_home_t` | Files in home directories |
| `container_file_t` | Volumes for Podman/Docker |
| `var_log_t` | Logs |

---

## Ports

A service can only listen on ports with the right type.

```bash
semanage port -l | grep -w http_port_t       # 80, 443, 8008, 8009, 8443...
semanage port -a -t http_port_t -p tcp 8888  # Add a port
semanage port -m -t http_port_t -p tcp 8080  # Port already has a type (http_cache_port_t) → -m
semanage port -d -t http_port_t -p tcp 8888  # Remove
semanage port -l -C                          # Only your changes
```

| Service | Port type |
|---|---|
| Apache, Nginx | `http_port_t` |
| SSH | `ssh_port_t` |
| MariaDB/MySQL | `mysqld_port_t` |
| PostgreSQL | `postgresql_port_t` |
| DNS | `dns_port_t` |

---

## Booleans

On/off switches in the policy for common needs.

```bash
getsebool -a | grep httpd
semanage boolean -l | grep httpd             # With a description
setsebool httpd_can_network_connect on       # Until reboot
setsebool -P httpd_can_network_connect on    # Persistent (-P)
semanage boolean -l -C                       # Only changed booleans
```

| Boolean | Allows |
|---|---|
| `httpd_can_network_connect` | Apache/Nginx to connect to the network (reverse proxy, APIs) |
| `httpd_can_network_connect_db` | Apache to connect to a database |
| `httpd_enable_homedirs` | Apache to read `~/public_html` |
| `httpd_use_nfs` / `httpd_use_cifs` | Apache to serve NFS / Samba mounts |
| `httpd_execmem` | Apps that need executable memory |
| `samba_enable_home_dirs` | Samba to share home directories |
| `samba_export_all_ro` / `_rw` | Samba to share any folder |
| `use_nfs_home_dirs` | Homes on NFS |
| `ftpd_full_access` | FTP to all files |
| `container_manage_cgroup` | Containers running systemd |

---

## Troubleshooting

### Method

1. Something fails with "Permission denied" but permissions look right → think SELinux.
2. Test: `setenforce 0`, try again. Works now? It's SELinux. **Then `setenforce 1`.**
3. Read the denial.
4. Fix in this order: **label** → **port** → **boolean** → custom module (last resort).

### Read denials

```bash
ausearch -m AVC -ts recent                   # Last 10 minutes (-ts today, -c httpd)
ausearch -m AVC -ts recent | audit2why       # Why + often the fix
journalctl -t setroubleshoot                 # Human summary (setroubleshoot-server)
sealert -a /var/log/audit/audit.log          # Full analysis + suggested commands
```

```
type=AVC msg=audit(...): avc:  denied  { read } for  pid=1234 comm="httpd"
  name="index.html" scontext=system_u:system_r:httpd_t:s0
  tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file
```

- `denied { read }` → the action
- `comm="httpd"` → the program
- `scontext=...httpd_t` → type of the process
- `tcontext=...user_home_t` → type of the file: **wrong label** → `restorecon`
- `tclass=file` → object kind (file, dir, tcp_socket...)

### Hidden denials

Some denials are not logged (`dontaudit` rules).

```bash
semodule -DB                                 # Log everything
# ... reproduce the problem, read ausearch ...
semodule -B                                  # Back to normal
```

### Custom module (last resort)

```bash
ausearch -m AVC -c myapp --raw | audit2allow -M myapp   # Creates myapp.te + myapp.pp
cat myapp.te                                            # READ what it allows
semodule -i myapp.pp
semodule -l | grep myapp
semodule -r myapp                                       # Remove
```

Check the label, port and boolean first. `audit2allow` can allow far too much.

---

## Common scenarios

### Website in a custom folder

```bash
semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'
restorecon -Rv /srv/web
# Writable folder (uploads):
semanage fcontext -a -t httpd_sys_rw_content_t '/srv/web/uploads(/.*)?'
restorecon -Rv /srv/web/uploads
```

### Apache or Nginx on a custom port

```bash
semanage port -a -t http_port_t -p tcp 8888
firewall-cmd --permanent --add-port=8888/tcp && firewall-cmd --reload
systemctl restart httpd
```

### SSH on port 2222

```bash
semanage port -a -t ssh_port_t -p tcp 2222
# Port 2222 in /etc/ssh/sshd_config, then:
sshd -t && systemctl restart sshd
```

### Reverse proxy (Nginx → backend)

```bash
setsebool -P httpd_can_network_connect on    # Error 502 + AVC name_connect without it
```

### Files moved with mv

```bash
mv ~/index.html /var/www/html/               # Keeps user_home_t → 403 Forbidden
restorecon -v /var/www/html/index.html
```

### Samba share

```bash
semanage fcontext -a -t samba_share_t '/srv/share(/.*)?'
restorecon -Rv /srv/share
```

### Container volume

```bash
podman run -v /data:/data:Z image            # :Z = private label for this container
podman run -v /data:/data:z image            # :z = shared between containers
```

Never use `:Z` on system folders like `/home` or `/etc`.

---

## SELinux users (optional)

```bash
semanage login -l                            # Linux user → SELinux user
semanage login -a -s user_u alice            # Confined user: no sudo, no su
semanage login -a -s staff_u bob             # Can use sudo with a role change
```

---

## Packages

```bash
dnf install policycoreutils-python-utils     # semanage, audit2allow, audit2why
dnf install setroubleshoot-server            # sealert, setroubleshoot logs
```

---

## Pitfalls

- `chcon` is temporary: use `semanage fcontext` + `restorecon`.
- `mv` keeps the old label, `cp` takes the new one.
- `setsebool` without `-P` is lost at reboot.
- `semanage port -a` fails if the port already has a type: use `-m`.
- Don't disable SELinux to fix a problem: use permissive, find the denial, fix it, back to enforcing.
- Coming back from disabled: full relabel needed.
- `audit2allow` is the last resort: read the `.te` file before loading it.
- Check firewall **and** SELinux: both can block a new port.
