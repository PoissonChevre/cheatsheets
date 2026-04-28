# Proxmox Container Template
# https://www.youtube.com/watch?v=J29onrRqE_I&t=206s
# https://pve.proxmox.com/wiki/Linux_Container

# update container
sudo apt update && sudo apt dist-upgrade

# clean apt
sudo apt clean
sudo apt autoremove

# erase ssh hosts id
sudo rm ssh_host_*

# erase machine-id
cat /etc/machine-id
sudo truncate -s 0 /etc/machine-id

# poweroff
sudo poweroff

# convert to TEMPLATE PROXMOX GUI

# when first starting the clone ct , reconfigure ssh host key in console proxmox GUI
sudo dpkg-reconfigure openssh-server