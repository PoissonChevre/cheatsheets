# Proxmox VE — Cheat Sheet

Virtualization platform: KVM virtual machines (`qm`) and LXC containers (`pct`), managed from the web UI (port 8006) or the shell of the host.

---

## Basics

| What | Where |
|---|---|
| Web UI | `https://HOST_IP:8006` (user `root`, realm `Linux PAM`) |
| VM config | `/etc/pve/qemu-server/<vmid>.conf` |
| Container config | `/etc/pve/lxc/<ctid>.conf` |
| Storage config | `/etc/pve/storage.cfg` |
| Network config | `/etc/network/interfaces` |
| ISO and container templates | `/var/lib/vz/template/iso/`, `/var/lib/vz/template/cache/` |

```bash
pveversion -v                 # Versions of all Proxmox packages
apt update && apt full-upgrade   # Update (never plain "apt upgrade" on Proxmox)
```

- VM and container IDs share the same numbers (100, 101...) and must be unique.
- No subscription? **Node → Updates → Repositories**: disable the *enterprise* repositories, add *No-Subscription*.

---

## Virtual machines (qm)

```bash
qm list
qm config 100                 # Current configuration
qm start 100 ; qm shutdown 100 ; qm reboot 100
qm stop 100                   # Hard stop (like pulling the power)
qm terminal 100               # Serial console (needs --serial0 socket)

qm create 100 --name web --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm set 100 --memory 4096 --cores 4
qm set 100 --net0 virtio,bridge=vmbr0,tag=50     # NIC in VLAN 50
qm set 100 --agent enabled=1                      # QEMU guest agent (install it in the VM too)
qm set 100 --onboot 1                             # Start at host boot

qm disk resize 100 scsi0 +10G                     # Grow a disk (then grow the filesystem inside)
qm disk move 100 scsi0 other-storage              # Move a disk to another storage
qm disk import 100 image.qcow2 local-zfs          # Import a disk image (appears as "unused")

qm clone 9000 120 --name web1 --full              # Full clone of a template
qm template 9000                                  # Turn a VM into a template (no way back)
qm destroy 100 --purge                            # Delete VM, disks and references

qm snapshot 100 before-upgrade
qm listsnapshot 100
qm rollback 100 before-upgrade
qm delsnapshot 100 before-upgrade
```

---

## Cloud-init templates

Build a template once from a cloud image, then clone it for each new VM. Ready-made script: [templates/vm-cloud-init-template.sh](./templates/vm-cloud-init-template.sh).

```bash
# Customize a clone before its first boot
qm clone 9000 120 --name web1 --full
qm set 120 --ciuser admin --sshkeys ~/.ssh/authorized_keys
qm set 120 --ipconfig0 ip=192.168.1.120/24,gw=192.168.1.1   # Or: ip=dhcp
qm set 120 --nameserver 192.168.1.1
qm disk resize 120 scsi0 20G
qm start 120

qm cloudinit dump 120 user                        # Generated cloud-init config
qm cloudinit update 120                           # Regenerate after a change
```

- Cloud images don't include `qemu-guest-agent`: install it in the template (the script can do it) or with cloud-init.
- Talos Linux: use the *nocloud* image from the Image Factory, not a generic cloud image.

---

## Containers (pct)

```bash
pveam update                                      # Refresh the template list
pveam available --section system                  # Templates you can download
pveam download local debian-13-standard_<version>_amd64.tar.zst
pveam list local

pct create 200 local:vztmpl/debian-13-standard_<version>_amd64.tar.zst \
  --hostname ct1 --cores 1 --memory 512 --swap 512 \
  --rootfs local-zfs:8 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --unprivileged 1 --features nesting=1 \
  --ssh-public-keys ~/.ssh/authorized_keys --start 1

pct list
pct enter 200                                     # Shell inside the container
pct exec 200 -- apt update                        # One command
pct start 200 ; pct shutdown 200 ; pct stop 200
pct set 200 --memory 1024 --cores 2
pct set 200 --mp0 /tank/data,mp=/data             # Bind mount a host folder
pct resize 200 rootfs +4G
pct push 200 local.conf /etc/app.conf ; pct pull 200 /var/log/app.log ./app.log
pct template 200                                  # Turn into a template
pct destroy 200 --purge
```

Prepare a container before making it a template: [templates/lxc-template-prep.sh](./templates/lxc-template-prep.sh).

---

## Storage

```bash
pvesm status                                      # All storages, usage
pvesm list local-zfs                              # Content of one storage
cat /etc/pve/storage.cfg

# ZFS (default with a ZFS install: pool "rpool", storage "local-zfs")
zpool status                                      # Health of the disks
zpool list ; zfs list
zpool scrub rpool                                 # Check data (monthly scrub is scheduled by default)
zfs list -t snapshot
arc_summary | head -40                            # ZFS cache (ARC) RAM usage
```

| Content type | Use |
|---|---|
| `images` | VM disks |
| `rootdir` | Container disks |
| `iso` / `vztmpl` | ISO files / container templates |
| `backup` | vzdump backups |
| `snippets` | Cloud-init custom files, hook scripts |

Add an NFS share from the NAS for backups and ISOs: **Datacenter → Storage → Add → NFS**.

---

## Network

```bash
cat /etc/network/interfaces
ifreload -a                                       # Apply changes (ifupdown2)
ip -br a ; ip -br link
bridge vlan show                                  # VLANs on bridge ports
```

VLAN-aware bridge: one bridge, the VLAN is set on each VM NIC (`tag=50`).

```
# /etc/network/interfaces
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet manual
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094

# Host management IP in VLAN 20
auto vmbr0.20
iface vmbr0.20 inet static
    address 192.168.20.10/24
    gateway 192.168.20.1
```

Keep a console (or IPMI/physical access) when you change the host network: a mistake cuts the web UI.

---

## Backup and restore

```bash
vzdump 100 --storage nas-backup --mode snapshot --compress zstd
vzdump --all --storage nas-backup --mode snapshot --compress zstd --prune-backups keep-daily=7,keep-weekly=4

qmrestore /mnt/pve/nas-backup/dump/vzdump-qemu-100-<date>.vma.zst 100 --storage local-zfs
pct restore 200 /mnt/pve/nas-backup/dump/vzdump-lxc-200-<date>.tar.zst --storage local-zfs
```

| Mode | Downtime | Note |
|---|---|---|
| `snapshot` | None | Best with the guest agent (consistent filesystem) |
| `suspend` | Short | |
| `stop` | Full | Most consistent |

Scheduled jobs: **Datacenter → Backup** (saved in `/etc/pve/jobs.cfg`). For deduplicated, incremental backups: Proxmox Backup Server (PBS).

---

## Users, API and Terraform

```bash
pveum user list
pveum user add terraform@pve
pveum role add TerraformProv -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Audit VM.PowerMgmt VM.GuestAgent.Audit Datastore.AllocateSpace Datastore.Audit SDN.Use Sys.Audit"
pveum aclmod / -user terraform@pve -role TerraformProv
pveum user token add terraform@pve tf --privsep 0   # Shows the secret ONCE: save it

pvesh get /nodes                                  # API from the shell
pvesh get /nodes/$(hostname)/qemu --output-format json-pretty
pvesh get /cluster/resources --type vm
```

---

## Cluster

```bash
pvecm create homelab                              # On the first node
pvecm add 192.168.20.10                           # On a new node: IP of an existing member
pvecm status                                      # Quorum, members
pvecm nodes
pvecm expected 1                                  # Emergency: regain quorum when other nodes are down
pvecm qdevice setup 192.168.20.5                  # Third vote for a 2-node cluster (corosync-qnetd on another machine)
```

---

## Troubleshooting

| Problem | Check / fix |
|---|---|
| "VM is locked (backup/snapshot)" | `qm unlock 100` (make sure no job is still running) |
| VM won't stop | `qm stop 100 --skiplock`, then look at `ps aux \| grep "kvm -id 100"` |
| Web UI down or certificate error | `systemctl restart pveproxy`, `pvecm updatecerts --force` |
| Storage full | `pvesm status`, `zfs list -o space`, old snapshots and backups |
| VM has no network | Bridge name, VLAN `tag`, `bridge-vlan-aware yes`, firewall checkbox on the NIC |
| Clone gets the same IP/hostname | Cloud-init not used, or the template was started before conversion |

```bash
journalctl -u pveproxy -u pvedaemon -e
systemctl status pve-cluster pvedaemon pveproxy pvestatd
tail -f /var/log/pve/tasks/active
```

---

## Pitfalls

- `qm` = VMs, `pct` = containers. IDs are unique across both.
- `qm template` can't be undone, and a template can't be started: clone it.
- Linked clones are fast but depend on the template; full clones are independent.
- Don't start the base VM before turning it into a template: cloud-init runs once and leaves machine IDs and SSH keys behind.
- `--cpu host` gives the best performance but blocks live migration to a different CPU.
- `tag=` on a VM NIC only works on a VLAN-aware bridge.
- A backup on the same disks as the VMs is not a backup: send it to the NAS or PBS.
- A 2-node cluster loses quorum when one node is down: add a QDevice.
- `/etc/pve` is a cluster filesystem: changes replicate to all nodes immediately.
- Unprivileged containers map UIDs: bind mounts need matching permissions on the host.
- Use `apt full-upgrade`, not `apt upgrade`, and never remove the `proxmox-ve` package.

---

## Links

- [Proxmox VE documentation](https://pve.proxmox.com/pve-docs/) · [qm](https://pve.proxmox.com/pve-docs/qm.1.html) · [pct](https://pve.proxmox.com/pve-docs/pct.1.html) · [Cloud-init support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
