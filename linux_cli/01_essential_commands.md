# LFCS — Essential Commands (20%)

## File & Directory Navigation

```bash
ls                          # List files in current directory
ls -la /home/bob/data/      # Long listing including hidden files (find hidden files)
ls -al                      # Formatted listing with hidden files
ls -Z /bin/sudo             # Display SELinux label for the file

cd dir                      # Change directory to dir
cd                          # Change to home directory
cd -                        # Switch to previous directory
pwd                         # Print working directory

mkdir dir                   # Create a directory
mkdir -p /a/b/c             # Create directory tree, no error if existing

rmdir dir                   # Remove empty directory
```

## File Manipulation

```bash
touch /home/bob/myfile      # Create empty file or update timestamp
touch path/file             # Create new empty file

cp file1 file2              # Copy file1 to file2
cp -r dir1 dir2             # Copy dir1 to dir2 recursively (creates dir2 if absent)

mv file1 file2              # Rename or move file1 to file2 (if file2 is a dir, file1 moves into it)

rm file                     # Delete file
rm -r dir                   # Delete directory recursively
rm -f file                  # Force remove file (no prompt)
rm -rf dir                  # Force remove directory recursively  *use with extreme caution*

ln -s /target /link         # Create a symbolic link

cat > file                  # Place standard input into file
cat file                    # Read / output file contents
more file                   # Output contents one page at a time
less file                   # Paginated view (opposite of more, allows back-scroll)
head file                   # First 10 lines of file
head -n 20 file             # First 20 lines
tail file                   # Last 10 lines of file
tail -n 20 file             # Last 20 lines
tail -f file                # Follow file as it grows (logs)
```

## Searching Files & Content

```bash
grep pattern files                  # Search for pattern in files
grep -r pattern dir                 # Recursive search for pattern in dir
grep -Iris 'string' /dir/           # Recursive, case-insensitive, ignore binaries, silent on errors
grep -r --text 'reboot' /var/log/   # Recursive search treating binary files as text
command | grep pattern              # Filter command output

find <dir> -name "*.conf"           # Find files by name
find <dir> -mmin -<n> -type f       # Files modified in the last <n> minutes
find . -mmin -5 -type f             # Example: files modified in last 5 minutes
find <dir> -size +100M              # Files larger than 100 MB
find <dir> -user john               # Files owned by user john
find <dir> -perm 644                # Files with exact permissions

locate filename                     # Quick database-based file lookup
which app                           # Show full path of an executable
whereis app                         # Show binary, source and man-page locations
```

## Text Processing & Streams

```bash
wc -l file                  # Count lines, words, characters
sort file                   # Sort lines alphabetically
uniq                        # Remove duplicate lines (use after sort)
cut -d: -f1 /etc/passwd     # Cut field 1, ":" delimited
col<n> "<separator>" file   # Show only the nth column (col2 "," foo.csv)
awk '{print $2}' file       # Print second field of each line
sed 's/old/new/g' file      # Substitute text globally in file

diff file1 file2            # Compare files line by line
cmp file1 file2             # Compare files byte by byte

tee file                    # Write input to file AND stdout
echo "content" | sudo tee /etc/file    # Useful when redirection needs root
```

## Redirection & Pipes

```bash
command > file              # Redirect stdout to file (overwrite)
command >> file             # Append stdout to file
command 2> file             # Redirect stderr to file
command > file 2>&1         # Redirect both stdout and stderr
command1 | command2         # Pipe stdout of cmd1 into cmd2
command < file              # Read stdin from file
command > /dev/null 2>&1    # Discard all output
```

## File Creation Helpers

```bash
touch <filename>                       # Create empty file
fallocate -l <size> <filename>         # Create file of specific size
echo "<content>" > <filename>          # Create file with content
```

## Archives & Compression

```bash
tar cf archive.tar files                  # Create tar archive
tar xf archive.tar                        # Extract tar archive
tar czf archive.tar.gz files              # Create gzip-compressed tar
tar xzf archive.tar.gz                    # Extract gzip tar
tar cvzf <target>.tar.gz <source dir>     # Verbose pack into gzip tar
tar cjf archive.tar.bz2 files             # Create bzip2-compressed tar
tar xjf archive.tar.bz2                   # Extract bzip2 tar

gzip file                                 # Compress file → file.gz
gzip -d file.gz                           # Decompress file.gz back to file
gunzip file.gz                            # Same as gzip -d

zip -r <target> <source dir>              # Create zip archive
unzip <zip file>                          # Extract zip archive
```

## File Permissions & Ownership

```bash
chmod 777 file              # rwxrwxrwx — read, write, execute for all
chmod 755 file              # rwxr-xr-x — owner full, others rx
chmod 644 file              # rw-r--r-- — owner rw, others r
chmod u+x ./script.sh       # Add execute permission for owner
chmod -R 750 dir/           # Recursive permission change
# Octal values: 4=read, 2=write, 1=execute   (sum them per role)

chown user:group file       # Change owner and group
chown -R user:group /dir/   # Recursive ownership change
chgrp group file            # Change group ownership only

umask 022                   # Default mask: new files 644, dirs 755
```

## ACLs (Access Control Lists)

```bash
getfacl archive                                          # List ACL permissions on file
setfacl --modify user:john:rw specialfile                # Grant user john rw on file
setfacl --modify group:mail:rx specialfile               # Grant group mail rx on file
setfacl --remove user:john specialfile                   # Remove ACL for user john
setfacl --recursive --modify user:john:rwx collection/   # Recursive ACL on directory
```

## SSL / Certificates

```bash
openssl req -newkey rsa:4096 -keyout priv.key -out cert.csr
# Generate a 4096-bit RSA key and a Certificate Signing Request (CSR)

openssl x509 -in my.crt -text     # Inspect cert — identify CN, validity, issuer
```

## Help & Documentation

```bash
man command                 # Display manual page for command
man -k keyword              # Search man pages by keyword (= apropos)
apropos "NFS mounts"        # Search manual page names and descriptions
command --help              # Quick inline help
whatis command              # One-line description of a command
info command                # GNU info documentation
```

## Editor Essentials (vi / vim)

```bash
vi file                     # Open file in vi/vim
# Modes:  i = insert    Esc = normal    : = command-line
# Save/quit:  :w  save  |  :q  quit  |  :wq  save+quit  |  :q!  force quit
# Editing:    dd delete line | yy copy line | p paste | u undo
# Search:     /pattern  forward  |  ?pattern  backward  |  n next | N prev
```

## Git (Version Control)

```bash
git init                              # Initialize repository
git clone "repository"                # Clone the repo
git add *.cpp                         # Stage all .cpp files for next commit
git commit -m "Message"               # Commit staged files with message
git status                            # Show working tree status
git log --raw                         # Show files modified in latest commits
git branch testing                    # Create branch named testing
git checkout master                   # Switch to master branch
git branch --delete testing           # Delete the testing branch
git merge "branch name"               # Merge branch into current branch
git pull origin master                # Pull latest commits from remote
git push origin master                # Push commits to master branch on remote
```

## SSH & Remote Access

```bash
ssh -V                            # Display the SSH client version
ssh user@host                     # Connect to host as user
ssh -p <port> user@host           # Connect on a custom port
ssh -v alex@localhost             # Verbose mode — debug failing connections
ssh-copy-id user@host             # Push public key to host for passwordless login

scp file user@host:/path/         # Copy file to remote host
scp -r dir/ user@host:/path/      # Copy directory recursively
scp user@host:/file ./            # Copy file from remote to local

rsync -avzh source/ dest/         # Local sync, archive + compress + human readable
rsync <file> user@host:<dest>     # Copy file to remote (e.g. admin@192.0.0.0:/config)
rsync -avruz user@host:src dest   # Copy directory recursively from remote
```

## File Transfer (other)

```bash
wget file_url                # Download file
wget -c file_url             # Continue a stopped download
curl -fsSLo out.txt url      # Fetch URL silently and save (used in install scripts)
curl url                     # Transfer data / fetch from server
ftp host                     # Insecure file-transfer client
telnet host                  # Connect to remote host (insecure — debugging only)
```
