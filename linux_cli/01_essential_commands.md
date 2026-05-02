# LFCS — Essential Commands (20%)

> Navigation, file manipulation, search, text processing, archives, permissions, ACLs, help.

---

## Navigation & Listing

```bash
pwd                                  # Print working directory
cd dir                               # Change directory
cd                                   # Home directory
cd -                                 # Previous directory

ls                                   # List files
ls -la                               # Long listing + hidden files
ls -lah                              # Human-readable sizes
ls -lahZ                             # + SELinux context
ls -ltr                              # Sort by time, oldest last
```

## Directory Management

```bash
mkdir dir                            # Create directory
mkdir -p /a/b/c                      # Create tree, no error if existing
rmdir dir                            # Remove EMPTY directory
rm -rf dir                           # Remove directory recursively (use with care)
```

## File Manipulation

```bash
touch file                           # Create empty file or update timestamp

cp file1 file2                       # Copy
cp -r dir1 dir2                      # Copy recursively
cp -a src dst                        # Archive mode (preserves all attributes)

mv file1 file2                       # Move/rename
rm file                              # Delete
rm -rf dir                           # Force delete recursively

ln -s /target /link                  # Symbolic link (relative or absolute)
ln /target /link                     # Hard link (same inode, same FS only)
```

## File Inspection

```bash
cat file                             # Show full content
less file                            # Paginated, scrollable (q to quit, / to search)
more file                            # Paginated forward only
head file                            # First 10 lines
head -n 20 file                      # First 20 lines
tail file                            # Last 10 lines
tail -n 20 file                      # Last 20 lines
tail -f file                         # Follow growing file (logs)

stat file                            # Detailed metadata (inode, timestamps, perms)
file fichier                         # Identify file type (binary, ASCII, etc.)
```

---

## Searching Files & Content

### find — by attributes

```bash
find <dir> -name "*.conf"            # By name pattern
find <dir> -iname "*.LOG"            # Case-insensitive
find <dir> -type f                   # Files only
find <dir> -type d                   # Directories only
find <dir> -size +100M               # Larger than 100M
find <dir> -size -3k                 # Smaller than 3K
find <dir> -mmin -5                  # Modified in last 5 min
find <dir> -mtime -7                 # Modified in last 7 days
find <dir> -user john                # Owned by john
find <dir> -group dev                # Owned by group dev
find <dir> -perm 644                 # Exact permissions
find <dir> -perm /4000               # SUID files (security audit)
find <dir> -maxdepth 1               # Limit depth (current dir only)
find <dir> ! -newermt "2020-01-01"   # Older than date

# Execute action on results
find <dir> -name "*.tmp" -delete                 # Delete matches
find <dir> -name "*.log" -exec gzip {} \;        # One command per file
find <dir> -name "*.log" -exec gzip {} +         # Batch (faster)
find <dir> -size +10k -exec mv {} /backup/ \;   # Move large files
```

**Pitfalls:**
- `-maxdepth N` must come **before** other filters
- Always test with listing **before** adding `-delete` or `-exec rm`
- `-exec ... \;` runs once per file (slow); `-exec ... +` batches (fast)

### grep — by content

```bash
grep "pattern" file                  # Basic search
grep -i "pattern" file               # Case-insensitive
grep -v "pattern" file               # Invert (lines NOT matching)
grep -r "pattern" /dir/              # Recursive
grep -E "regex" file                 # Extended regex (+, ?, |, ())
grep -c "pattern" file               # Count matching lines
grep -n "pattern" file               # Show line numbers
grep -l "pattern" *                  # List files containing pattern
grep -Iris "pattern" /dir/           # Recursive, case-insensitive, ignore binaries, silent
```

### Other search tools

```bash
locate filename                      # Fast DB lookup (run updatedb first)
which command                        # Path of executable in PATH
whereis command                      # Binary, source, man pages
type command                         # Show whether command is alias/builtin/file
```

---

## Text Processing

```bash
wc -l file                           # Count lines
wc -w file                           # Count words
wc -c file                           # Count characters

sort file                            # Sort alphabetically
sort -n file                         # Numeric sort
sort -r file                         # Reverse
sort -k2 file                        # Sort by column 2
sort -u file                         # Sort + unique

uniq file                            # Remove adjacent duplicates (sort first!)
uniq -c                              # Prefix lines with count

cut -d: -f1 /etc/passwd              # Field 1, ":" delimiter
cut -d, -f1,3 file.csv               # Fields 1 and 3 from CSV
cut -c1-10 file                      # Characters 1-10

awk '{print $2}' file                # Print 2nd field (whitespace delim)
awk -F: '{print $1}' /etc/passwd     # ":" as delimiter

diff file1 file2                     # Line-by-line diff
diff -u file1 file2                  # Unified format (like Git)
cmp file1 file2                      # Byte-by-byte comparison

tee file                             # Write to file AND stdout
echo "x" | sudo tee /etc/file        # Useful when redirection needs root
echo "x" | sudo tee -a /etc/file     # Append mode
```

### sed — stream editor

```bash
sed 's/old/new/' file                # Replace first occurrence per line
sed 's/old/new/g' file               # Replace all occurrences
sed 's/old/new/2' file               # Replace 2nd occurrence per line
sed -i 's/old/new/g' file            # In-place modification
sed -i.bak 's/old/new/g' file        # In-place + automatic .bak backup
sed -n '5,10p' file                  # Print lines 5 to 10
sed '/pattern/d' file                # Delete lines matching pattern
```

**Pitfall:** `sed -i` without backup = no undo. Use `sed -i.bak` for safety.

---

## Regex Quick Reference

### Basic regex

| Symbol | Meaning |
|---|---|
| `.` | Any single character |
| `*` | 0 or more of previous |
| `.*` | Anything (any sequence) |
| `^` | Start of line |
| `$` | End of line |
| `[abc]` | One of a, b, or c |
| `[^abc]` | NOT a, b, or c |
| `[0-9]` | Range |
| `\.` | Literal dot (escaped) |

### Extended regex (`grep -E`)

| Symbol | Meaning |
|---|---|
| `+` | 1 or more of previous |
| `?` | 0 or 1 of previous |
| `\|` | OR |
| `()` | Group |
| `{n}` | Exactly n times |
| `{n,m}` | Between n and m times |

### Common patterns

```bash
grep -E "^root"                      # Lines starting with root
grep -E "bash$"                      # Lines ending with bash
grep -E "^$"                         # Empty lines
grep -E "[0-9]+"                     # One or more digits
grep -E "/app/user.*hacker-bot/1.2"  # Order-imposed match
sed 's/^container.*24h$/REMOVED/'    # Replace full pattern lines
```

---

## Redirection & Pipes

```bash
command > file                       # stdout to file (overwrite)
command >> file                      # stdout to file (append)
command 2> file                      # stderr to file
command 2>> file                     # stderr append
command > file 2>&1                  # stdout AND stderr to same file
command &> file                      # Same as above (bash shortcut)
command < file                       # stdin from file
command1 | command2                  # Pipe stdout of cmd1 to cmd2
command > /dev/null 2>&1             # Discard all output
```

**Pitfalls:**
- Order matters: `> file 2>&1` works, `2>&1 > file` does NOT redirect stderr to file
- `>` overwrites, `>>` appends
- `2>&1` means "send stderr where stdout is currently going"

---

## Exit Code (`$?`)

```bash
command
echo $?                              # Exit code of LAST command (0 = success)

command
EXIT=$?                              # Save before running anything else
echo "anything"                      # This overwrites $?
echo $EXIT                           # Saved value still valid
```

**Pitfall:** `$?` is overwritten by every command. Capture immediately or save in variable.

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Generic error |
| 2 | Misuse of command |
| 126 | Permission denied |
| 127 | Command not found |
| 130 | Ctrl+C (128 + 2) |
| 137 | Killed (128 + 9) |

---

## Archives & Compression

### tar

```bash
tar cf archive.tar files             # Create uncompressed
tar xf archive.tar                   # Extract uncompressed
tar tf archive.tar                   # List contents (no extract)

tar czf archive.tar.gz files         # Create gzip
tar xzf archive.tar.gz               # Extract gzip
tar tzf archive.tar.gz               # List gzip contents

tar cjf archive.tar.bz2 files        # Create bzip2
tar xjf archive.tar.bz2              # Extract bzip2

tar cJf archive.tar.xz files         # Create xz (best compression, slowest)

# Custom compression level
tar -I 'gzip -9' -cf archive.tar.gz dir/    # Best gzip compression
tar -I 'gzip -1' -cf archive.tar.gz dir/    # Fastest gzip

# Mnemonic: Create / eXtract / list / Zipped / file
```

**Pitfalls:**
- `GZIP=-9 tar czf` is **deprecated** — use `tar -I 'gzip -9'` instead
- `-z` (gzip) and `-j` (bzip2) work fine; just no level control
- `tar` strips leading `/` from absolute paths by default (security feature)

### Standalone compression

```bash
gzip file                            # Compress → file.gz (removes original)
gzip -k file                         # Keep original
gzip -9 file                         # Best compression (--best)
gzip -1 file                         # Fastest (--fast)
gzip -d file.gz                      # Decompress
gunzip file.gz                       # Same as gzip -d
gzip -l file.gz                      # Show compression ratio

bzip2 / bunzip2                      # Same pattern, better ratio than gzip
xz / unxz                            # Best ratio, slowest

zip -r archive.zip dir/              # Create zip
unzip archive.zip                    # Extract zip
unzip -l archive.zip                 # List contents
```

---

## File Permissions

### Standard permissions

```bash
chmod 755 file                       # rwxr-xr-x (owner full, others read+exec)
chmod 644 file                       # rw-r--r-- (owner rw, others read)
chmod 600 file                       # rw------- (owner only) — SSH keys, secrets
chmod 777 file                       # rwxrwxrwx (everyone full) — avoid

chmod u+x script.sh                  # Add execute for owner
chmod g-w file                       # Remove write from group
chmod o+r file                       # Add read for others
chmod a+x file                       # Add execute for all (a = ugo)
chmod -R 750 dir/                    # Recursive

# Octal:  4=read  2=write  1=execute  (sum per role)
# Symbolic:  u=user  g=group  o=other  a=all
#            +=add   -=remove  ==set exactly
```

### Special bits

```bash
chmod u+s file                       # SUID — run as owner
chmod g+s file                       # SGID — run as group / inherit group on dir
chmod +t dir                         # Sticky bit — only owner can delete (e.g. /tmp)

chmod 4755 file                      # SUID + 755
chmod 2755 dir                       # SGID + 755
chmod 1777 dir                       # Sticky + 777

# Find SUID files (security audit)
find / -perm /4000 -type f 2>/dev/null
```

### Ownership

```bash
chown user file                      # Change owner
chown user:group file                # Change owner and group
chown :group file                    # Change group only
chown -R user:group dir/             # Recursive

chgrp group file                     # Change group only
```

### Default permissions (umask)

```bash
umask                                # Show current umask (typically 022)
umask 027                            # New files: 640, new dirs: 750

# Default file perms: 666 - umask
# Default dir perms:  777 - umask
```

### Extended attributes

```bash
chattr +i file                       # Make immutable (cannot modify/delete)
chattr -i file                       # Remove immutable
chattr +a file                       # Append-only
lsattr file                          # List attributes
```

---

## ACLs (Access Control Lists)

```bash
getfacl file                         # Show ACL entries
setfacl -m u:john:rw file            # Grant john read+write
setfacl -m g:dev:rx file             # Grant group dev read+execute
setfacl -x u:john file               # Remove user entry
setfacl -b file                      # Remove all ACLs
setfacl -R -m u:john:rwx dir/        # Recursive

# Default ACLs (inherited by new files in dir)
setfacl -d -m u:john:rwx dir/
```

**Note:** Filesystem must be mounted with `acl` option (default on most modern FS).

---

## Help & Documentation

```bash
man command                          # Full manual page
man 5 passwd                         # Specific section (5 = file formats)
man -k keyword                       # Search by keyword in descriptions
apropos keyword                      # Same as man -k
whatis command                       # One-line description

command --help                       # Quick help (faster than man)
command -h                           # Short alias

info command                         # GNU info pages (more detailed)

# Inside man / less:
# /pattern    search forward
# ?pattern    search backward
# n           next match
# N           previous match
# q           quit
```

**Exam reflex:** When stuck on a command, try in order:
1. `command --help`
2. `man -k keyword`
3. `man command` + `/option`

### Man sections

| Section | Content |
|---|---|
| 1 | User commands |
| 2 | System calls |
| 3 | Library functions |
| 4 | Special files (`/dev/*`) |
| 5 | File formats (`/etc/passwd`, `crontab`) |
| 7 | Miscellaneous |
| 8 | Admin commands |

---

## Editor Essentials (vi / vim)

```bash
vi file
```

| Mode | Switch with | Purpose |
|---|---|---|
| Normal | `Esc` | Navigation, commands |
| Insert | `i` `a` `o` | Type text |
| Command | `:` | Save, quit, search-replace |

**Essential commands:**
```
:w           save
:q           quit
:wq          save + quit
:q!          force quit (discard changes)
:set nu      show line numbers
/pattern     search forward
?pattern     search backward
n / N        next / previous match
:%s/old/new/g    replace all in file
dd           delete line
yy           copy line
p            paste
u            undo
Ctrl+R       redo
gg           top of file
G            bottom of file
```

---

## Pitfalls Summary

```bash
# 1. find -delete — always test with listing first
# 2. sed -i — always backup or use sed -i.bak
# 3. tar -P — never use unless you specifically need absolute paths
# 4. $? — capture immediately, every command overwrites it
# 5. > vs >> — overwrite vs append, very different
# 6. 2>&1 placement — must come AFTER stdout redirection
# 7. chmod 777 — almost never the right answer
# 8. rm -rf — verify pwd before running
# 9. grep without -E — limited regex (no +, ?, |)
# 10. cp without -a — loses permissions/timestamps/links
```
