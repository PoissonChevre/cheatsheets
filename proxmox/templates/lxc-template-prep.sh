#!/bin/bash
# Proxmox: clean an LXC container before turning it into a template
# Run INSIDE the container (pct enter <ctid>).
# Then on the host: pct template <ctid>

apt update && apt -y full-upgrade
apt -y autoremove && apt clean

rm -f /etc/ssh/ssh_host_*          # SSH keys: recreated on each clone
truncate -s 0 /etc/machine-id      # New machine ID on each clone

poweroff

# On each new clone, first start:
#   ssh-keygen -A && systemctl restart ssh
