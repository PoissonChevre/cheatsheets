# Proxmox — Cheat Sheet

Open-source virtualization platform for VMs and containers.

---

## VM Management

```bash
qm list  # List all VMs
qm create <vmid> --name <name> --memory 2048  # Create new VM
qm set <vmid> --cores 4 --sockets 1  # Configure CPU
qm set <vmid> --net0 virtio,bridge=vmbr0  # Add network interface
qm start <vmid>  # Start VM
qm stop <vmid>  # Stop VM gracefully
qm reset <vmid>  # Hard reset VM
qm reboot <vmid>  # Reboot VM
qm shutdown <vmid>  # Shutdown VM
qm delete <vmid>  # Delete VM
qm monitor <vmid>  # Open QEMU monitor
qm terminal <vmid>  # Open console
qm status <vmid>  # Show VM status
qm config <vmid>  # Show VM configuration
qm disk list <vmid>  # List VM disks
```

## LXC Containers

```bash
pct list  # List all containers
pct create <ctid> <image> --hostname <name>  # Create container
pct set <ctid> --cores 2 --memory 512  # Configure container resources
pct set <ctid> --net0 name=eth0,bridge=vmbr0,ip=dhcp  # Configure networking
pct start <ctid>  # Start container
pct stop <ctid>  # Stop container
pct reboot <ctid>  # Reboot container
pct enter <ctid>  # Enter container shell
pct delete <ctid>  # Delete container
pct config <ctid>  # Show container configuration
pct status <ctid>  # Show container status
pct clone <ctid> <newid> --hostname <name>  # Clone container
pct exec <ctid> -- command  # Execute command in container
```

## Storage

```bash
pvesm list  # List storage
pvesm status  # Show storage status
pvesm alloc <storage> <vmid> <name> <size>  # Allocate storage
pvesm content <storage>  # List storage content
pvesm enable <storage>  # Enable storage
pvesm disable <storage>  # Disable storage
pvesm add <type> <storage-id> --content <types>  # Add storage backend
qm importdisk <vmid> <source> <storage>  # Import disk image
qm move-disk <vmid> <source> --storage <storage>  # Move VM disk
qm rescan  # Rescan storage
```

## Networking

```bash
ip a  # Show network interfaces
cat /etc/network/interfaces  # Show network config
brctl show  # List network bridges
brctl addbr vmbr1  # Create new bridge
ifconfig vmbr0 up  # Bring interface up
pvesh create /nodes/<node>/network --type bridge --iface vmbr1  # Create bridge via API
```

## Backup & Restore

```bash
vzdump <vmid> --storage <storage>  # Backup VM
vzdump <ctid> --dumpdir /mnt/backup  # Backup container to directory
qmrestore <backup-file> <vmid>  # Restore VM from backup
pct restore <ctid> <backup-file>  # Restore container from backup
cat /etc/cron.d/vzdump  # Show backup schedule
# Schedule backup in /etc/cron.d/vzdump or web UI
```

## Cluster

```bash
pvecm status  # Show cluster status
pvecm nodes  # List cluster nodes
pvecm add <host>  # Add node to cluster
pvecm delete <node>  # Remove node from cluster
pvecm expected-nodes <count>  # Set expected node count (quorum)
ls /etc/pve  # Cluster config files (auto-synced)
corosync-cfgtool -s  # Show Corosync status
pvecm help  # Full cluster management help
```

## CLI Tools (pvesh, qm, pct)

```bash
pvesh get /nodes  # List all nodes via API
pvesh get /nodes/<node>/qemu  # List VMs on node
pvesh create /nodes/<node>/qemu --vmid 100 --name test  # Create via API
pvesh set /nodes/<node>/qemu/<vmid>/config --cores 4  # Update config
qm monitor <vmid> -- info vnc  # Get VNC connection info
qm vncproxy <vmid>  # Get VNC proxy details
pct config <ctid> | grep -i hostname  # Filter container config
pct resize <ctid> <disk> <size>  # Resize container disk
qm importcloudinit <vmid> <cloudinit-file> <storage>  # Add cloud-init
```

---

## Pitfalls

- `qm` manages VMs, `pct` manages LXC containers. IDs are unique in the whole cluster.
- A template can't be started: clone it (linked clone = fast but tied to the template, full clone = independent).
- A backup on the same storage as the VMs is not a backup: send vzdump to another machine (PBS, NAS).
- A 2-node cluster loses quorum when one node is down: add a QDevice.
- `/etc/pve` is the cluster filesystem: edit it with care, changes replicate to all nodes.
- Without a subscription, switch to the no-subscription repository or `apt update` fails.
- Unprivileged LXC (default) maps UIDs: bind mounts need matching permissions on the host.
