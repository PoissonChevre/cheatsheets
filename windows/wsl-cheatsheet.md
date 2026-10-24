# WSL — Cheat Sheet

Windows Subsystem for Linux - Run Linux environments natively on Windows.

---

## Installation & Config

```powershell
wsl --install  # Install WSL2 with default Ubuntu
wsl --install -d Ubuntu-22.04  # Install specific distribution
wsl --list --online  # List available distributions
wsl --list --verbose  # List installed distributions with versions
wsl --unregister Ubuntu  # Uninstall distribution
wsl --set-default Ubuntu  # Set default distribution
wsl --set-version Ubuntu 2  # Convert WSL1 to WSL2
wsl --update  # Update WSL kernel
```

## Launch & Access

```powershell
wsl  # Launch default distribution
wsl -d Ubuntu  # Launch specific distribution
wsl -d Ubuntu -u root  # Launch as root user
wsl -e /bin/bash  # Execute specific shell
wsl --shutdown  # Shutdown all WSL instances
wsl --terminate Ubuntu  # Terminate specific distribution
wsl --help  # Show WSL commands
```

## File Access & Transfer

```bash
# In WSL:
ls /mnt/c/  # Access Windows C: drive
cd /mnt/c/Users/Username  # Navigate Windows directories
cp /mnt/c/file.txt ~  # Copy from Windows to WSL home
cp ~/file.txt /mnt/c/Users/Username/Desktop/  # Copy to Windows
```

```powershell
# In PowerShell:
wsl ls -la /home  # Run WSL command from Windows
wsl cat /etc/os-release  # Execute WSL commands
Get-ChildItem \\wsl$\Ubuntu\home  # Access WSL files via network path
```

## Distribution Management

```powershell
wsl --list  # List installed distributions
wsl -l -v  # List with version and status
wsl --export Ubuntu backup.tar  # Export distribution
wsl --import MyUbuntu C:\WSLDistros\MyUbuntu backup.tar  # Import distribution
wsl --move <Distribution> <NewLocation>  # Move to different drive
wsl --set-default Ubuntu-22.04  # Set default distro
wsl --uninstall-kernel  # Remove WSL kernel (keep distros)
```

## Interoperability

```bash
# In WSL:
notepad.exe file.txt  # Open file in Windows Notepad from WSL
explorer.exe .  # Open current directory in Windows Explorer
powershell.exe -Command "Get-Process"  # Execute PowerShell from WSL
wslpath -w /home/user  # Convert Linux path to Windows
wslpath -u 'C:\Windows'  # Convert Windows path to Linux
```

```powershell
# In PowerShell:
wsl cat /etc/lsb-release  # Run Linux command from Windows
wsl grep "pattern" file.txt  # Use WSL grep from Windows
```

## Networking Configuration

```bash
# In WSL:
ip addr show  # Show WSL network configuration
hostname -I  # Show WSL IP address
sudo ip route show  # Show network routes
```

```powershell
# In PowerShell:
wsl hostname -I  # Get WSL IP from Windows
netstat -ano | findstr :3000  # Find listening ports on Windows
```

**Port Forwarding (localhostForwarding in .wslconfig):**
```bash
# In WSL:
npm start  # Accessible at localhost:3000 from Windows
python -m http.server 8000  # Accessible from Windows at localhost:8000
```

## .wslconfig Options

Global settings for all WSL 2 distributions: `C:\Users\<UserName>\.wslconfig` (then `wsl --shutdown`).

```ini
[wsl2]
memory=4GB  # Limit memory usage
processors=4  # Limit CPU cores
swap=2GB  # Set swap size
swapfile=C:\\temp\\wsl-swap.vhdx  # Custom swap location
localhostForwarding=true  # Enable localhost forwarding
debugConsole=true  # Debug output on distro open
nestedVirtualization=false  # Disable nested VM
pageReporting=false  # Disable memory reporting

[interop]
enabled=true  # Enable Windows/WSL interop
appendWindowsPath=true  # Add Windows PATH to WSL

[user]
default=username  # Default user for distro
```

## /etc/wsl.conf Options

Settings for one distribution: `/etc/wsl.conf` inside it.

```ini
[boot]
systemd=true  # Enable systemd (WSL2 only)
command=service docker start  # Command to run on boot

[interop]
enabled=true  # Enable Windows/WSL interop
appendWindowsPath=true  # Append Windows PATH

[user]
default=username  # Default user for distribution

[automount]
enabled=true  # Auto-mount Windows drives
root=/mnt  # Mount point for drives
options=metadata,uid=1003,gid=1003  # Mount options

[network]
hostname=MyHost  # Set hostname
generateHosts=false  # Don't auto-generate /etc/hosts
generateResolvConf=false  # Don't auto-generate resolv.conf
```

## Troubleshooting

```powershell
# Check WSL status
wsl --status  # Show WSL version and kernel version
wsl -l -v  # Verify installation and version

# Restart WSL
wsl --shutdown  # Clean shutdown
wsl  # Restart with default distribution

# Update WSL kernel
wsl --update  # Update to latest kernel
wsl --update --web-download  # Update offline

# Check WSL logs
Get-Content $env:USERPROFILE\.wsl\wsl.log  # WSL event logs

# Verify virtualization enabled
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -Online -FeatureName WSL
```

PowerShell commands: see [powershell-cheatsheet.md](./powershell-cheatsheet.md).

---

## Pitfalls

- Keep projects in the Linux filesystem (`~`), not in `/mnt/c`: it is much faster.
- Run `wsl --shutdown` after changing `.wslconfig`.
- The WSL 2 IP changes at every start (NAT): use mirrored networking (Windows 11) or a port forwarding script.
- Git line endings: set `core.autocrlf` to avoid CRLF/LF changes.
- WSL 2 can use a lot of RAM: limit it with `memory=` in `.wslconfig`.
- Open Linux files from Windows through `\\wsl.localhost\<distro>`, never through the hidden AppData folder.
