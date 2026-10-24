# Firewall and NAT

ufw, firewalld, nftables, iptables, NAT and port forwarding.

[← Back to index](./README.md)

---

## How it fits together

```
                 netfilter (kernel)
                        │
                  nftables (engine)
                        │
     ┌──────────────┬───┴──────────┬──────────────┐
    nft         iptables-nft    firewalld         ufw
  (direct)    (compat layer)  (RHEL, Fedora)   (Ubuntu)
```

- Use **one** front end per machine. Never ufw and firewalld together.
- `nft list ruleset` shows **all** active rules, whatever tool created them.

### What is running?

```bash
systemctl status ufw firewalld nftables
iptables --version       # "(nf_tables)" or "(legacy)"
nft list ruleset
```

---

## ufw (Ubuntu)

```bash
ufw allow 22/tcp         # FIRST, before enable, or you lose SSH
ufw default deny incoming
ufw default allow outgoing
ufw enable
ufw status verbose       # Rules + default policies
ufw status numbered      # With numbers
```

```bash
ufw allow 22/tcp                         # Without /tcp = TCP AND UDP
ufw allow ssh                            # By service name (/etc/services)
ufw deny 443/tcp
ufw allow from 10.0.0.0/24
ufw allow from 192.168.1.5 to any port 22 proto tcp
ufw allow proto tcp from any to any port 80,443
ufw deny out to 1.2.3.4
ufw insert 1 allow from 10.0.0.5         # Put at the top
ufw delete 3                             # By number
ufw delete allow 22/tcp                  # By rule
ufw logging on                           # /var/log/ufw.log
ufw reset                                # Delete everything + disable
```

---

## firewalld (RHEL, Fedora)

Each interface belongs to **one zone**. Each zone has its own rules.

| Zone | Use |
|---|---|
| public | Untrusted networks (default) |
| home / work | Internal LAN |
| trusted | Allow everything |
| dmz | Exposed server |
| block | Reject everything (ICMP reply) |
| drop | Drop everything (no reply) |

### Inspect

```bash
firewall-cmd --state
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones          # Zones + their interfaces
firewall-cmd --list-all                  # Default zone
firewall-cmd --zone=public --list-all
firewall-cmd --get-services              # Predefined services
firewall-cmd --get-zone-of-interface=eth0
```

### Open and close

```bash
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-port=5000-5010/tcp
firewall-cmd --permanent --zone=dmz --add-service=ssh
firewall-cmd --permanent --remove-service=http
firewall-cmd --reload                    # REQUIRED after --permanent
```

`--permanent` alone = saved but not active. Without `--permanent` = active but lost at reload or reboot.
`firewall-cmd --runtime-to-permanent` saves what you tested at runtime.

### Zones and sources

```bash
firewall-cmd --set-default-zone=home
firewall-cmd --permanent --zone=trusted --change-interface=eth1
firewall-cmd --permanent --zone=trusted --add-source=10.0.0.0/24
```

### Rich rules

```bash
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.1.5 accept'
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=1.2.3.4 reject'
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 service name=ssh accept'
firewall-cmd --permanent --add-rich-rule='rule service name=ssh log prefix="SSH " level=notice accept'
```

---

## nftables

### Read

```bash
nft list ruleset
nft list tables
nft list table inet filter
nft -a list ruleset      # With handles (to delete rules)
```

### Write

```bash
nft add table inet filter                # inet = IPv4 + IPv6
nft 'add chain inet filter input { type filter hook input priority 0 ; policy drop ; }'
nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport { 80, 443 } accept
nft add rule inet filter input ip saddr 10.0.0.0/24 accept

nft delete rule inet filter input handle 5
nft flush ruleset                        # Delete everything
```

### Persist

```bash
nft list ruleset > /etc/nftables.conf    # RHEL: /etc/sysconfig/nftables.conf
systemctl enable --now nftables
```

---

## iptables

On recent distributions, `iptables` is `iptables-nft`: rules are translated to nftables.

```bash
iptables -L -n -v --line-numbers         # List with numbers
iptables -t nat -L -n -v                 # NAT table

iptables -A INPUT -p tcp --dport 22 -j ACCEPT        # Append (end)
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT      # Insert at position 1
iptables -D INPUT 3                                  # Delete by number
iptables -D INPUT -p tcp --dport 22 -j ACCEPT        # Delete by rule
iptables -P INPUT DROP                               # Default policy
iptables -F                                          # Flush rules

# Allow one source, block the others: ACCEPT BEFORE DROP
iptables -A INPUT -i eth0 -p tcp --dport 6002 -s 192.168.10.80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 6002 -j DROP

iptables -A OUTPUT -d 192.168.10.70 -p tcp -j DROP   # Block outgoing

iptables-save > /etc/iptables/rules.v4               # Debian: package iptables-persistent
iptables-restore < /etc/iptables/rules.v4
```

| Chain | Traffic |
|---|---|
| INPUT | To this host |
| OUTPUT | From this host |
| FORWARD | Through this host (router) |
| PREROUTING | Before routing (DNAT, REDIRECT) — table nat |
| POSTROUTING | After routing (SNAT, MASQUERADE) — table nat |

- Rules are read from top to bottom. The first match wins.
- NAT rules need `-t nat`.
- Local traffic (`lo`) is not matched by `-i eth0` rules.

---

## NAT and port forwarding

Enable forwarding first: `sysctl -w net.ipv4.ip_forward=1` (persistent in `/etc/sysctl.d/`).

### Masquerade (share an internet connection)

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

nft add table ip nat
nft 'add chain ip nat postrouting { type nat hook postrouting priority 100 ; }'
nft add rule ip nat postrouting oifname "eth0" masquerade

firewall-cmd --permanent --add-masquerade && firewall-cmd --reload
```

### Port forwarding

```bash
# REDIRECT: same machine, other port
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 6000 -j REDIRECT --to-port 6001

# DNAT: other machine and/or other port
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:8080

# firewalld
firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080
firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=192.168.1.10
firewall-cmd --reload
```

---

## Same task, three tools

| Task | ufw | firewalld | nftables |
|---|---|---|---|
| Open 80/tcp | `ufw allow 80/tcp` | `firewall-cmd --permanent --add-port=80/tcp` + `--reload` | `nft add rule inet filter input tcp dport 80 accept` |
| Open a service | `ufw allow ssh` | `firewall-cmd --permanent --add-service=ssh` + `--reload` | By port |
| Block an IP | `ufw deny from 1.2.3.4` | Rich rule `reject` | `nft add rule inet filter input ip saddr 1.2.3.4 drop` |
| Show rules | `ufw status numbered` | `firewall-cmd --list-all` | `nft list ruleset` |
| Reset | `ufw reset` | `firewall-cmd --complete-reload` | `nft flush ruleset` |

### Example: open 8080/tcp and allow SSH only from 10.0.0.0/24

```bash
# Ubuntu
ufw allow from 10.0.0.0/24 to any port 22 proto tcp
ufw allow 8080/tcp
ufw enable
ufw status verbose

# RHEL
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 service name=ssh accept'
firewall-cmd --reload
firewall-cmd --list-all
```

---

## Pitfalls

- `ufw enable` can cut your SSH session: allow 22/tcp first.
- `ufw allow 22` without `/tcp` opens TCP and UDP.
- firewalld: `--permanent` needs `--reload`.
- The default zone is not always the zone of your interface: check `--get-active-zones`.
- iptables: first match wins. ACCEPT before DROP.
- Don't mix raw iptables rules and firewalld.
