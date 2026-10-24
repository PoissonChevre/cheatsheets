#!/usr/bin/env bash
# Create a Proxmox VM template from a cloud image (cloud-init).
# Run on the Proxmox host as root.
#
# Usage:   ./vm-cloud-init-template.sh <vmid> <name> <image-url>
# Example: ./vm-cloud-init-template.sh 9000 debian-13 \
#            https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
#
# Options (environment variables):
#   STORAGE=local-zfs  BRIDGE=vmbr0  VLAN=50  CI_USER=admin  SSH_KEYS=/root/.ssh/authorized_keys
#   MEMORY=2048  CORES=2  DISK_SIZE=10G
#
# Cloud images:
#   Debian 13    https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
#   Debian 12    https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
#   Ubuntu 24.04 https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
#   Rocky 9      https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2
#
# Based on: apalrd.net/posts/2023/pve_cloud, technotim.live/posts/cloud-init-cloud-image

set -euo pipefail

VMID=${1:?Usage: $0 <vmid> <name> <image-url>}
NAME=${2:?Usage: $0 <vmid> <name> <image-url>}
URL=${3:?Usage: $0 <vmid> <name> <image-url>}

STORAGE=${STORAGE:-local-zfs}
BRIDGE=${BRIDGE:-vmbr0}
VLAN=${VLAN:-}
CI_USER=${CI_USER:-admin}
SSH_KEYS=${SSH_KEYS:-/root/.ssh/authorized_keys}
MEMORY=${MEMORY:-2048}
CORES=${CORES:-2}
DISK_SIZE=${DISK_SIZE:-10G}

if qm status "$VMID" &>/dev/null; then
  echo "VM $VMID already exists" >&2
  exit 1
fi
[[ -f "$SSH_KEYS" ]] || { echo "SSH key file not found: $SSH_KEYS" >&2; exit 1; }

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT
IMG="$WORKDIR/$(basename "$URL")"

echo "==> Downloading $URL"
wget -q --show-progress -O "$IMG" "$URL"

# Optional: add the QEMU guest agent to the image (apt install libguestfs-tools)
if command -v virt-customize &>/dev/null; then
  echo "==> Installing qemu-guest-agent in the image"
  virt-customize -a "$IMG" --install qemu-guest-agent --truncate /etc/machine-id
fi

NET="virtio,bridge=$BRIDGE${VLAN:+,tag=$VLAN}"

echo "==> Creating VM $VMID ($NAME)"
qm create "$VMID" \
  --name "$NAME" \
  --ostype l26 \
  --memory "$MEMORY" --cores "$CORES" --cpu host \
  --net0 "$NET" \
  --scsihw virtio-scsi-single \
  --scsi0 "$STORAGE:0,import-from=$IMG,discard=on,ssd=1" \
  --boot order=scsi0 \
  --ide2 "$STORAGE:cloudinit" \
  --serial0 socket --vga serial0 \
  --agent enabled=1,fstrim_cloned_disks=1 \
  --ciuser "$CI_USER" \
  --sshkeys "$SSH_KEYS" \
  --ipconfig0 "ip=dhcp"

qm disk resize "$VMID" scsi0 "$DISK_SIZE"

echo "==> Converting $VMID to a template"
qm template "$VMID"

echo "Done. Clone it with: qm clone $VMID <newid> --name <name> --full"
