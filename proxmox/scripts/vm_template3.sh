# Perfect Proxmox Template with Cloud Image and Cloud Init
# https://technotim.live/posts/cloud-init-cloud-image/

# Download Ubuntu (replace with the url of the one you chose from above)
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

# Create a new virtual machine
qm create 8000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0

# Import the downloaded Ubuntu disk to local storage (Change local to the storage of your choice)
qm disk import 8000 noble-server-cloudimg-amd64.img local

# Attach the new disk to the vm as a scsi drive on the scsi controller (Change local to the storage of your choice)
qm set 8000 --scsihw virtio-scsi-pci --scsi0 local:vm-8000-disk-0

# Add cloud init drive ((Change local to the storage of your choice)
qm set 8000 --ide2 local:cloudinit

# Make the cloud init drive bootable and restrict BIOS to boot from disk only
qm set 8000 --boot c --bootdisk scsi0

# Add serial console
qm set 8000 --serial0 socket --vga serial0

# DO NOT START YOUR VM !!!
# Now, configure hardware and cloud init, then create a template and clone.
# If you want to expand your hard drive you can on this base image before creating a template 
# or after you clone a new machine.I prefer to expand the hard drive after I clone a new machine based on need.

# Create template.
qm template 8000

# Clone template.
qm clone 8000 135 --name yoshi --full
