# Proxmox VE — Cheat Sheets

| File | Content |
|---|---|
| [proxmox-cheatsheet.md](./proxmox-cheatsheet.md) | VMs (`qm`), containers (`pct`), storage, networking, backup, cluster, API |

## Scripts

| Script | Use |
|---|---|
| [vm_template1.sh](./scripts/vm_template1.sh) | Create a VM template from a cloud image, with arguments (VM ID, image...) |
| [vm_template2.sh](./scripts/vm_template2.sh) | Cloud-init VM template for Kubernetes nodes |
| [vm_template3.sh](./scripts/vm_template3.sh) | Ubuntu cloud image + cloud-init template, step by step |
| [ct_template1.sh](./scripts/ct_template1.sh) | Prepare an LXC container before turning it into a template |

## Resources

- [Learn Linux TV — Proxmox VE full course](https://www.learnlinux.tv/proxmox-full-course/)
- [Techno Tim — Perfect Proxmox template with cloud image and cloud-init](https://technotim.live/posts/cloud-init-cloud-image/)
- [apalrd — Proxmox VM templates with cloud images](https://www.apalrd.net/posts/2023/pve_cloud/)
- [Ubuntu cloud images](https://cloud-images.ubuntu.com/)

Related: [Terraform](../terraform/README.md) · [Talos Linux](../talos/talos-cheatsheet.md)
