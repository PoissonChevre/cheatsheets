# Essential Commands

Files, search, text processing, regex, redirection, archives, permissions, ACLs, help, vim.

[← Back to index](./README.md)

---

## Navigation and files

```bash
pwd                      # Current directory
cd -                     # Previous directory
cd                       # Home directory

ls -lah                  # Long list, hidden files, human sizes
ls -ltr                  # Sort by time, newest last
ls -Z                    # SELinux context

mkdir -p /a/b/c          # Create a tree (no error if it exists)
rmdir dir                # Delete an EMPTY directory
rm -rf dir               # Delete recursively — check pwd first!

touch file               # Create empty file or update timestamp
cp -a src dst            # Copy and keep permissions, owner, timestamps, links
cp -r dir1 dir2          # Copy a directory
mv old new               # Move or rename

ln -s /target link       # Symbolic link
ln /target link          # Hard link (same inode, same filesystem only)
```

## Read files

```bash
cat file
less file                # Scroll (/ search, q quit)
head -n 20 file          # First 20 lines
tail -n 20 file          # Last 20 lines
tail -f file             # Follow a growing file (logs)
stat file                # Metadata: inode, timestamps, permissions
file file                # File type
```

---

## Search

### find — by name, size, date, owner...

```bash
find /etc -name "*.conf"          # By name
find / -iname "*.log"             # Case-insensitive
find . -type f                    # Files only (d = directories)
find . -size +100M                # Bigger than 100 MB (-3k = smaller than 3 KB)
find . -mmin -5                   # Modified in the last 5 minutes
find . -mtime -7                  # Modified in the last 7 days
find . ! -newermt "2020-01-01"    # Older than a date
find . -user john -group dev      # By owner and group
find . -perm 644                  # Exact permissions
find / -perm /4000 -type f 2>/dev/null   # SUID files (security audit)
find . -maxdepth 1 -type f        # No recursion

find . -name "*.tmp" -delete                # Delete results
find . -name "*.log" -exec gzip {} \;       # One command per file
find . -name "*.log" -exec gzip {} +        # One command for all files (faster)
find . -maxdepth 1 -size +10k -type f -exec mv {} /backup/ \;
```

### grep — by content

```bash
grep "text" file
grep -i                  # Case-insensitive
grep -v                  # Lines that do NOT match
grep -n                  # Line numbers
grep -c                  # Count matching lines
grep -l "text" *         # Only file names
grep -rn "text" /etc/    # Recursive
grep -E "a|b"            # Extended regex
grep -Iris "text" /dir/  # Recursive, case-insensitive, skip binaries, no errors
```

### Find a command

```bash
which cmd                # Path of the executable
whereis cmd              # Binary, source, man pages
type cmd                 # Alias, builtin or file?
locate file              # Fast search in a database (run updatedb first)
```

---

## Text processing

```bash
wc -l file               # Lines (-w words, -c bytes)
sort file                # -n numeric, -r reverse, -k2 column 2, -u unique
sort file | uniq -c      # Count duplicates (uniq needs sorted input)
cut -d: -f1 /etc/passwd  # Field 1, ":" delimiter
cut -c1-10 file          # Characters 1 to 10
awk '{print $2}' file    # Column 2 (spaces)
awk -F: '{print $1}' /etc/passwd
diff -u file1 file2      # Differences (Git format)
cmp file1 file2          # Byte by byte
echo "x" | sudo tee /etc/file      # Write to a root file (-a = append)
```

### sed

```bash
sed 's/old/new/' file      # First match on each line
sed 's/old/new/g' file     # All matches
sed -i 's/old/new/g' file  # Edit the file
sed -i.bak 's/old/new/g' file   # Edit and keep a .bak copy
sed -n '5,10p' file        # Print lines 5 to 10
sed '/pattern/d' file      # Delete matching lines
```

### Regex

| Basic | Meaning | | Extended (`grep -E`) | Meaning |
|---|---|---|---|---|
| `.` | Any character | | `+` | 1 or more |
| `*` | 0 or more | | `?` | 0 or 1 |
| `^` / `$` | Start / end of line | | `\|` | OR |
| `[abc]` | a, b or c | | `()` | Group |
| `[^abc]` | Not a, b, c | | `{n,m}` | n to m times |
| `\.` | A real dot | | | |

```bash
grep -E "^root"          # Starts with root
grep -E "bash$"          # Ends with bash
grep -E "^$"             # Empty lines
grep -E "[0-9]+"         # Numbers
```

---

## Redirection and pipes

```bash
cmd > file               # stdout, overwrite
cmd >> file              # stdout, append
cmd 2> file              # stderr
cmd > file 2>&1          # stdout + stderr (same as: cmd &> file)
cmd > /dev/null 2>&1     # Discard everything
cmd < file               # stdin from file
cmd1 | cmd2              # Pipe
```

`2>&1` must come **after** `> file`. `2>&1 > file` does not send stderr to the file.

### Exit code

```bash
cmd; echo $?             # 0 = success
cmd; RC=$?               # Save it now: every command overwrites $?
```

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Generic error |
| 126 | Not executable |
| 127 | Command not found |
| 130 | Ctrl+C (128+2) |
| 137 | Killed (128+9) |

---

## Archives and compression

```bash
tar cf a.tar dir/        # Create
tar xf a.tar             # Extract (-C /dest to choose the folder)
tar tf a.tar             # List

tar czf a.tar.gz dir/    # gzip   (x to extract: tar xzf)
tar cjf a.tar.bz2 dir/   # bzip2
tar cJf a.tar.xz dir/    # xz (best ratio, slowest)
tar -I 'gzip -9' -cf a.tar.gz dir/   # Choose the compression level
```

Mnemonic: **c**reate, e**x**tract, lis**t**, **z** gzip, **j** bzip2, **J** xz, **f** file.
`GZIP=-9 tar czf` is deprecated. tar removes the leading `/` of absolute paths (safety).

```bash
gzip file                # → file.gz (deletes the original, -k keeps it)
gzip -9 file             # Best compression
gunzip file.gz           # Decompress (same as gzip -d)
bzip2 / bunzip2          # Same options
xz / unxz
zip -r a.zip dir/ ; unzip a.zip ; unzip -l a.zip
```

---

## Permissions

```bash
chmod 755 file           # rwxr-xr-x
chmod 644 file           # rw-r--r--
chmod 600 file           # rw------- (keys, secrets)
chmod u+x,g-w,o+r file   # Symbolic: u g o a, + - =
chmod -R 750 dir/

chown user:group file
chown :group file        # Group only (same as chgrp)
chown -R user:group dir/
```

r = 4, w = 2, x = 1 (add them for each role: user, group, other).

### Special bits

| Bit | Octal | On a file | On a directory |
|---|---|---|---|
| SUID `u+s` | 4000 | Runs as the owner | — |
| SGID `g+s` | 2000 | Runs as the group | New files get the group of the directory |
| Sticky `+t` | 1000 | — | Only the owner can delete (e.g. /tmp) |

### umask

```bash
umask                    # Usually 022
umask 027                # New files 640, new directories 750
```

Files: 666 − umask. Directories: 777 − umask.

### Attributes

```bash
chattr +i file           # Immutable (even root cannot change or delete)
chattr +a file           # Append only
chattr -i file
lsattr file
```

---

## ACLs

```bash
getfacl file
setfacl -m u:john:rw file        # Give john rw
setfacl -m g:dev:rx file         # Give group dev rx
setfacl -R -m u:john:rwx dir/    # Recursive
setfacl -d -m u:john:rwx dir/    # Default ACL (new files inherit it)
setfacl -x u:john file           # Remove one entry
setfacl -b file                  # Remove all ACLs
```

A `+` at the end of `ls -l` permissions means the file has an ACL.

---

## Help

```bash
cmd --help               # Fast
man cmd                  # / search, n next, q quit
man 5 passwd             # Section 5 = file formats
man -k keyword           # Search man pages (same as apropos)
whatis cmd               # One-line description
```

| Section | Content |
|---|---|
| 1 | User commands |
| 5 | File formats (`/etc/passwd`, `crontab`) |
| 8 | Admin commands |

When stuck: `cmd --help` → `man -k keyword` → `man cmd` and `/option`.

---

## vim

| Mode | Key | |
|---|---|---|
| Normal | `Esc` | Move, commands |
| Insert | `i` `a` `o` | Type text |
| Command | `:` | Save, quit, replace |

```
:w  :q  :wq  :q!         Save, quit, save + quit, quit without saving
:set nu                  Line numbers
/text   n   N            Search, next, previous
:%s/old/new/g            Replace everywhere
dd  yy  p                Delete line, copy line, paste
u   Ctrl+R               Undo, redo
gg  G                    Top, bottom
```

---

## Pitfalls

- Test `find` without `-delete` or `-exec rm` first.
- `-maxdepth` goes before the other filters.
- `sed -i` has no undo: use `sed -i.bak`.
- `>` overwrites, `>>` appends.
- `$?` changes after every command: save it right away.
- `grep` without `-E`: no `+`, `?`, `|`.
- `cp` without `-a` loses permissions and timestamps.
- `chmod 777` is almost never the right answer.
