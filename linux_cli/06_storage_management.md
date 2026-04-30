# LFCS — Storage Management (11%)

## Inspecting Block Devices

```bash
lsblk                       # Display block devices (disks, partitions, LVM)
lsblk -f                    # With filesystem type and UUID
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
blkid                       # Show UUID, TYPE, LABEL of all block devices
blkid /dev/sda1             # Same for one device
fdisk -l                    # Display disk information
parted -l                   # Same — GPT-aware listing
findmnt /dev/vda1           # Show mount options used with /dev/vda1
findmnt -t ext4             # Show only ext4 mounts
```

## Partitioning

```bash
fdisk /dev/vdb              # Update primary partitions on /dev/vdb (MBR-friendly, GPT supported)
cfdisk                      # Curses UI to create / delete / modify partitions on a disk
gdisk /dev/sdb              # GPT partition tool (preferred for >2TB)
parted /dev/sdb             # Scriptable partition editor (GPT or MBR)
parted /dev/sdb mklabel gpt          # Create new GPT label
parted /dev/sdb mkpart primary ext4 1MiB 100%

partprobe /dev/sdb          # Inform kernel about partition table changes
partx -u /dev/sdb           # Update kernel partition table without reboot
```

## Filesystem Creation

```bash
mkfs.ext4 /dev/vdc                          # Create ext4 filesystem
mkfs.ext4 -N 2048 /dev/vdc                  # Create ext4 with 2048 inodes
mkfs.xfs /dev/vdb                           # Create XFS filesystem
mkfs.xfs -L "DataDisk" /dev/vdb             # Create XFS labelled "DataDisk"
mkfs.xfs /dev/volume1/smalldata             # Create XFS on a logical volume
mkfs.btrfs /dev/sdc                         # Create Btrfs filesystem
mkfs.vfat /dev/sdd1                         # Create FAT filesystem (USB / EFI)

# RHEL syntax: mkfs.<filesystem_type> (ext4, xfs)
```

## Filesystem Labels

```bash
e2label /dev/sda1 DATA                      # Set label for ext2/3/4
xfs_admin -L "SwapFS" /dev/vdb              # Change label for XFS filesystem
tune2fs -L DATA /dev/sda1                   # Set ext label (also tune2fs -L)
blkid /dev/sda1                             # Verify label and UUID
```

## Mounting

```bash
mount                                       # Show currently mounted filesystems
mount /dev/vdb /mnt                         # Mount /dev/vdb in /mnt directory
mount -o ro,noexec,nosuid /dev/vdb1 /mnt    # Mount read-only, no exec, no setuid
mount -t nfs server:/share /mnt             # Mount NFS share
mount -a                                    # Mount everything in /etc/fstab

umount /mnt                                 # Unmount filesystem mounted at /mnt
umount /dev/vdb1                            # Unmount by device

# Persistent mounts — /etc/fstab
# <device>          <mountpoint>  <fstype>  <options>           <dump>  <pass>
# UUID=xxx-xxx-xxx  /data         ext4      defaults             0       2
# /dev/vg1/lv_data  /var/data     xfs       defaults,noatime     0       2
# server:/share     /mnt/nfs      nfs       defaults,_netdev     0       0
```

## Filesystem Check & Repair

```bash
fsck /dev/sdb1                              # Check filesystem
fsck -y /dev/sdb1                           # Auto-answer yes
e2fsck -f /dev/sdb1                         # Force ext check (must be unmounted)
xfs_repair /dev/vdb                         # Check / repair XFS filesystem (must be unmounted)
xfs_check /dev/vdb                          # Read-only check (older XFS)
```

## Filesystem Growth & Defragmentation

```bash
# Resize after expanding partition / LV
resize2fs /dev/vg1/lv_data                  # Grow ext2/3/4 (online supported)
xfs_growfs /mountpoint                      # Grow XFS — must be MOUNTED
xfs_growfs /                                # Common case

# Defragmentation
e4defrag /mount/point                       # ext4 defrag
xfs_fsr                                     # XFS file-system reorganizer (defrag)

# Shrink
# ⚠ XFS CANNOT be shrunk — copy data → smaller new FS → re-mount
resize2fs /dev/vg1/lv_data 5G               # Shrink ext4 (unmount first)
```

## Swap Space

```bash
mkswap /dev/vdb2                            # Format /dev/vdb2 as swap
mkswap /dev/vdb3                            # (Same — vdb3 is the partition we format)
swapon /dev/vdb2                            # Activate swap on /dev/vdb2
swapon --show                               # Identify the swapfile / active swap
swapoff /dev/vdb2                           # Deactivate swap on /dev/vdb2

# Swap file creation
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# Persist in /etc/fstab:
# /swapfile   none   swap   sw   0   0
```

## LVM — Physical Volumes (PV)

```bash
pvcreate /dev/vdb /dev/vdc                  # Add disks as Physical Volumes to LVM
pvs                                         # Display list of PVs used by LVM
pvdisplay                                   # Detailed attributes of PVs
pvremove /dev/vdc                           # Remove /dev/vdc as PV from LVM
pvscan                                      # Scan for all PVs
```

## LVM — Volume Groups (VG)

```bash
vgcreate volume1 /dev/vdb                   # Create VG 'volume1' on PV /dev/vdb
vgextend volume1 /dev/vdc                   # Add /dev/vdc to volume1 (grow VG)
vgreduce volume1 /dev/vdc                   # Remove /dev/vdc from volume1
vgs                                         # Display all volume groups
vgdisplay                                   # Detailed VG info
vgremove volume1                            # Remove a VG (must be empty)
```

## LVM — Logical Volumes (LV)

```bash
lvcreate                                    # Create a Logical Volume (LV)
lvcreate -L 10G -n smalldata volume1        # 10G LV named 'smalldata' on VG volume1
lvcreate -l 100%FREE -n bigdata volume1     # Use all remaining space in VG
lvs                                         # List all LVs
lvdisplay                                   # Detailed LV info

lvresize --size 752M volume1/smalldata      # Resize LV smalldata to 752 MB
lvextend -L +5G /dev/volume1/smalldata      # Add 5G to existing LV
lvextend -L +5G -r /dev/volume1/smalldata   # Extend AND resize FS in one shot (-r)
lvreduce -L -2G /dev/volume1/smalldata      # Shrink LV by 2G (unmount + resize2fs first!)
lvremove volume1/smalldata                  # Remove the LV smalldata
```

### LVM common workflow

```bash
pvcreate /dev/vdb /dev/vdc                          # 1. PV
vgcreate datavg /dev/vdb /dev/vdc                   # 2. VG
lvcreate -L 20G -n appdata datavg                   # 3. LV
mkfs.xfs /dev/datavg/appdata                        # 4. FS
mkdir /mnt/appdata && mount /dev/datavg/appdata /mnt/appdata
echo "/dev/datavg/appdata /mnt/appdata xfs defaults 0 2" >> /etc/fstab
```

## RAID (mdadm — software RAID)

```bash
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdb /dev/vdc
# Create a level-1 RAID array at /dev/md0 with two devices /dev/vdb and /dev/vdc

mdadm --detail /dev/md0                     # Detailed status of array
cat /proc/mdstat                            # All MD arrays summary
mdadm --stop /dev/md0                       # Stop array
mdadm --assemble /dev/md0 /dev/vdb /dev/vdc # Reassemble
mdadm --add /dev/md0 /dev/vdd               # Add device (e.g. spare)
mdadm --fail /dev/md0 /dev/vdb              # Mark device as failed
mdadm --remove /dev/md0 /dev/vdb            # Remove failed device

# Persist config
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u                         # Debian/Ubuntu
```

## Disk Quotas (XFS)

```bash
xfs_quota -x -c 'limit bsoft=100m bhard=500m john' /dev/vda1
# Edit disk quotas for user john on /dev/vda1
# Soft limit: 100 MB    Hard limit: 500 MB

# Mount with quota support: add `uquota,gquota` to fstab options
mount -o remount,uquota /home

xfs_quota -x -c 'report -h' /home           # Report quotas in human-readable form
```

## Disk Quotas (ext4)

```bash
sudo apt install quota
# Mount with usrquota,grpquota in /etc/fstab, then:
quotacheck -cum /home                       # Build quota database
quotaon /home                               # Turn quotas on
edquota -u john                             # Edit user quota
quota -u john                               # Show user usage
repquota -a                                 # Report all quotas
```

## NFS — Server Side

```bash
# /etc/exports
# /srv/share   192.168.1.0/24(rw,sync,no_subtree_check)
# /srv/public  *(ro,sync)

exportfs -r                                 # Reexport /etc/exports configuration
exportfs -a                                 # Export everything in /etc/exports
exportfs -v                                 # Show currently exported shares
showmount -e <server>                       # Show shares exported by server
systemctl enable --now nfs-server
```

## NFS — Client

```bash
sudo apt install nfs-common                 # Debian/Ubuntu
mount -t nfs server:/srv/share /mnt/share   # Mount NFS share
# Persistent /etc/fstab line:
# server:/srv/share  /mnt/share  nfs  defaults,_netdev  0  0
```

## ACLs (storage perspective)

```bash
getfacl archive                                                 # List ACL permissions on file
setfacl --modify user:john:rw specialfile                       # Grant john rw on file
setfacl --modify group:mail:rx specialfile                      # Grant group mail rx
setfacl --remove user:john specialfile                          # Remove ACL for john
setfacl --recursive --modify user:john:rwx collection/          # Recursive — john rwx everywhere

# Mount with ACL support (most modern FS support it by default)
# fstab option: acl
```

## Encrypted Storage (LUKS)

```bash
cryptsetup luksFormat /dev/sdb1                                 # Initialize LUKS volume
cryptsetup luksOpen /dev/sdb1 secure_data                       # Unlock as /dev/mapper/secure_data
mkfs.ext4 /dev/mapper/secure_data                               # Create FS on unlocked device
mount /dev/mapper/secure_data /mnt/secure
cryptsetup luksClose secure_data                                # Lock and detach
cryptsetup luksAddKey /dev/sdb1                                 # Add another passphrase
cryptsetup luksDump /dev/sdb1                                   # Show LUKS header info

# Persist /etc/crypttab:
# secure_data   /dev/sdb1   none   luks
```

## Common Pitfalls (Pièges LFCS)

```bash
# 1. XFS CANNOT shrink. Only grows.
#    To "shrink": create smaller FS on new volume → copy data → swap.

# 2. xfs_growfs takes the MOUNTPOINT, not the device:
#    xfs_growfs /mnt    ✅       xfs_growfs /dev/vg/lv   ❌

# 3. resize2fs takes the DEVICE, not the mountpoint:
#    resize2fs /dev/vg/lv   ✅       resize2fs /mnt   ❌

# 4. lvextend -L +5G → only LV grows. FS does NOT auto-resize.
#    Use `lvextend -L +5G -r /dev/...` to resize FS in same call.

# 5. /etc/fstab typo + reboot = unbootable.
#    Verify with `mount -a` BEFORE reboot. Use `nofail` for non-critical mounts.

# 6. fdisk doesn't reload partition table on busy disks.
#    After fdisk → run `partprobe` or `partx -u`.

# 7. mkswap erases data on the partition. Same with mkfs.*.
#    Always verify lsblk + blkid before formatting.

# 8. XFS uses xfs_repair (not fsck.xfs). Filesystem MUST be unmounted.

# 9. mdadm arrays need to be persisted in /etc/mdadm/mdadm.conf,
#    otherwise the kernel may renumber them at boot (md0 → md127).

# 10. ALWAYS verify with: lsblk + blkid + findmnt + pvs + vgs + lvs
#     before any destructive command.
```
