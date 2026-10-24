# Users and Groups

Users, groups, passwords, sudo, environment, limits, sessions.

[← Back to index](./README.md)

---

## Create users

```bash
useradd -m -s /bin/bash -G dev,ops jack          # Home + shell + extra groups
useradd -m -u 5322 -c "Jack Smith" -e 2026-12-31 jack
useradd -m -d /home/custom/jack jack             # Custom home
passwd jack

adduser jack             # Debian/Ubuntu interactive wrapper
```

| Option | Effect |
|---|---|
| `-m` | Create the home directory (not created by default on Debian/Ubuntu) |
| `-s` | Login shell |
| `-g` | **Primary** group |
| `-G` | Supplementary groups |
| `-u` | UID |
| `-d` | Home path |
| `-c` | Comment (full name) |
| `-e` | Account expiry date |

Use `useradd` in scripts and exams: it is predictable. `adduser` asks questions.

## Modify users

```bash
usermod -aG dev jack     # ADD to group dev
usermod -G dev jack      # REPLACES all supplementary groups
usermod -g rugby jack    # Primary group
usermod -s /bin/zsh jack
usermod -d /new/home -m jack   # Change home AND move files (without -m: files stay)
usermod -L jack ; usermod -U jack   # Lock, unlock password
usermod -e 2030-03-01 jack     # Expiry ("" = never)
usermod -l newname oldname     # Rename
```

| Flag | Effect |
|---|---|
| `-g group` | Primary group |
| `-G g1,g2` | Replace all supplementary groups |
| `-aG g1,g2` | Add to supplementary groups |

## Delete users

```bash
userdel -r jack          # Delete user + home + mail (without -r the home stays)
```

---

## Passwords and aging

```bash
passwd jack
passwd -l jack ; passwd -u jack   # Lock, unlock
passwd -e jack           # Must change at next login
passwd -S jack           # Status

chage -l jack            # Show aging info
chage -M 90 jack         # Max password age
chage -m 7 jack          # Min password age
chage -W 7 jack          # Warn 7 days before
chage -I 30 jack         # Inactive days after expiry
chage -E 2026-12-31 jack # Account expiry (-1 = never)
chage -d 0 jack          # Force change at next login
```

Locking the password does **not** block SSH keys. To disable an account completely:

```bash
chage -E 0 jack
usermod -s /usr/sbin/nologin jack
```

---

## Groups

```bash
groupadd -g 9875 dev     # With GID
groupmod -n new old      # Rename
groupdel dev

id jack                  # UID, GID, groups
groups jack
getent group dev         # Works with LDAP too
getent passwd jack

gpasswd -a jack wheel    # Add member
gpasswd -d jack wheel    # Remove member
newgrp dev               # Change primary group in this shell
```

---

## sudo

```bash
sudo -u jack cmd         # Run as another user
sudo -i                  # Root login shell
sudo -l                  # My rights
sudo -l -U jack          # Rights of jack
sudo -k                  # Forget cached password

su - jack                # Switch user with his environment

visudo                   # Edit /etc/sudoers with syntax check
visudo -f /etc/sudoers.d/jack
visudo -c                # Check syntax
```

### Syntax

```
who   host=(run_as)   [NOPASSWD:] commands
```

```
jack        ALL=(ALL)   ALL                         # Everything, as any user
jack        ALL=(root)  /usr/bin/systemctl, /usr/bin/ls
jack        ALL=(root)  NOPASSWD: /bin/bash /root/script.sh
%developers ALL=(ALL)   ALL                         # A group
```

`(ALL)` = can run as any user. `(root)` = only as root: use it unless the task says "any user".

Drop-in file:

```bash
echo "jack ALL=(root) NOPASSWD: /bin/bash /root/script.sh" | sudo tee /etc/sudoers.d/jack
sudo chmod 440 /etc/sudoers.d/jack
sudo visudo -c
```

- Always `visudo`: a syntax error in sudoers can lock you out of sudo.
- Use full paths for commands.
- Admin group: `sudo` on Ubuntu, `wheel` on RHEL.

---

## Account files

```
/etc/passwd        name:x:UID:GID:comment:home:shell
/etc/shadow        name:hash:lastchange:min:max:warn:inactive:expire
/etc/group         name:x:GID:members
/etc/login.defs    Defaults (UID_MIN, PASS_MAX_DAYS...)
/etc/default/useradd
/etc/skel/         Copied into every new home
```

In `/etc/shadow`, a hash starting with `!` or `*` = locked. Last change = days since 1970-01-01.

---

## Environment

```bash
env                      # All variables
export VAR=value         # For this shell + child processes
VAR=value                # This shell only
unset VAR
source ~/.bashrc         # Reload
```

| File | When |
|---|---|
| `~/.bash_profile` or `~/.profile` | Login shell |
| `~/.bashrc` | Interactive shell |
| `/etc/profile`, `/etc/profile.d/*.sh` | Login shell, all users |
| `/etc/bash.bashrc` (Debian), `/etc/bashrc` (RHEL) | Interactive shell, all users |
| `/etc/environment` | `KEY=value` only, not a script |

```bash
echo 'export MYVAR=value' > /etc/profile.d/myvar.sh   # All users
echo 'export MYVAR=value' >> ~/.bashrc                # One user
```

---

## Resource limits

```bash
ulimit -a                # All limits of this shell
ulimit -Sn 4096          # Soft limit for open files (-H = hard)
ulimit -u                # Max processes
```

```
# /etc/security/limits.conf or /etc/security/limits.d/*.conf
# <who>        <soft|hard>  <item>      <value>
jack           hard         nproc       1024
@developers    soft         nofile      8192
@operators     hard         maxlogins   1
*              hard         core        0
```

| Item | Meaning |
|---|---|
| nproc | Processes |
| nofile | Open files |
| maxlogins | Simultaneous logins |
| fsize | File size |
| core | Core dump size |

A user can raise the soft limit up to the hard limit. Only root can raise the hard limit.

---

## Sessions

```bash
w ; who ; whoami
last -n 10               # Login history
lastb                    # Failed logins (root)
lastlog                  # Last login of each user
```

---

## Pitfalls

- `usermod -G` without `-a` removes all other groups.
- `-g` = primary group, `-G` = supplementary groups.
- `userdel` without `-r` leaves the home.
- `usermod -d` without `-m` does not move the files.
- `passwd -l` does not block SSH keys.
- `chage -d 0` = change password at next login.
- Files in `/etc/sudoers.d/` load in alphabetical order.
