# Storage

Disks, partitions, filesystems, mounts, LVM, swap, RAID, quotas, LUKS, NBD.

[← Back to index](./README.md) · NFS, Samba, SSHFS: [services.md](./services.md)

---

## Inspect

```bash
lsblk -f                 # Tree + filesystem, UUID, mount point (-e7 hides loop devices)
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,UUID
blkid                    # UUID, type, label
findmnt                  # Mount tree (findmnt /dev/sdb1, findmnt -t ext4)
fdisk -l /dev/sda        # Partition table
parted -l
df -hT ; df -i           # Usage, inodes
```

---

## Partitions

```bash
wipefs -a /dev/sdb       # Erase all signatures (partition table too!)
```

### fdisk

```
fdisk /dev/sdb
g        new GPT table (o = MBR)
n        new partition (Enter x3 = whole disk)
t        type: use the alias  linux | swap | lvm | raid | uefi
p        print — check before writing
w        write and quit (q = quit without saving)
```

The type numbers change between fdisk versions. The aliases always work.

### Other tools

```bash
cfdisk /dev/sdb          # Menu interface, easier
gdisk /dev/sdb           # GPT only
parted -s /dev/sdb mklabel gpt mkpart primary ext4 1MiB 100%   # Scriptable

partprobe /dev/sdb       # Kernel re-reads the table (or partx -u /dev/sdb)
```

---

## Filesystems

```bash
mkfs.ext4 -L DATA /dev/sdb1
mkfs.xfs -L DATA /dev/sdb1          # -f to overwrite an existing filesystem
mkfs.vfat -F32 -n EFI /dev/sdb1
mkfs.exfat -L USB /dev/sdb1         # Package exfatprogs
mkfs.btrfs /dev/sdb1

e2label /dev/sdb1 DATA              # Change label (ext)
xfs_admin -L DATA /dev/sdb1         # Change label (xfs)
tune2fs -l /dev/sdb1                # ext info
xfs_info /mnt/data                  # xfs info
```

| FS | Max file | Use | Shrink? |
|---|---|---|---|
| FAT32 | 4 GiB | EFI partition | — |
| exFAT | 16 EiB | USB, Windows/macOS | — |
| ext4 | 16 TiB | `/`, `/home` | Yes (unmounted) |
| XFS | 8 EiB | Big files, VMs (RHEL default) | **No** |
| Btrfs | 16 EiB | Snapshots, copy-on-write | Yes |

`mkfs` erases the partition: check with `lsblk` first.

### Check and repair (unmounted!)

```bash
e2fsck -f /dev/sdb1      # ext4 (or fsck -y)
xfs_repair /dev/sdb1     # XFS (-n = dry run)
```

`fsck.xfs` exists but does nothing. To check the root filesystem: boot with the kernel parameter `fsck.mode=force`.

---

## Mount

```bash
mount /dev/sdb1 /mnt/data
mount -o ro,noexec /dev/sdb1 /mnt/data
mount -o remount,rw /
umount /mnt/data         # -l = lazy, when busy
```

Busy? `lsof /mnt/data` or `fuser -vm /mnt/data` (`fuser -km` kills the processes).

| Option | Meaning |
|---|---|
| defaults | rw, suid, dev, exec, auto, nouser, async |
| ro / rw | Read-only / read-write |
| noexec, nosuid, nodev | No executables, no SUID, no device files |
| noatime | Don't update access time (faster) |
| nofail | Boot even if the device is missing |
| _netdev | Wait for the network (NFS, iSCSI) |

### /etc/fstab

```
# <device>          <mount point>  <type>  <options>          <dump> <pass>
UUID=abc-123        /data          ext4    defaults           0      2
LABEL=BACKUP        /backup        xfs     defaults,noatime   0      2
/dev/vg1/lv_data    /var/data      xfs     defaults,nofail    0      2
/swapfile           none           swap    defaults           0      0
```

pass: 0 = no check, 1 = root, 2 = others.

```bash
findmnt --verify         # Check fstab syntax
mount -a                 # Test BEFORE rebooting
systemctl daemon-reload  # systemd reads fstab too
```

---

## LVM

```
Disk / partition  →  PV (physical volume)
PVs               →  VG (volume group = pool)
VG                →  LV (logical volume = used like a partition)
```

### Full workflow

```bash
pvcreate /dev/sdb1
vgcreate vg_data /dev/sdb1
lvcreate -L 10G -n lv_data vg_data      # -l 100%FREE = all free space
mkfs.ext4 /dev/vg_data/lv_data
mkdir -p /mnt/data
echo "/dev/vg_data/lv_data /mnt/data ext4 defaults 0 2" >> /etc/fstab
mount -a
```

LV path: `/dev/vg_data/lv_data` = `/dev/mapper/vg_data-lv_data`.

### PV and VG

```bash
pvs ; vgs ; lvs                 # Summary (pvdisplay, vgdisplay, lvdisplay = details)
vgextend vg_data /dev/sdc       # Add a disk to the VG
pvmove /dev/sdb                 # Move data off a disk...
vgreduce vg_data /dev/sdb       # ...then remove it from the VG
pvremove /dev/sdb
vgrename old new
vgchange -ay vg_data            # Activate (-an = deactivate)
pvscan ; vgscan                 # Detect after hotplug
```

### Grow

```bash
lvextend -r -L +5G /dev/vg_data/lv_data       # Grow LV AND filesystem (best)
lvextend -r -l +100%FREE /dev/vg_data/lv_data

# Without -r, grow the filesystem yourself:
resize2fs /dev/vg_data/lv_data   # ext4: takes the DEVICE
xfs_growfs /mnt/data             # XFS: takes the MOUNT POINT
```

### Shrink (ext4 only)

```bash
umount /mnt/data
lvreduce -r -L 8G /dev/vg_data/lv_data        # Checks + shrinks FS and LV
mount -a
```

Manual way: `e2fsck -f` → `resize2fs DEV 8G` → `lvreduce -L 8G` (in this order).

---

## Swap

```bash
mkswap /dev/sdb2 && swapon /dev/sdb2

fallocate -l 2G /swapfile        # Swap file
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

swapon --show ; free -h
swapoff /swapfile
echo "vm.swappiness = 10" > /etc/sysctl.d/99-swap.conf   # Use swap less
```

---

## RAID (mdadm)

```bash
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sd[bcd]

cat /proc/mdstat
mdadm --detail /dev/md0
mdadm /dev/md0 --fail /dev/sdb --remove /dev/sdb
mdadm /dev/md0 --add /dev/sde

mdadm --detail --scan >> /etc/mdadm/mdadm.conf   # RHEL: /etc/mdadm.conf
update-initramfs -u                              # RHEL: dracut -f
```

Without `mdadm.conf`, `md0` can become `md127` after reboot.

| Level | Disks | Description |
|---|---|---|
| 0 | 2+ | Stripe: speed, no redundancy |
| 1 | 2 | Mirror |
| 5 | 3+ | Stripe + parity (1 disk can fail) |
| 6 | 4+ | Double parity (2 disks can fail) |
| 10 | 4+ | Mirror + stripe |

---

## Quotas

### XFS

```bash
# fstab options: uquota,gquota — then unmount and mount again (remount is not enough)
xfs_quota -x -c 'limit bsoft=100m bhard=500m john' /home
xfs_quota -x -c 'report -h' /home
```

### ext4

```bash
# fstab options: usrquota,grpquota — then mount -o remount /home
quotacheck -cugm /home
quotaon /home
edquota -u john          # Or: setquota -u john 100M 500M 0 0 /home
quota -u john ; repquota -a
```

---

## LUKS encryption

```bash
cryptsetup luksFormat /dev/sdb1          # Type YES in uppercase
cryptsetup open /dev/sdb1 secure         # → /dev/mapper/secure
mkfs.ext4 /dev/mapper/secure
mount /dev/mapper/secure /mnt/secure

umount /mnt/secure && cryptsetup close secure   # Always in this order

cryptsetup isLuks /dev/sdb1 && echo yes
cryptsetup luksDump /dev/sdb1            # Header, key slots
cryptsetup status secure
cryptsetup luksAddKey /dev/sdb1          # Up to 8 (LUKS1) or 32 (LUKS2) key slots
cryptsetup luksChangeKey /dev/sdb1
cryptsetup luksRemoveKey /dev/sdb1
```

```
# /etc/crypttab — open at boot
# <name>   <device>         <keyfile>          <options>
secure     UUID=abc-123     none               luks     # none = ask the passphrase
backup     UUID=def-456     /root/backup.key   luks     # keyfile: chmod 600
```

Then mount `/dev/mapper/secure` in `/etc/fstab`.

---

## Device mapper

```bash
dmsetup ls               # LVM, LUKS... devices
dmsetup info vg_data-lv_data
dmsetup deps vg_data-lv_data      # Underlying disks
dmsetup remove vg_old-lv_old      # Remove a stale entry
```

---

## NBD (network block device)

Share a disk or an image over TCP. The client sees a local disk.

```bash
# Server
nbd-server 10809 /path/disk.img

# Client
modprobe nbd max_part=8
nbd-client 192.168.1.10 10809 /dev/nbd0
mount /dev/nbd0p1 /mnt
umount /mnt && nbd-client -d /dev/nbd0
```

```ini
# /etc/nbd-server/config
[generic]
    user = nbd
    group = nbd

[myimage]
    exportname = /srv/disk.img
    readonly = false
    copyonwrite = true    # Writes don't change the original image
```

---

## Pitfalls

- `resize2fs` takes the device, `xfs_growfs` takes the mount point.
- XFS cannot shrink: back up, recreate, restore.
- `lvextend` without `-r` does not grow the filesystem.
- `vgextend` adds a disk to a VG, `lvextend` grows an LV.
- A typo in `/etc/fstab` can block the boot: `mount -a` before rebooting, `nofail` for non-critical disks.
- Repair only unmounted filesystems. Use `xfs_repair` for XFS.
- `mkfs` and `wipefs` erase data: check `lsblk -f` first.
- Save the RAID in `mdadm.conf`.
