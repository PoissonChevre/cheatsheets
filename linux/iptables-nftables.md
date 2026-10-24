# iptables and nftables

Low-level Linux firewall: tables, chains, rules, NAT, sets, persistence, migration, troubleshooting.

[← Back to index](./README.md) · ufw and firewalld (easier front ends): [firewall.md](./firewall.md)

---

## Which one?

- **nftables** (`nft`) is the modern tool. Default backend on recent Debian, Ubuntu, RHEL, Fedora.
- **iptables** today is usually `iptables-nft`: same commands, translated to nftables.
- ufw and firewalld write their rules into nftables too.

```bash
iptables --version       # "(nf_tables)" = translated, "(legacy)" = old kernel backend
nft list ruleset         # Shows ALL rules, whatever tool created them
```

Don't add raw iptables/nft rules on a machine managed by firewalld or ufw: they will conflict or be erased at reload.

---

## Packet flow

```
Incoming packet ─► PREROUTING ─► routing ─┬─► INPUT ─► local process
                   (DNAT)                  │                │
                                           │             OUTPUT
                                           │                │
                                           └─► FORWARD ─► POSTROUTING ─► out
                                                          (SNAT, MASQUERADE)
```

| Table | Use | Chains |
|---|---|---|
| `filter` (default) | Accept or block | INPUT, FORWARD, OUTPUT |
| `nat` | Change addresses and ports | PREROUTING, OUTPUT, POSTROUTING |
| `mangle` | Change packet fields (TTL, marks) | All |

---

## iptables

### List

```bash
iptables -L -n -v --line-numbers         # Rules, counters, numbers (-n = no DNS)
iptables -L INPUT -n -v
iptables -S                              # Rules as commands (easy to copy)
iptables -t nat -L -n -v                 # NAT table
ip6tables -L -n -v                       # IPv6 has its own rules!
```

### Add, insert, replace, delete

```bash
iptables -A INPUT -p tcp --dport 22 -j ACCEPT           # Append at the end
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT         # Insert at position 1
iptables -R INPUT 5 -p tcp --dport 443 -j ACCEPT        # Replace rule 5
iptables -D INPUT 5                                     # Delete rule 5
iptables -D INPUT -p tcp --dport 22 -j ACCEPT           # Delete by exact rule
```

### Policies, flush, chains

```bash
iptables -P INPUT DROP                   # Default policy (ACCEPT or DROP only)
iptables -F INPUT                        # Delete the rules of a chain (-F = all chains)
iptables -Z                              # Reset counters
iptables -N SSH_IN                       # Create a custom chain
iptables -A INPUT -p tcp --dport 22 -j SSH_IN    # Jump to it
iptables -X SSH_IN                       # Delete it (must be empty and unused)
```

`-F` does not reset the policy. With policy DROP + `-F`, remote access is cut.

### Matches

| Match | Example |
|---|---|
| Protocol | `-p tcp`, `-p udp`, `-p icmp` |
| Port | `--dport 22`, `--sport 1024:65535` |
| Several ports | `-m multiport --dports 80,443` |
| Source / destination | `-s 192.168.1.0/24`, `-d 10.0.0.5` |
| Interface | `-i eth0` (in), `-o eth0` (out) |
| Negation | `! --dport 22`, `! -s 10.0.0.0/8` |
| Connection state | `-m conntrack --ctstate ESTABLISHED,RELATED` |
| Rate | `-m limit --limit 5/minute --limit-burst 10` |
| Comment | `-m comment --comment "web"` |

### Targets

| Target | Effect |
|---|---|
| `ACCEPT` | Let it pass |
| `DROP` | Drop silently |
| `REJECT` | Drop and answer (`--reject-with tcp-reset` or `icmp-port-unreachable`) |
| `LOG` | Log to the kernel log, then continue to the next rule |
| `RETURN` | Go back to the calling chain |
| `MASQUERADE`, `SNAT`, `DNAT`, `REDIRECT` | NAT (table nat) |

### Basic server ruleset

Order matters: allow SSH **before** setting the policy to DROP.

```bash
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -p tcp --dport 23 -j LOG --log-prefix "TELNET: "   # Log, then the policy drops it
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

### Allow one source, block the others

```bash
iptables -A INPUT -i eth0 -p tcp --dport 6002 -s 192.168.10.80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 6002 -j DROP     # ACCEPT must come FIRST
```

### Limit SSH brute force

```bash
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 5/minute --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j DROP
```

### NAT

Routing first: `sysctl -w net.ipv4.ip_forward=1` (persistent in `/etc/sysctl.d/`), and FORWARD must accept the traffic.

```bash
# Share the internet connection of eth0 (dynamic IP)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Same with a fixed public IP
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 203.0.113.50

# Port forwarding: public 8080 → internal server port 80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.100:80
iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT

# Same machine, other port
iptables -t nat -A PREROUTING -p tcp --dport 6000 -j REDIRECT --to-port 6001
```

| | Changes | Where |
|---|---|---|
| `REDIRECT` | Port only | This machine |
| `DNAT` | IP and/or port | Another machine (or this one) |
| `SNAT` | Source IP (fixed) | Outgoing |
| `MASQUERADE` | Source IP (IP of the interface) | Outgoing, dynamic IP |

### Save and restore

```bash
iptables-save > rules.v4 ; ip6tables-save > rules.v6
iptables-restore < rules.v4

# Debian/Ubuntu
apt install iptables-persistent
netfilter-persistent save                # → /etc/iptables/rules.v4 and rules.v6

# RHEL (instead of firewalld)
dnf install iptables-services
systemctl disable --now firewalld
systemctl enable --now iptables
service iptables save                    # → /etc/sysconfig/iptables
```

Without saving, iptables rules are lost at reboot.

---

## nftables

### Structure

```
table (family) ─► chain (hook, priority, policy) ─► rules
```

| Family | Traffic |
|---|---|
| `inet` | IPv4 + IPv6 (use this) |
| `ip` / `ip6` | IPv4 only / IPv6 only |
| `arp`, `bridge`, `netdev` | Special cases |

There are no default tables: you create them. A **base chain** has a `hook` (input, output, forward, prerouting, postrouting) and receives packets. A **regular chain** is only used by `jump`.

### Read

```bash
nft list ruleset
nft -a list ruleset                      # With handles (needed to delete)
nft list tables
nft list table inet filter
nft list chain inet filter input
```

### Tables and chains

```bash
nft add table inet filter
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
nft add chain inet filter forward '{ type filter hook forward priority 0 ; policy drop ; }'
nft add chain inet filter output '{ type filter hook output priority 0 ; policy accept ; }'

nft flush chain inet filter input        # Delete its rules
nft delete chain inet filter input       # Must be empty
nft delete table inet filter             # Table + everything inside
nft flush ruleset                        # EVERYTHING — no firewall left
```

Put the `{ ... }` in quotes, or escape the `;` (`\;`), or the shell cuts the command.

### Rules

```bash
nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input ct state invalid drop
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport { 80, 443 } accept      # Anonymous set
nft add rule inet filter input ip saddr 10.0.0.0/24 tcp dport 3306 accept
nft add rule inet filter input tcp dport 22 ct state new limit rate 5/minute accept
nft add rule inet filter input tcp dport 23 log prefix \"TELNET: \" drop
nft add rule inet filter input counter                           # Count packets here

nft insert rule inet filter input tcp dport 8080 accept          # At the top
nft add rule inet filter input position 12 tcp dport 9000 accept # After handle 12
nft replace rule inet filter input handle 12 tcp dport 443 accept
nft delete rule inet filter input handle 12
```

`add` = end of chain, `insert` = top. Every rule has a **handle**: find it with `nft -a list ruleset`.

### Named sets

Change the list without touching the rules.

```bash
nft add set inet filter web_ports '{ type inet_service ; }'
nft add element inet filter web_ports '{ 80, 443, 8080 }'
nft add rule inet filter input tcp dport @web_ports accept

nft add set inet filter blocklist '{ type ipv4_addr ; flags interval ; }'
nft add element inet filter blocklist '{ 203.0.113.0/24, 198.51.100.7 }'
nft insert rule inet filter input ip saddr @blocklist drop

nft list set inet filter blocklist
nft delete element inet filter blocklist '{ 198.51.100.7 }'
```

Types: `inet_service` (port), `ipv4_addr`, `ipv6_addr`, `ether_addr`. `flags interval` allows networks and ranges.

### NAT

```bash
nft add table ip nat
nft add chain ip nat prerouting '{ type nat hook prerouting priority -100 ; }'
nft add chain ip nat postrouting '{ type nat hook postrouting priority 100 ; }'

nft add rule ip nat postrouting oifname "eth0" masquerade
nft add rule ip nat postrouting oifname "eth0" snat to 203.0.113.50
nft add rule ip nat prerouting iifname "eth0" tcp dport 8080 dnat to 192.168.1.100:80
nft add rule ip nat prerouting tcp dport 6000 redirect to :6001
```

In an `inet` table, write the family: `dnat ip to 192.168.1.100:80`, `snat ip to ...`.

### Config file (persistent)

```
#!/usr/sbin/nft -f
# /etc/nftables.conf (RHEL: /etc/sysconfig/nftables.conf)
flush ruleset

table inet filter {
    set web_ports {
        type inet_service
        elements = { 80, 443 }
    }

    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state established,related accept
        ct state invalid drop
        meta l4proto { icmp, ipv6-icmp } accept
        tcp dport 22 accept
        tcp dport @web_ports accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

```bash
nft -c -f /etc/nftables.conf             # Check syntax only
nft -f /etc/nftables.conf                # Load
nft list ruleset > /etc/nftables.conf    # Save the current rules (add "flush ruleset" at the top)
systemctl enable --now nftables          # Load at boot
```

---

## Migrate from iptables

```bash
iptables-translate -A INPUT -p tcp --dport 22 -j ACCEPT    # One rule → nft syntax
iptables-save > rules.v4
iptables-restore-translate -f rules.v4 > rules.nft         # A whole ruleset
nft -c -f rules.nft && nft -f rules.nft
```

---

## Same rule, two syntaxes

| Task | iptables | nftables |
|---|---|---|
| List | `iptables -L -n -v` | `nft list ruleset` |
| Allow port | `-A INPUT -p tcp --dport 22 -j ACCEPT` | `add rule inet filter input tcp dport 22 accept` |
| Several ports | `-m multiport --dports 80,443` | `tcp dport { 80, 443 }` |
| Source | `-s 10.0.0.0/24` | `ip saddr 10.0.0.0/24` |
| State | `-m conntrack --ctstate ESTABLISHED,RELATED` | `ct state established,related` |
| Insert at top | `-I INPUT 1 ...` | `insert rule ...` |
| Delete | `-D INPUT 3` | `delete rule ... handle 3` |
| Policy | `-P INPUT DROP` | `policy drop;` in the chain |
| Masquerade | `-t nat -A POSTROUTING -o eth0 -j MASQUERADE` | `oifname "eth0" masquerade` |
| Save | `iptables-save` | `nft list ruleset` |

---

## Troubleshooting

```bash
iptables -L -n -v                        # Which rule counters increase?
nft list ruleset                         # Add "counter" to rules to see hits
tcpdump -nn -i eth0 port 22              # Do packets arrive?
journalctl -k | grep -E "TELNET|DROP"    # LOG / log prefix messages
sysctl net.ipv4.ip_forward               # Must be 1 for routing and NAT
conntrack -L                             # Tracked connections (package conntrack)
ss -tulpn                                # Is the service listening at all?
```

Changing rules on a remote server? Plan a rollback first:

```bash
nft list ruleset > /root/old.nft && sed -i '1i flush ruleset' /root/old.nft
echo "nft -f /root/old.nft" | at now + 5 minutes    # Rollback if you lose access
nft -f new-rules.nft
atq ; atrm JOB_ID                                   # Still connected? Cancel the rollback
```

---

## Pitfalls

- First match wins: ACCEPT before DROP.
- Allow SSH before `-P INPUT DROP` or `policy drop`.
- `iptables -F` keeps the policy: with DROP, remote access is gone.
- IPv6 needs `ip6tables` rules too (or an nftables `inet` table).
- NAT needs `ip_forward=1` and FORWARD rules.
- iptables rules are lost at reboot without `iptables-persistent` or `iptables-services`.
- `nft flush ruleset` removes everything, including rules from firewalld or Docker.
- Don't mix firewalld/ufw with raw rules.
- `iptables-save | nft -f -` does not work: use `iptables-restore-translate`.
