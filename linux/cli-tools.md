# CLI tools

curl, wget, jq, rsync, netcat, nmap, lsof, strace, htop, fzf.

[← Back to index](./README.md)

---

## curl

```bash
curl https://example.com
curl -I https://example.com              # Headers only
curl -v https://example.com              # Debug (TLS, headers)
curl -L https://short.url                # Follow redirects
curl -o file https://example.com/f       # Save as "file" (-O = keep remote name)
curl -fsSLO https://example.com/f        # Quiet, fail on error, follow, save
curl -u user:pass https://example.com    # Basic auth
curl -H "Authorization: Bearer TOKEN" https://api.example.com
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://api.example.com
curl -s -o /dev/null -w "%{http_code}\n" https://example.com   # Only the HTTP code
```

## wget

```bash
wget https://example.com/file
wget -O name https://example.com/file
wget -c https://example.com/big.iso      # Continue a download
wget -q https://example.com/file         # Quiet
wget -r -l 2 https://example.com         # Recursive, depth 2
wget -r -A pdf https://example.com       # Only PDF files
wget --mirror -np https://example.com/docs/   # Mirror, don't go to the parent folder
```

---

## jq

Query and transform JSON. For Kubernetes (JSONPath, custom-columns, kubectl + jq): see [kubectl-jsonpath.md](../k8s/kubectl-jsonpath.md).

### Read

```bash
jq . file.json                           # Pretty print
curl -s api | jq .
jq -r '.name' file.json                  # Raw text, no quotes (for scripts)
jq -c '.items[]' file.json               # Compact, one object per line
jq '.spec.replicas' file.json            # Nested key
jq '.items[0]' file.json                 # First element
jq '.items[].name' file.json             # Field of each element
jq '[.items[].name]' file.json           # Same, as an array
jq '.items | length' file.json           # Count
jq 'keys' file.json                      # Keys of an object
```

### Filter and transform

```bash
jq '.items[] | select(.status == "Running")' f.json
jq '.items[] | select(.name | test("^web"))' f.json      # Regex
jq '.items[] | {name, ip: .status.ip}' f.json            # New object
jq -r '.items[] | "\(.name)\t\(.status)"' f.json         # Text with variables
jq -r '.items[] | [.name, .status] | @tsv' f.json        # Table (@csv for CSV)
jq '.items | sort_by(.age)' f.json
jq '[.items[].image] | unique' f.json
jq '.items | group_by(.node) | map({node: .[0].node, count: length})' f.json
jq '.name // "unknown"' f.json                           # Default value if null
jq --arg n web1 '.items[] | select(.name == $n)' f.json  # Use a shell variable
jq '.spec.replicas = 3' f.json                           # Change a value
jq 'del(.metadata.annotations)' f.json                   # Delete a key
jq -s 'add' a.json b.json                                # Merge files
```

### With cloud CLIs

```bash
az vm list -o json | jq -r '.[] | "\(.name)\t\(.hardwareProfile.vmSize)"'
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "\(.InstanceId)\t\(.State.Name)"'
```

`az` and `aws` also have `--query` (JMESPath) built in: no jq needed for simple cases.

[jq manual](https://jqlang.org/manual/) · [jq playground](https://jqplay.org/)

---

## rsync

```bash
rsync -av src/ dst/                      # Copy the CONTENT of src (trailing /)
rsync -av src dst/                       # Copy the folder src itself
rsync -avz src/ user@host:/dst/          # To remote (-z compress)
rsync -av -e "ssh -p 2222" src/ user@host:/dst/
rsync -av --delete src/ dst/             # Mirror: delete what is not in src
rsync -av --exclude='*.log' src/ dst/    # --exclude-from=list.txt
rsync -av --progress src/ dst/
rsync -avn src/ dst/                     # Dry run: test first!
rsync -av --bwlimit=1000 src/ dst/       # Max 1000 KB/s
rsync -av --backup --backup-dir=../old src/ dst/
```

---

## netcat (nc)

```bash
nc -zv host 22                           # Port open?
nc -zv host 20-25                        # Port range
nc -w 3 host 22                          # Timeout 3 s (shows the banner)
nc -l 8000                               # Listen (some versions: nc -l -p 8000)
nc -u -l 5353                            # Listen UDP

# Send a file
nc -l 8000 > backup.tar                  # Receiver
nc -q 1 host 8000 < backup.tar           # Sender (-q / -N depending on version)

printf "GET / HTTP/1.0\r\n\r\n" | nc example.com 80   # Raw HTTP request
```

---

## nmap

Scan only machines you own or have permission to scan.

```bash
nmap host
nmap -p 22,80,443 host
nmap -p 1-1000 host
nmap -sT host                            # TCP connect (no root)
nmap -sS host                            # SYN scan (root)
nmap -sU host                            # UDP (root, slow)
nmap -sV host                            # Service versions
nmap -O host                             # OS detection (root)
nmap -A host                             # OS + versions + scripts
nmap -Pn host                            # Don't ping first
nmap -sn 192.168.1.0/24                  # Find hosts, no port scan
nmap --script http-title host
nmap -oN scan.txt host                   # -oX = XML
```

---

## lsof

```bash
lsof -i :8000                            # Process using port 8000
lsof -i TCP:22
lsof -i -P -n                            # All network files, numeric
lsof -p PID                              # Files of a process
lsof -u john                             # Files of a user
lsof -c nginx                            # Files of a command
lsof /var/log/syslog                     # Who uses this file
lsof +D /path                            # Open files in a folder (recursive)
lsof /mnt/data                           # Why umount says "busy"

fuser -vm /mnt/data                      # Processes using a mount point
fuser -km /mnt/data                      # Kill them
```

---

## strace

```bash
strace cmd                               # Trace system calls
strace -p PID                            # Attach to a running process
strace -f cmd                            # Follow child processes
strace -c cmd                            # Summary table
strace -e trace=file cmd                 # File syscalls (network, process...)
strace -e trace=openat,read cmd          # Only these syscalls
strace -e kill -p PID                    # Only kill()
strace -tt -o out.txt cmd                # Timestamps, save to file
strace -s 100 cmd                        # Longer strings

ltrace cmd                               # Library calls
```

---

## htop / btop

```bash
htop -u john                             # One user
htop -p PID                              # One process
btop                                     # Modern monitor
```

| Key (htop) | Action |
|---|---|
| `F5` | Tree view |
| `F6` | Sort |
| `/` | Search |
| `u` | Filter by user |
| `k` | Kill |
| `s` | strace the process |
| `l` | lsof the process |
| `H` | Hide/show threads |
| `F10` | Quit |

---

## fzf

```bash
find . -type f | fzf                     # Pick a file
vim "$(fzf)"
fzf --preview 'cat {}'                   # With preview
fzf -m                                   # Multi-select (Tab)
fzf -q "text"                            # Start with a query
history | fzf
# Ctrl+R = history search, Ctrl+T = insert file (with the shell integration)
```