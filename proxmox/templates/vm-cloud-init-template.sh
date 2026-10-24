#!/bin/bash
# Proxmox: create a VM template from a cloud image (cloud-init)
# Run on the Proxmox host as root. Change the variables, then run.
# Source: https://technotim.live/posts/cloud-init-cloud-image/

VMID=9000
NAME=debian-13
IMAGE_URL=https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
STORAGE=local-zfs
BRIDGE=vmbr0

# 1. Download the cloud image
wget -O /tmp/cloud.img "$IMAGE_URL"

# 2. Create the VM
qm create $VMID --name $NAME --memory 2048 --cores 2 --net0 virtio,bridge=$BRIDGE

# 3. Import the image as the VM disk
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $STORAGE:0,import-from=/tmp/cloud.img

# 4. Add the cloud-init drive
qm set $VMID --ide2 $STORAGE:cloudinit

# 5. Boot from the disk, serial console, guest agent
qm set $VMID --boot order=scsi0 --serial0 socket --vga serial0 --agent enabled=1

# 6. Cloud-init defaults: user, SSH key, DHCP
qm set $VMID --ciuser admin --sshkeys ~/.ssh/authorized_keys --ipconfig0 ip=dhcp

# 7. Turn it into a template (never start the VM before this step)
qm template $VMID

# 8. Clean up
rm /tmp/cloud.img

# Create a VM from the template:
#   qm clone 9000 120 --name web1 --full
#   qm disk resize 120 scsi0 20G
#   qm start 120
