# 🛠 WSL — Cheat Sheet
*Windows Subsystem for Linux - Run Linux environments natively on Windows*

---

## WSL: Installation & Config
*Install and configure WSL distributions*

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

## WSL: Launch & Access
*Enter and exit WSL environments*

```powershell
wsl  # Launch default distribution
wsl -d Ubuntu  # Launch specific distribution
wsl -d Ubuntu -u root  # Launch as root user
wsl -e /bin/bash  # Execute specific shell
wsl --shutdown  # Shutdown all WSL instances
wsl --terminate Ubuntu  # Terminate specific distribution
wsl --help  # Show WSL commands
```

## WSL: File Access & Transfer
*Access files between Windows and WSL*

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

## WSL: Distribution Management
*Manage multiple WSL distributions*

```powershell
wsl --list  # List installed distributions
wsl -l -v  # List with version and status
wsl --export Ubuntu backup.tar  # Export distribution
wsl --import MyUbuntu C:\WSLDistros\MyUbuntu backup.tar  # Import distribution
wsl --move <Distribution> <NewLocation>  # Move to different drive
wsl --set-default Ubuntu-22.04  # Set default distro
wsl --uninstall-kernel  # Remove WSL kernel (keep distros)
```

## WSL: Interoperability
*Call commands across Windows and WSL*

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

## WSL: Networking Configuration
*Configure network access and port forwarding*

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

## WSL: .wslconfig Options
*Configure WSL2 global settings (C:\Users\<UserName>\.wslconfig)*

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

## WSL: /etc/wsl.conf Options
*Configure WSL per-distribution settings (/etc/wsl.conf inside WSL)*

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

## WSL: Troubleshooting
*Diagnose and fix WSL issues*

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

## PowerShell: Basic Commands & Syntax
*Essential PowerShell commands and language basics*

```powershell
Get-Help command  # Get help for command
Get-Help -Examples  # Show usage examples
Get-Help -Full  # Display full help
Get-Command  # List all available commands
cls  # Clear screen
$?  # Check if last command succeeded
$LastExitCode  # Get exit code of last command
```

## PowerShell: Navigation & File Paths
*Browse directories and manage paths*

```powershell
Get-Location  # Show current directory (pwd alias)
Set-Location C:\Users\Name  # Change directory (cd alias)
Push-Location C:\temp  # Save current location and move
Pop-Location  # Return to saved location
Get-Item -Path C:\  # Get item properties
Get-ChildItem -Path C:\  # List files and folders (dir alias)
Get-ChildItem -Path C:\ -Recurse  # List recursively
Get-ChildItem -Path C:\ -Hidden  # Show hidden files
Get-ChildItem -Filter *.txt  # Filter by extension
```

## PowerShell: Files & Permissions
*Create, modify, and manage files with permissions*

```powershell
New-Item -ItemType Directory -Path C:\NewFolder  # Create directory
New-Item -ItemType File -Path C:\file.txt  # Create empty file
Remove-Item -Path C:\file.txt  # Delete file
Remove-Item -Path C:\Folder -Recurse -Force  # Delete directory recursively
Copy-Item -Path C:\source.txt -Destination C:\dest.txt  # Copy file
Copy-Item -Path C:\Folder -Destination C:\Backup -Recurse  # Copy directory
Move-Item -Path C:\file.txt -Destination C:\NewFolder\  # Move file
Rename-Item -Path C:\old.txt -NewName C:\new.txt  # Rename file
Get-ItemProperty -Path C:\file.txt  # Get file properties
Set-ItemProperty -Path C:\file.txt -Name IsReadOnly -Value $true  # Set read-only
Get-Acl -Path C:\file.txt  # Get file permissions
Set-Acl -Path C:\file.txt -AclObject $acl  # Set file permissions
```

## PowerShell: Processes & Services
*Control processes and services*

```powershell
Get-Process  # List running processes
Get-Process -Name "notepad"  # Find specific process
Start-Process -FilePath "notepad.exe"  # Start application
Start-Process -FilePath "notepad" -ArgumentList "file.txt"  # Start with args
Stop-Process -Name "notepad"  # Stop process by name
Stop-Process -Id 1234  # Stop process by ID
Stop-Process -Name "notepad" -Force  # Force stop
Get-Process | Where-Object { $_.ProcessName -like "note*" }  # Filter processes
Get-Service  # List all services
Start-Service -Name "Windows Update"  # Start service
Stop-Service -Name "Windows Update"  # Stop service
Restart-Service -Name "Windows Update"  # Restart service
```

## PowerShell: Networking & Connectivity
*Network diagnostics and configuration*

```powershell
ipconfig  # Show all network interfaces and IPs
ipconfig /all  # Detailed network configuration
ipconfig /release  # Release DHCP lease
ipconfig /renew  # Renew DHCP lease
netstat  # Show network connections and listening ports
netstat -ano  # Detailed with process IDs
ping hostname  # Ping host
nslookup domain.com  # DNS lookup
tracert domain.com  # Trace route to host
Get-NetIPAddress  # Get IP addresses
Test-NetConnection -ComputerName server.com -Port 443  # Test connection
```

## PowerShell: String Manipulation
*Work with text and strings*

```powershell
$string = "Hello World"  # Create string
$string.ToUpper()  # Convert to uppercase
$string.ToLower()  # Convert to lowercase
$string.Length  # Get string length
$string.Substring(0, 5)  # Extract substring
$string.Replace("World", "PowerShell")  # Replace text
$string.Split(" ")  # Split string by delimiter
$string -match "pattern"  # Match regex pattern
$string -like "Hello*"  # Wildcard match
"$name is $age years old"  # String interpolation
"{0} {1}" -f $first, $last  # String formatting
@"
Multi-line
string
"@  # Here-string syntax
```

## PowerShell: Error Handling
*Handle and manage errors in scripts*

```powershell
try { Get-Item C:\invalid } catch { Write-Host "Error occurred" }  # Try-catch block
try { } catch [System.IO.FileNotFoundException] { }  # Catch specific exception
try { } catch { $_.Exception.Message }  # Get error message
try { } finally { Write-Host "Cleanup" }  # Finally block always runs
$ErrorActionPreference = "Stop"  # Stop on error
$ErrorActionPreference = "SilentlyContinue"  # Suppress errors
$ErrorActionPreference = "Continue"  # Continue on error (default)
Write-Error "Custom error"  # Write error message
Write-Warning "Warning message"  # Write warning
Write-Host "Message" -ForegroundColor Red  # Colored output
```

## PowerShell: Modules & Functions
*Create and import reusable code*

```powershell
Get-Module  # List loaded modules
Get-Module -ListAvailable  # List all available modules
Import-Module ModuleName  # Import module
Get-Command -Module ModuleName  # List module commands
function Say-Hello { Write-Host "Hello!" }  # Define function
function Greet($name) { Write-Host "Hello, $name!" }  # Function with parameter
function Add-Numbers($a, $b) { return $a + $b }  # Function with return value
function Get-Info {
    param(
        [string]$Name,
        [int]$Age
    )
    Write-Host "$Name is $Age years old"
}  # Function with typed parameters
Export-ModuleMember -Function Say-Hello  # Export function from module
```

## PowerShell: Scripts & Automation Best Practices
*Write maintainable and efficient scripts*

```powershell
# Comment your code
<#
  Multi-line comment
  describing script purpose
#>

# Use meaningful variable names
$userName = "admin"  # Good
$u = "admin"  # Avoid

# Use parameter blocks
param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,
    
    [int]$Port = 3389
)

# Proper error handling
$ErrorActionPreference = "Stop"
trap { Write-Error $_; exit 1 }

# Use Write-Host sparingly (prefer Write-Output for pipeline)
Write-Output "Message to pipeline"
Write-Host "Visual message to console"

# Logging
Add-Content -Path "log.txt" -Value "$(Get-Date): Action completed"

# Use filters and Where-Object efficiently
Get-Process | Where-Object { $_.Memory -gt 100MB }

# Always quote paths with spaces
Get-Item -Path "C:\Program Files\App"

# Use -WhatIf and -Confirm for destructive operations
Remove-Item -Path C:\file.txt -WhatIf  # Preview without executing
```
