# PowerShell — Cheat Sheet

Microsoft's cross-platform task automation and configuration management framework.

---

## Basics & Syntax

```powershell
# Variable assignment
$variable = "value"  # Assign string variable
$number = 42  # Assign integer
$boolean = $true  # Assign boolean
$null  # Empty/null value
[string]$var = "text"  # Type casting

# Arrays and Collections
$array = @(1, 2, 3, 4)  # Create array
$array += 5  # Add element
$array[0]  # Access element
$array.Count  # Get array count
$array.Length  # Get array length
$hash = @{"key" = "value"; "name" = "John"}  # Create hashtable
$hash["key"]  # Access hashtable value

# Comments
# Single-line comment
<# Multi-line
   comment block #>
```

## Navigation

```powershell
Get-Location  # Show current directory (pwd alias)
Set-Location C:\Users\Name  # Change directory (cd alias)
Get-Item -Path C:\  # Get item properties
Get-ChildItem -Path C:\  # List files and folders (dir alias)
Get-ChildItem -Path C:\ -Recurse  # List recursively
Get-ChildItem -Path C:\ -Filter *.txt  # Filter by extension
Push-Location C:\temp  # Save location and change
Pop-Location  # Return to saved location
```

## Files & Permissions

```powershell
New-Item -ItemType Directory -Path C:\NewFolder  # Create directory
New-Item -ItemType File -Path C:\file.txt  # Create empty file
Remove-Item -Path C:\file.txt  # Delete file
Remove-Item -Path C:\Folder -Recurse -Force  # Delete directory recursively
Copy-Item -Path C:\source.txt -Destination C:\dest.txt  # Copy file
Copy-Item -Path C:\Folder -Destination C:\Backup -Recurse  # Copy directory
Move-Item -Path C:\file.txt -Destination C:\NewFolder\  # Move file
Rename-Item -Path C:\old.txt -NewName new.txt  # Rename file
Get-ItemProperty -Path C:\file.txt  # Get file properties
Set-ItemProperty -Path C:\file.txt -Name IsReadOnly -Value $true  # Set read-only
Get-Content -Path C:\file.txt  # Read file content
Set-Content -Path C:\file.txt -Value "content"  # Write to file
Add-Content -Path C:\file.txt -Value "append"  # Append to file
```

## Permissions (NTFS ACL)

```powershell
Get-Acl -Path C:\file.txt  # Get file permissions
Get-Acl -Path C:\Folder | Format-List  # View detailed permissions
$acl = Get-Acl -Path C:\file.txt  # Get ACL object
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("user", "FullControl", "Allow")  # Create rule
$acl.SetAccessRule($rule)  # Add rule to ACL
Set-Acl -Path C:\file.txt -AclObject $acl  # Apply ACL
icacls C:\file.txt /grant "user:F"  # Grant full control (cmd style)
icacls C:\file.txt /remove "user"  # Remove user permissions
```

## Processes

```powershell
Get-Process  # List running processes
Get-Process -Name "notepad"  # Find specific process
Get-Process | Where-Object { $_.Memory -gt 100MB }  # Filter by memory usage
Start-Process -FilePath "notepad.exe"  # Start application
Start-Process -FilePath "notepad" -ArgumentList "file.txt"  # Start with arguments
Start-Process notepad.exe -WindowStyle Minimized  # Start minimized
Stop-Process -Name "notepad"  # Stop process by name
Stop-Process -Id 1234  # Stop process by ID
Stop-Process -Name "notepad" -Force  # Force stop
Get-Process | Sort-Object -Property WorkingSet -Descending  # Top memory users
```

## Networking

```powershell
ipconfig  # Show all network interfaces and IPs
ipconfig /all  # Detailed network configuration
ipconfig /release  # Release DHCP lease
ipconfig /renew  # Renew DHCP lease
netstat  # Show network connections and listening ports
netstat -ano  # Detailed with process IDs
netstat -ano | findstr :3000  # Find specific port listener
ping hostname  # Ping host
nslookup domain.com  # DNS lookup
nslookup domain.com 8.8.8.8  # DNS lookup on specific server
tracert domain.com  # Trace route to host
Get-NetIPAddress  # List IP addresses
Get-NetAdapter  # List network adapters
Get-NetConnectionProfile  # Show network profiles
Test-NetConnection -ComputerName server.com -Port 443  # Test TCP connection
Test-Connection -ComputerName server.com  # Ping test
Get-NetTCPConnection  # Show active TCP connections
Get-NetTCPConnection -LocalPort 443  # Connections on specific port
```

## String Manipulation

```powershell
$string = "Hello World"  # Create string
$string.Length  # Get string length
$string.ToUpper()  # Convert to uppercase
$string.ToLower()  # Convert to lowercase
$string.Trim()  # Remove leading/trailing whitespace
$string.Substring(0, 5)  # Extract substring (0-5 characters)
$string.IndexOf("World")  # Find position of substring
$string.Replace("World", "PowerShell")  # Replace text
$string.Split(" ")  # Split string by delimiter
$string -match "pattern"  # Match regex pattern (returns $true/$false)
$string -like "Hello*"  # Wildcard match
$string -contains "o"  # Check if contains (for arrays)

# String formatting and interpolation
"$name is $age years old"  # String interpolation with $variables
"{0} {1}" -f $first, $last  # String formatting with placeholders
@"
Multi-line
string literal
"@  # Here-string syntax (preserves formatting)

# Advanced string operations
$regex = [regex]"(\w+)@(\w+)"  # Create regex object
$regex.Match("user@domain")  # Match against string
$string | Select-String "pattern"  # Search within string
```

## Error Handling & Debugging

```powershell
try {
    Get-Item C:\invalid
} catch {
    Write-Host "Error occurred"
}  # Basic try-catch

try { } catch [System.IO.FileNotFoundException] { }  # Catch specific exception
try { } catch [System.UnauthorizedAccessException] { }  # Catch access denied
try {
    # code
} catch {
    $_.Exception.Message  # Get error message
    $_.Exception.GetType().Name  # Get exception type
}  # Access error details

try { } catch { } finally { Write-Host "Cleanup" }  # Finally block always runs

$ErrorActionPreference = "Stop"  # Stop on error
$ErrorActionPreference = "Continue"  # Continue on error (default)
$ErrorActionPreference = "SilentlyContinue"  # Suppress errors
$ErrorActionPreference = "Inquire"  # Ask user on error

Write-Error "Custom error message"  # Write error to stream
Write-Warning "Warning message"  # Write warning
Write-Verbose "Debug message" -Verbose  # Verbose output
Write-Debug "Debug message" -Debug  # Debug output (requires -Debug)
```

## Modules & Imports

```powershell
Get-Module  # List currently loaded modules
Get-Module -ListAvailable  # List all available modules on system
Get-Module -Name Microsoft.PowerShell.Archive  # Get specific module info
Import-Module ModuleName  # Import module
Import-Module C:\path\to\module.psm1  # Import from file path
Get-Command -Module ModuleName  # List all commands in module
Get-Help -Module ModuleName  # Get module help
Remove-Module ModuleName  # Unload module
$env:PSModulePath  # Show module search paths
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted  # Trust repository
Find-Module ModuleName  # Search PowerShell Gallery
Install-Module ModuleName  # Install from PowerShell Gallery
Update-Module ModuleName  # Update installed module
```

## Script Best Practices

```powershell
#!/usr/bin/env pwsh  # Shebang for cross-platform scripts

# Script metadata and help
<#
.SYNOPSIS
    Brief description of script functionality

.DESCRIPTION
    Detailed description of what the script does

.PARAMETER ComputerName
    Name of the computer to process

.PARAMETER Port
    Port number (default: 3389)

.EXAMPLE
    .\script.ps1 -ComputerName "SERVER01" -Port 443

.NOTES
    Author: Your Name
    Version: 1.0
#>

# Parameter block with validation
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,

    [Parameter(Mandatory=$false)]
    [int]$Port = 3389,

    [switch]$Verbose
)

# Error handling setup
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
trap { Write-Error $_; exit 1 }

# Use meaningful variable names (avoid abbreviations)
$targetServer = "SERVER01"  # Good
$ts = "SERVER01"  # Avoid

# Use functions for reusable code
function Invoke-SafeOperation {
    param([string]$Path)
    try {
        Get-Item -Path $Path
    } catch {
        Write-Error "Failed to access $Path : $_"
        return $null
    }
}

# Logging for auditing
$logFile = "C:\logs\script_$(Get-Date -Format 'yyyyMMdd').log"
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $Message"
}

# Prefer Output cmdlets over Host for pipeline compatibility
Write-Output "Data to pipeline"  # Recommended
Write-Host "Visual display only"  # Use sparingly

# Avoid quotes unless necessary
Get-ChildItem -Path C:\Users  # Good
Get-ChildItem -Path "C:\Users"  # Also fine

# Quote paths with spaces
Get-Item -Path "C:\Program Files\App"  # Required

# Use -WhatIf and -Confirm for destructive operations
Remove-Item -Path C:\file.txt -WhatIf  # Preview without executing
Remove-Item -Path C:\file.txt -Confirm  # Ask before deleting

# Efficient filtering (filter left, not right)
Get-Process | Where-Object { $_.Memory -gt 100MB }  # Process each item
Get-Process -Name "notepad"  # Filter at source (more efficient)

# Use splatting for readable command calls
$params = @{
    Path = "C:\file.txt"
    Filter = "*.log"
    Recurse = $true
}
Get-ChildItem @params  # More readable

# Return $null explicitly for clarity
if (-not $result) {
    return $null  # Explicit return
}
```

## Variables & Data Types

```powershell
# String operations
$string = "Hello World"  # Create string
$variable.Length  # Get string length
$array = @(1, 2, 3, 4)  # Create array
$array[0]  # Access array element
$array.Count  # Get array count
$hash = @{"key" = "value"; "name" = "John"}  # Create hashtable

# Type casting
[string]$var = "text"  # Explicitly typed string
[int]$number = 42  # Explicitly typed integer
[array]$list = 1, 2, 3  # Convert to array
[PSCustomObject]@{Name="John"; Age=30}  # Create custom object

# Boolean and comparison
$true / $false  # Boolean values
$x -eq 5  # Equal to
$x -ne 5  # Not equal to
$x -gt 5  # Greater than
$x -lt 5  # Less than
$x -ge 5  # Greater or equal
$x -le 5  # Less or equal

# Logical operators
-not $condition  # Logical NOT
$x -and $y  # Logical AND
$x -or $y  # Logical OR
```

## Conditionals & Loops

```powershell
# If-else statements
if ($condition) {
    Write-Host "True"
}  # If statement
if ($x -eq 5) {
    Write-Host "Equal"
} elseif ($x -gt 5) {
    Write-Host "Greater"
} else {
    Write-Host "Less"
}  # If-elseif-else

# Switch statement
switch ($status) {
    "Running" { Write-Host "Active" }
    "Stopped" { Write-Host "Inactive" }
    default { Write-Host "Unknown" }
}  # Switch with default

# For loop
for ($i = 0; $i -lt 10; $i++) {
    Write-Host $i
}  # C-style for loop

# Foreach loop
foreach ($item in $collection) {
    Write-Host $item
}  # For-each loop
1..10 | ForEach-Object { Write-Host $_ }  # Range loop

# While loop
while ($condition) { }  # While loop
do { } while ($condition)  # Do-while loop

# Loop control
break  # Exit loop
continue  # Skip to next iteration
```

## Functions

```powershell
# Simple function
function Say-Hello {
    Write-Host "Hello!"
}

# Function with parameters
function Greet($name) {
    Write-Host "Hello, $name!"
}

# Function with return value
function Add-Numbers($a, $b) {
    return $a + $b
}

# Function with typed parameters
function Get-Info {
    param(
        [string]$Name,
        [int]$Age
    )
    Write-Host "$Name is $Age years old"
}

# Function with default values
function Set-Config {
    param(
        [string]$Path = "C:\Config\default.cfg",
        [int]$Timeout = 30
    )
    Write-Host "Using $Path with timeout $Timeout"
}

# Function with mandatory parameters
function Remove-UserAccount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    Write-Host "Removing account: $Username"
}
```

## Arrays & Collections

```powershell
$array = @(1, 2, 3)  # Create array
$array += 4  # Add element
$array[0]  # Access element
$array.Length  # Get count
$array | ForEach-Object { $_ * 2 }  # Iterate and double each
$array | Where-Object { $_ -gt 2 }  # Filter items greater than 2
$array | Sort-Object  # Sort array
$array | Sort-Object -Descending  # Sort descending
$array | Select-Object -First 2  # Get first 2 items
$array | Select-Object -Last 2  # Get last 2 items
$array | Measure-Object -Sum  # Calculate sum
$array | Measure-Object -Average  # Calculate average
```

## Output & Formatting

```powershell
Write-Host "message"  # Write to console (colored output)
Write-Host "Red text" -ForegroundColor Red  # Colored text
Write-Host "Bold text" -BackgroundColor Black  # Background color
Write-Output "message"  # Write to pipeline
Write-Error "error message"  # Write error
Write-Warning "warning message"  # Write warning
Write-Verbose "verbose message" -Verbose  # Verbose output

# Format output
Get-Process | Format-Table  # Table format
Get-Process | Format-List  # List format
Get-Process | Format-List -Property Name, Id  # Specific properties
Get-Process | Select-Object Name, Id  # Select specific columns
Get-Process | Sort-Object -Property Name  # Sort output
Get-Process | Group-Object -Property ProcessName  # Group by property
Get-Process | Measure-Object  # Count and statistics
```

## Pipeline & Data Flow

```powershell
command1 | command2  # Pipe output as input
Get-Process | Where-Object { $_.ProcessName -like "note*" }  # Filter
Get-Process | Select-Object -Property Name, Id  # Select properties
Get-ChildItem | Sort-Object -Property LastWriteTime  # Sort
Get-Process | Group-Object -Property ProcessName  # Group by property
Get-Service | Where-Object { $_.Status -eq "Running" } | Stop-Service  # Chain filters
$output = Get-Process | ConvertTo-Json  # Convert to JSON
$data = Get-Content -Path data.json | ConvertFrom-Json  # Parse JSON
Get-ChildItem | Export-Csv -Path output.csv  # Export to CSV
Import-Csv -Path data.csv | ForEach-Object { $_.Name }  # Import from CSV
```

---

## Pitfalls

- PowerShell passes **objects**, not text: use `Select-Object`, `Where-Object` instead of parsing strings.
- Comparisons are `-eq -ne -gt -lt -like -match`; `>` is a redirection.
- The escape character is the backtick `` ` ``, not `\`.
- Scripts blocked? `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`.
- `try/catch` only catches terminating errors: add `-ErrorAction Stop` or `$ErrorActionPreference = 'Stop'`.
- Windows PowerShell 5.1 and PowerShell 7 (`pwsh`) differ; in 5.1 `curl` and `wget` are aliases of `Invoke-WebRequest`.
- Use `-WhatIf` before destructive commands.
