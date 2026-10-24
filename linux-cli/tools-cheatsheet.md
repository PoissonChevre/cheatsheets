# Tools Cheat Sheet
*Essential Linux command-line tools for system administration and debugging*

## curl
*Transfer data using URLs (HTTP/HTTPS/FTP)*

```bash
curl https://example.com  # Fetch webpage
curl -o filename https://example.com/file  # Download with custom name
curl -O https://example.com/file  # Download keeping original name
curl -X POST -d "data=value" https://example.com  # POST request
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://api.example.com  # POST JSON
curl -H "Authorization: Bearer token" https://api.example.com  # Add header
curl -u username:password https://example.com  # Basic auth
curl -L https://short.url  # Follow redirects
curl -I https://example.com  # Show headers only (HEAD request)
curl -v https://example.com  # Verbose output (debug)
```

## wget
*Download files from the web (non-interactive)*

```bash
wget https://example.com/file  # Download file
wget -O filename https://example.com/file  # Download with custom name
wget -r https://example.com  # Recursive download (mirror site)
wget --depth=2 https://example.com  # Limit recursion depth
wget --accept=pdf https://example.com  # Download only PDF files
wget -c https://example.com/largefile  # Continue partial download
wget --mirror https://example.com  # Full site mirror
wget -q https://example.com/file  # Quiet mode (no output)
wget --user=username --password=password https://example.com  # Authentication
```

## jq
*JSON query and transformation tool*

```bash
jq . file.json  # Pretty-print JSON
curl api.example.com | jq .  # Parse JSON from pipe
jq '.key' file.json  # Extract specific key
jq '.[] | .name' file.json  # Extract field from each array element
jq '.data | length' file.json  # Get array/object length
jq '.data | sort_by(.age)' file.json  # Sort by field
jq '.data | map(.name)' file.json  # Extract field from all elements
jq 'select(.status == "active")' file.json  # Filter records
jq '.data | select(.id > 5)' file.json  # Filter by condition
jq '{id, name}' file.json  # Create new object with selected fields
jq -r '.data[]' file.json  # Raw output (no quotes)
jq -s 'add' file1.json file2.json  # Merge JSON files
```

## rsync
*Fast incremental file synchronization*

```bash
rsync -av source/ destination/  # Sync with verbose output
rsync -avz source/ destination/  # Sync with compression
rsync -av --delete source/ destination/  # Delete removed files in destination
rsync -av --exclude='*.log' source/ destination/  # Exclude pattern
rsync -av --exclude-from=exclude.txt source/ destination/  # Exclude from file
rsync -av -e ssh local/ user@host:/remote/  # Remote sync over SSH
rsync -av --progress source/ destination/  # Show progress
rsync -av --bwlimit=1000 source/ destination/  # Limit bandwidth (KB/s)
rsync -av -n source/ destination/  # Dry-run (no changes)
rsync -av --backup --backup-dir=backups/ source/ destination/  # Backup changed files
```

## netcat (nc)
*Network utility for reading/writing data across networks*

```bash
nc -l -p 8000  # Listen on port 8000
nc example.com 80  # Connect to host on port 80
echo "GET / HTTP/1.0" | nc example.com 80  # Send HTTP request
nc -l -p 8000 > backup.tar  # Receive file
nc -w 3 example.com 22  # Test port connectivity
nc -v example.com 443  # Verbose connection test
nc -u -l -p 5353  # Listen on UDP port
nc -z -v example.com 1-1000  # Scan port range
echo "test" | nc -l -p 8000  # Send data from listener
cat file | nc -q 1 example.com 8000  # Send file and close
```

## nmap
*Network scanner for discovering hosts and services*

```bash
nmap example.com  # Scan single host
nmap -p 22,80,443 example.com  # Scan specific ports
nmap -p 1-1000 example.com  # Scan port range
nmap -sV example.com  # Detect service versions
nmap -O example.com  # Detect OS (requires root)
nmap -A example.com  # Aggressive scan (OS + service detection)
nmap -sS example.com  # TCP SYN scan (stealth scan)
nmap -sU example.com  # UDP scan
nmap -Pn example.com  # Skip ping (assume host up)
nmap -oX output.xml example.com  # Output to XML file
nmap 192.168.1.0/24  # Scan subnet
nmap --script http-title example.com  # Run specific NSE script
```

## htop/btop
*Interactive process viewer and system monitor*

```bash
htop  # Interactive process viewer
btop  # Modern system monitor
htop -p <pid>  # Monitor specific process
htop -u <username>  # Show processes for user
# Inside htop:
F5  # View process tree
F6  # Sort by column
F10  # Exit
k  # Kill selected process
Space  # Tag process
S  # Strace process
L  # Trace process calls
T  # Show process threads
u  # Filter by user
# Inside btop:
p  # Process list
m  # Memory details
d  # Disk I/O
n  # Network activity
```

## strace
*Trace system calls and signals (debug tool)*

```bash
strace command  # Trace command execution
strace -e trace=read,write command  # Trace specific syscalls
strace -o output.txt command  # Output to file
strace -p <pid>  # Attach to running process
strace -e trace=network command  # Trace network syscalls
strace -e trace=file command  # Trace file syscalls
strace -c command  # Summary of syscalls
strace -tt command  # Show timestamps
strace -f command  # Follow child processes
strace --max-strlen=100 command  # Limit string output length
```

## lsof
*List open files and network connections*

```bash
lsof  # List all open files
lsof -u <username>  # Show files opened by user
lsof -p <pid>  # Show files opened by process
lsof -i :8000  # Show process listening on port
lsof -i TCP:22  # Show TCP connections on port 22
lsof /path/to/file  # Show processes accessing file
lsof -c <command>  # Show files opened by command name
lsof -d cwd  # Show current working directory
lsof -d 0-3  # Show specific file descriptors
lsof +D /path  # List open files in directory (recursive)
```

## fzf
*Fuzzy finder for interactive filtering and selection*

```bash
fzf  # Interactive file/line selector
command | fzf  # Pipe output to fzf
fzf --preview 'cat {}'  # Show preview of selected file
fzf -m  # Multi-select mode
fzf --height 50%  # Set window height
fzf --reverse  # Reverse display order
fzf -q "query"  # Start with search query
find . -type f | fzf  # Find and select file
history | fzf  # Search command history
vim $(fzf)  # Open selected file in vim
```
