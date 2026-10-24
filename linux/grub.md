# GRUB and Boot

Boot process, GRUB config, kernel parameters, kernels and initramfs, rescue modes, root password reset, boot troubleshooting.

[← Back to index](./README.md) · Targets and systemd: [system.md](./system.md#systemd) · SELinux: [selinux.md](./selinux.md)

---

## Boot process

```
Firmware (BIOS or UEFI)
   → GRUB (menu, loads kernel + initramfs, passes parameters)
      → kernel
         → initramfs (small temporary root: drivers, LVM, LUKS, finds the real root)
            → switch_root to the real root
               → systemd (PID 1) → default target
```

| | BIOS | UEFI |
|---|---|---|
| GRUB location | Start of the disk (MBR) | EFI partition (FAT32, `/boot/efi`) |
| Partition table | MBR or GPT | GPT |
| Secure Boot | — | Possible (`shim` loads GRUB) |

```bash
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS   # How did this machine boot?
mokutil --sb-state                                    # Secure Boot on?
efibootmgr -v                                         # UEFI boot entries
```

---

## Files

| File | Role | Edit? |
|---|---|---|
| `/etc/default/grub` | Main settings | **Yes** |
| `/etc/grub.d/` | Scripts that build the menu (`40_custom` = your entries) | Sometimes |
| `/boot/grub/grub.cfg` (Debian) | Generated menu | **No** |
| `/boot/grub2/grub.cfg` (RHEL) | Generated menu | **No** |
| `/boot/loader/entries/*.conf` (RHEL 8+, Fedora) | One file per kernel (BLS) | Use `grubby` |
| `/boot/grub2/grubenv` | Saved default entry | Use the tools |

### /etc/default/grub

```bash
GRUB_TIMEOUT=5                          # Seconds before boot (-1 = wait forever)
GRUB_TIMEOUT_STYLE=menu                 # menu | hidden (Ubuntu hides the menu by default)
GRUB_DEFAULT=0                          # First entry, "saved", or the entry title
GRUB_SAVEDEFAULT=true                   # Remember the last choice (needs GRUB_DEFAULT=saved)
GRUB_CMDLINE_LINUX="console=tty0"       # Parameters for ALL entries
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"   # Debian: normal entries only (not recovery)
GRUB_DISABLE_RECOVERY=true              # No recovery entries
GRUB_ENABLE_BLSCFG=true                 # RHEL: use /boot/loader/entries
```

### Apply

```bash
update-grub                                  # Debian/Ubuntu (= grub-mkconfig -o /boot/grub/grub.cfg)
grub2-mkconfig -o /boot/grub2/grub.cfg       # RHEL 9 (BIOS and UEFI)
```

RHEL 8 with UEFI: `/boot/efi/EFI/redhat/grub.cfg`. Since RHEL 9, always `/boot/grub2/grub.cfg`.

### Custom entry

```bash
# /etc/grub.d/40_custom (keep the first lines of the file)
menuentry "UEFI firmware settings" {
    fwsetup
}
```

Then `update-grub` or `grub2-mkconfig`.

---

## Kernel parameters

```bash
cat /proc/cmdline                            # Parameters of the current boot
```

### RHEL: grubby

`grubby` edits the BLS entries directly. No `grub2-mkconfig` needed.

```bash
grubby --info=ALL                            # All entries + parameters
grubby --default-kernel
grubby --update-kernel=ALL --args="console=ttyS0"
grubby --update-kernel=ALL --remove-args="rhgb quiet"
grubby --update-kernel=/boot/vmlinuz-$(uname -r) --args="nomodeset"   # One kernel only
```

### Debian/Ubuntu

Edit `GRUB_CMDLINE_LINUX` in `/etc/default/grub`, then `update-grub`.

### Useful parameters

Add them at the end of the `linux` line (at boot with `e`, or permanently).

| Parameter | Effect |
|---|---|
| `systemd.unit=rescue.target` | Rescue mode: single user, root password needed |
| `systemd.unit=emergency.target` | Emergency mode: read-only root, almost nothing started |
| `rd.break` | Stop in the initramfs, before switch_root (RHEL) |
| `init=/bin/bash` | Root shell instead of systemd |
| `enforcing=0` | SELinux permissive for this boot |
| `selinux=0` | SELinux disabled (avoid: needs a relabel to come back) |
| `fsck.mode=force` | Check filesystems at boot |
| `nomodeset` | No graphics driver (black screen) |
| `rd.lvm.lv=rhel/root` | Tell the initramfs which LV to activate |
| `rhgb quiet` / `quiet splash` | Remove them to see boot messages |

---

## Default entry

```bash
# RHEL
grubby --set-default=/boot/vmlinuz-5.14.0-427.el9.x86_64
grubby --set-default-index=1
grub2-set-default 1                          # Same, by number
grub2-reboot 1                               # Only for the next boot
grub2-editenv list                           # Show saved_entry

# Debian (needs GRUB_DEFAULT=saved)
grub-set-default 1
grub-reboot 1
```

Entries are numbered from 0.

---

## Kernels and initramfs

```bash
uname -r                                     # Running kernel
ls /boot/vmlinuz-*                           # Installed kernels

# RHEL
rpm -q kernel
dnf remove --oldinstallonly                  # Remove old kernels
# /etc/dnf/dnf.conf: installonly_limit=3 (kernels kept)

# Debian/Ubuntu
dpkg -l 'linux-image*' | grep ^ii
apt autoremove --purge                       # Remove old kernels
```

New kernel broken? Choose the previous kernel in the GRUB menu, then make it the default.

### Rebuild the initramfs

Needed after changing drivers, LVM, LUKS, RAID or `/etc/crypttab`.

```bash
dracut -f                                    # RHEL: current kernel
dracut -f --kver 5.14.0-427.el9.x86_64       # RHEL: another kernel
lsinitrd | less                              # RHEL: content

update-initramfs -u                          # Debian: current kernel (-k all = all kernels)
lsinitramfs /boot/initrd.img-$(uname -r)     # Debian: content
```

---

## At the GRUB menu

| Key | Action |
|---|---|
| `Shift` (BIOS) or `Esc` (UEFI) | Show a hidden menu (Ubuntu) |
| `e` | Edit the selected entry |
| `Ctrl+E` | End of line |
| `Ctrl+X` or `F10` | Boot with your changes |
| `Esc` | Cancel |
| `c` | GRUB command line |

Changes made with `e` are lost after this boot.

---

## Rescue and emergency modes

| | rescue.target | emergency.target |
|---|---|---|
| Root filesystem | Mounted read-write | Mounted **read-only** |
| Other filesystems | Mounted | Not mounted |
| Services | Basic | Almost none |
| Use | Repair config, users | Broken fstab, rescue fails |

Both ask for the **root password**. If root is locked or has no password (RHEL 9 option at install), they refuse: use `rd.break`.

In emergency mode:

```bash
mount -o remount,rw /           # Make root writable
vi /etc/fstab                   # Fix the error
systemctl daemon-reload
mount -a                        # Test
systemctl default               # Continue the normal boot (or reboot)
```

Switch from a running system: `systemctl isolate rescue.target`.

---

## Reset the root password (RHEL / CentOS / Rocky / Alma)

1. Reboot. In the GRUB menu, select the kernel and press `e`.
2. Go to the line that starts with `linux`. Press `Ctrl+E` and add:
   ```
   rd.break
   ```
   In a VM or cloud image, also remove `console=ttyS0...` if you see nothing on screen.
3. Press `Ctrl+X`. You get a `switch_root:/#` shell (in the initramfs).
4. Run:
   ```bash
   mount -o remount,rw /sysroot    # The real root is mounted read-only on /sysroot
   chroot /sysroot                 # Work inside the real system
   passwd root
   touch /.autorelabel             # SELinux: relabel at next boot (REQUIRED)
   exit                            # Leave the chroot
   exit                            # Continue the boot (or: reboot -f)
   ```
5. The relabel runs, the machine reboots once more, then you can log in.

Without `touch /.autorelabel`, `/etc/shadow` gets a wrong SELinux label and **nobody can log in**.

**Faster** on a big disk (no full relabel): use `rd.break enforcing=0` in step 2, skip `touch /.autorelabel`, then after login:

```bash
restorecon -v /etc/shadow
setenforce 1
```

**Other method**: `init=/bin/bash` instead of `rd.break`, then:

```bash
mount -o remount,rw /
passwd root
touch /.autorelabel              # RHEL only
exec /sbin/init
```

**Ubuntu**: same `init=/bin/bash` method, without the SELinux step.

---

## Boot troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `grub>` prompt | GRUB found, no config | Boot by hand (below), then regenerate `grub.cfg` |
| `grub rescue>` prompt | GRUB modules not found | Set `prefix` and `root` (below), then reinstall GRUB |
| `Kernel panic ... VFS: Unable to mount root fs` | Wrong `root=`, broken initramfs | Check `root=`, older kernel, `dracut -f` |
| `dracut-initqueue timeout`, then dracut shell | Root device not found (LVM, LUKS, disk) | `lvm vgscan`, `lvm vgchange -ay`, check `rd.lvm.lv=` |
| "You are in emergency mode" | Error in `/etc/fstab`, failed fsck | Emergency steps above |
| Boot hangs on a "start job" | Missing disk or network mount | `nofail` or `_netdev` in fstab |
| Can't log in after a reset | SELinux labels | `touch /.autorelabel` and reboot |

```bash
journalctl -b -1 -p err          # Errors of the previous boot
systemd-analyze                  # Boot time
systemd-analyze blame            # Slowest units
systemd-analyze critical-chain   # What delayed the boot
systemctl --failed
```

### Boot by hand from `grub>`

```
ls                                   # (hd0) (hd0,gpt1) (hd0,gpt2)...
ls (hd0,gpt2)/                       # Find the partition with vmlinuz
set root=(hd0,gpt2)
linux /vmlinuz-6.8.0-45-generic root=/dev/sda2    # Tab completion works
initrd /initrd.img-6.8.0-45-generic
boot
```

With LVM: `root=/dev/mapper/rhel-root`. If `/boot` is a separate partition, the files are at the top of it (`/vmlinuz-...`).

### From `grub rescue>`

```
ls
set prefix=(hd0,gpt2)/boot/grub      # RHEL: /boot/grub2
set root=(hd0,gpt2)
insmod normal
normal                               # Normal menu appears
```

---

## Reinstall GRUB

```bash
# BIOS
grub-install /dev/sda                        # RHEL: grub2-install /dev/sda

# UEFI — Debian/Ubuntu
grub-install --target=x86_64-efi --efi-directory=/boot/efi

# UEFI — RHEL (don't use grub2-install with Secure Boot)
dnf reinstall grub2-efi-x64 shim-x64

# Then regenerate the config
update-grub                                  # RHEL: grub2-mkconfig -o /boot/grub2/grub.cfg
```

From a live USB, when the system does not boot:

```bash
mount /dev/sda2 /mnt                         # Root partition (or the LV)
mount /dev/sda1 /mnt/boot/efi                # EFI partition (UEFI)
for d in dev proc sys run; do mount --rbind /$d /mnt/$d; done
chroot /mnt
grub-install ... && update-grub              # Commands above
exit
```

---

## GRUB password

Stops people from editing entries at boot (`e`) — and from using `rd.break`.

```bash
grub2-setpassword                            # RHEL: creates /boot/grub2/user.cfg
```

```bash
grub-mkpasswd-pbkdf2                         # Debian: create a hash
# Add to /etc/grub.d/40_custom:
#   set superusers="admin"
#   password_pbkdf2 admin grub.pbkdf2.sha512.10000.XXXX
update-grub
```

On Debian, this asks the password at **every** boot, unless the entries have `--unrestricted`. On RHEL, `grub2-setpassword` only protects editing.

---

## Pitfalls

- Never edit `grub.cfg`: edit `/etc/default/grub`, then `update-grub` or `grub2-mkconfig`.
- RHEL: use `grubby` for kernel parameters.
- RHEL 8 UEFI and RHEL 9 use different `grub.cfg` paths.
- Changes with `e` at boot are temporary.
- `rd.break`: remount `/sysroot` read-write, `chroot`, and never forget `touch /.autorelabel`.
- Emergency mode: root is read-only, run `mount -o remount,rw /` first.
- Rebuild the initramfs after changing LVM, LUKS or RAID.
- On UEFI with Secure Boot (RHEL), reinstall the packages instead of `grub2-install`.
