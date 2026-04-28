# 🔥 Iptables / Nftables — Cheat Sheet
*Firewalls for Linux that control packet filtering, NAT, and network traffic rules.*

---

## 🔗 Iptables: Chains & Policies
*Configure packet filtering chains and default policies.*

```bash
iptables -L  # List all rules for IPv4
## Shows INPUT, FORWARD, OUTPUT chains and their rules

iptables -L -v  # List rules with packet and byte counters
## Useful for seeing which rules are matching traffic

iptables -L INPUT  # List rules for INPUT chain only
## Shows all rules that match incoming packets

iptables -P INPUT DROP  # Set default policy for INPUT chain
## Packets not matching any rule are dropped

iptables -P FORWARD ACCEPT  # Set default policy for FORWARD chain
## Default policies: ACCEPT, DROP, or REJECT

iptables -N custom_chain  # Create a new custom chain
## User-defined chains for organizing rules

iptables -X custom_chain  # Delete a custom chain
## Chain must be empty and not referenced by other rules

iptables -F  # Flush (delete) all rules in all chains
## Dangerous; usually want to specify chain like iptables -F INPUT

iptables -F INPUT  # Flush all rules in INPUT chain
## Resets chain to default policy

iptables -Z  # Zero packet and byte counters
## Resets counters for all rules

iptables -v -L --line-numbers  # List rules with line numbers
## Essential for identifying which rule to modify
```

---

## 📋 Iptables: Rules (ACCEPT/DROP/REJECT)
*Add and manage firewall rules.*

```bash
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # Accept SSH traffic
## -A appends rule; -p specifies protocol; --dport is destination port

iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT  # Insert rule at position 1
## -I inserts at specific line number; shifts others down

iptables -D INPUT -p tcp --dport 22 -j ACCEPT  # Delete specific rule
## Must match exactly to delete

iptables -D INPUT 5  # Delete rule at line 5
## Easier than matching exact rule

iptables -R INPUT 5 -p tcp --dport 443 -j ACCEPT  # Replace rule at line 5
## Modifies rule without deleting and re-adding

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT  # Accept established connections
## Allows return traffic from outgoing connections

iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT  # Accept from subnet
## -s specifies source IP or network

iptables -A INPUT -d 10.0.0.5 -j DROP  # Drop traffic to destination IP
## -d specifies destination IP

iptables -A INPUT -p tcp ! --dport 22 -j DROP  # Drop all TCP except port 22
## ! negates the condition (except)

iptables -A INPUT -j REJECT --reject-with icmp-host-unreachable  # Reject with ICMP response
## REJECT tells sender packet was blocked; DROP is silent
```

---

## 🔄 Iptables: NAT & Masquerade
*Configure network address translation.*

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  # Enable masquerading
## Rewrites source IP to outgoing interface; enables NAT for internal networks

iptables -t nat -A PREROUTING -d 203.0.113.1 -j DNAT --to 192.168.1.100  # Destination NAT
## Rewrites destination IP; routes external traffic to internal server

iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to 192.168.1.100:80  # Port forwarding
## Forwards external port 8080 to internal 192.168.1.100:80

iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 203.0.113.50  # Source NAT
## Rewrites source IP for outgoing traffic; less common than masquerade

iptables -t nat -L  # List NAT rules
## Shows PREROUTING, POSTROUTING, and OUTPUT chains for nat table

iptables -t nat -F POSTROUTING  # Flush all NAT rules
## Dangerous; usually want to delete specific rules

iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE  # Delete masquerade rule
## Disables NAT for that interface
```

---

## 💾 Iptables: Save & Restore
*Persist iptables rules across reboots.*

```bash
iptables-save > /etc/iptables/rules.v4  # Save rules to file
## Standard location for IPv4 rules

ip6tables-save > /etc/iptables/rules.v6  # Save IPv6 rules
## Separate file for IPv6 rules

iptables-restore < /etc/iptables/rules.v4  # Restore rules from file
## Loads rules back after reboot or service restart

iptables-restore -c < /etc/iptables/rules.v4  # Restore with counters
## -c preserves packet/byte counters if file includes them

systemctl enable iptables  # Enable iptables service at boot
## Ensures rules are restored on system restart

systemctl start iptables  # Start iptables service
## Loads saved rules into kernel

systemctl save-state iptables  # Save current state
## Depends on iptables service configuration
```

---

## 🎯 Iptables: Common Patterns
*Frequently used firewall configurations.*

```bash
# Allow SSH, HTTP, HTTPS from anywhere
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow localhost (loopback)
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Drop all other incoming traffic
iptables -P INPUT DROP

# Allow all outgoing traffic
iptables -P OUTPUT ACCEPT

# Allow forwarding between interfaces
iptables -P FORWARD ACCEPT

# Rate limiting (5 connections per minute)
iptables -A INPUT -p tcp --dport 22 -m limit --limit 5/minute -j ACCEPT
## Prevents brute force attacks

# Block specific IP
iptables -A INPUT -s 192.168.1.100 -j DROP

# Logging before dropping
iptables -A INPUT -p tcp --dport 23 -j LOG --log-prefix "TELNET_ATTEMPT: "
iptables -A INPUT -p tcp --dport 23 -j DROP
## Logs all telnet attempts before dropping
```

---

## 🆕 Nftables: Tables & Chains
*Modern firewall framework replacing iptables.*

```bash
nft list tables  # List all tables
## Shows inet, ip, ip6, and arp tables

nft list table inet filter  # List rules in specific table
## inet table for both IPv4 and IPv6

nft create table inet myfirewall  # Create new table
## Tables are container for chains and rules

nft create chain inet myfirewall input { type filter hook input priority 0 \; policy drop \; }  # Create chain
## Hook types: ingress, input, forward, output, postrouting

nft list chain inet filter input  # List rules in specific chain
## Shows all rules in that chain

nft delete chain inet myfirewall input  # Delete chain
## Chain must be empty of rules
```

---

## 📍 Nftables: Rules
*Add and manage nftables rules.*

```bash
nft add rule inet filter input tcp dport 22 accept  # Accept SSH
## Simpler syntax than iptables

nft insert rule inet filter input tcp dport 22 accept  # Insert rule at beginning
## insert adds at start; add appends at end

nft delete rule inet filter input handle 5  # Delete rule by handle number
## Use 'list' with --handle to see handle numbers

nft replace rule inet filter input handle 5 tcp dport 443 accept  # Replace rule
## Modify rule by specifying handle

nft add rule inet filter input ip protocol tcp accept  # Accept TCP traffic
## Cleaner syntax than iptables

nft add rule inet filter input ip saddr 192.168.1.0/24 accept  # Accept from subnet
## ip saddr is source address

nft add rule inet filter input ct state established,related accept  # Accept established
## ct state for connection tracking
```

---

## 📦 Nftables: Sets
*Create and use named sets for rule optimization.*

```bash
nft add set inet filter allowed_ports { type inet_service \; }  # Create set of ports
## inet_service is port type; can also use ipv4_addr, ipv6_addr

nft add element inet filter allowed_ports { 22, 80, 443 }  # Add ports to set
## Comma-separated list

nft add rule inet filter input tcp dport @allowed_ports accept  # Use set in rule
## @ references set; prevents listing all ports individually

nft delete element inet filter allowed_ports { 443 }  # Remove port from set
## Useful for temporary rule changes

nft list set inet filter allowed_ports  # Show set contents
## Lists all elements in set
```

---

## 🔄 Nftables: NAT
*Network address translation with nftables.*

```bash
nft add rule inet nat postrouting oif eth0 masquerade  # Enable masquerading
## oif is outgoing interface

nft add rule inet nat prerouting iif eth0 dnat to 192.168.1.100  # Destination NAT
## iif is incoming interface

nft add rule inet nat prerouting tcp dport 8080 dnat to 192.168.1.100:80  # Port forwarding
## Cleaner syntax than iptables

nft add rule inet nat postrouting tcp dport 80 snat to 203.0.113.50  # Source NAT
## Rewrites source address
```

---

## 🔄 Migration from Iptables to Nftables
*Transition from iptables to nftables.*

```bash
iptables-save | nft -f -  # Convert iptables rules to nftables
## Reads iptables rules and converts to nftables syntax

nft -f /etc/nftables.conf  # Load nftables rules from config file
## Standard location: /etc/nftables.conf

systemctl enable nftables  # Enable nftables service at boot
## Loads rules on system startup

systemctl start nftables  # Start nftables service
## Activates firewall rules

nft list ruleset  # Show all nftables rules
## Complete view of all tables, chains, and rules

nft flush ruleset  # Remove all rules (reset to default)
## Dangerous; leaves system open to traffic

# Backup iptables before migration
iptables-save > /root/iptables-backup.v4
ip6tables-save > /root/iptables-backup.v6

# Install nftables
apt-get install nftables

# Load converted rules
iptables-save | nft -f -

# Enable service
systemctl enable nftables
systemctl restart nftables
```

---

## 🔧 Troubleshooting
*Debug firewall issues.*

```bash
iptables -L -n -v  # Show rules with IP addresses and counters
## -n prevents DNS lookups; -v shows packet counts

nft list ruleset --handle --all  # Show all rules with handles
## Handles needed for rule modification

iptables -t filter -L INPUT -n --line-numbers  # List with line numbers
## Essential for identifying rules to modify

nft list table inet filter --all  # Show complete table with all details
## Displays full configuration

ping -c 1 8.8.8.8  # Test outgoing connectivity
## If fails, check OUTPUT policy and rules

tcpdump -i eth0 'tcp port 22' -n  # Capture SSH traffic
## See actual packets matching rule criteria

sysctl net.ipv4.ip_forward  # Check IP forwarding enabled
## Must be 1 for routing/NAT to work

echo 1 > /proc/sys/net/ipv4/ip_forward  # Enable IP forwarding
## Required for NAT to function
```
