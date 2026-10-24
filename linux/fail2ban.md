# Fail2ban

Fail2ban reads logs (SSH, web server…) and bans the IPs that fail too often, with a firewall rule. Main use: stop brute-force attacks on SSH.

[← Back to index](./README.md) · Firewall: [firewall.md](./firewall.md)

---

## How it works

```
log file / journal  →  filter (regex)  →  too many failures?  →  action: ban the IP in the firewall
```

| Word | Meaning |
|---|---|
| **Jail** | One protected service: a filter + a log + an action (e.g. `sshd`) |
| **Filter** | Regex that finds a failed attempt in the log (`filter.d/`) |
| **Action** | What to do with the IP: firewall rule, mail (`action.d/`) |
| `maxretry` | Number of failures before the ban |
| `findtime` | Time window to count the failures |
| `bantime` | How long the IP stays banned |

---

## Install

```bash
sudo apt install fail2ban                   # Debian / Ubuntu
sudo dnf install epel-release && sudo dnf install fail2ban fail2ban-firewalld   # RHEL / Rocky
sudo systemctl enable --now fail2ban
```

| Path | Content |
|---|---|
| `/etc/fail2ban/jail.conf` | Default settings: **never edit**, updates overwrite it |
| `/etc/fail2ban/jail.local` | My settings (or files in `jail.d/*.local`) |
| `/etc/fail2ban/filter.d/` | Filters |
| `/etc/fail2ban/action.d/` | Actions |
| `/var/log/fail2ban.log` | Bans and unbans |

---

## Protect SSH

`/etc/fail2ban/jail.local`:

```ini
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24    # Never ban my own network
banaction = nftables-multiport               # Or: iptables-multiport, firewallcmd-rich-rules, ufw

[sshd]
enabled = true
port    = ssh                                # Or the real port, e.g. 2222
backend = systemd                            # Read the journal (Debian 12+ has no auth.log)
```

```bash
sudo fail2ban-client reload
sudo fail2ban-client status sshd             # Check the jail is active
```

---

## Daily commands

```bash
sudo fail2ban-client status                          # List of jails
sudo fail2ban-client status sshd                     # Failures and banned IPs for sshd
sudo fail2ban-client set sshd unbanip 203.0.113.5    # Unban an IP
sudo fail2ban-client set sshd banip 203.0.113.5      # Ban an IP by hand
sudo fail2ban-client unban --all                     # Unban everything
sudo fail2ban-client reload                          # Reload the config
sudo tail -f /var/log/fail2ban.log                   # Watch bans live
sudo nft list ruleset | grep -A5 f2b                 # See the ban in the firewall (nftables)
```

---

## Custom filter

Example: ban IPs with too many failed logins (HTTP 401) on a web app.

`/etc/fail2ban/filter.d/myapp.conf`:

```ini
[Definition]
failregex = ^<HOST> .* "POST /login HTTP/[^"]*" 401
ignoreregex =
```

`<HOST>` = where the IP is in the log line.

Add the jail in `jail.local`:

```ini
[myapp]
enabled  = true
port     = http,https
filter   = myapp
logpath  = /var/log/nginx/access.log
maxretry = 5
```

Test the filter on the real log before enabling it:

```bash
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/myapp.conf
```

---

## Pitfalls

- Edit `jail.local`, never `jail.conf`.
- Put your own IP or network in `ignoreip` **before** testing, or you can lock yourself out.
- Debian 12+: no `/var/log/auth.log` by default → `backend = systemd` for sshd, or the jail does not start.
- SSH on another port: set `port` in the jail, or the ban blocks the wrong port.
- `banaction` must match the firewall in use (nftables, firewalld, ufw).
- Fail2ban only reacts to logs: it does not replace a firewall. Key-only SSH (`PasswordAuthentication no`) is the real protection.
- After a change: `reload`, then `status` to check the jail is active.
