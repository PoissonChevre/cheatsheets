# Networking

Interfaces, routing, ports, DNS, configuration (Netplan, NetworkManager), bonding, time sync, SSH.

[← Back to index](./README.md) · Firewall and NAT: [firewall.md](./firewall.md) · NFS, Samba, SSHFS: [services.md](./services.md)

---

## Interfaces

```bash
ip a                             # Interfaces + IPs (-4 or -6 to filter)
ip a show dev eth0
ip a add 192.168.9.3/24 dev eth1 # Add an IP (lost at reboot)
ip a del 192.168.9.3/24 dev eth1
ip link set eth0 up|down
ip link set eth0 mtu 9000
ethtool eth0                     # Speed, duplex, link
hostname -I                      # All IPs
```

## Routing

```bash
ip route                         # Routing table
ip route get 8.8.8.8             # Which route is used
ip route add 10.0.0.0/24 via 192.168.1.1    # Lost at reboot
ip route add default via 192.168.1.1
ip route del 10.0.0.0/24

sysctl -w net.ipv4.ip_forward=1  # Act as a router (persistent: /etc/sysctl.d/)
```

## Ports and connections

```bash
ss -tulpn                        # Listening TCP/UDP ports + process (reflex #1)
ss -tulpn | grep :80
ss state established
ss -s                            # Summary
netstat -tulpn                   # Old equivalent
```

Test a remote port: `nc -zv host 22`. More tools (nc, nmap, curl, lsof): see [tools.md](./tools.md).

---

## DNS and hostname

```bash
dig example.com                  # +short = only the IP
dig @8.8.8.8 example.com         # Ask a specific server
dig example.com MX
dig -x 8.8.8.8                   # Reverse lookup
host example.com
getent hosts example.com         # Uses the system resolver (includes /etc/hosts)
resolvectl status                # systemd-resolved: DNS per interface

hostnamectl set-hostname srv01   # Then update /etc/hosts
```

| File | Content |
|---|---|
| `/etc/hosts` | Static name → IP |
| `/etc/resolv.conf` | DNS servers (often a link to the 127.0.0.53 stub) |
| `/etc/nsswitch.conf` | Lookup order (files, dns...) |
| `/etc/systemd/resolved.conf` | systemd-resolved config |
| `/etc/hostname` | Hostname |

To change DNS with systemd-resolved, edit Netplan or `resolved.conf`, not `resolv.conf`.

---

## Connectivity tests

```bash
ping -c 4 host                   # -6 for IPv6
tracepath host                   # No root needed
traceroute -I host               # ICMP
mtr host                         # ping + traceroute live

tcpdump -i eth0                  # Capture
tcpdump -nn -i any port 80       # No name resolution, one port
tcpdump -nn -i eth0 host 10.0.0.1
tcpdump -w cap.pcap ; tcpdump -r cap.pcap
```

---

## Netplan (Ubuntu)

```yaml
# /etc/netplan/01-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.10/24]
      routes:
        - to: default
          via: 192.168.1.1
        - to: 10.0.0.0/24
          via: 192.168.1.254
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
        search: [example.com]
```

```bash
sudo chmod 600 /etc/netplan/*.yaml
sudo netplan try                 # Apply with auto-rollback if you lose access
sudo netplan apply
```

YAML: spaces only, no tabs.

## NetworkManager (RHEL, desktops)

```bash
nmcli device status
nmcli con show

# Static IP
nmcli con mod eth0 ipv4.method manual ipv4.addresses 192.168.1.10/24 \
    ipv4.gateway 192.168.1.1 ipv4.dns "1.1.1.1 8.8.8.8"
nmcli con mod eth0 +ipv4.routes "10.0.0.0/24 192.168.1.254"
nmcli con up eth0                # REQUIRED to apply

nmcli con mod eth0 ipv4.method auto && nmcli con up eth0   # Back to DHCP

nmcli con add type ethernet con-name mycon ifname eth1 \
    ipv4.method manual ipv4.addresses 10.0.0.5/24 ipv4.gateway 10.0.0.1

nmtui                            # Text UI, easier
```

### Bonding

```bash
nmcli con add type bond con-name bond0 ifname bond0 \
    bond.options "mode=active-backup,miimon=100"
nmcli con add type ethernet con-name bond0-p1 ifname eth0 master bond0
nmcli con add type ethernet con-name bond0-p2 ifname eth1 master bond0
nmcli con mod bond0 ipv4.method manual ipv4.addresses 10.0.0.10/24
nmcli con up bond0

cat /proc/net/bonding/bond0      # Check
```

| Mode | Name | Use |
|---|---|---|
| 0 | balance-rr | Round robin |
| 1 | active-backup | Failover (most common) |
| 4 | 802.3ad | LACP (switch must support it) |
| 6 | balance-alb | Adaptive load balancing |

`miimon=100` checks the link every 100 ms. Without it, failover does not work.

---

## Time sync

```bash
timedatectl                      # Time, timezone, NTP status
timedatectl list-timezones
timedatectl set-timezone Europe/Brussels
timedatectl set-ntp true
timedatectl set-time "2026-05-02 14:30:00"   # Only when NTP is off
```

### chrony (RHEL, recent Ubuntu)

```bash
systemctl status chronyd         # Service "chrony" on Ubuntu
chronyc sources -v
chronyc tracking
chronyc makestep                 # Correct the time now
# Config: /etc/chrony.conf or /etc/chrony/chrony.conf
#   pool 2.pool.ntp.org iburst
```

### systemd-timesyncd (Ubuntu default)

```ini
# /etc/systemd/timesyncd.conf
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org
FallbackNTP=ntp.ubuntu.com
```

```bash
systemctl restart systemd-timesyncd
timedatectl timesync-status
```

---

## SSH

### Client

```bash
ssh user@host -p 2222 -i ~/.ssh/id_ed25519
ssh -v user@host                 # Debug
ssh -L 8080:localhost:80 host    # Local port forward
ssh -R 8080:localhost:80 host    # Remote port forward
ssh -D 1080 host                 # SOCKS proxy
ssh -J bastion user@host         # Through a jump host

ssh-keygen -t ed25519
ssh-copy-id user@host
ssh-add ~/.ssh/id_ed25519
```

```bash
scp file user@host:/path/        # -r recursive, -P port (uppercase!)
scp user@host:/file ./
```

For rsync, see [tools.md](./tools.md#rsync).

### Server

```bash
sshd -t                          # Test config
sshd -T -C user=alice            # Effective config for a user
systemctl reload sshd            # "ssh" on Ubuntu; keeps open sessions
```

```
# /etc/ssh/sshd_config or /etc/ssh/sshd_config.d/*.conf
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers alice bob
AllowGroups admins
MaxAuthTries 3
ClientAliveInterval 300
Banner /etc/ssh/banner

# Match blocks: at the END of the file, or in a 99-*.conf drop-in
Match User alice
    PasswordAuthentication yes
```

After a `Match` line, every setting belongs to that block until the next `Match` or the end of the file. Drop-ins load in alphabetical order, and the first value found wins.

| Server | Client |
|---|---|
| `/etc/ssh/sshd_config` | `~/.ssh/config` |
| `~/.ssh/authorized_keys` (600) | `~/.ssh/id_ed25519` (600) + `.pub` |
| | `~/.ssh/known_hosts` |

---

## Troubleshooting order

```bash
ss -tulpn | grep PORT            # 1. Is the service listening?
nc -zv host PORT                 # 2. Can I reach it from outside?
nft list ruleset                 # 3. Firewall? (or ufw status / firewall-cmd --list-all)
dig name                         # 4. DNS?
ip route get IP                  # 5. Route?
ausearch -m AVC -ts recent       # 6. SELinux? (RHEL)
```

---

## Pitfalls

- `ip a add` and `ip route add` are lost at reboot: use Netplan or nmcli.
- `nmcli con mod` does not apply anything: run `nmcli con up`.
- Netplan: use `netplan try` first.
- `/etc/resolv.conf` is usually managed: don't edit it directly.
- Bonding needs `miimon`.
- `sshd_config`: `Match` blocks at the end. Test with `sshd -t` before reload.
