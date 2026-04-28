# ⚙️ Systemd — Cheat Sheet
*System and service manager for Linux that provides dependency-based startup ordering and parallel service startup.*

---

## 🎯 Service Management (systemctl)
*Control and manage systemd services.*

```bash
systemctl start nginx  # Start a service immediately
## Does not enable the service to start at boot

systemctl stop nginx  # Stop a running service
## Service remains disabled for future boots

systemctl restart nginx  # Stop and restart a service
## Useful for applying config changes without reboot

systemctl reload nginx  # Reload service configuration
## Gentler than restart; not all services support it

systemctl enable nginx  # Enable service to start at boot
## Creates symlink in /etc/systemd/system/multi-user.target.wants/

systemctl disable nginx  # Disable service from starting at boot
## Removes symlink; service remains running until stopped

systemctl status nginx  # Show current service status and recent logs
## Includes PID, memory usage, and last status change

systemctl is-enabled nginx  # Check if service is enabled for boot
## Returns 'enabled', 'disabled', or 'static'

systemctl is-active nginx  # Check if service is currently running
## Returns 'active' or 'inactive'

systemctl daemon-reload  # Reload systemd configuration
## Run after editing .service files before starting service

systemctl list-units --type=service --all  # List all services (running and stopped)
## Use --state=running to show only running services

systemctl mask nginx  # Prevent service from being started manually or at boot
## Creates symlink to /dev/null; stronger than disable
```

---

## ⏰ Timers
*Schedule tasks using systemd timers instead of cron.*

```bash
systemctl list-timers  # List all active timers
## Shows next trigger time and previous trigger

systemctl list-timers --all  # Show all timers including inactive ones
## Useful for seeing disabled but configured timers

systemctl start mybackup.timer  # Start a timer
## Must also enable it for boot persistence

systemctl enable mybackup.timer  # Enable timer at boot
## Pairs with associated .service file

systemctl status mybackup.timer  # Check timer status
## Shows when it will next trigger

systemctl stop mybackup.timer  # Stop an active timer
## Prevents further executions
```

Example timer unit file:
```ini
[Unit]
Description=Daily Backup Timer
Requires=mybackup.service

[Timer]
OnCalendar=daily  # Run daily at 00:00
OnCalendar=*-*-* 02:30:00  # Run at 2:30 AM every day
Persistent=true  # Run missed timers at next boot

[Install]
WantedBy=timers.target
```

---

## 🎚️ Targets
*Manage systemd targets (equivalent to runlevels).*

```bash
systemctl get-default  # Show current default target
## Usually multi-user.target for servers, graphical.target for desktops

systemctl set-default multi-user.target  # Set default boot target
## Changes /etc/systemd/system/default.target symlink

systemctl isolate graphical.target  # Switch to graphical target
## Activates all units in target; deactivates others

systemctl isolate rescue.target  # Switch to rescue mode
## Single-user mode for maintenance

systemctl list-units --type=target  # List all targets
## Shows active and inactive targets

systemctl list-dependencies multi-user.target  # Show dependencies for target
## Useful for understanding target startup order
```

---

## 📖 Journalctl & Logs
*Query and manage systemd journal logs.*

```bash
journalctl  # Display all journal entries
## Shows logs from all services; press 'q' to exit

journalctl -u nginx  # Show logs for specific service
## Filters to only nginx-related entries

journalctl -u nginx -n 50  # Show last 50 lines for a service
## Use -f for live follow (tail -f style)

journalctl -u nginx --since "1 hour ago"  # Show logs from specific time range
## Also supports dates like "2026-04-28 14:30:00"

journalctl -u nginx --until "2 hours ago"  # Show logs until specific time
## Combine with --since for time range

journalctl -p err  # Show only error and critical messages
## Severity levels: emerg, alert, crit, err, warning, notice, info, debug

journalctl -x  # Show log entries with explanatory help text
## Useful for understanding cryptic error messages

journalctl --vacuum-time=30d  # Delete journal entries older than 30 days
## Frees disk space; be careful not to delete needed logs

journalctl -b  # Show logs from current boot
## Use -b -1 for previous boot, -b -2 for boot before that

journalctl --no-pager  # Show output without pagination
## Useful for piping to other commands

journalctl -o verbose  # Show detailed log format
## Also supports json, short, cat formats
```

---

## 📝 Unit File Structure
*Create and configure systemd unit files.*

```ini
[Unit]
Description=Nginx Web Server
After=network.target  # Start after network target
Requires=network.target  # Require network target to be active
Wants=ssl-cert.service  # Soft dependency; doesn't fail if missing
Conflicts=apache2.service  # Prevent this and apache2 running together

[Service]
Type=simple  # Service type: simple, forking, oneshot, dbus, notify, idle
ExecStart=/usr/sbin/nginx -g daemon off;  # Command to start service
ExecStop=/bin/kill -s QUIT $MAINPID  # Command to stop service
ExecReload=/bin/kill -s HUP $MAINPID  # Command to reload config
Restart=always  # Restart policy: always, on-success, on-failure, on-abnormal
RestartSec=5  # Wait 5 seconds before restarting
StandardOutput=journal  # Send stdout to systemd journal
StandardError=journal  # Send stderr to systemd journal
User=www-data  # Run service as this user
Group=www-data  # Run service with this group
WorkingDirectory=/var/www  # Set working directory

[Install]
WantedBy=multi-user.target  # Install in this target
Alias=web.service  # Alternative name for service
```

---

## 🔌 Socket Activation
*Use systemd socket activation for on-demand service startup.*

```ini
# sshd.socket
[Unit]
Description=OpenSSH Server Socket
Before=sshd.service

[Socket]
ListenStream=22  # Listen on TCP port 22
ListenStream=[::]:22  # Also listen on IPv6
Accept=yes  # Accept incoming connections

[Install]
WantedBy=sockets.target
```

```bash
systemctl start sshd.socket  # Activate socket
## Service will start automatically when connection arrives

systemctl enable sshd.socket  # Enable socket at boot
## Service starts on demand when socket receives connection

systemctl status sshd.socket  # Check socket status
## Shows listening ports and connected units
```

---

## 🔧 Troubleshooting
*Debug systemd and service issues.*

```bash
systemctl status nginx -l  # Show full status without truncation
## -l shows complete lines of output

systemctl list-dependencies nginx  # Show what nginx depends on
## Useful for understanding startup order

systemctl list-dependencies nginx --reverse  # Show what depends on nginx
## See which services would be affected by stopping nginx

systemctl cat nginx  # Show nginx.service file
## Displays loaded unit file content

systemctl show nginx  # Show all properties of service
## Comprehensive output of service configuration

systemctl show nginx -p ExecStart  # Show specific property
## Useful for checking exact command being run

systemctl reset-failed  # Clear failed status for all services
## Allows services in failed state to be started again

systemctl reset-failed nginx  # Clear failed status for specific service
## Resets one service from failed state

journalctl -u nginx --since today  # Troubleshoot service issues
## Check logs from current day for errors

systemd-analyze  # Analyze boot time
## Shows slowest services and overall boot duration

systemd-analyze blame  # Rank services by startup time
## Identifies slowest services during boot

systemd-analyze critical-chain  # Show critical boot sequence
## Explains which services are slowing down boot

systemctl daemon-reload && systemctl start nginx  # Reload config then start
## Always reload daemon after editing .service files
```

---

## 🚀 Common Patterns
*Useful systemd configurations.*

```ini
# Service that requires other services
[Unit]
Description=Application Server
After=postgresql.service redis.service
Requires=postgresql.service redis.service

# Service with health check
[Unit]
Description=Health Check Service

[Service]
ExecStart=/usr/local/bin/health-check
ExecStop=/bin/kill $MAINPID
Restart=on-failure
RestartSec=10

# One-shot service for initialization
[Unit]
Description=Database Migration

[Service]
Type=oneshot
ExecStart=/usr/local/bin/migrate-db
RemainAfterExit=yes  # Service stays "active" after ExecStart completes

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload  # Always after editing unit files
systemctl enable myservice.service  # Enable at boot
systemctl start myservice.service  # Start immediately
systemctl status myservice.service  # Verify status
```
