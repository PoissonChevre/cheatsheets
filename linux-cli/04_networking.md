# LFCS — Networking (13%)

> Interfaces, routing, DNS, hostname, firewall, SSH, NFS/SSHFS, time sync, NAT, bonding.

---

## Interfaces & Addresses

```bash
ip a                                 # All interfaces + IPs (most useful)
ip addr show                         # Same as ip a
ip addr show dev eth0                # One specific interface
ip -4 a                              # IPv4 only
ip -6 a                              # IPv6 only

ip a add 192.168.9.3/24 dev eth1     # Add IP (TEMPORARY!)
ip a del 192.168.9.3/24 dev eth1     # Remove IP

ip link                              # Link-layer info
ip link set eth0 up                  # Enable interface
ip link set eth0 down                # Disable interface
ip link set eth0 mtu 1500            # Change MTU

hostname -I                          # All host IPs
ethtool eth0                         # NIC driver, speed, duplex, link state
```

**Pitfall:** `ip a add` is temporary (lost at reboot). For persistence: Netplan, NetworkManager, or systemd-networkd.

---

## Routing

```bash
ip route                             # Routing table
ip route show                        # Same
ip route get 8.8.8.8                 # Which route would be used to reach 8.8.8.8

# Static routes (TEMPORARY)
ip route add 10.0.0.0/24 via 192.168.1.1
ip route add default via 192.168.1.1
ip route del 10.0.0.0/24

# Persistent (Netplan — Ubuntu)
# /etc/netplan/01-config.yaml :
#   network:
#     ethernets:
#       eth0:
#         routes:
#           - to: 10.0.0.0/24
#             via: 192.168.1.1

# Persistent (NetworkManager — RHEL)
nmcli con mod eth0 +ipv4.routes "10.0.0.0/24 192.168.1.1"
nmcli con up eth0

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1                    # Temporary
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-forward.conf    # Persistent
sysctl -p /etc/sysctl.d/99-forward.conf
```

---

## Ports & Connections

```bash
ss -tulpn                            # TCP+UDP, listeners, PID, numeric (REFLEX #1)
ss -tunlp                            # Same (different option order)
ss -an                               # All sockets, numeric
ss state established                 # Only ESTABLISHED connections
ss -tulpn | grep :80                 # Who is listening on port 80?
ss -s                                # Summary statistics

# Legacy
netstat -tulpn                       # Equivalent of ss -tulpn

lsof -i :80                          # Process using port 80
lsof -i -P -n                        # All open ports with PIDs
lsof -i tcp                          # Only TCP

# nc / netcat — connectivity tests
nc -zv host 22                       # Is port 22 open?
nc -zv host 20-25                    # Range scan
nc host 22                           # Show banner (verify service responds)
nc -l 9999                           # Listen mode (server)

nmap -sT host                        # TCP connect scan
```

---

## DNS / Name Resolution

```bash
dig example.com                      # Detailed DNS lookup
dig +short example.com               # Just the IP
dig -x 8.8.8.8                       # Reverse lookup (PTR)
dig @8.8.8.8 example.com             # Query specific server
dig example.com MX                   # MX records
dig example.com ANY                  # All record types

nslookup example.com                 # Legacy lookup
host example.com                     # Simpler
getent hosts example.com             # System resolver (respects /etc/hosts)
whois example.com                    # Domain info
```

### DNS Configuration Files

```
/etc/hosts                           # Static IP → hostname mappings
/etc/resolv.conf                     # Active DNS servers
/etc/nsswitch.conf                   # Resolution order (files, dns, ldap...)

# systemd-resolved (modern Ubuntu)
systemd-resolve --status
resolvectl status

# /etc/resolv.conf is often a symlink to a stub at 127.0.0.53.
# To change DNS: edit /etc/systemd/resolved.conf or use Netplan.
```

---

## Hostname

```bash
hostname                             # Show
hostname -I                          # All IPs
hostnamectl                          # Full info (hostname, OS, kernel)
hostnamectl set-hostname srv01       # Set persistently

# Files
/etc/hostname                        # Persistent hostname
/etc/hosts                           # ⚠ Update for local resolution
```

---

## Connectivity Testing

```bash
ping host                            # ICMP echo
ping -c 4 host                       # Send 4 packets
ping -i 0.5 host                     # Interval
ping6 host                           # IPv6 ping

traceroute host                      # Trace network path (UDP)
traceroute -I host                   # ICMP
mtr host                             # traceroute + ping continuous
tracepath host                       # No root needed

curl -I https://example.com          # HTTP headers
curl -v https://example.com          # Verbose (TLS debug)
curl -fsSLo file.txt URL             # Quiet, save, follow redirects

tcpdump -i eth0                      # Capture all on eth0
tcpdump -i any port 80               # HTTP on any interface
tcpdump -nn -i eth0 host 10.0.0.1    # No name resolution
tcpdump -w capture.pcap              # Save to file
tcpdump -r capture.pcap              # Read pcap file
```

---

## Network Configuration — Netplan (Ubuntu)

```yaml
# /etc/netplan/01-config.yaml
network:
  version: 2
  renderer: networkd                 # or NetworkManager
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.10/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
        search: [example.com]
```

```bash
sudo netplan apply                   # Apply
sudo netplan try                     # Apply temporarily — auto-rollback if no confirm
sudo netplan generate                # Generate backend config without applying
```

**Pitfall:** YAML is space-sensitive. Use `netplan try` first — it auto-rolls back if you lose connectivity.

---

## Network Configuration — NetworkManager (RHEL/CentOS)

```bash
nmcli device status                  # Interface status
nmcli connection show                # All connections
nmcli connection show "Wired connection 1"   # Details

# Static IP
nmcli con mod eth0 ipv4.method manual
nmcli con mod eth0 ipv4.addresses 192.168.1.10/24
nmcli con mod eth0 ipv4.gateway 192.168.1.1
nmcli con mod eth0 ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con up eth0                    # Apply

# Back to DHCP
nmcli con mod eth0 ipv4.method auto
nmcli con up eth0

# IPv6
nmcli con mod eth0 ipv6.method manual
nmcli con mod eth0 ipv6.addresses "2001:db8::10/64"
nmcli con up eth0

# New connection
nmcli con add type ethernet con-name mycon ifname eth1 \
    ipv4.addresses 10.0.0.5/24 ipv4.gateway 10.0.0.1 \
    ipv4.method manual

nmtui                                # Text-based UI (easier at exam!)
```

**Pitfall:** `nmcli con mod` does NOT apply immediately. Always run `nmcli con up <name>`.

---

## Network Bonding / Teaming

```bash
# Bonding via NetworkManager
nmcli con add type bond con-name bond0 ifname bond0 \
    bond.options "mode=active-backup,miimon=100"
nmcli con add type ethernet con-name bond0-slave1 ifname eth0 master bond0
nmcli con add type ethernet con-name bond0-slave2 ifname eth1 master bond0
nmcli con mod bond0 ipv4.addresses 10.0.0.10/24 ipv4.method manual
nmcli con up bond0

# Verify
cat /proc/net/bonding/bond0
ip a show bond0
```

### Bonding modes

| Mode | Name | Use case |
|---|---|---|
| 0 | balance-rr | Round-robin (more bandwidth) |
| 1 | active-backup | Failover (most common) |
| 2 | balance-xor | XOR hash |
| 4 | 802.3ad | LACP (needs compatible switch) |
| 6 | balance-alb | Adaptive load balancing |

**Critical:** `miimon=100` (link monitoring interval, ms). Without it, failover does NOT work properly.

---

## NAT (Network Address Translation)

```bash
# Enable forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-forward.conf

# NAT with iptables (legacy)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# NAT with nftables
nft add table nat
nft 'add chain nat postrouting { type nat hook postrouting priority 100 ; }'
nft add rule nat postrouting oifname "eth0" masquerade

# NAT with firewalld (RHEL)
firewall-cmd --permanent --zone=public --add-masquerade
firewall-cmd --reload
```

### Port Forwarding

```bash
# DNAT — to another machine or different port
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:8080

# REDIRECT — to local port only (simpler)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 6000 \
    -j REDIRECT --to-port 6001

# firewalld
firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080
firewall-cmd --reload
```

### REDIRECT vs DNAT

- **REDIRECT** — only to local machine, only changes port. Simpler.
- **DNAT** — can target another machine, changes IP and/or port. More powerful.

---

## Time Synchronization (NTP)

```bash
timedatectl                          # Status: date, timezone, NTP
timedatectl status                   # Same (explicit)
timedatectl list-timezones           # All timezones
timedatectl set-timezone Europe/Athens
timedatectl set-timezone Europe/Brussels
timedatectl set-ntp true             # Enable NTP sync
timedatectl set-time "2026-05-02 14:30:00"   # Manual time (only if NTP off)

date                                 # Current date/time
date -u                              # UTC

# chronyd (modern — RHEL 8+, recent Ubuntu)
systemctl status chronyd
chronyc sources -v                   # NTP sources detail
chronyc tracking                     # Sync status
chronyc makestep                     # Force sync now
# Config: /etc/chrony.conf or /etc/chrony/chrony.conf
#   server ntp.ubuntu.com iburst
#   pool 2.pool.ntp.org iburst

# systemd-timesyncd (Ubuntu default if no chronyd)
systemctl status systemd-timesyncd
# Config: /etc/systemd/timesyncd.conf
#   [Time]
#   NTP=0.pool.ntp.org 1.pool.ntp.org
#   FallbackNTP=ntp.ubuntu.com 0.debian.pool.ntp.org
#   PollIntervalMaxSec=1000
#   ConnectionRetrySec=20

# Test NTP server manually
ntpdate -q 0.pool.ntp.org            # Query, don't update
```

---

## Firewall — UFW (Ubuntu)

```bash
sudo ufw enable                      # Enable (+ on boot)
sudo ufw disable                     # Disable
sudo ufw reset                       # Reset all rules
sudo ufw status                      # Active rules
sudo ufw status verbose              # + default policies
sudo ufw status numbered             # With numbers (for delete/insert)

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp                # Allow SSH (TCP only!)
sudo ufw allow ssh                   # By service name
sudo ufw deny 443/tcp
sudo ufw allow from 10.0.0.0/24
sudo ufw allow from 10.0.0.5 to any port 22
sudo ufw allow proto tcp from any to any port 80,443

sudo ufw delete allow 22/tcp         # Delete by spec
sudo ufw delete 3                    # Delete rule #3
sudo ufw insert 1 allow from 10.0.0.5

sudo ufw logging on                  # /var/log/ufw.log
sudo ufw reload
```

**Critical pitfalls:**
- `ufw allow 22` (no `/tcp`) opens both TCP **and** UDP. Always specify `/tcp`.
- `ufw enable` can lock you out via SSH! Always `ufw allow 22/tcp` **before** `ufw enable`.

---

## Firewall — firewalld (RHEL/CentOS)

```bash
firewall-cmd --state                                  # Active?
firewall-cmd --get-default-zone                       # Default zone
firewall-cmd --get-active-zones                       # Active zones + interfaces
firewall-cmd --list-all                               # Default zone rules
firewall-cmd --zone=public --list-all                 # Specific zone

# Open service/port (always --permanent + --reload!)
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=5000-5010/tcp     # Range
firewall-cmd --permanent --remove-service=http
firewall-cmd --reload                                 # MANDATORY after --permanent

# Zones
firewall-cmd --set-default-zone=home
firewall-cmd --permanent --zone=trusted --add-interface=eth1
firewall-cmd --get-zone-of-interface=eth0

# Rich rules
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 accept'
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=1.2.3.4 reject'
firewall-cmd --permanent --add-rich-rule='rule service name=ssh log prefix="SSH " accept'

# Save runtime → permanent
firewall-cmd --runtime-to-permanent
```

### firewalld Zones

| Zone | Purpose |
|---|---|
| public | Untrusted networks (default) |
| trusted | Allow everything |
| drop | Drop all, no response |
| block | Reject all with ICMP |
| home / work | Trusted LAN |
| dmz | Exposed server |

**Critical pitfalls:**
- Without `--permanent` → rule lost at reboot
- Without `--reload` after `--permanent` → rule not active in runtime
- Combo: `--permanent ... && firewall-cmd --reload`

---

## Firewall — iptables

```bash
iptables -L -v -n                            # List with counters, numeric
iptables -L INPUT -v -n --line-numbers       # With rule numbers
iptables -t nat -L -v -n                     # NAT table

# Add rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT       # Append
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT     # Insert at position 1

# Delete
iptables -D INPUT 3                          # By number
iptables -D INPUT -p tcp --dport 22 -j ACCEPT       # By spec

# Default policies
iptables -P INPUT DROP
iptables -F                                  # Flush all rules

# NAT and PREROUTING
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 6000 \
    -j REDIRECT --to-port 6001

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:8080

# Source-restricted access (the Q7 pattern)
iptables -A INPUT -i eth0 -p tcp --dport 6002 -s 192.168.10.80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 6002 -j DROP
# ⚠ ORDER MATTERS — ACCEPT must come BEFORE DROP

# OUTPUT chain (block outgoing)
iptables -A OUTPUT -d 192.168.10.70 -p tcp -j DROP

# Persist
iptables-save > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4
```

### Chains

| Chain | Direction |
|---|---|
| INPUT | Incoming packets to this host |
| OUTPUT | Outgoing packets from this host |
| FORWARD | Packets passing through (routing) |
| PREROUTING | Before routing decision (DNAT/REDIRECT) |
| POSTROUTING | After routing decision (SNAT/MASQUERADE) |

**Critical pitfalls:**
- Rules evaluated **top-down**, first match wins
- ACCEPT before DROP for source-restricted access
- `-t nat` must be specified for NAT rules (default is filter)
- `localhost` traffic NOT affected by `-i eth0` rules

---

## Firewall — nftables (modern)

```bash
nft list ruleset                     # All rules (absolute truth)
nft list tables                      # All tables
nft -a list ruleset                  # With handles (for delete)

# Create
nft add table inet filter
nft 'add chain inet filter input { type filter hook input priority 0 ; policy drop ; }'
nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport {80, 443} accept
nft add rule inet filter input ip saddr 10.0.0.0/24 accept

# Delete
nft -a list ruleset                  # Find handle
nft delete rule inet filter input handle 5

# Flush
nft flush ruleset                    # Wipe everything

# Persist
nft list ruleset > /etc/nftables.conf
systemctl enable --now nftables
```

---

## SSH (Server / Client)

### Server config

```bash
systemctl enable --now sshd
sshd -t                              # Test config syntax
sshd -T                              # Show effective config
sshd -T -C user=alice                # Effective config for specific user
systemctl reload sshd                # Apply without dropping sessions
```

### `/etc/ssh/sshd_config` essentials

```
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers alice bob                 # Whitelist
DenyUsers mallory                    # Blacklist
AllowGroups admins
MaxAuthTries 3
X11Forwarding no
Banner /etc/ssh/banner

# Per-user/group overrides — must be at END of file!
Match User alice
    PasswordAuthentication yes
    Banner /etc/ssh/banner

Match Group developers
    AllowAgentForwarding yes
```

### Drop-in config files

```
/etc/ssh/sshd_config.d/*.conf        # Loaded in lexical order
# Use 99-* for files with Match blocks (must be last)
```

### Client

```bash
ssh user@host                        # Connect
ssh -p 2222 user@host                # Custom port
ssh -i ~/.ssh/id_ed25519 user@host   # Specific key
ssh -v user@host                     # Verbose (debug)
ssh -L 8080:localhost:80 host        # Local port forward
ssh -R 8080:localhost:80 host        # Remote port forward
ssh -D 1080 host                     # SOCKS proxy

ssh-keygen -t ed25519                # Generate keypair (preferred)
ssh-keygen -t rsa -b 4096            # RSA alternative
ssh-copy-id user@host                # Push pubkey
ssh-add ~/.ssh/id_ed25519            # Add key to agent
```

### Files

```
# Server
/etc/ssh/sshd_config
/etc/ssh/sshd_config.d/
~/.ssh/authorized_keys

# Client
~/.ssh/id_ed25519                    # Private key
~/.ssh/id_ed25519.pub                # Public key
~/.ssh/config                        # Per-user client config
~/.ssh/known_hosts                   # Server fingerprints
```

### Transferring Files

```bash
scp file user@host:/path/            # Single file
scp -r dir/ user@host:/path/         # Recursive
scp -P 2222 file user@host:/path/    # Custom port (uppercase P!)
scp user@host:/file ./               # Remote → local

rsync -avzh source/ dest/            # Local sync
rsync -avzh src/ user@host:dst/      # To remote
rsync -avzh user@host:src/ dst/      # From remote
rsync --delete -av src/ dst/         # Mirror (delete extras in dst)
rsync -avzh -e "ssh -p 2222" src dst # Custom SSH port
```

---

## SSHFS — mount remote dir over SSH

```bash
sudo mkdir -p /mnt/remote
sudo sshfs -o allow_other,rw user@host:/remote/dir /mnt/remote

# Unmount
fusermount -u /mnt/remote
# or
sudo umount /mnt/remote
```

**Pitfall:** `allow_other` lets non-root users access the mount — useful but be aware in production.

---

## NFS

### Server

```bash
# Install
sudo apt install nfs-kernel-server   # Debian/Ubuntu
sudo yum install nfs-utils           # RHEL/CentOS

# /etc/exports format:
# <directory>   <client>(<options>)
/srv/share    192.168.1.0/24(rw,sync,no_subtree_check)
/srv/public   *(ro,sync)
/data         host1.example.com(rw,sync,no_root_squash)

# Apply
exportfs -ra                         # Re-export all
exportfs -a                          # Export all
exportfs -v                          # List active exports
showmount -e localhost               # Show exports
showmount -e <server>                # Show remote exports

systemctl enable --now nfs-server    # Start service
```

### Common export options

| Option | Meaning |
|---|---|
| rw | Read-write |
| ro | Read-only |
| sync | Sync writes (safer) |
| async | Async writes (faster) |
| no_subtree_check | Skip subtree check (recommended) |
| no_root_squash | Allow remote root to be root |
| root_squash | Map remote root to nobody (default, safer) |

### Client

```bash
sudo apt install nfs-common          # Debian/Ubuntu

# Manual mount
mkdir /mnt/share
mount -t nfs server:/srv/share /mnt/share

# Persistent in /etc/fstab
# server:/srv/share  /mnt/share  nfs  defaults,_netdev  0  0
mount -a
```

**Pitfall:** Always test NFS port (2049) before mounting:

```bash
nc -zv server 2049
```

---

## Quick Diagnostic Workflow

When something doesn't work, run this sequence:

```bash
# 1. Service running locally?
ss -tulpn | grep <port>

# 2. Reachable from remote?
nc -zv host <port>

# 3. Firewall blocking?
ufw status                # Ubuntu
firewall-cmd --list-all   # RHEL
iptables -L -v -n         # Universal

# 4. DNS working?
dig hostname

# 5. Routing OK?
ip route get <target-IP>

# 6. SELinux blocking? (RHEL)
getenforce
ausearch -m AVC -ts recent
```

---

## Pitfalls Summary

```bash
# 1. ip a add is TEMPORARY. Use Netplan/NetworkManager for persistence.

# 2. ufw allow 22 (no /tcp) opens TCP AND UDP. Always specify /tcp.

# 3. ufw enable can break SSH session! Always allow 22 BEFORE enable.

# 4. firewalld: missing --permanent = lost at reboot.
#    Missing --reload after --permanent = not active in runtime.

# 5. ss > netstat. Reflex: ss -tulpn for listening ports.

# 6. /etc/resolv.conf is often a symlink to a stub (127.0.0.53).
#    Edit /etc/systemd/resolved.conf or Netplan instead.

# 7. iptables rules are top-down, first match wins.
#    ACCEPT before DROP for source-restricted access.

# 8. Don't mix raw iptables + firewalld → conflicts.

# 9. After /etc/netplan/*.yaml changes → ALWAYS netplan apply.
#    Use netplan try first for auto-rollback.

# 10. nmcli con mod does NOT apply immediately.
#     Always nmcli con up <name> to activate.

# 11. Bonding: miimon=100 is CRITICAL for failover.

# 12. Match blocks in sshd_config must be at END (or 99-* drop-in).

# 13. NFS: always test port 2049 with nc before mounting.

# 14. systemd-resolved status command varies:
#     - Old: systemd-resolve --status
#     - New: resolvectl status
```
