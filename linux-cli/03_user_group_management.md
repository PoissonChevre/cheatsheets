# LFCS — User & Group Management (10%)

> Users, groups, sudo, password aging, environment, resource limits, sessions.

---

## User Account Creation

```bash
useradd jack                         # Create user (low-level, NO home by default on RHEL)
useradd -m jack                      # Create with home directory
useradd -m -s /bin/bash jack         # + specify shell
useradd -m -s /bin/bash -G dev,ops jack         # + supplementary groups
useradd -m -s /bin/bash -G dev -u 5322 jack     # + specific UID
useradd -m -s /bin/bash -d /home/custom/jack jack   # + custom home

# Common pattern:
useradd -m -s /bin/bash -G wheel,docker username

# Debian/Ubuntu interactive wrapper (creates home + asks password):
adduser jack
adduser --shell /bin/bash --home /home/custom/jack jack
```

### useradd options

| Option | Effect |
|---|---|
| `-m` | Create home directory |
| `-s /bin/bash` | Login shell |
| `-G grp1,grp2` | Supplementary groups (creates a NEW user, no `-a` needed) |
| `-g group` | Primary group (lowercase!) |
| `-u 1500` | Specific UID |
| `-d /path` | Custom home directory |
| `-c "Comment"` | GECOS field (full name) |
| `-e 2026-12-31` | Account expiration date |

**Pitfall:** `useradd` is the scriptable, predictable command. `adduser` is the Debian interactive wrapper. **Use `useradd` at exam.**

---

## User Modification

```bash
usermod -a -G dev jack               # APPEND to group dev (CRITICAL: -a)
usermod -G dev jack                  # ⚠ REPLACES all supplementary groups!
usermod -g rugby jack                # Change PRIMARY group
usermod -L jack                      # Lock account (! prefix in /etc/shadow)
usermod -U jack                      # Unlock account
usermod -s /bin/zsh jack             # Change login shell
usermod -d /new/home jack            # Change home (does NOT move files)
usermod -d /new/home -m jack         # Change home AND move files
usermod -e 2030-03-01 jack           # Set expiration
usermod -e "" jack                   # Remove expiration (never expires)
usermod -l newname oldname           # Rename user
```

### Group flags — the trap

| Flag | Effect |
|---|---|
| `-g group` (lowercase) | **Primary** group |
| `-G grp1,grp2` (uppercase, no -a) | Replace **all** supplementary groups |
| `-aG grp1,grp2` (with -a) | **Append** to supplementary groups |

**Critical pitfall:** `usermod -G` without `-a` REMOVES all other groups. Always use `-aG` to add to groups.

---

## User Deletion

```bash
userdel jack                         # Delete user, KEEP home
userdel -r jack                      # Delete user AND home + mail spool
deluser john                         # Debian interactive wrapper
deluser --remove-home john           # Debian: + remove home
```

**Pitfall:** `userdel` without `-r` leaves orphaned `/home/jack`. Almost always use `-r`.

---

## Password Management

```bash
passwd                               # Change own password
passwd jack                          # Change jack's (root)
sudo passwd jack                     # Same with sudo

passwd -l jack                       # Lock account (adds ! to hash)
passwd -u jack                       # Unlock
passwd -d jack                       # Delete password (passwordless)
passwd -e jack                       # Force change at next login
passwd -S jack                       # Show password status
```

**Pitfall:** `passwd -l` and `usermod -L` lock the password but do NOT prevent SSH key login. To fully disable SSH access, also set:

```bash
chage -E 0 jack                      # Expire account
usermod -s /usr/sbin/nologin jack    # Disable shell
```

---

## Account / Password Aging (chage)

```bash
chage -l jack                        # Display password aging info
chage jack                           # Interactive edit
sudo chage jack                      # Same as root

chage -W 7 jack                      # Warn 7 days before password expires
chage -M 90 jack                     # Maximum password age: 90 days
chage -m 7 jack                      # Minimum password age: 7 days
chage -E 2026-12-31 jack             # Account expiration date
chage -E -1 jack                     # Remove expiration
chage -I 30 jack                     # Inactivity period after pwd expiry
chage -d 0 jack                      # Force password change at next login
chage --lastday 0 jack               # Same (force change next login)
```

---

## Group Management

```bash
groupadd dev                         # Create group
groupadd -g 9875 dev                 # With specific GID

groupmod -n newname oldname          # Rename group (preserves GID)
groupmod -g 1500 dev                 # Change GID

groupdel dev                         # Delete group (must have no primary members)

groups                               # Current user's groups
groups jack                          # Jack's groups
id jack                              # UID, primary GID, all groups
getent group dev                     # Show group entry (incl. LDAP/etc.)
getent passwd jack                   # Show user entry from passwd databases

gpasswd -a jack wheel                # Add jack to wheel
gpasswd -d jack wheel                # Remove jack from wheel
gpasswd -A admin1,admin2 dev         # Set group administrators
gpasswd dev                          # Set group password (rarely used)
```

---

## Sudo & Privilege Escalation

```bash
sudo command                         # Run as root (default)
sudo -u jack command                 # Run as another user
sudo -u jack -g devs command         # As user AND group
sudo -i                              # Interactive root LOGIN shell
sudo -s                              # Root shell (non-login)
sudo -k                              # Reset cached credentials
sudo -l                              # List own sudo permissions
sudo -l -U jack                      # List jack's sudo permissions
sudo -ll -U jack                     # Long format

su -                                 # Switch to root with full env
su - jack                            # Switch to jack with jack's env
su jack                              # Switch but keep current env

visudo                               # Edit /etc/sudoers safely (syntax check on save)
visudo -c                            # Check syntax without editing
visudo -f /etc/sudoers.d/myrule      # Edit a drop-in policy file
```

### Sudoers Syntax

```
user    host=(run_as_user:run_as_group) [tags:] command_list
```

| Field | Meaning |
|---|---|
| user | Who runs the rule (or `%group`) |
| host | On which hosts (`ALL` for any) |
| (run_as) | What identity to use (`(ALL)` = anyone, `(root)` = root only) |
| tags | `NOPASSWD:`, `PASSWD:`, etc. |
| commands | Commands allowed (full paths!) |

### Sudoers Examples

```
# Full power
jack    ALL=(ALL)        ALL                    # Run any command as anyone
jack    ALL=(ALL:ALL)    ALL                    # + as any group

# Run as root only (more restrictive, preferred)
jack    ALL=(root)       ALL

# Restricted commands
jack    ALL=(root)       /bin/systemctl, /bin/ls

# No password required
jack    ALL=(root)       NOPASSWD: /bin/bash /root/dangerous.sh

# Group-based
%developers ALL=(ALL)    ALL
%sudo       ALL=(ALL)    NOPASSWD: ALL          # Ubuntu 'sudo' group

# Drop-in file (recommended over /etc/sudoers)
echo "user2 ALL=(root) NOPASSWD: /bin/bash /root/dangerous.sh" \
    | sudo tee /etc/sudoers.d/user2
```

### `(ALL)` vs `(root)`

```
user2 ALL=(ALL)  NOPASSWD: /bin/bash /root/dangerous.sh
# user2 can run as ANY user (root, alice, bob, etc.)

user2 ALL=(root) NOPASSWD: /bin/bash /root/dangerous.sh
# user2 can run ONLY as root (more secure, principle of least privilege)
```

**Best practice:** Use `(root)` unless the task explicitly says "any user".

### Sudoers Pitfalls

- **Always use `visudo`**, never `vim /etc/sudoers` — syntax check prevents lockout
- **Always use absolute paths** for commands (`/bin/bash`, not `bash`)
- **`NOPASSWD:`** has a colon, must precede the command
- **Drop-in files** in `/etc/sudoers.d/` are loaded in lexical order
- **Ubuntu** uses `sudo` group; **RHEL** uses `wheel` group
- **`sudo -l`** verifies what is actually allowed for a user

---

## Authentication Files (read-only reference)

```
/etc/passwd       username:x:UID:GID:GECOS:home:shell
/etc/shadow       username:hashed_password:lastchange:min:max:warn:inactive:expire
/etc/group        groupname:x:GID:member1,member2
/etc/gshadow      group password / administrators
/etc/sudoers      sudo policies (use visudo!)
/etc/sudoers.d/   drop-in sudo policies
/etc/login.defs   default settings (UID_MIN, PASS_MAX_DAYS...)
/etc/skel/        template files copied to new user homes
/etc/default/useradd    useradd defaults
```

### /etc/passwd line example

```
jack:x:1001:1001:Jack Smith:/home/jack:/bin/bash
│   │ │    │   │           │          └─ shell
│   │ │    │   │           └─ home directory
│   │ │    │   └─ GECOS (full name, info)
│   │ │    └─ primary GID
│   │ └─ UID
│   └─ password placeholder (real one in /etc/shadow)
└─ username
```

### /etc/shadow line example

```
jack:$6$abc...xyz:19500:0:90:7:30::
│    │             │     │ │  │ │ └─ unused
│    │             │     │ │  │ └─ inactive period (days after expiry)
│    │             │     │ │  └─ warning (days before expiry)
│    │             │     │ └─ max age
│    │             │     └─ min age
│    │             └─ last password change (days since 1970-01-01)
│    └─ hashed password (! or * = locked)
└─ username
```

---

## User Environment

```bash
echo $VAR                            # Print value of variable
env                                  # Show all environment variables
printenv                             # Same as env
export VAR=value                     # Set for current shell + children
unset VAR                            # Remove variable
source ~/.bashrc                     # Re-read shell init file
. ~/.bashrc                          # POSIX shorthand
```

### Bash startup files (per user)

```
~/.bash_profile        # Login shell only — read once at login
~/.bash_login          # Fallback if ~/.bash_profile missing
~/.profile             # POSIX login init (Ubuntu default)
~/.bashrc              # Interactive non-login shells
~/.bash_logout         # Run at logout
```

### System-wide

```
/etc/profile               # Login shells, all users
/etc/profile.d/*.sh        # Drop-in scripts auto-sourced
/etc/bashrc                # Non-login shells (RHEL)
/etc/bash.bashrc           # Non-login shells (Debian)
/etc/environment           # Simple KEY=value (NOT a shell script)
```

### Setting persistent env variables

```bash
# For all users
echo 'export MYVAR=value' >> /etc/profile.d/myvar.sh

# For one user
echo 'export MYVAR=value' >> ~/.bashrc

# Apply without logout
source ~/.bashrc
```

### export vs no-export

```bash
TEST1=foo                            # Local to current shell
export TEST2=bar                     # Available to child processes too

bash                                 # Spawn child shell
echo $TEST1                          # Empty (not exported)
echo $TEST2                          # bar (exported)
```

---

## Resource Limits

```bash
ulimit -a                            # Show all current limits
ulimit -n 4096                       # Open files (soft limit)
ulimit -u                            # Max user processes (nproc)
ulimit -f                            # Max file size
ulimit -v                            # Virtual memory
ulimit -c                            # Core file size
```

### Persistent limits — `/etc/security/limits.conf`

```
# Format:  <domain>  <type>  <item>  <value>
#
# domain: username | @groupname | * (everyone)
# type:   soft | hard
# item:   nproc | nofile | maxlogins | priority | etc.

jack         soft    nproc       1024
jack         hard    nproc       2048
@developers  soft    nofile      8192
@operators   hard    maxlogins   1
*            hard    core        0
```

### Drop-in files

```
/etc/security/limits.d/*.conf        # Recommended over editing limits.conf
```

### Common limits

| Item | Meaning |
|---|---|
| `nproc` | Max number of processes |
| `nofile` | Max open files |
| `maxlogins` | Max simultaneous logins |
| `fsize` | Max file size |
| `priority` | Default nice value |
| `core` | Core file size (0 to disable) |

**Pitfall:** Hard limit cannot be raised by user once set, only by root. Soft limit can be raised up to hard limit.

---

## Sessions / Logged-in Users

```bash
w                                    # Who is logged in + activity
who                                  # Logged-in users + login source
whoami                               # Current effective user
users                                # Just usernames
last                                 # Recent login history
last -F                              # Full dates
last -n 10                           # Last 10 logins
lastb                                # Failed login attempts (root only)
lastlog                              # Last login per user
finger user                          # User info (if installed)
pinky user                           # Lightweight finger alternative
```

---

## Pitfalls Summary

```bash
# 1. usermod -G  WITHOUT -a  REMOVES all other supplementary groups.
#    ALWAYS use -aG to APPEND.

# 2. usermod -g (lowercase) sets PRIMARY group.
#    usermod -G (uppercase) sets SUPPLEMENTARY groups.
#    usermod -aG = APPEND.

# 3. userdel without -r leaves /home behind.

# 4. passwd -l locks password but does NOT prevent SSH key login.
#    Combine with chage -E 0 to fully expire account.

# 5. After editing /etc/sudoers manually, system can be unusable.
#    ALWAYS use visudo (syntax check on save).

# 6. Ubuntu uses 'sudo' group; RHEL uses 'wheel' group.

# 7. (ALL) is permissive; (root) is principle of least privilege.

# 8. Drop-in files in /etc/sudoers.d/ load in lexical order.
#    Use 99-* to make sure your file loads last.

# 9. usermod -d without -m changes /etc/passwd but does NOT move files.
#    Use -dm to do both.

# 10. chage -d 0  =  force password change at next login.
```
