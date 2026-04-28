# Linux CLI - Networking Cheat Sheet

## NMAP - Network Scanning

### TCP Scan (SYN Stealth Scan)
- Scans only the most common 1750 ports (much faster than full scan)
- Uses SYN packets (stealth method)
```bash
nmap -sS 10.8.97.1
```

### UDP Scan
- Scans UDP ports (slower but catches UDP services)
```bash
nmap -sU 10.8.97.1
```

---

## DIG - DNS Lookup

### Query DNS server
- Lookup hostname on specific DNS server (10.8.98.235)
```bash
dig @10.8.98.235 www.itinet.fr
```

---

## TCPDUMP - Packet Capture

### Capture HTTP Traffic
- `-n`: Do not resolve hostnames (faster)
- `-i eth0`: Capture on eth0 interface
- `port http`: Filter for HTTP traffic (port 80)
```bash
tcpdump -n -i eth0 port http
tcpdump -n -i eth0 port 81
```

### Common Tcpdump Options
```bash
tcpdump -i eth0 -c 100        # Capture 100 packets
tcpdump -i eth0 -w dump.pcap  # Save to file
tcpdump -i eth0 src 192.168.1.100  # Filter by source IP
tcpdump -i eth0 dst 192.168.1.1    # Filter by destination IP
```

---

## Other Network Tools

### Check listening ports
```bash
ss -tlnp    # TCP, Listen, Numeric, Process
netstat -tlnp
```

### Network interface info
```bash
ip addr show
ifconfig
```
