# Tailscale — Cheat Sheet

Zero-config mesh VPN built on WireGuard — connect your devices into a private "tailnet".

---

## Install & Service

```bash
curl -fsSL https://tailscale.com/install.sh | sh  # Install on Linux
sudo systemctl enable --now tailscaled  # Start daemon at boot
sudo tailscale update  # Update client
```

## Connect

```bash
sudo tailscale up  # Connect (opens login URL on first run)
sudo tailscale up --authkey=tskey-auth-XXXX  # Headless login (servers)
sudo tailscale set --hostname=srv-web01  # Rename device in the tailnet
sudo tailscale down  # Disconnect (stay logged in)
sudo tailscale logout  # Disconnect and remove device
```

## Status

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

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf  # Enable IP forwarding (required)
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

sudo tailscale set --advertise-routes=192.168.1.0/24  # Share home LAN with the tailnet
sudo tailscale set --accept-routes  # Use shared routes (Linux clients)
sudo tailscale set --advertise-exit-node  # Offer this device as exit node
sudo tailscale set --exit-node=srv-web01  # Route all internet traffic through it
sudo tailscale set --exit-node=  # Stop using exit node
```

## Tailscale SSH & Files

```bash
sudo tailscale set --ssh  # Enable Tailscale SSH on this device
ssh user@srv-web01  # Connect by name
tailscale file cp report.pdf srv-web01:  # Send a file (Taildrop)
sudo tailscale file get ~/Downloads  # Receive files
tailscale serve --bg 3000  # Share localhost:3000 over HTTPS (tailnet only)
tailscale serve reset  # Stop sharing
```

## Homelab

**Add to `/etc/pve/lxc/<CTID>.conf`, then restart the container:**
```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

## Troubleshooting

```bash
# Ping shows "via DERP" → relayed (slower), UDP blocked by a firewall
# Device disconnected after ~6 months → disable "Key expiry" in admin console
# Subnet not reachable → IP forwarding off, route not approved, or missing --accept-routes
# LXC "failed to create tun" → add the /dev/net/tun lines above
journalctl -u tailscaled -f  # Follow daemon logs
```

---

## Pitfalls

- Subnet routes and exit nodes must be approved in the admin console.
- A subnet router needs IP forwarding (`net.ipv4.ip_forward=1`).
- Linux clients need `--accept-routes` to use subnet routes.
- Node keys expire: disable key expiry for servers in the admin console.
- In an LXC container, `/dev/net/tun` must be passed through (or use userspace networking).
- Don't advertise a subnet that overlaps the local network of a client (e.g. 192.168.1.0/24 on both sides).

---

## References

- [Tailscale documentation](https://tailscale.com/kb)
- [CLI reference](https://tailscale.com/kb/1080/cli)
