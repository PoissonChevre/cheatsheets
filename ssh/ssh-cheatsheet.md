# SSH Cheat Sheet
*Secure Shell protocol for remote login and command execution*

## Key Management
*Generate, manage, and organize SSH keys*

```bash
ssh-keygen -t ed25519 -C "your@email.com"  # Generate Ed25519 key (recommended)
ssh-keygen -t rsa -b 4096 -C "comment"  # Generate 4096-bit RSA key
ssh-keygen -p -f ~/.ssh/id_ed25519  # Change key passphrase
ssh-keygen -l -f ~/.ssh/id_ed25519.pub  # Show key fingerprint
ssh-copy-id -i ~/.ssh/id_ed25519 user@host  # Copy public key to remote
cat ~/.ssh/id_ed25519.pub | ssh user@host "cat >> ~/.ssh/authorized_keys"  # Manual key copy
ssh-keygen -R hostname  # Remove host key from known_hosts
```

## Connection & Config
*Connect to hosts and manage SSH configuration*

```bash
ssh user@hostname  # Connect to remote host
ssh -p 2222 user@hostname  # Connect to non-standard port
ssh user@hostname "command"  # Execute remote command
ssh -v user@hostname  # Verbose output (debug connection)
ssh -vvv user@hostname  # Very verbose debugging
cat ~/.ssh/config  # Show SSH config file format
```

**~/.ssh/config example:**
```
Host myserver
    HostName example.com
    User username
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
```

```bash
ssh myserver  # Connect using config entry
```

## SCP & rsync
*Transfer files securely*

```bash
scp file.txt user@host:/path/  # Copy file to remote
scp user@host:/path/file.txt .  # Copy file from remote
scp -r directory/ user@host:/path/  # Copy directory recursively
scp -P 2222 file.txt user@host:/path/  # Use non-standard port
rsync -avz local/ user@host:/remote/  # Sync with compression
rsync -avz --delete user@host:/remote/ local/  # Sync and delete removed files
rsync -avz -e "ssh -p 2222" dir/ user@host:/path/  # Rsync with custom SSH port
```

## Port Forwarding
*Route network traffic through SSH tunnel*

```bash
ssh -L 8080:localhost:3000 user@host  # Local port forward (machine → host → remote)
ssh -R 8080:localhost:3000 user@host  # Remote port forward (host → machine)
ssh -D 9999 user@host  # Dynamic SOCKS5 proxy
curl -x socks5://localhost:9999 http://example.com  # Use SOCKS proxy
ssh -L 8080:database.internal:5432 user@bastion  # Access internal service through bastion
```

## Agent & Jump Hosts
*SSH agent for key management and multi-hop connections*

```bash
eval "$(ssh-agent -s)"  # Start SSH agent (sh/bash)
eval "$(ssh-agent -c)"  # Start SSH agent (csh/tcsh)
ssh-add ~/.ssh/id_ed25519  # Add key to agent
ssh-add -l  # List keys in agent
ssh-add -D  # Remove all keys from agent
ssh -A user@host  # Forward agent to remote (allows chained ssh)
```

**Multi-hop via config:**
```
Host bastion
    HostName bastion.example.com
    User ubuntu

Host internal
    HostName 10.0.1.5
    User ubuntu
    ProxyJump bastion
```

```bash
ssh internal  # Connect through bastion automatically
```

## Hardening Tips
*Secure SSH configuration practices*

```bash
# ~/.ssh/config security settings
Host *
    IdentitiesOnly yes  # Only use explicitly configured keys
    AddKeysToAgent yes  # Auto-add keys to agent
    StrictHostKeyChecking accept-new  # Verify new hosts
    PubkeyAuthentication yes  # Enable public key auth
    PasswordAuthentication no  # Disable password auth (use keys)
    ChallengeResponseAuthentication no  # Disable challenge-response
    
# Server-side (/etc/ssh/sshd_config)
PermitRootLogin no  # Disable root login
PasswordAuthentication no  # Require key-based auth
PubkeyAuthentication yes  # Enable public key auth
Port 2222  # Use non-standard port
AllowUsers user1 user2  # Whitelist specific users
```

```bash
ssh-keyscan -H hostname >> ~/.ssh/known_hosts  # Pre-verify host key
```

## Troubleshooting
*Diagnose and fix SSH connection issues*

```bash
ssh -v user@host  # Verbose output for debugging
ssh -vvv user@host  # Very verbose debugging
ssh-keyscan hostname  # Check remote host key
ssh-keygen -l -f ~/.ssh/id_ed25519.pub  # Verify key fingerprint
ssh-keygen -F hostname  # Find hostname in known_hosts
ssh -o StrictHostKeyChecking=no user@host  # Skip host verification (risky!)
```

**Common issues:**
```bash
# "Permission denied (publickey)" → check ~/.ssh/authorized_keys permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# "Host key verification failed" → verify with ssh-keyscan
ssh-keyscan -H hostname >> ~/.ssh/known_hosts

# "Agent refused operation" → check agent is running
ssh-add -l  # Shows "Could not open a connection" if agent down
```
