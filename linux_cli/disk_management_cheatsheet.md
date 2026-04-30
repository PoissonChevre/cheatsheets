# Disk Management Cheatsheet — Linux
> Partitioning · LVM · Filesystem · Encryption (LUKS)

---

## 1. Inspection Commands

```bash
# List block devices (excluding loop devices)
lsblk -e7

# List with filesystem info (UUID, FSTYPE, label, usage)
lsblk -f
lsblk -e7 -f

# Show all block devices with UUIDs
blkid

# Show partition table
sudo fdisk -l /dev/sda

# Show disk usage
df -h
```

---

## 2. Partitioning

### wipefs — erase all signatures before repartitioning
```bash
sudo wipefs -a /dev/sda        # erase partition table + filesystem signatures
sudo wipefs -a /dev/sda1       # erase signatures on a specific partition
```

### fdisk — partition a disk (CLI)
```bash
sudo fdisk /dev/sda

# Inside fdisk:
g        # create new GPT partition table
n        # new partition
<Enter>  # partition number (default = 1)
<Enter>  # first sector (default)
<Enter>  # last sector (default = entire disk)
t        # change partition type
30       # Linux LVM  (use 1 for Linux filesystem, 19 for swap)
p        # print partition table — verify before writing
w        # write to disk and quit
```

### cfdisk — partition a disk (TUI, more user-friendly)
```bash
sudo cfdisk /dev/sda
# → New → Enter (max size) → Type → Write → yes → Quit
```

### partprobe — reload partition table without reboot
```bash
sudo partprobe /dev/sda        # kernel re-reads partition table
# required after fdisk/cfdisk so sda1 becomes visible immediately
```

---

## 3. Filesystem — mkfs

```bash
# EFI partition (always FAT32)
sudo mkfs.vfat -F32 /dev/sda1
sudo mkfs.vfat -F32 -n "EFI" /dev/sda1      # with label

# ext4 — standard Linux filesystem (/, /home)
sudo mkfs.ext4 /dev/sda1
sudo mkfs.ext4 -L "mydata" /dev/sda1         # with label

# xfs — high performance, large files (VMs, videos)
sudo mkfs.xfs /dev/sda1
sudo mkfs.xfs -L "myvms" /dev/sda1           # with label

# exFAT — cross-platform (Linux + Windows + macOS)
sudo apt install exfatprogs
sudo mkfs.exfat -L "MYUSB" /dev/sda1

# swap
sudo mkswap /dev/sda2
sudo swapon /dev/sda2                         # activate swap
```

### Filesystem comparison

| Filesystem | Max file | Best for | Notes |
|------------|----------|----------|-------|
| FAT32 | 4 GiB | EFI only | Universal but limited |
| exFAT | 16 EiB | USB drives | Cross-platform |
| ext4 | 16 TiB | / and /home | Standard Linux |
| xfs | 8 EiB | VMs, large files | Online grow only |
| btrfs | 16 EiB | Snapshots | Copy-on-write |

---

## 4. Mount

```bash
# Mount a filesystem
sudo mkdir /mnt/data
sudo mount /dev/sda1 /mnt/data
sudo mount /dev/vg_data/lv_data /mnt/data

# Mount with options
sudo mount -o ro /dev/sda1 /mnt/data         # read-only
sudo mount -o noatime /dev/sda1 /mnt/data    # no access time update

# Unmount
sudo umount /mnt/data
sudo umount /dev/sda1                         # by device

# Check active mounts
mount | grep sda
df -hT | grep sda
```

### /etc/fstab — persistent mounts
```bash
# Get UUID
sudo blkid /dev/sda1

# Format:
# <UUID>  <mountpoint>  <type>  <options>  <dump>  <pass>
UUID=abc123  /mnt/data   ext4    defaults    0       2
UUID=def456  /mnt/vms    xfs     defaults    0       2

# Test fstab without rebooting
sudo mount -a             # mounts everything in fstab
```

---

## 5. LVM — Logical Volume Manager

### Concepts
```
PV (Physical Volume)  = disk or partition declared to LVM
VG (Volume Group)     = pool aggregating one or more PVs
LV (Logical Volume)   = logical partition carved from the VG
PE (Physical Extent)  = smallest allocation unit (default 4 MiB)
```

```
/dev/sda1  (PV)
    ↓
  vg_data   (VG)
    ↓
  ├─ lv_home    (LV) → mkfs.ext4 → /home
  ├─ lv_vms     (LV) → mkfs.xfs  → /vms
  └─ lv_backup  (LV) → mkfs.xfs  → /backup
```

### PV commands
```bash
sudo pvcreate /dev/sda1              # create PV
sudo pvs                             # short summary
sudo pvdisplay                       # detailed info
sudo pvdisplay /dev/sda1             # specific PV
sudo pvremove /dev/sda1              # remove PV
sudo pvscan                          # scan all PVs
```

### VG commands
```bash
sudo vgcreate vg_data /dev/sda1              # create VG
sudo vgcreate vg_data /dev/sda1 /dev/sdb1   # multiple PVs
sudo vgextend vg_data /dev/sdb1              # add PV to VG
sudo vgreduce vg_data /dev/sdb1              # remove PV from VG
sudo vgs                                     # short summary
sudo vgdisplay                               # detailed info
sudo vgrename vg_data vg_newname             # rename VG
sudo vgchange -an vg_data                    # deactivate VG
sudo vgchange -ay vg_data                    # activate VG
sudo vgremove vg_data                        # remove VG (must be empty)
sudo vgscan                                  # scan and discover VGs
```

### LV commands
```bash
# Create
sudo lvcreate -L 100G -n lv_data vg_data          # fixed size
sudo lvcreate -l 100%FREE -n lv_data vg_data       # all free space
sudo lvcreate -l 50%VG -n lv_data vg_data          # 50% of VG

# Extend
sudo lvextend -L +50G /dev/vg_data/lv_data         # add 50G
sudo lvextend -L 200G /dev/vg_data/lv_data         # set total to 200G
sudo lvextend -l +100%FREE /dev/vg_data/lv_data    # use all free space
sudo lvextend -r -L +50G /dev/vg_data/lv_data      # extend LV + resize fs

# Resize filesystem after lvextend (without -r)
xfs_growfs /mnt/data                               # xfs — online, no umount needed
sudo resize2fs /dev/vg_data/lv_data                # ext4

# Reduce (ext4 only — xfs cannot be shrunk)
sudo umount /mnt/data
sudo e2fsck -f /dev/vg_data/lv_data                # check fs first
sudo resize2fs /dev/vg_data/lv_data 80G            # shrink fs
sudo lvreduce -L 80G /dev/vg_data/lv_data          # shrink LV

# Info
sudo lvs                                            # short summary
sudo lvdisplay                                      # detailed info

# Remove
sudo lvremove /dev/vg_data/lv_data
```

### Full LVM workflow — new disk to mounted LV
```bash
# 1. Create partition (type: Linux LVM)
sudo fdisk /dev/sdb      # g → n → t → 30 → w
sudo partprobe /dev/sdb

# 2. Create PV
sudo pvcreate /dev/sdb1

# 3. Create VG
sudo vgcreate vg_data /dev/sdb1

# 4. Create LV
sudo lvcreate -L 100G -n lv_data vg_data

# 5. Format
sudo mkfs.ext4 /dev/vg_data/lv_data

# 6. Mount
sudo mkdir /mnt/data
sudo mount /dev/vg_data/lv_data /mnt/data

# 7. Persist in fstab
sudo blkid /dev/vg_data/lv_data
echo "UUID=xxx /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo mount -a
```

---

## 6. LUKS Encryption

### Concepts
```
/dev/sda1  (encrypted partition)
    ↓
LUKS header (stores encrypted key slots)
    ↓
/dev/mapper/mycrypt  (decrypted device — use like a normal disk)
    ↓
filesystem (ext4, exFAT, xfs...)
```

### Setup
```bash
# Install
sudo apt install cryptsetup

# Format partition with LUKS2
sudo cryptsetup luksFormat /dev/sda1
# → type YES (uppercase) → enter passphrase → confirm

# Open (decrypt) — creates /dev/mapper/mycrypt
sudo cryptsetup open /dev/sda1 mycrypt
# alternative syntax:
sudo cryptsetup luksOpen /dev/sda1 mycrypt

# Format the decrypted device
sudo mkfs.exfat -L "MYUSB" /dev/mapper/mycrypt
# or ext4:
sudo mkfs.ext4 /dev/mapper/mycrypt

# Mount
sudo mkdir /mnt/secure
sudo mount /dev/mapper/mycrypt /mnt/secure
```

### Daily use
```bash
# Open + mount
sudo cryptsetup open /dev/sda1 mycrypt
sudo mount /dev/mapper/mycrypt /mnt/secure

# Unmount + close (always in this order)
sudo umount /mnt/secure
sudo cryptsetup close mycrypt          # re-encrypts on close
```

### Inspection and key management
```bash
# Check if partition is LUKS
sudo cryptsetup isLuks /dev/sda1 && echo "YES" || echo "NO"

# Show LUKS header info (cipher, key slots...)
sudo cryptsetup luksDump /dev/sda1

# Show status of open container
sudo cryptsetup status mycrypt

# Add a second passphrase (LUKS supports up to 8 key slots)
sudo cryptsetup luksAddKey /dev/sda1

# Change passphrase
sudo cryptsetup luksChangeKey /dev/sda1

# Remove a passphrase
sudo cryptsetup luksRemoveKey /dev/sda1
```

### /etc/crypttab — auto-open at boot
```bash
# Format:
# <name>  <device/UUID>  <keyfile>  <options>
mycrypt   UUID=abc123    none       luks

# none = prompt for passphrase at boot
# with keyfile = silent unlock
```

---

## 7. Device Mapper

```bash
# List all active device-mapper devices
sudo dmsetup ls

# Show info on a specific device
sudo dmsetup info vg_home-lv_data

# Show dependencies (which physical device it sits on)
sudo dmsetup deps vg_home-lv_data

# Show mapping table
sudo dmsetup table vg_home-lv_data

# Remove orphaned device-mapper entry
sudo dmsetup remove vg_clef-lv_data

# Remove all inactive device-mapper entries
sudo dmsetup remove_all
```

---

## 8. NBD — Network Block Device

Expose a disk image or block device over TCP — client sees it as a local disk.

```bash
# SERVER — expose a file or device
sudo apt install nbd-server
nbd-server 10809 /path/to/image.img      # one-shot, no config needed

# CLIENT — connect and use as local disk
sudo apt install nbd-client
sudo modprobe nbd max_part=8             # load kernel module
sudo nbd-client 192.168.1.10 10809 /dev/nbd0
lsblk | grep nbd
mount /dev/nbd0p1 /mnt

# Disconnect
sudo umount /mnt
sudo nbd-client -d /dev/nbd0
```

### Make nbd module persistent
```bash
echo "nbd" > /etc/modules-load.d/nbd.conf        # load at boot
echo "options nbd max_part=8" > /etc/modprobe.d/nbd.conf  # with params

# Verify
cat /sys/module/nbd/parameters/max_part           # should return 8
```

### /etc/nbd-server/config
```ini
[generic]
    user = nbd
    group = nbd
    includedir = /etc/nbd-server/conf.d

[myimage]
    exportname = /home/user/Vms/disk.img
    readonly = false
    copyonwrite = true    # writes don't modify original image
```

---

## 9. Quick Reference

```bash
# Full disk overview
lsblk -e7 -f

# LVM status at a glance
sudo pvs && sudo vgs && sudo lvs

# Check filesystem usage
df -hT

# Find UUID of a device
sudo blkid /dev/sda1

# Scan for LVM volumes (after hotplug)
sudo pvscan
sudo vgscan && sudo vgchange -ay

# Check and repair ext4
sudo e2fsck -f /dev/vg_data/lv_data

# Reload partition table
sudo partprobe /dev/sda
```

---

*Generated: 2026-04-29 — homelab reference*
