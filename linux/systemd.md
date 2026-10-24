# systemd

Services, unit files, dependencies, timers, sockets, targets, journal, user services, troubleshooting.

[← Back to index](./README.md) · Boot and GRUB: [grub.md](./grub.md)

---

## Unit types

| Type | Extension | Use |
|---|---|---|
| Service | `.service` | A daemon or a command |
| Timer | `.timer` | Run a service on a schedule (cron alternative) |
| Socket | `.socket` | Start a service when a connection arrives |
| Target | `.target` | Group of units (like runlevels) |
| Mount | `.mount` | Mount point (generated from `/etc/fstab`) |
| Path | `.path` | Start a service when a file changes |
| Slice | `.slice` | Resource group (cgroup) |

---

## Manage services

```bash
systemctl start|stop|restart SVC
systemctl reload SVC              # Reload config without stopping (needs ExecReload=)
systemctl reload-or-restart SVC
systemctl status SVC              # State, PID, memory, last logs (-l = full lines)

systemctl enable SVC              # Start at boot (symlink in *.target.wants/)
systemctl enable --now SVC        # Enable + start
systemctl disable --now SVC       # Disable + stop
systemctl mask SVC                # Block every start (link to /dev/null)
systemctl unmask SVC

systemctl is-active SVC           # active / inactive / failed
systemctl is-enabled SVC          # enabled / disabled / static / masked
systemctl is-failed SVC
```

`static` = no `[Install]` section: started only by another unit.

## List and inspect

```bash
systemctl list-units --type=service              # Loaded services (--all = also inactive)
systemctl list-units --type=service --state=running
systemctl --failed
systemctl list-unit-files --type=service         # Installed + enable state

systemctl cat SVC                                # Unit file + drop-ins
systemctl show SVC                               # All properties
systemctl show SVC -p ExecStart -p User          # Some properties
systemctl list-dependencies SVC                  # What SVC needs
systemctl list-dependencies SVC --reverse        # What needs SVC
```

---

## Unit files

### Locations (highest priority first)

```
/etc/systemd/system/          # Your units and overrides
/run/systemd/system/          # Runtime (lost at reboot)
/usr/lib/systemd/system/      # Installed by packages — don't edit
```

### Change a unit: drop-in override

```bash
systemctl edit SVC            # Creates /etc/systemd/system/SVC.service.d/override.conf
systemctl edit --full SVC     # Copies the full unit to /etc/systemd/system/
systemctl revert SVC          # Remove your overrides
systemctl daemon-reload       # REQUIRED after editing files by hand
```

A drop-in only contains what changes:

```ini
# /etc/systemd/system/nginx.service.d/override.conf
[Service]
Restart=always
Environment="WORKERS=4"
```

To **replace** a list setting like `ExecStart`, empty it first:

```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/custom.conf
```

### Template

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
Documentation=https://example.com/docs
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/var/lib/myapp
Environment="LOG_LEVEL=info"
EnvironmentFile=-/etc/myapp/env       # "-" = OK if the file is missing
ExecStartPre=/usr/local/bin/myapp --check-config
ExecStart=/usr/local/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now myapp
systemd-analyze verify /etc/systemd/system/myapp.service   # Check syntax
```

### [Unit] — order and dependencies

Order and dependency are **separate**: `Requires=` without `After=` starts both at the same time.

| Setting | Meaning |
|---|---|
| `After=` / `Before=` | Order only |
| `Wants=` | Start the other unit too; OK if it fails (soft) |
| `Requires=` | Start the other unit too; stop me if it stops (hard) |
| `BindsTo=` | Like Requires, and stop me if it disappears |
| `Conflicts=` | Can't run together |
| `PartOf=` | Restart/stop me with the other unit |

Usual pair: `Wants=network-online.target` + `After=network-online.target`.

### [Service] — Type

| Type | The service is "started" when... |
|---|---|
| `simple` (default) | The process is launched |
| `exec` | The binary has been executed successfully |
| `forking` | The parent exits (old daemons; add `PIDFile=`) |
| `oneshot` | The command finished (scripts; often with `RemainAfterExit=yes`) |
| `notify` | The service sends "ready" to systemd |

### [Service] — other useful settings

| Setting | Use |
|---|---|
| `Restart=` | `no`, `on-failure`, `always`, `on-abnormal` |
| `RestartSec=` | Wait before restart |
| `TimeoutStartSec=` / `TimeoutStopSec=` | Max time to start / stop |
| `User=` / `Group=` | Run as |
| `Environment=` / `EnvironmentFile=` | Variables |
| `ExecStartPre=` / `ExecStartPost=` / `ExecStop=` | Extra commands |
| `MemoryMax=` / `CPUQuota=50%` | Resource limits |
| `NoNewPrivileges=yes`, `PrivateTmp=yes`, `ProtectSystem=strict` | Hardening |

### [Install]

| Setting | Use |
|---|---|
| `WantedBy=multi-user.target` | Start at boot (normal server) |
| `WantedBy=timers.target` | For timers |
| `Alias=` | Other name |

### Oneshot example

```ini
[Unit]
Description=Database migration
After=postgresql.service
Requires=postgresql.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/migrate-db
RemainAfterExit=yes          # Stays "active" after the command

[Install]
WantedBy=multi-user.target
```

---

## Timers

Two files with the same name: `backup.timer` starts `backup.service`.

```ini
# /etc/systemd/system/backup.service
[Unit]
Description=Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily backup

[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true              # Run at boot if the machine was off at 02:30
RandomizedDelaySec=5min      # Spread the load

[Install]
WantedBy=timers.target
```

```bash
systemctl daemon-reload
systemctl enable --now backup.timer      # Enable the TIMER, not the service
systemctl list-timers --all              # Next and last run
systemctl start backup.service           # Test the job now
journalctl -u backup.service             # Job output
```

| Setting | Example | Meaning |
|---|---|---|
| `OnCalendar=` | `daily` | Every day 00:00 |
| | `Mon *-*-* 09:00` | Monday 09:00 |
| | `*-*-* *:00/15` | Every 15 minutes |
| | `*-*-01 00:00` | First day of the month |
| `OnBootSec=` | `10min` | 10 min after boot |
| `OnUnitActiveSec=` | `1h` | 1 h after the last run |

```bash
systemd-analyze calendar "Mon *-*-* 09:00"       # Check an OnCalendar value
systemd-run --on-calendar="*-*-* 03:00" /usr/local/bin/job.sh   # Quick timer without files
systemd-run --on-active=30m /usr/local/bin/job.sh               # Once, in 30 min
```

---

## Socket activation

systemd listens on the port. The service starts at the first connection.

```ini
# /etc/systemd/system/myapp.socket
[Socket]
ListenStream=8080

[Install]
WantedBy=sockets.target
```

```bash
systemctl enable --now myapp.socket      # Starts myapp.service on demand
systemctl list-sockets
```

`Accept=yes` starts one service instance per connection and needs a template unit (`myapp@.service`).

---

## Targets

```bash
systemctl get-default
systemctl set-default multi-user.target    # Text mode (link /etc/systemd/system/default.target)
systemctl set-default graphical.target     # Desktop
systemctl isolate rescue.target            # Switch now
systemctl default                          # Go back to the default target
systemctl list-units --type=target
systemctl list-dependencies multi-user.target
```

| Target | Old runlevel | Use |
|---|---|---|
| poweroff.target | 0 | Halt |
| rescue.target | 1 | Single user, root password |
| multi-user.target | 3 | Multi-user, no GUI |
| graphical.target | 5 | Multi-user + GUI |
| reboot.target | 6 | Reboot |
| emergency.target | — | Read-only root, minimal shell |

Rescue and emergency at boot: see [grub.md](./grub.md#rescue-and-emergency-modes).

---

## Journal (journalctl)

```bash
journalctl -e                    # Jump to the end
journalctl -f                    # Follow
journalctl -u nginx              # One unit (-u several times = several units)
journalctl -u nginx -n 50        # Last 50 lines
journalctl -u nginx -f
journalctl -xe                   # End + explanations
journalctl -b                    # Current boot (-b -1 = previous boot)
journalctl --list-boots
journalctl -p err -b             # Errors (and worse) since boot
journalctl --since "1 hour ago"
journalctl --since "2026-01-01 08:00" --until "2026-01-01 12:00"
journalctl --since today
journalctl _PID=1234 ; journalctl _UID=1000
journalctl -k                    # Kernel messages (like dmesg)
journalctl -o verbose            # All fields (json, cat, short-iso...)
journalctl --no-pager | grep error
```

Priorities: 0 emerg, 1 alert, 2 crit, 3 err, 4 warning, 5 notice, 6 info, 7 debug.

### Journal size and persistence

```bash
journalctl --disk-usage
journalctl --vacuum-time=30d     # Delete older than 30 days
journalctl --vacuum-size=500M
```

```ini
# /etc/systemd/journald.conf
[Journal]
Storage=persistent               # Keep logs after reboot (/var/log/journal)
SystemMaxUse=500M
```

```bash
systemctl restart systemd-journald
```

If `/var/log/journal/` does not exist, logs may be in memory only (`/run/log/journal`) and lost at reboot.

---

## User services

Services of a normal user, without root.

```bash
mkdir -p ~/.config/systemd/user
# ~/.config/systemd/user/myapp.service ([Install] WantedBy=default.target)
systemctl --user daemon-reload
systemctl --user enable --now myapp
systemctl --user status myapp
journalctl --user -u myapp

loginctl enable-linger $USER     # Keep user services running after logout
```

---

## Troubleshooting

```bash
systemctl status SVC -l
journalctl -u SVC -b -e
systemctl cat SVC                        # Which files are really used?
systemctl show SVC -p ExecStart
systemd-analyze verify SVC.service       # Errors in the unit file
systemctl reset-failed SVC               # Clear the failed state (start limit)

systemd-analyze                          # Boot time
systemd-analyze blame                    # Slowest units
systemd-analyze critical-chain           # What delayed the boot
systemd-analyze security SVC             # Hardening score
```

| Symptom | Check |
|---|---|
| Changes ignored | `systemctl daemon-reload` |
| "Unit is masked" | `systemctl unmask SVC` |
| "start request repeated too quickly" | Fix the cause, then `reset-failed` |
| Service starts then stops | `Type=` wrong (forking vs simple), `journalctl -u` |
| Not started at boot | `is-enabled`, `[Install]` section, `WantedBy=` |
| Starts before the network | `After=` + `Wants=network-online.target` |
| Permission denied, files look OK | `User=`, SELinux (`ausearch -m AVC`) |

---

## Pitfalls

- After editing a unit file: `systemctl daemon-reload`.
- `enable` ≠ `start`: use `enable --now`.
- `mask` blocks even starts by dependencies.
- `reload` works only with `ExecReload=`; otherwise `restart`.
- Don't edit files in `/usr/lib/systemd/system/`: use `systemctl edit`.
- In a drop-in, empty `ExecStart=` before setting a new one.
- `Requires=` does not set the order: add `After=`.
- Timers: enable the `.timer`, not the `.service`.
- Without persistent storage, the journal is lost at reboot.
