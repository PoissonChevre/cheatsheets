# Proxmox VE — Cheat Sheets

| File | Content |
|---|---|
| [proxmox-cheatsheet.md](./proxmox-cheatsheet.md) | VMs (`qm`), cloud-init, containers (`pct`), storage and ZFS, network and VLANs, backup, users and API, cluster, troubleshooting |

## Templates

Scripts to build reusable templates.

| Script | Use |
|---|---|
| [vm-cloud-init-template.sh](./templates/vm-cloud-init-template.sh) | VM template from a cloud image, with cloud-init (on the host) |
| [lxc-template-prep.sh](./templates/lxc-template-prep.sh) | Clean a container before turning it into a template (inside the container) |

Change the variables at the top of the script, then run it.

## Resources

- [Proxmox VE documentation](https://pve.proxmox.com/pve-docs/)
- [Learn Linux TV — Proxmox VE full course](https://www.learnlinux.tv/proxmox-full-course/)
- [Techno Tim — Proxmox template with cloud image and cloud-init](https://technotim.live/posts/cloud-init-cloud-image/)
- [apalrd — Proxmox VM templates with cloud images](https://www.apalrd.net/posts/2023/pve_cloud/)
- [Ubuntu cloud images](https://cloud-images.ubuntu.com/) · [Debian cloud images](https://cloud.debian.org/images/cloud/)

Related: [Terraform](../terraform/README.md) · [Talos Linux](../talos/talos-cheatsheet.md)
