# LFCS — Networking (13%)

## Network Interfaces & Addresses

```bash
ip a                                  # Display interfaces, IPs, routes, tunnels (all-in-one)
ip addr show                          # Same as `ip a`
ip addr show dev eth0                 # Just one interface
ip a add 192.168.9.3/24 dev eth1      # Add a temporary extra IP to eth1
ip a del 192.168.9.3/24 dev eth1      # Remove an IP from interface

ip link                               # Show link layer info for all interfaces
ip link set <interface> up            # Enable interface
ip link set <interface> down          # Disable interface
ip link set eth0 mtu 1500             # Change MTU

hostname -I                           # Display all IP addresses of the host
networkctl status                     # IP address of all interfaces (systemd-networkd)
ifconfig                              # Legacy — print system network info
ifup <interface>                      # Bring interface up (legacy)
ifdown <interface>                    # Bring interface down (legacy)
ethtool eth0                          # NIC driver, link state, speed, duplex
```

## Routing

```bash
ip route                              # Show all routes
ip route show                         # Display IPv4 routing table
ip route get <IP>                     # Which route will be used to reach <IP>
ip route get 8.8.8.8                  # Trace effective route to 8.8.8.8
ip route add 10.0.0.0/24 via 192.168.1.1   # Add static route
ip route add default via 192.168.1.1       # Set default gateway
ip route del 10.0.0.0/24                   # Delete a route
route -n                              # Legacy — show routes (numeric)
```

## Port & Connection Inspection

```bash
ss -tulpn                   # Show TCP+UDP listening ports + processes (numeric)
ss -tunlp                   # Same — listening ports
sudo ss -tulpn              # Open ports + associated processes
ss -tunlp                   # Display all incoming TCP/UDP listeners with PID
ss -an                      # All sockets, numeric
ss state established        # Only ESTABLISHED connections

netstat -tulpn              # Legacy equivalent of ss -tulpn
netstat -tulpn              # Get list of all incoming open ports

lsof -i :80                 # Find which process is using port 80
```

## DNS Resolution

```bash
dig domain                  # Get DNS information for domain
dig +short example.com      # Quick A record lookup
dig -x <IP>                 # Reverse lookup (PTR)
dig @8.8.8.8 example.com    # Query a specific DNS server

nslookup domain             # Legacy DNS lookup utility
host domain                 # Simpler DNS lookup
getent hosts example.com    # Use system resolver (NSS — respects /etc/hosts)
whois domain                # Get whois info for domain

# Resolver config files
/etc/hosts                  # Static IP → hostname mappings
/etc/resolv.conf            # Active DNS server list (often auto-generated)
/etc/nsswitch.conf          # Order of name resolution (files, dns, ldap...)
systemd-resolve --status    # systemd-resolved status
```

## Connectivity Testing

```bash
ping host                   # Send ICMP echo to host
ping -c 4 8.8.8.8           # Send only 4 packets
ping6 host                  # ICMPv6 ping

traceroute host             # Trace route to host (UDP by default)
traceroute -I host          # Use ICMP
mtr host                    # Combined traceroute + ping (live)
tracepath host              # Like traceroute, no root needed

tcpdump -i eth0             # Show every in/out packet on eth0
tcpdump -i any port 80      # Capture HTTP traffic on all interfaces
tcpdump -nn -i eth0 host 1.2.3.4    # No DNS / port resolution

nmap -sT host               # TCP connect scan
ncat / nc -zv host 22       # Probe whether TCP port is open
```

## Hostname Configuration

```bash
hostname                          # Display system hostname
hostname -I                       # Display all IP addresses of the host
hostnamectl                       # systemd hostname management
hostnamectl set-hostname srv01    # Set static hostname
# Files:
/etc/hostname                     # Persistent hostname
/etc/hosts                        # Local name resolution
```

## Network Configuration Files

```bash
# Debian / Ubuntu (Netplan — modern Ubuntu)
/etc/netplan/*.yaml         # YAML network config
sudo netplan apply          # Apply current netplan configuration to running system
sudo netplan try            # Apply temporarily — auto-rollback if no confirm
sudo netplan generate       # Generate backend config without applying

# Debian (legacy ifupdown)
/etc/network/interfaces

# RHEL/CentOS 7 (NetworkManager + ifcfg)
/etc/sysconfig/network-scripts/ifcfg-<interface>
nmcli connection show
nmcli connection up <name>
nmcli connection modify <name> ipv4.addresses 192.168.1.10/24
nm-connection-editor                  # GUI

# RHEL/CentOS 8+ (NetworkManager keyfiles)
/etc/NetworkManager/system-connections/

# systemd-networkd
/etc/systemd/network/*.network
systemctl restart systemd-networkd
```

## Time & Date

```bash
timedatectl                                     # Show time / date / timezone / NTP status
timedatectl status                              # Same — explicit
timedatectl list-timezones                      # List all timezones
timedatectl set-timezone America/New_York       # Set system timezone
sudo timedatectl set-timezone <zone>            # Persistent timezone change
timedatectl set-ntp true                        # Enable NTP synchronization

date                            # Display current date/time
date -u                         # UTC

# NTP services
chronyc sources                 # Chronyd (newer) — show NTP sources
chronyc tracking                # Chronyd — synchronization status
ntpq -p                         # Legacy NTP — peers
```

## Firewall — UFW (Ubuntu)

```bash
sudo ufw enable                         # Turn on UFW (and enable at boot)
sudo ufw disable                        # Disable UFW
sudo ufw status                         # Show active rules
sudo ufw status numbered                # List numbered firewall rules

sudo ufw allow 22                       # Allow SSH on port 22
sudo ufw allow <port>                   # Allow port
sudo ufw deny 443/tcp                   # Deny incoming TCP/443
sudo ufw deny <port>                    # Deny port
sudo ufw allow from 207.45.232.181      # Allow all traffic from a single IP
sudo ufw allow from 10.11.12.0/24       # Allow all traffic from a /24 network
sudo ufw delete deny 443/tcp            # Delete a specific rule by spec
sudo ufw delete 8                       # Delete a numbered rule (rule #8)
```

## Firewall — firewalld (RHEL/CentOS)

```bash
firewall-cmd --state                                  # Service running?
firewall-cmd --get-default-zone                       # Default zone
firewall-cmd --list-all                               # All rules in default zone
firewall-cmd --permanent --add-service=http           # Open HTTP persistently
firewall-cmd --permanent --add-port=8080/tcp          # Open custom port
firewall-cmd --permanent --remove-port=8080/tcp       # Remove a port
firewall-cmd --reload                                 # Reload (apply --permanent)
firewall-cmd --zone=public --add-source=10.0.0.0/24 --permanent
firewall-config                                       # GUI tool
```

## Firewall — iptables (legacy)

```bash
iptables -L -v -n                                     # List rules with counters
iptables -A INPUT -p tcp --dport 22 -j ACCEPT         # Allow incoming SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT         # Allow incoming HTTP
iptables -P INPUT DROP                                # Default policy DROP
iptables-save > /etc/iptables/rules.v4                # Persist rules (Debian)
ip6tables ...                                         # IPv6 equivalent
```

## SSH (server-side basics)

```bash
ssh user@host                       # Connect remotely
ssh-keygen -t ed25519               # Generate SSH keypair (preferred today)
ssh-copy-id user@host               # Push pubkey for passwordless login

# Server-side files
/etc/ssh/sshd_config                # SSH server configuration
/etc/ssh/ssh_config                 # SSH client defaults
~/.ssh/authorized_keys              # Allowed pubkeys for the user

systemctl restart sshd              # Apply sshd_config changes
sshd -t                             # Test sshd config syntax
```

## Security & Failed-Login Protection

```bash
sudo apt install fail2ban           # Auto-detect & ban abusive IPs
sudo fail2ban-client status         # Show banned IP addresses (overall)
sudo fail2ban-client status <jail>  # Show banned IPs in specific jail
```

## Common Pitfalls (Pièges LFCS)

```bash
# 1. After editing /etc/netplan/*.yaml → ALWAYS run `netplan apply`
#    Use `netplan try` first to auto-rollback if you lose connectivity.

# 2. ip a add 192.168.9.3/24 dev eth1  is TEMPORARY (lost on reboot).
#    Persist via netplan / NetworkManager / ifcfg / systemd-networkd.

# 3. ufw rules are evaluated TOP-DOWN — first match wins.
#    Use `ufw status numbered` and `ufw insert N rule` to control order.

# 4. firewalld rules without --permanent are RUNTIME ONLY.
#    Always pair: --permanent ... && firewall-cmd --reload

# 5. ss > netstat — `ss -tulpn` shows the same data without legacy deps.

# 6. RHEL → firewalld + NetworkManager  |  Ubuntu → ufw + netplan
#    Don't mix iptables raw rules + firewalld on RHEL → conflicts.

# 7. systemd-resolved — /etc/resolv.conf is often a symlink to a stub
#    file (127.0.0.53). Edit /etc/systemd/resolved.conf instead.
```
