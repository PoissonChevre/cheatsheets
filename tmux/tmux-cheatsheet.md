# Tmux Cheat Sheet

Terminal multiplexer for managing multiple sessions and windows

## Sessions

Create and manage tmux sessions

```bash
tmux new-session -s name  # Create new session
tmux new-session -s name -d -c /path  # Create detached session in directory
tmux list-sessions  # List all sessions
tmux attach -t name  # Attach to session
tmux detach  # Detach from session (prefix + d)
tmux kill-session -t name  # Kill session
tmux kill-server  # Kill entire tmux server
tmux rename-session -t old new  # Rename session
tmux list-commands  # List all tmux commands
```

## Windows

Create and switch between windows within a session

```bash
tmux new-window -t session:1  # Create new window in session
tmux list-windows -t session  # List windows
tmux kill-window -t session:1  # Kill specific window
tmux rename-window -t session:1 newname  # Rename window
# Inside tmux (use prefix key, default Ctrl+b):
prefix + c  # Create new window
prefix + n  # Go to next window
prefix + p  # Go to previous window
prefix + w  # List windows interactively
prefix + 0-9  # Jump to window number
prefix + ,  # Rename current window
prefix + &  # Kill current window
```

## Panes

Split windows into multiple panes

```bash
tmux split-window -h  # Split horizontally
tmux split-window -v  # Split vertically
tmux list-panes -t session  # List panes
tmux kill-pane -t session:window.pane  # Kill pane
# Inside tmux:
prefix + %  # Split horizontally
prefix + "  # Split vertically
prefix + arrow-key  # Move between panes
prefix + o  # Select next pane
prefix + ;  # Toggle between panes
prefix + x  # Kill current pane
prefix + space  # Rotate pane layout
prefix + {  # Swap pane left
prefix + }  # Swap pane right
prefix + z  # Zoom current pane (toggle)
```

## Copy Mode

Select, copy, and paste text

```bash
# Inside tmux (navigate with vi/emacs keys):
prefix + [  # Enter copy mode
prefix + ]  # Paste from buffer
# In copy mode (vi keybindings by default):
space  # Start selection
enter  # Copy selected text
/pattern  # Search down
?pattern  # Search up
n  # Next search result
N  # Previous search result
q  # Exit copy mode
```

## Custom Key Bindings

Configure custom shortcuts in ~/.tmux.conf

```bash
# Rebind prefix key to Ctrl+a
set -g prefix C-a
unbind C-b

# Bind common actions
bind -n M-h select-pane -L  # Alt+h to move left
bind -n M-j select-pane -D  # Alt+j to move down
bind -n M-k select-pane -U  # Alt+k to move up
bind -n M-l select-pane -R  # Alt+l to move right

# Quick window/session navigation
bind -n M-1 select-window -t :1
bind c new-window -c "#{pane_current_path}"  # New window in current directory
bind '"' split-window -c "#{pane_current_path}"  # New pane in current directory
bind '%' split-window -h -c "#{pane_current_path}"

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# Mouse support
set -g mouse on
```

## Config Tips

Optimize tmux configuration

```bash
# ~/.tmux.conf example:

# Set color
set -g default-terminal "screen-256color"
set-option -ga terminal-overrides ",xterm-256color:RGB"

# Set status bar
set -g status-bg black
set -g status-fg white
set -g status-left "#[bg=blue] [#S] "
set -g status-right "%H:%M %d-%b"

# History
set -g history-limit 10000

# Responsive repeat time
set -g repeat-time 1000

# Disable rename prompts
set -g allow-rename off

# Enable activity notification
set -g monitor-activity on
set -g visual-activity on

# Start pane numbering from 1
set -g base-index 1
setw -g pane-base-index 1

# Reload config on change
bind r source-file ~/.tmux.conf

# Show available sessions on new tmux
new-session -s work -d
```

```bash
tmux source-file ~/.tmux.conf  # Reload config
```
