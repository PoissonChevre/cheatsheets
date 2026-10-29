# Cheat sheet — SMB and NFS client setup (Linux)

How to mount network shares on a Linux client, what the fstab options mean, and how to debug a mount that fails.

## SMB vs NFS

| | SMB (CIFS) | NFS |
| --- | --- | --- |
| Origin | Windows | Unix / Linux |
| Authentication | username + password per share | client IP (+ UID/GID sent by the client) |
| Identity on files | the logged-in SMB user | numeric UID/GID: must match on client and server |
| Best for | mixed clients: Windows, macOS, Android, Linux | Linux-to-Linux, hypervisors (Proxmox), Kubernetes |
| Default port | TCP 445 | TCP 2049 (NFSv4) ; + 111 rpcbind for NFSv3 |
| Client package (Fedora) | `cifs-utils` | `nfs-utils` |
| Client package (Debian/Ubuntu) | `cifs-utils` | `nfs-common` |
| fstab type | `cifs` | `nfs` |
| Remote path syntax | `//server/share` | `server:/export/path` |

Rule of thumb: SMB when you need a password or non-Linux clients, NFS for Linux machines and services on a trusted network.

**!** Basic NFS (`sec=sys`) trusts the client: anyone with an allowed IP can claim any UID. Restrict exports to specific hosts.

## Install

```bash
# Fedora / RHEL
sudo dnf install -y cifs-utils nfs-utils samba-client

# Debian / Ubuntu
sudo apt install -y cifs-utils nfs-common smbclient
```

`samba-client` / `smbclient` is only for testing (listing shares), not needed to mount.

## fstab line anatomy

```
<what>                    <where>      <type>  <options>                         <dump> <pass>
//nas.lan/media           /mnt/media   cifs    credentials=/root/.smb-nas,...    0      0
nas.lan:/mnt/tank/iso     /mnt/iso     nfs     _netdev,x-systemd.automount,...   0      0
```

| Field | Meaning |
| --- | --- |
| what | the remote share |
| where | local mount point (the directory must exist: `sudo mkdir -p /mnt/media`) |
| type | filesystem type: `cifs` or `nfs` |
| options | comma-separated, no spaces |
| dump | backup flag, always `0` for network shares |
| pass | fsck order, always `0` for network shares |

Use a hostname (`nas.lan`) rather than an IP when you have local DNS: one place to change if the server moves.

## Common options (both protocols)

| Option | Effect |
| --- | --- |
| `defaults` | rw, auto, and other standard defaults |
| `ro` / `rw` | read-only / read-write |
| `_netdev` | network filesystem: wait for the network before mounting |
| `noauto` | do not mount at boot |
| `nofail` | boot continues even if the mount fails |
| `x-systemd.automount` | mount on first access instead of at boot (pairs well with `noauto`) |
| `x-systemd.idle-timeout=10min` | unmount automatically after inactivity |
| `x-systemd.mount-timeout=15` | give up after N seconds instead of hanging |

Recommended for a laptop: `_netdev,noauto,x-systemd.automount,x-systemd.mount-timeout=15` → no slow boot when you are away from home.

## SMB (cifs) options

| Option | Effect |
| --- | --- |
| `credentials=/root/.smb-nas` | file holding username and password (keeps them out of fstab) |
| `username=myuser` | inline user (avoid for passwords) |
| `uid=1000,gid=1000` | local owner shown for all files (SMB does not map UIDs) |
| `file_mode=0644,dir_mode=0755` | local permissions shown for files and directories |
| `vers=3.1.1` | force SMB protocol version (default negotiates the highest) |
| `seal` | encrypt traffic (SMB3) |
| `iocharset=utf8` | character set for file names |

Credentials file:

```
username=myuser
password=PASSWORD
domain=WORKGROUP
```

```bash
sudo chmod 600 /root/.smb-nas
```

**!** No spaces around `=`, no quotes. `domain` is optional.

## NFS options

| Option | Effect |
| --- | --- |
| `vers=4.2` (or `nfsvers=`) | force NFS version (default negotiates) |
| `hard` | retry forever if the server disappears (default, safe for data) |
| `soft` | return an error after retries (risk of corrupt writes) |
| `timeo=600,retrans=2` | timeout in tenths of a second, number of retries |
| `rsize=1048576,wsize=1048576` | read/write block size |
| `nconnect=4` | several TCP connections, faster on fast links |
| `sec=sys` | default auth: trust client UID/GID |
| `sec=krb5p` | Kerberos auth + encryption (needs a Kerberos setup) |
| `noatime` | do not update access times, fewer writes |

NFS identity on the server side (export options):

| Export option | Effect |
| --- | --- |
| `root_squash` | client root becomes `nobody` (default) |
| `no_root_squash` | client root stays root (avoid) |
| `all_squash` | every client user becomes one user |
| `anonuid` / `anongid` | which user/group squashed users become |

**!** Client UID must match the server UID (`id -u` on both). Group membership is sent by the client unless the server manages groups itself (e.g. TrueNAS "Manage Groups Server-side", or `rpc.mountd --manage-gids`).

## Mount and apply

```bash
# Test a mount without fstab
sudo mount -t cifs //nas.lan/media /mnt/media -o username=myuser,uid=1000,gid=1000
sudo mount -t nfs nas.lan:/mnt/tank/iso /mnt/iso

# After editing fstab
sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target   # starts the automount units
sudo mount -a                             # mounts everything not marked noauto

# Mount / unmount one entry from fstab
sudo mount /mnt/media
sudo umount /mnt/media

# What is mounted, with which options
findmnt -t cifs,nfs4,nfs
```

## Debugging — step by step

Work from the network up to the permissions.

**1. Can I reach the server?**

```bash
ping -c 3 nas.lan
nc -zv nas.lan 445     # SMB
nc -zv nas.lan 2049    # NFS
ip route get <nas-ip>  # which interface is used (VPN or LAN?)
```

**2. Does the server offer the share?**

```bash
smbclient -L //nas.lan -U myuser           # list SMB shares
smbclient //nas.lan/media -U myuser -c ls  # enter one share
showmount -e nas.lan                       # list NFS exports (NFSv3 / rpcbind)
```

**3. Mount by hand with details**

```bash
sudo mount -v -t cifs //nas.lan/media /mnt/media -o username=myuser
sudo mount -v -t nfs nas.lan:/mnt/tank/iso /mnt/iso
sudo dmesg | tail -n 20                    # kernel messages (CIFS errors land here)
```

**4. If it works by hand but not from fstab**

```bash
systemctl list-units --type=automount,mount | grep mnt
systemctl status mnt-media.automount mnt-media.mount
journalctl -u mnt-media.mount -b
```

Unit names come from the path: `/mnt/media` → `mnt-media.mount` (`systemd-escape -p /mnt/media` shows it).

**5. Permissions once mounted**

```bash
ls -ln /mnt/iso          # numeric UID/GID as the client sees them
id                       # your UID and groups
touch /mnt/iso/test && rm /mnt/iso/test
```

**6. SELinux (Fedora / RHEL)**

```bash
sudo ausearch -m AVC -ts recent
```# Cheat sheet — SMB and NFS client setup (Linux)

How to mount network shares on a Linux client, what the fstab options mean, and how to debug a mount that fails.

## SMB vs NFS

| | SMB (CIFS) | NFS |
| --- | --- | --- |
| Origin | Windows | Unix / Linux |
| Authentication | username + password per share | client IP (+ UID/GID sent by the client) |
| Identity on files | the logged-in SMB user | numeric UID/GID: must match on client and server |
| Best for | mixed clients: Windows, macOS, Android, Linux | Linux-to-Linux, hypervisors (Proxmox), Kubernetes |
| Default port | TCP 445 | TCP 2049 (NFSv4) ; + 111 rpcbind for NFSv3 |
| Client package (Fedora) | `cifs-utils` | `nfs-utils` |
| Client package (Debian/Ubuntu) | `cifs-utils` | `nfs-common` |
| fstab type | `cifs` | `nfs` |
| Remote path syntax | `//server/share` | `server:/export/path` |

Rule of thumb: SMB when you need a password or non-Linux clients, NFS for Linux machines and services on a trusted network.

**!** Basic NFS (`sec=sys`) trusts the client: anyone with an allowed IP can claim any UID. Restrict exports to specific hosts.

## Install

```bash
# Fedora / RHEL
sudo dnf install -y cifs-utils nfs-utils samba-client

# Debian / Ubuntu
sudo apt install -y cifs-utils nfs-common smbclient
```

`samba-client` / `smbclient` is only for testing (listing shares), not needed to mount.

## fstab line anatomy

```
<what>                    <where>      <type>  <options>                         <dump> <pass>
//nas.lan/media           /mnt/media   cifs    credentials=/root/.smb-nas,...    0      0
nas.lan:/mnt/tank/iso     /mnt/iso     nfs     _netdev,x-systemd.automount,...   0      0
```

| Field | Meaning |
| --- | --- |
| what | the remote share |
| where | local mount point (the directory must exist: `sudo mkdir -p /mnt/media`) |
| type | filesystem type: `cifs` or `nfs` |
| options | comma-separated, no spaces |
| dump | backup flag, always `0` for network shares |
| pass | fsck order, always `0` for network shares |

Use a hostname (`nas.lan`) rather than an IP when you have local DNS: one place to change if the server moves.

## Common options (both protocols)

| Option | Effect |
| --- | --- |
| `defaults` | rw, auto, and other standard defaults |
| `ro` / `rw` | read-only / read-write |
| `_netdev` | network filesystem: wait for the network before mounting |
| `noauto` | do not mount at boot |
| `nofail` | boot continues even if the mount fails |
| `x-systemd.automount` | mount on first access instead of at boot (pairs well with `noauto`) |
| `x-systemd.idle-timeout=10min` | unmount automatically after inactivity |
| `x-systemd.mount-timeout=15` | give up after N seconds instead of hanging |

Recommended for a laptop: `_netdev,noauto,x-systemd.automount,x-systemd.mount-timeout=15` → no slow boot when you are away from home.

## SMB (cifs) options

| Option | Effect |
| --- | --- |
| `credentials=/root/.smb-nas` | file holding username and password (keeps them out of fstab) |
| `username=myuser` | inline user (avoid for passwords) |
| `uid=1000,gid=1000` | local owner shown for all files (SMB does not map UIDs) |
| `file_mode=0644,dir_mode=0755` | local permissions shown for files and directories |
| `vers=3.1.1` | force SMB protocol version (default negotiates the highest) |
| `seal` | encrypt traffic (SMB3) |
| `iocharset=utf8` | character set for file names |

Credentials file:

```
username=myuser
password=PASSWORD
domain=WORKGROUP
```

```bash
sudo chmod 600 /root/.smb-nas
```

**!** No spaces around `=`, no quotes. `domain` is optional.

## NFS options

| Option | Effect |
| --- | --- |
| `vers=4.2` (or `nfsvers=`) | force NFS version (default negotiates) |
| `hard` | retry forever if the server disappears (default, safe for data) |
| `soft` | return an error after retries (risk of corrupt writes) |
| `timeo=600,retrans=2` | timeout in tenths of a second, number of retries |
| `rsize=1048576,wsize=1048576` | read/write block size |
| `nconnect=4` | several TCP connections, faster on fast links |
| `sec=sys` | default auth: trust client UID/GID |
| `sec=krb5p` | Kerberos auth + encryption (needs a Kerberos setup) |
| `noatime` | do not update access times, fewer writes |

NFS identity on the server side (export options):

| Export option | Effect |
| --- | --- |
| `root_squash` | client root becomes `nobody` (default) |
| `no_root_squash` | client root stays root (avoid) |
| `all_squash` | every client user becomes one user |
| `anonuid` / `anongid` | which user/group squashed users become |

**!** Client UID must match the server UID (`id -u` on both). Group membership is sent by the client unless the server manages groups itself (e.g. TrueNAS "Manage Groups Server-side", or `rpc.mountd --manage-gids`).

## Mount and apply

```bash
# Test a mount without fstab
sudo mount -t cifs //nas.lan/media /mnt/media -o username=myuser,uid=1000,gid=1000
sudo mount -t nfs nas.lan:/mnt/tank/iso /mnt/iso

# After editing fstab
sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target   # starts the automount units
sudo mount -a                             # mounts everything not marked noauto

# Mount / unmount one entry from fstab
sudo mount /mnt/media
sudo umount /mnt/media

# What is mounted, with which options
findmnt -t cifs,nfs4,nfs
```

## Debugging — step by step

Work from the network up to the permissions.

**1. Can I reach the server?**

```bash
ping -c 3 nas.lan
nc -zv nas.lan 445     # SMB
nc -zv nas.lan 2049    # NFS
ip route get <nas-ip>  # which interface is used (VPN or LAN?)
```

**2. Does the server offer the share?**

```bash
smbclient -L //nas.lan -U myuser           # list SMB shares
smbclient //nas.lan/media -U myuser -c ls  # enter one share
showmount -e nas.lan                       # list NFS exports (NFSv3 / rpcbind)
```

**3. Mount by hand with details**

```bash
sudo mount -v -t cifs //nas.lan/media /mnt/media -o username=myuser
sudo mount -v -t nfs nas.lan:/mnt/tank/iso /mnt/iso
sudo dmesg | tail -n 20                    # kernel messages (CIFS errors land here)
```

**4. If it works by hand but not from fstab**

```bash
systemctl list-units --type=automount,mount | grep mnt
systemctl status mnt-media.automount mnt-media.mount
journalctl -u mnt-media.mount -b
```

Unit names come from the path: `/mnt/media` → `mnt-media.mount` (`systemd-escape -p /mnt/media` shows it).

**5. Permissions once mounted**

```bash
ls -ln /mnt/iso          # numeric UID/GID as the client sees them
id                       # your UID and groups
touch /mnt/iso/test && rm /mnt/iso/test
```

**6. SELinux (Fedora / RHEL)**

```bash
sudo ausearch -m AVC -ts recent
```

Denials for `rpcbind` binding random ports are harmless.

## Common errors

| Error | Likely cause | Fix |
| --- | --- | --- |
| `can't find in /etc/fstab` | no fstab line for that mount point | add the line, check the path |
| `mount error(13): Permission denied` (SMB) | wrong credentials, or the user has no rights on the share | test with `smbclient`, check the credentials file and server ACL |
| `NT_STATUS_LOGON_FAILURE` | wrong password or user not allowed on SMB | reset the SMB password on the server |
| `NT_STATUS_ACCESS_DENIED` | login OK, folder permissions refuse | fix owner/group/ACL on the server |
| `mount error(112): Host is down` | SMB version mismatch or SMB1 only | add `vers=3.0` or check server SMB settings |
| `access denied by server while mounting` (NFS) | client IP not in the export | fix allowed hosts/networks, check `exportfs -v` on the server |
| `Permission denied` on write (NFS) | UID/GID mismatch or missing group | align UIDs, server-side group management |
| `No such file or directory` | wrong export path or missing mount point | check the path on the server, `mkdir` the mount point |
| `Stale file handle` | export changed or recreated on the server | `sudo umount -f /mnt/x` then mount again |
| `target is busy` on umount | a process uses the mount | `sudo fuser -vm /mnt/x` or `lsof +f -- /mnt/x`, or `umount -l` |
| boot hangs on the mount | server unreachable, no automount | `noauto,x-systemd.automount` or `nofail` |
| works at home only via VPN, NFS denied | traffic goes through the VPN, server sees the router IP | use the LAN route, or allow the VPN source IP |

## Security notes

- Keep passwords in a credentials file with `chmod 600`, never in fstab.
- Never expose SMB (445) or NFS (2049) to the internet; use a VPN.
- Restrict NFS exports to specific hosts, keep `root_squash`.
- SMB1 should be disabled on the server.

Denials for `rpcbind` binding random ports are harmless.

## Common errors

| Error | Likely cause | Fix |
| --- | --- | --- |
| `can't find in /etc/fstab` | no fstab line for that mount point | add the line, check the path |
| `mount error(13): Permission denied` (SMB) | wrong credentials, or the user has no rights on the share | test with `smbclient`, check the credentials file and server ACL |
| `NT_STATUS_LOGON_FAILURE` | wrong password or user not allowed on SMB | reset the SMB password on the server |
| `NT_STATUS_ACCESS_DENIED` | login OK, folder permissions refuse | fix owner/group/ACL on the server |
| `mount error(112): Host is down` | SMB version mismatch or SMB1 only | add `vers=3.0` or check server SMB settings |
| `access denied by server while mounting` (NFS) | client IP not in the export | fix allowed hosts/networks, check `exportfs -v` on the server |
| `Permission denied` on write (NFS) | UID/GID mismatch or missing group | align UIDs, server-side group management |
| `No such file or directory` | wrong export path or missing mount point | check the path on the server, `mkdir` the mount point |
| `Stale file handle` | export changed or recreated on the server | `sudo umount -f /mnt/x` then mount again |
| `target is busy` on umount | a process uses the mount | `sudo fuser -vm /mnt/x` or `lsof +f -- /mnt/x`, or `umount -l` |
| boot hangs on the mount | server unreachable, no automount | `noauto,x-systemd.automount` or `nofail` |
| works at home only via VPN, NFS denied | traffic goes through the VPN, server sees the router IP | use the LAN route, or allow the VPN source IP |

## Security notes

- Keep passwords in a credentials file with `chmod 600`, never in fstab.
- Never expose SMB (445) or NFS (2049) to the internet; use a VPN.
- Restrict NFS exports to specific hosts, keep `root_squash`.
- SMB1 should be disabled on the server.
