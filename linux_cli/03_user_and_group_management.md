# LFCS — User & Group Management (10%)

## User Account Creation

```bash
useradd jack                                 # Create user jack (low-level, no home by default on RHEL)
useradd -m jack                              # Create user with home directory
useradd -s /bin/csh -m jack                  # Create user jack with /bin/csh as login shell + home
useradd -G soccer sam --uid 5322             # Create user sam with UID 5322, also member of soccer group
useradd -m -s /bin/bash -G wheel,docker user # Common pattern: home + bash + supplementary groups

adduser jack                                 # Debian/Ubuntu interactive wrapper (creates home, prompts password)
adduser --shell /bin/othershell --home /home/otherdir/ john    # Custom shell + home
```

## User Account Modification

```bash
usermod -a -G developers jane          # Add user jane to group developers (-a APPEND, critical!)
usermod -G developers jane             # WITHOUT -a → REPLACES all supplementary groups (dangerous)
usermod -g rugby sam                   # Update primary group of user sam to rugby
usermod -L sam                         # Lock user account (disables password)
usermod -U sam                         # Unlock user account
usermod -s /bin/zsh jane               # Change login shell
usermod -d /new/home -m jane           # Change home directory and move contents
usermod -e 2030-03-01 jane             # Set jane's account to expire on 2030-03-01
usermod -e "" jane                     # Unexpire jane's account (never expires)
```

## User Account Deletion

```bash
userdel jack                # Delete user (keeps home directory)
userdel -r jack             # Delete user AND remove home directory + mail spool
deluser john                # Debian: remove user, keep home
deluser --remove-home john  # Debian: remove user + home directory
```

## Password Management

```bash
passwd                      # Change current user's password
passwd john                 # Change john's password (root only)
sudo passwd john            # Set / reset password for john

passwd -l john              # Lock account (prefixes ! in /etc/shadow)
passwd -u john              # Unlock account

passwd -e john              # Force password change at next login
chage --lastday 0 jane      # Force jane to change password on next login (mark expired)
```

## Account / Password Expiration (chage)

```bash
chage -l john               # List password aging info for john
chage john                  # Interactive — change all aging options
sudo chage john             # Set user password expiration date interactively

chage -W 2 jane             # Warn jane 2 days before password expires
chage -M 90 jane            # Maximum password age: 90 days
chage -m 7 jane             # Minimum password age: 7 days
chage -E 2026-12-31 jane    # Account expiry date
chage -I 30 jane            # Inactivity period after password expiry (days)
```

## Group Management

```bash
groupadd developers                       # Create group developers
groupadd -g 9875 cricket                  # Create group cricket with GID 9875

groupmod -n soccer cricket                # Rename group cricket → soccer (preserves GID)
groupmod -g 1500 developers               # Change GID of group

groupdel appdevs                          # Delete the group appdevs

groups                                    # Groups of current user
groups jane                               # Groups jane belongs to
id jane                                   # UID, primary GID, all groups
getent group developers                   # Show group entry from /etc/group + LDAP/etc.
getent passwd jane                        # Show user entry from passwd databases

gpasswd -a trinity wheel                  # Add user trinity to group wheel (sudo group)
gpasswd -d trinity wheel                  # Remove user trinity from group wheel
gpasswd -A admin1,admin2 developers       # Set group administrators
```

## Sudo & Privilege Escalation

```bash
sudo command                              # Run command as root (default)
sudo -u trinity ls /home/trinity/         # Run command as another user
sudo -i                                   # Interactive root shell (login shell)
sudo -s                                   # Root shell (non-login)
su -                                      # Switch to root, login shell
su - jane                                 # Switch to user jane with her environment

sudo visudo                               # Safely edit /etc/sudoers (syntax-checks on save)
visudo -f /etc/sudoers.d/myrule           # Edit a drop-in policy file safely
```

### sudoers syntax (5 fields)

```
user/group  host=(run_as_user:run_as_group)  command_list
```

```
trinity ALL=(ALL) ALL                # trinity may run any command as any user
trinity ALL=(aaron, john) ALL        # trinity may run cmds only as aaron or john
trinity ALL= ALL                     # third field optional → defaults to root
trinity ALL=(ALL) /bin/ls, /bin/stat # trinity may only run ls and stat
%developers ALL=(ALL) ALL            # entire group developers
%sudo ALL=(ALL) NOPASSWD: ALL        # passwordless sudo for sudo group
```

## Authentication Files (read-only reference)

```bash
/etc/passwd     # username:x:UID:GID:GECOS:home:shell
/etc/shadow     # username:hashed_password:lastchange:min:max:warn:inactive:expire
/etc/group      # groupname:x:GID:member1,member2
/etc/gshadow    # group password / administrators
/etc/sudoers    # sudo policies (edit only via visudo)
/etc/sudoers.d/ # drop-in sudo policy directory
/etc/login.defs # default shadow / aging settings for new users
/etc/skel/      # template files copied to new user homes
```

## User Environment

```bash
echo $MYVAR                 # Print value of an environment variable
env                         # Print full current environment
export VAR=value            # Set environment variable for current shell + children
source ~/.bashrc            # Re-read shell environment file (apply changes now)
. ~/.bashrc                 # Same — POSIX shorthand

# Per-user shell init files:
~/.bash_profile             # Login shell — read once at login
~/.bashrc                   # Interactive non-login shell
~/.profile                  # POSIX-compatible login init (Ubuntu default)
~/.bash_logout              # Run at logout

# System-wide:
/etc/profile                # Sourced by login shells for all users
/etc/profile.d/*.sh         # Drop-in scripts auto-sourced
/etc/bashrc | /etc/bash.bashrc   # Non-login shell defaults (RHEL | Debian)
```

## Resource Limits

```bash
ulimit -a                   # Show all current limits for the shell
ulimit -n 4096              # Set max open files (soft limit)
ulimit -u                   # Max number of user processes (nproc)

# Persistent limits — /etc/security/limits.conf
# Format:  <domain>  <type>  <item>  <value>
# Examples:
#   john     soft    nproc       1024     # Soft limit on number of processes
#   john     hard    nproc       2048     # Hard limit on number of processes
#   @dev     soft    nofile      8192     # Group "dev" — soft open-files limit
```

## Logged-in / Session Information

```bash
w                           # Who is logged in and what they are doing
who                         # Logged-in users with login time / source
whoami                      # Current effective username
users                       # Just usernames currently logged in
last                        # History of past logins
last -F                     # Show full login dates
lastb                       # Failed login attempts (root only)
finger user                 # Detailed user info (if installed)
```

## Common Pitfalls (Pièges LFCS)

```bash
# 1. usermod -G  WITHOUT -a  REMOVES all other supplementary groups.
#    ALWAYS use -a -G to APPEND.

# 2. usermod -g (lowercase) sets the PRIMARY group.
#    usermod -G (uppercase) sets SUPPLEMENTARY groups.
#    -aG = APPEND to supplementary groups.

# 3. userdel without -r leaves /home/user behind (orphaned files).
#    Use userdel -r to remove home directory + mail spool.

# 4. passwd -l locks the password. usermod -L does the same.
#    But neither prevents key-based SSH login → also use:
#    chage -E 0 user   (expires the account)

# 5. After editing /etc/sudoers manually, system can be unusable.
#    ALWAYS use `visudo` (syntax check on save).

# 6. Ubuntu default sudo group = "sudo". RHEL default = "wheel".

# 7. chage --lastday 0 user  forces immediate password change at next login.
```
