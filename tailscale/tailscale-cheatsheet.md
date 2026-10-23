# Tailscale Cheat Sheet
*Zero-config mesh VPN built on WireGuard — connect your devices into a private "tailnet"*

## Install & Service
*Install the client and manage the daemon*

```bash
curl -fsSL https://tailscale.com/install.sh | sh  # Install on Linux
sudo systemctl enable --now tailscaled  # Start daemon at boot
sudo tailscale update  # Update client
```

## Connect
*Join and leave the tailnet*

```bash
sudo tailscale up  # Connect (opens login URL on first run)
sudo tailscale up --authkey=tskey-auth-XXXX  # Headless login (servers)
sudo tailscale set --hostname=srv-web01  # Rename device in the tailnet
sudo tailscale down  # Disconnect (stay logged in)
sudo tailscale logout  # Disconnect and remove device
```

## Status
*Check peers, IPs and connectivity*

```bash
tailscale status  # List devices and their tailnet IPs
tailscale ip -4  # Show this device's tailnet IP (100.x.y.z)
tailscale ping srv-web01  # Test connection (direct or via DERP relay)
tailscale netcheck  # Check NAT / UDP / nearest relay
```

**Good to know:**
```
Tailnet IPs : 100.64.0.0/10 — stable per device
MagicDNS    : reach devices by name → ssh user@srv-web01
```

## Subnet Router & Exit Node
*Reach a whole LAN through one device, or route internet traffic through it*

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf  # Enable IP forwarding (required)
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

sudo tailscale set --advertise-routes=192.168.1.0/24  # Share home LAN with the tailnet
sudo tailscale set --accept-routes  # Use shared routes (Linux clients)
sudo tailscale set --advertise-exit-node  # Offer this device as exit node
sudo tailscale set --exit-node=srv-web01  # Route all internet traffic through it
sudo tailscale set --exit-node=  # Stop using exit node
## Routes and exit nodes must be approved in the admin console
```

## Tailscale SSH & Files
*SSH without managing keys, send files between devices*

```bash
sudo tailscale set --ssh  # Enable Tailscale SSH on this device
ssh user@srv-web01  # Connect by name
tailscale file cp report.pdf srv-web01:  # Send a file (Taildrop)
sudo tailscale file get ~/Downloads  # Receive files
tailscale serve --bg 3000  # Share localhost:3000 over HTTPS (tailnet only)
tailscale serve reset  # Stop sharing
```

## Homelab
*Tailscale in a Proxmox LXC container*

**Add to `/etc/pve/lxc/<CTID>.conf`, then restart the container:**
```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

## Troubleshooting
*Common issues*

```bash
# Ping shows "via DERP" → relayed (slower), UDP blocked by a firewall
# Device disconnected after ~6 months → disable "Key expiry" in admin console
# Subnet not reachable → IP forwarding off, route not approved, or missing --accept-routes
# LXC "failed to create tun" → add the /dev/net/tun lines above
journalctl -u tailscaled -f  # Follow daemon logs
```

## References
- [Tailscale documentation](https://tailscale.com/kb)
- [CLI reference](https://tailscale.com/kb/1080/cli)
