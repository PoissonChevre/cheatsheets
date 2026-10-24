# VS Code Cheat Sheet (Linux)

Code editor by Microsoft — Linux shortcuts, CLI, config files and remote development.

---

## Install & Update

```bash
sudo apt install ./code_*_amd64.deb  # Install downloaded .deb (also adds Microsoft apt repo)
sudo apt update && sudo apt upgrade code  # Update through the repo
sudo snap install code --classic  # Alternative: Snap
# Avoid the Flatpak version: sandbox breaks terminal, SDKs and Remote-SSH
```

## Essential Shortcuts

`Ctrl+K Ctrl+S` shows and edits all shortcuts.

```
Ctrl+Shift+P   Command palette (everything is here)
Ctrl+P         Quick open file by name
Ctrl+,         Settings
Ctrl+B         Toggle sidebar
Ctrl+`         Toggle terminal
Ctrl+Shift+`   New terminal
Ctrl+\         Split editor
Ctrl+Tab       Switch between open files
Ctrl+W         Close file
Ctrl+Shift+T   Reopen closed file
```

## Editing

```
Alt+↑ / ↓          Move line up/down
Ctrl+Shift+K       Delete line
Ctrl+Enter         Insert line below
Ctrl+/             Toggle line comment
Ctrl+Shift+A       Toggle block comment
Ctrl+Shift+I       Format document
Ctrl+D             Select next occurrence (repeat to add more)
Ctrl+Shift+L       Select all occurrences
Alt+Click          Add cursor
Ctrl+U             Undo last cursor
Alt+Z              Toggle word wrap
```

## Navigation & Search

```
Ctrl+G             Go to line
Ctrl+Shift+O       Go to symbol in file
F12                Go to definition
F2                 Rename symbol everywhere
Ctrl+F / Ctrl+H    Find / replace in file
Ctrl+Shift+F       Search in all files
Ctrl+Shift+H       Replace in all files
Ctrl+Shift+E/G/X   Explorer / Git / Extensions panel
Ctrl+Shift+V       Markdown preview
```

## Command Line

```bash
code .  # Open current folder
code file.py  # Open a file
code -g main.tf:42  # Open file at line 42
code -n  # New window
code -r .  # Reuse current window
code -d old.yaml new.yaml  # Compare two files (diff)
code --list-extensions  # List installed extensions
code --install-extension hashicorp.terraform  # Install extension
code --list-extensions > extensions.txt  # Export extension list
xargs -L1 code --install-extension < extensions.txt  # Reinstall them on another machine
code --disable-extensions  # Start without extensions (debug)
```

## Config Files

```bash
~/.config/Code/User/settings.json  # User settings
~/.config/Code/User/keybindings.json  # Custom shortcuts
~/.config/Code/User/snippets/  # Code snippets
~/.vscode/extensions/  # Installed extensions
.vscode/settings.json  # Per-project settings (inside a repo)
# Settings Sync (account icon, bottom left) syncs everything via GitHub/Microsoft account
```

**settings.json example:**

```jsonc
{
  "editor.formatOnSave": true,
  "editor.rulers": [80, 120],
  "files.trimTrailingWhitespace": true,
  "files.autoSave": "onFocusChange",
  "terminal.integrated.defaultProfile.linux": "bash"
}
```

## Remote Development

```bash
# Extension "Remote - SSH" → uses your ~/.ssh/config hosts
code --remote ssh-remote+myserver /home/user/project  # Open remote folder from CLI
# Ctrl+Shift+P → "Remote-SSH: Connect to Host..."
# Extension "Dev Containers" → open a project inside a Docker container
```

## Useful Extensions (DevOps)

Install with `code --install-extension <id>`.

```bash
ms-vscode-remote.remote-ssh  # Remote SSH
ms-azuretools.vscode-docker  # Docker
ms-kubernetes-tools.vscode-kubernetes-tools  # Kubernetes
hashicorp.terraform  # Terraform
ms-azuretools.vscode-bicep  # Bicep (Azure)
redhat.vscode-yaml  # YAML (K8s, Ansible, CI)
redhat.ansible  # Ansible
ms-python.python  # Python
eamodio.gitlens  # Git history and blame
```

## Troubleshooting

```bash
# "Unable to watch for file changes" → raise inotify limit
echo 'fs.inotify.max_user_watches=524288' | sudo tee /etc/sysctl.d/99-vscode.conf
sudo sysctl -p /etc/sysctl.d/99-vscode.conf

# Settings Sync keeps asking to log in → force the keyring
code --password-store=gnome-libsecret

# Extension misbehaving → Ctrl+Shift+P "Developer: Reload Window"
```

---

## Pitfalls

- Use the Microsoft repo package: the Snap and Flatpak versions break the terminal, SDKs and Remote-SSH.
- Workspace settings (`.vscode/settings.json`) override user settings.
- With Remote-SSH, extensions run on the **server**: install them there too.
- Remote-SSH keeps old servers in `~/.vscode-server`: clean it when disk space is low.
- "Unable to watch for file changes": raise `fs.inotify.max_user_watches`.

---

## References

- [VS Code on Linux](https://code.visualstudio.com/docs/setup/linux)
- [Keyboard shortcuts for Linux (PDF)](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf)
- [Command line interface](https://code.visualstudio.com/docs/editor/command-line)
