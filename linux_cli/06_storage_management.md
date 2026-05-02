# LFCS — Storage Management (11%)

> Block devices, partitioning, filesystems, mounts, LVM, RAID, swap, quotas, encryption (LUKS).

---

## Inspecting Block Devices

```bash
lsblk                                # Tree view of block devices
lsblk -f                             # + filesystem type, UUID, mountpoint
lsblk -e7                            # Exclude loop devices
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,UUID

blkid                                # UUIDs, types, labels of all devices
blkid /dev/sda1                      # One device
findmnt                              # Hierarchical view of mounts
findmnt /dev/sda1                    # Show mount options for device
findmnt -t ext4                      # Filter by FS type

fdisk -l                             # All disks (MBR-friendly)
fdisk -l /dev/sda                    # One disk
parted -l                            # All disks (GPT-aware)

df -h                                # Mounted filesystems usage
df -hT                               # + filesystem types
df -i                                # Inode usage (often forgotten!)

du -sh /var/                         # Total directory size
du -h --max-depth=1 /var             # Top-level breakdown
du -sh * | sort -h                   # Sort by size
```

---

## Partitioning

### Pre-flight

```bash
wipefs -a /dev/sdb                   # Erase all signatures (DANGEROUS — clears partition table)
wipefs -a /dev/sdb1                  # Erase signatures on partition only
```

### fdisk (interactive, MBR/GPT)

```bash
fdisk /dev/sdb

# Inside fdisk:
# g       create new GPT partition table
# o       create new MBR partition table
# n       new partition (defaults often fine: number, first sector, last sector)
# d       delete partition
# t       change partition type (1=Linux, 19=swap, 30=Linux LVM)
# p       print partition table
# w       write changes and quit
# q       quit without writing
```

### Other partition tools

```bash
cfdisk /dev/sdb                      # Interactive TUI (easier)
gdisk /dev/sdb                       # GPT-only (>2TB recommended)
parted /dev/sdb                      # Scriptable

# Parted scripted (non-interactive)
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary ext4 1MiB 100%
```

### Reload partition table without reboot

```bash
partprobe /dev/sdb                   # Tell kernel to re-read
partx -u /dev/sdb                    # Alternative
```

**Pitfall:** After `fdisk`/`cfdisk`, run `partprobe` or `partx -u` for the kernel to see new partitions immediately.

---

## Filesystem Creation

```bash
# ext4 — standard Linux FS
mkfs.ext4 /dev/sdb1
mkfs.ext4 -L "DATA" /dev/sdb1        # With label
mkfs.ext4 -N 2048 /dev/sdb1          # Specific number of inodes

# Equivalent generic syntax (calls mkfs.ext4 internally):
mkfs -t ext4 /dev/sdb1

# xfs — high performance, large files, NO shrink
mkfs.xfs /dev/sdb1
mkfs.xfs -L "DATA" /dev/sdb1
mkfs.xfs -f /dev/sdb1                # Force overwrite

# vfat — EFI partition or USB
mkfs.vfat -F32 /dev/sdb1
mkfs.vfat -F32 -n "EFI" /dev/sdb1

# exFAT — cross-platform USB
sudo apt install exfatprogs
mkfs.exfat -L "MYUSB" /dev/sdb1

# btrfs
mkfs.btrfs /dev/sdb1

# Swap
mkswap /dev/sdb2
mkswap -L "SWAP" /dev/sdb2
```

### Filesystem comparison

| FS | Max file | Use case | Notes |
|---|---|---|---|
| FAT32 | 4 GiB | EFI only | Universal but limited |
| exFAT | 16 EiB | USB cross-platform | Modern FAT replacement |
| ext4 | 16 TiB | / and /home | Standard Linux, can shrink |
| xfs | 8 EiB | VMs, large files | Online grow ONLY (no shrink) |
| btrfs | 16 EiB | Snapshots | Copy-on-write |

**Critical pitfall:** `mkfs.*` ERASES the partition. Always verify with `lsblk` and `blkid` before formatting.

---

## Filesystem Labels

```bash
e2label /dev/sda1 DATA               # Set ext label
tune2fs -L DATA /dev/sda1            # Same (alternative)
xfs_admin -L DATA /dev/sdb1          # Set XFS label

blkid /dev/sda1                      # Verify label and UUID
```

---

## Mounting

```bash
mount                                # Show all mounted filesystems
mount /dev/sdb1 /mnt/data            # Mount
mount -t ext4 /dev/sdb1 /mnt/data    # Specify type
mount -o ro,noexec /dev/sdb1 /mnt    # With options
mount -t nfs server:/share /mnt      # NFS
mount -a                             # Mount everything in /etc/fstab

umount /mnt/data                     # Unmount by mountpoint
umount /dev/sdb1                     # Unmount by device
umount -l /mnt/data                  # Lazy unmount (when busy)
```

### Common mount options

| Option | Meaning |
|---|---|
| ro / rw | Read-only / read-write |
| noexec | No executables |
| nosuid | Ignore SUID bits |
| nodev | No device files |
| noatime | Don't update access times (perf boost) |
| user | Allow non-root users to mount |
| defaults | rw,suid,dev,exec,auto,nouser,async |
| _netdev | Wait for network (NFS, iSCSI) |
| nofail | Don't fail boot if absent |

### Persistent mounts — `/etc/fstab`

```
# Format:
# <device>          <mountpoint>  <type>  <options>           <dump>  <pass>

UUID=abc-123        /data         ext4    defaults             0       2
LABEL=BACKUP        /backup       xfs     defaults,noatime     0       2
/dev/vg1/lv_data    /var/data     xfs     defaults             0       2
server:/srv/share   /mnt/nfs      nfs     defaults,_netdev     0       0
/swapfile           none          swap    sw                   0       0
```

### Fields explained

| Field | Meaning |
|---|---|
| dump | 0 (don't backup with dump) or 1 |
| pass | 0 (no fsck), 1 (root, first), 2 (other) |

### Test fstab safely

```bash
mount -a                             # Test before reboot — fails loud if typo
findmnt --verify --verbose           # Validate fstab syntax
```

**Critical pitfall:** A typo in `/etc/fstab` + reboot = unbootable system. Always test with `mount -a` first. Use `nofail` for non-critical mounts.

---

## Filesystem Check & Repair

```bash
# ext4
fsck /dev/sdb1                       # Auto-detect type
fsck -y /dev/sdb1                    # Auto-yes
e2fsck -f /dev/sdb1                  # Force check (must be unmounted!)

# xfs (different command!)
xfs_repair /dev/sdb1                 # Must be unmounted
xfs_repair -n /dev/sdb1              # Dry-run

# Generic
fsck.ext4 /dev/sdb1
fsck.xfs /dev/sdb1                   # ⚠ EXISTS BUT DOES NOTHING — use xfs_repair!
```

**Critical pitfalls:**
- Filesystem MUST be unmounted before fsck (or you risk corruption)
- `fsck.xfs` is a placeholder, NOT a real check tool. Use `xfs_repair` for XFS.
- For root filesystem: `touch /forcefsck` then reboot

### When unmount refuses

```bash
lsof /mnt/data                       # Who is using the mount?
fuser -vm /mnt/data                  # Same, different format
fuser -km /mnt/data                  # Kill processes using the mount
# Or kill the PIDs manually then:
umount /mnt/data
```

---

## Filesystem Resize

### ext4 — can grow AND shrink

```bash
# Grow (works mounted)
resize2fs /dev/vg1/lv_data           # Grow to fill device

# Shrink (must be unmounted!)
umount /mnt/data
e2fsck -f /dev/vg1/lv_data           # Check first!
resize2fs /dev/vg1/lv_data 5G        # Shrink to 5G
mount /dev/vg1/lv_data /mnt/data
```

### xfs — can ONLY grow

```bash
# Grow (must be MOUNTED, takes mountpoint!)
xfs_growfs /mountpoint
xfs_growfs /                         # Common case

# Shrink: NOT POSSIBLE with XFS
# Workaround: backup → recreate smaller → restore
```

**Critical pitfalls:**
- `resize2fs` takes the **device** (`/dev/vg/lv`)
- `xfs_growfs` takes the **mountpoint** (`/mnt/data`) — NOT the device!
- XFS CANNOT shrink. Period.

### Defragmentation

```bash
e4defrag /mountpoint                 # ext4
xfs_fsr                              # XFS reorganizer
```

---

## Swap

```bash
# Create swap on partition
mkswap /dev/sdb2
swapon /dev/sdb2                     # Activate
swapon --show                        # List active swap
swapoff /dev/sdb2                    # Deactivate

# Create swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Persistent (in /etc/fstab):
# /swapfile   none   swap   sw   0   0

# Verify
free -h
cat /proc/swaps

# Adjust swappiness (0-100, lower = use swap less)
sysctl -w vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf
```

---

## LVM (Logical Volume Manager)

### Concept

```
Physical Volumes (PV)  =  disk or partition declared to LVM
        │
        ▼
Volume Group (VG)      =  pool of PVs
        │
        ▼
Logical Volumes (LV)   =  carved from VG, used as block devices
```

### Physical Volumes (PV)

```bash
pvcreate /dev/sdb                    # Initialize as PV
pvcreate /dev/sdb /dev/sdc           # Multiple at once
pvs                                  # Short summary
pvdisplay                            # Detailed
pvdisplay /dev/sdb                   # One PV
pvremove /dev/sdb                    # Remove PV
pvscan                               # Scan all PVs
pvmove /dev/sdb /dev/sdc             # Move data PV → PV (before pvremove)
```

### Volume Groups (VG)

```bash
vgcreate vg_data /dev/sdb            # Create VG
vgcreate vg_data /dev/sdb /dev/sdc   # Multiple PVs

vgextend vg_data /dev/sdc            # Add PV to existing VG
vgreduce vg_data /dev/sdc            # Remove PV from VG (must be empty)

vgs                                  # Short list
vgdisplay                            # Detailed
vgrename vg_old vg_new
vgchange -an vg_data                 # Deactivate
vgchange -ay vg_data                 # Activate
vgremove vg_data                     # Remove VG (must be empty)
vgscan                               # Discover VGs
```

### Logical Volumes (LV)

```bash
# Create
lvcreate -L 10G -n lv_data vg_data           # Fixed size
lvcreate -l 100%FREE -n lv_data vg_data      # All free space
lvcreate -l 50%VG -n lv_data vg_data         # 50% of VG

# Extend
lvextend -L +5G /dev/vg_data/lv_data         # Add 5G to LV (FS NOT resized!)
lvextend -L 20G /dev/vg_data/lv_data         # Set total to 20G
lvextend -l +100%FREE /dev/vg_data/lv_data   # Use all free space
lvextend -L +5G -r /dev/vg_data/lv_data      # ✅ EXTEND LV + RESIZE FS in one shot!

# Resize FS after lvextend (without -r)
xfs_growfs /mnt/data                          # XFS — takes mountpoint
resize2fs /dev/vg_data/lv_data                # ext4 — takes device

# Shrink (ext4 only — XFS can't!)
umount /mnt/data
e2fsck -f /dev/vg_data/lv_data
resize2fs /dev/vg_data/lv_data 8G
lvreduce -L 8G /dev/vg_data/lv_data           # Match the FS size
mount /dev/vg_data/lv_data /mnt/data

# List
lvs                                  # Summary
lvdisplay

# Remove
lvremove /dev/vg_data/lv_data
```

### Complete LVM Workflow

```bash
# 1. Partition (type Linux LVM = code 30 in fdisk)
fdisk /dev/sdb       # n → t → 30 → w
partprobe /dev/sdb

# 2. PV
pvcreate /dev/sdb1

# 3. VG
vgcreate vg_data /dev/sdb1

# 4. LV
lvcreate -L 10G -n lv_data vg_data

# 5. Filesystem
mkfs.ext4 /dev/vg_data/lv_data

# 6. Mount
mkdir /mnt/data
mount /dev/vg_data/lv_data /mnt/data

# 7. Persist
blkid /dev/vg_data/lv_data           # Get UUID
echo "UUID=xxx /mnt/data ext4 defaults 0 2" >> /etc/fstab
mount -a                             # Verify before reboot
```

### LV path conventions

```
/dev/vg_data/lv_data                 # Standard form
/dev/mapper/vg_data-lv_data          # Same, dash-separated (alternative)
```

**Critical pitfalls:**
- `lvextend -L +5G` only grows the LV, NOT the filesystem. Use `-r` to do both.
- `lvextend` and `lvreduce` don't auto-resize FS without `-r`.
- For XFS: `xfs_growfs MOUNTPOINT` (not device path)
- For ext4: `resize2fs DEVICE` (not mountpoint)
- Don't confuse `vgextend` (add PV to VG) with `lvextend` (grow an LV).

---

## RAID (mdadm — Software RAID)

```bash
# Create RAID 1 (mirror)
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc

# Create RAID 5
mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# Inspect
mdadm --detail /dev/md0              # Status
cat /proc/mdstat                     # Summary all arrays

# Manage
mdadm --stop /dev/md0
mdadm --assemble /dev/md0 /dev/sdb /dev/sdc
mdadm --add /dev/md0 /dev/sde        # Add device (e.g. spare)
mdadm --fail /dev/md0 /dev/sdb       # Mark as failed
mdadm --remove /dev/md0 /dev/sdb     # Remove failed device

# Persist config
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u                  # Debian/Ubuntu
dracut -f                            # RHEL
```

**Pitfall:** Without persisting in `/etc/mdadm/mdadm.conf`, kernel may renumber arrays at boot (`md0` → `md127`).

### RAID levels

| Level | Description |
|---|---|
| 0 | Stripe (no redundancy, performance) |
| 1 | Mirror (redundancy, halves capacity) |
| 5 | Stripe + parity (1 disk redundancy, ≥3 disks) |
| 6 | Stripe + double parity (2 disk redundancy, ≥4 disks) |
| 10 | Mirror + stripe (best perf + redundancy, ≥4 disks) |

---

## Disk Quotas — XFS

```bash
# Mount with quota support — add to fstab options:
# uquota,gquota
mount -o remount,uquota /home

# Set quota
xfs_quota -x -c 'limit bsoft=100m bhard=500m john' /home

# Report
xfs_quota -x -c 'report -h' /home
```

## Disk Quotas — ext4

```bash
sudo apt install quota

# Mount options in fstab: usrquota,grpquota
# Then:
quotacheck -cum /home                # Build quota database
quotaon /home                        # Activate
edquota -u john                      # Edit user quota
quota -u john                        # Show user usage
repquota -a                          # All quotas
```

---

## NFS — Storage Perspective

See `05_service_configuration.md` for full NFS reference.

```bash
# Server export
echo "/srv/share 192.168.1.0/24(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -ra
showmount -e localhost

# Client mount
mount -t nfs server:/srv/share /mnt/share
# Persistent: server:/srv/share /mnt/share nfs defaults,_netdev 0 0
```

---

## Encrypted Storage — LUKS

```bash
sudo apt install cryptsetup

# Initialize (LUKS2)
cryptsetup luksFormat /dev/sdb1
# Type YES (uppercase) → enter passphrase → confirm

# Open (decrypt)
cryptsetup open /dev/sdb1 mycrypt    # → /dev/mapper/mycrypt
cryptsetup luksOpen /dev/sdb1 mycrypt # Same syntax (older)

# Format the unlocked device
mkfs.ext4 /dev/mapper/mycrypt
# or any other FS

# Mount
mkdir /mnt/secure
mount /dev/mapper/mycrypt /mnt/secure

# Daily use — close (re-encrypts)
umount /mnt/secure
cryptsetup close mycrypt

# Inspection
cryptsetup isLuks /dev/sdb1 && echo YES || echo NO
cryptsetup luksDump /dev/sdb1        # Header info
cryptsetup status mycrypt            # Status of open container

# Key management (up to 8 key slots)
cryptsetup luksAddKey /dev/sdb1
cryptsetup luksChangeKey /dev/sdb1
cryptsetup luksRemoveKey /dev/sdb1
```

### `/etc/crypttab` — auto-open at boot

```
# Format:
# <name>  <device/UUID>  <keyfile>  <options>

mycrypt   UUID=abc123    none       luks
# none = prompt for passphrase at boot
# /path/to/keyfile = silent unlock (chmod 600!)
```

---

## Device Mapper (low-level)

```bash
dmsetup ls                           # List active dm devices
dmsetup info vg_data-lv_data         # Info about device
dmsetup deps vg_data-lv_data         # Underlying physical devices
dmsetup table vg_data-lv_data        # Mapping table
dmsetup remove vg_old-lv_old         # Remove orphan dm device
dmsetup remove_all                   # Remove all inactive dm
```

---

## Quick Reference Card

```bash
# Full overview
lsblk -e7 -f

# LVM at a glance
pvs && vgs && lvs

# Mounted FS usage (incl. inodes)
df -hT
df -i

# Find UUID
blkid /dev/sdb1

# Scan after hotplug
pvscan ; vgscan ; vgchange -ay

# Full LVM workflow:
pvcreate → vgcreate → lvcreate → mkfs → mount → fstab

# Resize:
lvextend -L +5G -r /dev/vg/lv        # Grow LV + FS
xfs_growfs /mountpoint                # XFS only (mounted)
resize2fs /dev/vg/lv                  # ext4 only (device)

# Reload partition table
partprobe /dev/sdb
```

---

## Pitfalls Summary

```bash
# 1. XFS CANNOT shrink. Only grows.
#    To "shrink": backup → mkfs smaller → restore.

# 2. xfs_growfs takes MOUNTPOINT, not device.
#    xfs_growfs /mnt    ✅       xfs_growfs /dev/vg/lv  ❌

# 3. resize2fs takes DEVICE, not mountpoint.
#    resize2fs /dev/vg/lv  ✅    resize2fs /mnt  ❌

# 4. lvextend -L +5G only grows the LV, NOT the FS.
#    Use lvextend -L +5G -r to grow both in one command.

# 5. /etc/fstab typo + reboot = unbootable system.
#    ALWAYS test with mount -a BEFORE rebooting.
#    Use `nofail` option for non-critical mounts.

# 6. fdisk doesn't reload partition table on busy disks.
#    After fdisk → run partprobe or partx -u.

# 7. mkfs.* ERASES data. Verify with lsblk + blkid before formatting.

# 8. XFS uses xfs_repair (not fsck.xfs!).
#    fsck.xfs exists but does NOTHING.
#    Filesystem MUST be unmounted.

# 9. mdadm arrays without /etc/mdadm/mdadm.conf entry can be
#    renumbered at boot (md0 → md127).

# 10. ALWAYS verify with lsblk + blkid + findmnt + pvs/vgs/lvs
#     BEFORE any destructive command.

# 11. ext4 shrink: e2fsck -f FIRST (mandatory), then resize2fs, then lvreduce.

# 12. LUKS: passphrase confirmation requires UPPERCASE "YES".

# 13. Don't confuse:
#     - vgextend (add PV to VG)
#     - lvextend (grow an LV)
#     - xfs_growfs (grow FS — XFS)
#     - resize2fs (grow/shrink FS — ext4)
```
