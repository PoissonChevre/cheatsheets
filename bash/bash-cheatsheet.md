# Bash — Cheat Sheet

POSIX-compliant shell scripting language for Unix/Linux automation and command execution.

---

## Variables & Quoting

```bash
name="Alice"  # Variable assignment (no spaces around =)
age=30  # Numbers (quotes optional)
echo $name  # Variable expansion
echo ${name}  # Braces disambiguate
echo $name $age  # Multiple variables

# Default values
echo ${name:-"Unknown"}  # Use default if not set
echo ${name:="Unknown"}  # Set and use default
echo ${name:+alt}  # Use if set, else nothing

# String operations
${name:0:3}  # Substring from position 0, length 3
${name#A}  # Remove prefix "A"
${name%ce}  # Remove suffix "ce"
${name/o/0}  # Replace first "o" with "0"
${name//o/0}  # Replace all "o" with "0"
${#name}  # Length of string

# Quoting types
echo "Text with $var"  # Double quotes: expand variables
echo 'Text with $var'  # Single quotes: literal
echo 'It'"'"'s'  # Escape single quote: close, add escaped quote, reopen

# Command substitution
result=$(date)  # Modern syntax
result=`date`  # Legacy syntax
echo "Today is $result"

# Arithmetic expansion
echo $((2 + 3 * 4))  # Arithmetic: 14
((x++))  # Increment
((y = 10 / 2))  # Assignment in arithmetic
```

---

## Conditionals

```bash
# if/elif/else
if [[ $x -gt 10 ]]; then  # Test arithmetic condition
    echo "x is greater than 10"
elif [[ $x -eq 10 ]]; then  # Equal to
    echo "x equals 10"
else
    echo "x is less than 10"
fi

# Test operators
[[ $x -lt 5 ]]   # Less than
[[ $x -le 5 ]]   # Less than or equal
[[ $x -gt 5 ]]   # Greater than
[[ $x -ge 5 ]]   # Greater than or equal
[[ $x -eq 5 ]]   # Equal
[[ $x -ne 5 ]]   # Not equal

# String tests
[[ $str == "hello" ]]  # String equality
[[ $str != "hello" ]]  # String inequality
[[ -z $str ]]  # String is empty
[[ -n $str ]]  # String is not empty
[[ $str =~ ^[0-9]+$ ]]  # Regex match

# Logical operators
[[ $x -gt 5 && $x -lt 10 ]]  # AND
[[ $x -lt 5 || $x -gt 10 ]]  # OR
[[ ! $condition ]]  # NOT

# Case statement
case $var in
    pattern1) echo "matches pattern1" ;;  # Execute if matches
    pattern2|pattern3) echo "matches pattern2 or 3" ;;  # Multiple patterns
    *) echo "default" ;;  # Wildcard default
esac
```

---

## Loops

```bash
# for loop - range
for i in {1..5}; do  # Range from 1 to 5
    echo $i
done

for i in {1..10..2}; do  # Range with step: 1, 3, 5, 7, 9
    echo $i
done

# for loop - list
for item in apple banana cherry; do  # Iterate over items
    echo $item
done

# for loop - array
for item in "${array[@]}"; do  # Iterate over array elements
    echo $item
done

# for loop - command output
for file in $(ls); do  # Iterate over command results
    echo $file
done

# while loop
while [[ $count -lt 5 ]]; do  # Repeat while true
    echo $count
    ((count++))  # Increment
done

# until loop
until [[ $count -eq 5 ]]; do  # Repeat until true
    echo $count
    ((count++))
done

# Loop control
for i in {1..10}; do
    if [[ $i -eq 3 ]]; then
        continue  # Skip to next iteration
    fi
    if [[ $i -eq 7 ]]; then
        break  # Exit loop
    fi
    echo $i
done
```

---

## Functions

```bash
# Function definition
function greet() {  # Function keyword optional
    echo "Hello, $1"  # $1 is first argument
}

greet() {  # Alternative syntax
    local name=$1  # Local variable
    echo "Hello, $name"
}

greet "Alice"  # Call function with argument

# Function with multiple arguments
function add() {
    local result=$(($1 + $2))  # Access arguments
    echo $result  # Return value (via output)
}

result=$(add 10 20)  # Capture output
echo $result  # 30

# Function with return code
function is_even() {
    if (($1 % 2 == 0)); then
        return 0  # Return success (true)
    else
        return 1  # Return failure (false)
    fi
}

if is_even 4; then
    echo "4 is even"
fi

# Local variables
function example() {
    local x=10  # Local scope
    y=20  # Global scope
}

# $@ vs $*
function print_args() {
    echo "All args: $@"  # Array of arguments
    echo "All as string: $*"  # Single string
}
```

---

## Arrays

```bash
# Array creation
arr=(apple banana cherry)  # Indexed array
arr[0]="apple"  # Add by index
arr+=("date")  # Append element
arr[3]="elderberry"  # Add to specific index

# Associative array
declare -A map  # Declare associative array
map["name"]="Alice"  # Key-value assignment
map["age"]=30

# Access array elements
echo ${arr[0]}  # First element
echo ${arr[-1]}  # Last element (bash 4.3+)
echo ${arr[@]}  # All elements
echo ${arr[*]}  # All elements as string
echo ${#arr[@]}  # Array length
echo ${!arr[@]}  # All indices

# Iterate over array
for item in "${arr[@]}"; do  # Use "@" to preserve spaces
    echo $item
done

for key in "${!map[@]}"; do  # Iterate over keys
    echo "$key: ${map[$key]}"
done

# Array operations
unset arr[1]  # Remove element
unset arr  # Unset entire array
```

---

## String Manipulation

```bash
str="hello world"

# Convert case
echo ${str^^}  # Uppercase (bash 4.0+)
echo ${str,,}  # Lowercase (bash 4.0+)
tr '[:lower:]' '[:upper:]' <<< "$str"  # Uppercase with tr

# Substring
echo ${str:0:5}  # First 5 characters: "hello"
echo ${str:6}  # From position 6: "world"
echo ${str: -5}  # Last 5 characters: "world"

# Find and replace
echo ${str/world/universe}  # Replace first match
echo ${str//l/L}  # Replace all matches

# Remove prefix/suffix
echo ${str#hello }  # Remove prefix: "world"
echo ${str% world}  # Remove suffix: "hello"
echo ${str##* }  # Remove longest prefix: "world"
echo ${str%% *}  # Remove longest suffix: "hello"

# Length
echo ${#str}  # String length: 11

# Index of substring
expr index "$str" "w"  # Position of "w": 7

# Extract words
echo $str | cut -d' ' -f1  # First word (split by space)
echo $str | awk '{print $2}'  # Second word
```

## File Tests

```bash
# File existence and type
[[ -e file.txt ]]  # File exists
[[ -f file.txt ]]  # Regular file
[[ -d /home ]]  # Directory
[[ -L symlink ]]  # Symbolic link
[[ -b /dev/sda ]]  # Block device
[[ -c /dev/null ]]  # Character device

# File permissions
[[ -r file.txt ]]  # Readable
[[ -w file.txt ]]  # Writable
[[ -x script.sh ]]  # Executable
[[ -u file.txt ]]  # Set-user-id bit

# File properties
[[ -s file.txt ]]  # File size > 0 (not empty)
[[ -z "$str" ]]  # String is empty
[[ -n "$str" ]]  # String is not empty
[[ file1 -nt file2 ]]  # file1 newer than file2
[[ file1 -ot file2 ]]  # file1 older than file2

# File comparison
if [[ -f $file ]]; then
    echo "File exists and is regular"
fi
```

---

## Process & Job Control

```bash
# Background processes
command &  # Run in background
sleep 100 &  # Run and get prompt back
wait  # Wait for all background jobs
wait $!  # Wait for last process

# Jobs
jobs  # List background jobs
jobs -l  # List with PID
jobs -r  # Running jobs only
fg  # Bring last job to foreground
fg %1  # Bring job 1 to foreground
bg  # Resume last job in background

# Process information
ps  # List processes
ps aux  # Detailed process list
ps aux | grep process_name  # Find specific process
pgrep process_name  # Get PID of process
top  # Interactive process monitor

# Kill processes
kill $PID  # Send SIGTERM
kill -9 $PID  # Send SIGKILL (force)
kill -STOP $PID  # Pause process
kill -CONT $PID  # Resume process
killall process_name  # Kill by name
```

---

## Input/Output & Redirection

```bash
# Redirection
command > file.txt  # Redirect stdout to file (overwrite)
command >> file.txt  # Append stdout to file
command < input.txt  # Redirect stdin from file
command 2> error.txt  # Redirect stderr to file
command &> output.txt  # Redirect both stdout and stderr
command 2>&1  # Redirect stderr to stdout

# Here-document
cat << EOF  # Multi-line input
This is a
multi-line
string
EOF

# Here-string
grep "pattern" <<< "text to search"  # Single line input

# Pipes
command1 | command2  # Pipe output of command1 to command2
cat file.txt | grep "pattern"  # Filter with grep
ls | wc -l  # Count lines
ps aux | grep process | grep -v grep  # Filter processes

# Process substitution
diff <(ls dir1) <(ls dir2)  # Compare directory listings

# Null device
command > /dev/null  # Discard output
command 2> /dev/null  # Discard errors

# Multiple redirections
exec 3< file.txt  # Open file descriptor 3 for reading
read -u 3 line  # Read from descriptor 3
exec 3>&-  # Close descriptor 3
```

---

## Script Best Practices

```bash
#!/bin/bash  # Shebang: specify interpreter
set -euo pipefail  # Exit on error, undefined var, pipe failure

# Use functions for organization
main() {
    echo "Script started"
    do_something
    do_something_else
}

# Check script arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 filename"  # $0 is script name
    exit 1  # Exit with error code
fi

# Use local variables in functions
do_something() {
    local file=$1  # Local prevents global pollution
    if [[ ! -f $file ]]; then
        echo "Error: file not found" >&2  # Write to stderr
        return 1  # Return error code
    fi
}

# Quoting variables to handle spaces
for file in *.txt; do
    process_file "$file"  # Always quote
done

# Comments
# This is a comment
: 'This is a
multi-line comment'  # Using : and string

# Strict mode
set -o nounset  # Error on undefined variables
set -o errexit  # Exit on any error
set -o pipefail  # Error if any pipe fails

# Trap errors
trap 'echo "Error on line $LINENO"' ERR  # Run on error
trap 'rm -f tempfile' EXIT  # Cleanup on exit
```

---

## Pitfalls

- Quote your variables: `"$var"`. Without quotes, spaces split the value and `*` expands.
- No spaces around `=` in assignments: `name=value`.
- Spaces are required inside tests: `[[ -f "$file" ]]`, not `[[-f $file]]`.
- Use `[[ ]]` in Bash scripts, `$( )` instead of backticks.
- `for f in $(ls)` breaks on file names with spaces: use `for f in *`.
- `$?` changes after every command: save it right away.
- Start scripts with `#!/usr/bin/env bash` and `set -euo pipefail`, then `chmod +x`.
- Check scripts with `shellcheck`.
