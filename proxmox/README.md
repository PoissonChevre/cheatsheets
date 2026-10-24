# Proxmox VE — Cheat Sheets

| File | Content |
|---|---|
| [proxmox-cheatsheet.md](./proxmox-cheatsheet.md) | VMs (`qm`), cloud-init, containers (`pct`), storage and ZFS, network and VLANs, backup, users and API, cluster, troubleshooting |

## Templates

Scripts to build reusable templates. Run them on the Proxmox host.

| Script | Use |
|---|---|
| [vm-cloud-init-template.sh](./templates/vm-cloud-init-template.sh) | VM template from a cloud image (Debian, Ubuntu, Rocky...) with cloud-init, optional VLAN and guest agent |
| [lxc-template-prep.sh](./templates/lxc-template-prep.sh) | Clean a Debian/Ubuntu container before converting it to a template |

```bash
./templates/vm-cloud-init-template.sh 9000 debian-13 \
  https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2

VLAN=50 STORAGE=local-zfs ./templates/vm-cloud-init-template.sh 9001 ubuntu-24-04 \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

## Resources

- [Proxmox VE documentation](https://pve.proxmox.com/pve-docs/)
- [Learn Linux TV — Proxmox VE full course](https://www.learnlinux.tv/proxmox-full-course/)
- [Techno Tim — Proxmox template with cloud image and cloud-init](https://technotim.live/posts/cloud-init-cloud-image/)
- [apalrd — Proxmox VM templates with cloud images](https://www.apalrd.net/posts/2023/pve_cloud/)
- [Ubuntu cloud images](https://cloud-images.ubuntu.com/) · [Debian cloud images](https://cloud.debian.org/images/cloud/)

Related: [Terraform](../terraform/README.md) · [Talos Linux](../talos/talos-cheatsheet.md)
