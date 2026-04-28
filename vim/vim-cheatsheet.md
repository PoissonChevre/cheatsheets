# Vim Cheat Sheet
*Highly configurable text editor with modal editing paradigm*

## Modes
*Understanding Vim's modal editing*

```bash
vim file.txt  # Open file in vim
# Key modes:
i  # Insert mode (edit text)
Esc  # Return to normal mode
:  # Command mode (type :)
/  # Search mode (find text)
?  # Reverse search mode
v  # Visual mode (select text)
V  # Visual line mode (select lines)
Ctrl+v  # Visual block mode (select columns)
```

## Navigation
*Move cursor through file*

```bash
h  # Move left
j  # Move down
k  # Move up
l  # Move right
w  # Move to next word start
W  # Move to next word (ignore punctuation)
b  # Move to previous word start
e  # Move to word end
0  # Move to line start
$  # Move to line end
gg  # Go to file start
G  # Go to file end
:42  # Go to line 42
Ctrl+f  # Page down
Ctrl+b  # Page up
Ctrl+d  # Half page down
Ctrl+u  # Half page up
{  # Previous paragraph
}  # Next paragraph
%  # Go to matching bracket
```

## Editing
*Insert, change, and delete text*

```bash
i  # Insert before cursor
I  # Insert at line start
a  # Append after cursor
A  # Append at line end
o  # Open new line below
O  # Open new line above
x  # Delete character
dd  # Delete line
dw  # Delete word
d$  # Delete to line end
d0  # Delete to line start
cw  # Change word
cc  # Change line
c$  # Change to line end
r<char>  # Replace character
R  # Replace mode (overwrite)
J  # Join lines
u  # Undo
Ctrl+r  # Redo
.  # Repeat last command
```

## Search & Replace
*Find and modify text*

```bash
/pattern  # Search forward
?pattern  # Search backward
n  # Next match
N  # Previous match
*  # Search current word forward
#  # Search current word backward
:s/old/new/  # Replace in current line
:s/old/new/g  # Replace all in current line
:%s/old/new/g  # Replace all in file
:%s/old/new/gc  # Replace with confirmation
:1,10s/old/new/g  # Replace in lines 1-10
:%s/^/prefix/  # Add prefix to all lines
:%s/$/suffix/  # Add suffix to all lines
```

## Macros
*Record and playback command sequences*

```bash
qa  # Start recording macro 'a'
q  # Stop recording
@a  # Playback macro 'a'
10@a  # Repeat macro 10 times
@@  # Repeat last macro
:reg  # Show all macros/registers
:reg a  # Show macro 'a' contents
```

## Splits & Tabs
*Work with multiple windows and tabs*

```bash
:split filename  # Split horizontally
:vsplit filename  # Split vertically
Ctrl+w w  # Switch between splits
Ctrl+w h  # Move to split on left
Ctrl+w j  # Move to split below
Ctrl+w k  # Move to split above
Ctrl+w l  # Move to split on right
Ctrl+w =  # Make splits equal size
Ctrl+w >  # Increase split width
Ctrl+w <  # Decrease split width
:tabnew filename  # Open file in new tab
gt  # Go to next tab
gT  # Go to previous tab
:tabc  # Close current tab
:tabl  # Close all other tabs
```

## Save & Quit
*Save files and exit vim*

```bash
:w  # Save file
:w filename  # Save as new filename
:wa  # Save all files
:wq  # Save and quit
ZZ  # Save and quit (shortcut)
:q  # Quit without saving
:q!  # Force quit without saving
:e filename  # Open file (replaces current)
:e!  # Reload file (discard changes)
:vs filename  # Open file in vertical split
:split filename  # Open file in horizontal split
:read filename  # Insert file contents
:terminal  # Open terminal buffer
```
