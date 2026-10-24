#!/usr/bin/env bash
# Clean a Debian/Ubuntu LXC container before converting it to a template.
# Run INSIDE the container, as root:  pct push <ctid> lxc-template-prep.sh /root/prep.sh && pct exec <ctid> -- bash /root/prep.sh
# Then on the host:                    pct shutdown <ctid> && pct template <ctid>
# On each new clone:                   pct exec <newid> -- bash -c 'ssh-keygen -A && systemctl restart ssh'

set -euo pipefail

echo "==> Updating packages"
apt-get update
apt-get -y full-upgrade
apt-get -y autoremove --purge
apt-get clean

echo "==> Removing machine identity"
rm -f /etc/ssh/ssh_host_*            # SSH host keys (regenerate on each clone)
truncate -s 0 /etc/machine-id        # New machine-id at next boot

echo "==> Cleaning logs and history"
find /var/log -type f -exec truncate -s 0 {} +
rm -f /root/.bash_history
rm -f /root/prep.sh

echo "Done. Now on the host: pct shutdown <ctid> && pct template <ctid>"
