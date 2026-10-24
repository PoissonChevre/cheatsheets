# Nagios — Cheat Sheet

Check-based monitoring: Nagios runs small programs (plugins) on a schedule, shows the state of every host and service, and sends an alert when a state changes. Centreon is built on the same ideas.

---

## How it works

1. A **plugin** tests something (ping, HTTP, disk…).
2. The plugin prints one line of text and returns an **exit code**.
3. Nagios turns the exit code into a **state**, shows it in the web UI, and notifies the contacts if it changed.

| Exit code | State |
|---|---|
| `0` | OK |
| `1` | WARNING |
| `2` | CRITICAL |
| `3` | UNKNOWN |

Remote machines: an **agent** runs local checks (disk, load) for Nagios. NRPE or NCPA on Linux, NSClient++ on Windows. Network devices: SNMP.

---

## Install (Debian / Ubuntu)

```bash
sudo apt install nagios4 monitoring-plugins nagios-nrpe-plugin   # Server
sudo apt install nagios-nrpe-server monitoring-plugins           # Each monitored Linux host
```

| | Debian package | Source install |
|---|---|---|
| Config | `/etc/nagios4/` | `/usr/local/nagios/etc/` |
| Plugins | `/usr/lib/nagios/plugins/` | `/usr/local/nagios/libexec/` |
| Web UI | `http://SERVER/nagios4` | `http://SERVER/nagios` |

---

## Run a plugin by hand

Always test a plugin by hand before adding it to the config.

```bash
cd /usr/lib/nagios/plugins
./check_ping -H 10.0.0.21 -w 100,20% -c 500,60%   # Warning: 100 ms or 20 % loss
./check_http -H 10.0.0.21                          # Web server answers?
./check_ssh -H 10.0.0.21                           # SSH answers?
./check_disk -w 20% -c 10% -p /                    # Free space on /
./check_load -w 5,4,3 -c 10,8,6                    # Load average (1, 5, 15 min)
echo $?                                            # Exit code = the state
```

`-w` = warning threshold, `-c` = critical threshold.

---

## Configuration objects

Files in the `objects/` folder of the config. Each object is a `define` block.

```
define host {
    use         linux-server        ; Template with default settings
    host_name   web01
    alias       Web server
    address     10.0.0.21
}

define service {
    use                 generic-service
    host_name           web01
    service_description HTTP
    check_command       check_http
}

define service {
    use                 generic-service
    host_name           web01
    service_description Disk /
    check_command       check_nrpe!check_disk    ; ! = argument passed to the command
}

define command {
    command_name    check_nrpe
    command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
```

| Object | Role |
|---|---|
| `host` | A machine to monitor |
| `service` | A check on a host (HTTP, disk…) |
| `command` | How to run a plugin |
| `contact` | Who gets the alerts, and how |
| `hostgroup` | A group of hosts (e.g. all Linux servers) |
| `timeperiod` | When to check and when to notify |

`$USER1$` = the plugins folder · `$HOSTADDRESS$` = the host IP · `$ARG1$` = first argument after `!`.

---

## Check the config and restart

```bash
sudo nagios4 -v /etc/nagios4/nagios.cfg     # Check the config (source install: nagios -v ...)
sudo systemctl restart nagios4
sudo systemctl status nagios4
```

---

## NRPE (agent on a Linux host)

On the **monitored host**, in `/etc/nagios/nrpe.cfg`:

```
allowed_hosts=127.0.0.1,10.0.0.10           # IP of the Nagios server
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_load]=/usr/lib/nagios/plugins/check_load -w 5,4,3 -c 10,8,6
```

```bash
sudo systemctl restart nagios-nrpe-server
sudo ufw allow from 10.0.0.10 to any port 5666 proto tcp    # NRPE port
```

From the **Nagios server**:

```bash
/usr/lib/nagios/plugins/check_nrpe -H 10.0.0.21                  # NRPE version = connection OK
/usr/lib/nagios/plugins/check_nrpe -H 10.0.0.21 -c check_disk
```

NRPE is in maintenance mode. Nagios now recommends NCPA, which works the same way.

---

## Write a simple plugin

Any script works: print one line, return the right exit code.

```bash
#!/bin/bash
# check_index: OK if the web page file exists, CRITICAL if not

FILE=/var/www/html/index.html

if [ -f "$FILE" ]; then
    echo "OK - $FILE exists"
    exit 0
else
    echo "CRITICAL - $FILE is missing"
    exit 2
fi
```

Copy it to the plugins folder, `chmod +x`, then add a `command` and a `service`.

---

## Pitfalls

- Run `nagios4 -v` before each restart: one config error and Nagios does not start.
- Test plugins as the `nagios` user: `sudo -u nagios ./check_disk -w 20% -c 10% -p /`.
- Nagios reads the **exit code**, not the text: a plugin that prints "CRITICAL" but returns `0` is OK.
- NRPE: the server IP must be in `allowed_hosts`, and port 5666 must be open.
- Define the NRPE commands on the monitored host: don't allow arguments from the server (`dont_blame_nrpe=0`).
- The plugins folder is not the same for a package and a source install.
