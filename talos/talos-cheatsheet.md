# Talos Linux — Cheat Sheet

Immutable, API-driven OS for Kubernetes. No SSH, no shell, no package manager: everything goes through `talosctl` and the machine config. Written for Talos 1.14.

---

## Mental model

| Tool | Talks to | Port | Config file |
|---|---|---|---|
| `talosctl` | Talos API on each node (the OS) | 50000 | `talosconfig` |
| `kubectl` | Kubernetes API (the cluster) | 6443 | `kubeconfig` |

- `--nodes` (`-n`) = the node(s) the command is **about**.
- `--endpoints` (`-e`) = the node(s) `talosctl` **connects to** (usually a control plane, which forwards).
- Use the `talosctl` version that matches the cluster version.

---

## Create a cluster

```bash
# 1. Image with extensions (iscsi-tools, util-linux-tools for Longhorn; qemu-guest-agent in VMs)
#    → https://factory.talos.dev — note the schematic ID, boot the ISO

# 2. Secrets (keep them safe: they ARE the cluster identity)
talosctl gen secrets -o secrets.yaml

# 3. Configs
talosctl gen config homelab https://10.10.50.10:6443 \
  --with-secrets secrets.yaml \
  --install-image factory.talos.dev/metal-installer/<schematic-id>:v1.14.4 \
  --config-patch @patches/common.yaml \
  --config-patch-control-plane @patches/controlplane.yaml \
  --config-patch-worker @patches/worker.yaml \
  --output-dir _out
# → _out/controlplane.yaml, _out/worker.yaml, _out/talosconfig

# 4. Per-node file (hostname, IP)
talosctl machineconfig patch _out/controlplane.yaml --patch @nodes/cp1.yaml -o _out/cp1.yaml

# 5. Send the config to nodes in maintenance mode (booted from ISO)
talosctl apply-config --insecure -n 10.10.50.10 -f _out/cp1.yaml
talosctl apply-config --insecure -n 10.10.50.20 -f _out/w1.yaml

# 6. talosctl client config
export TALOSCONFIG=$PWD/_out/talosconfig        # Or: talosctl config merge _out/talosconfig
talosctl config endpoint 10.10.50.10
talosctl config node 10.10.50.10

# 7. Start etcd — ONCE, on ONE control plane
talosctl bootstrap -n 10.10.50.10

# 8. Kubeconfig
talosctl kubeconfig -n 10.10.50.10              # Merged into ~/.kube/config
kubectl get nodes -o wide
```

`--insecure` is only for the first apply (maintenance mode, no certificates yet).

---

## Config patches

Small YAML files merged into the generated config. One file can hold several documents separated by `---`.

```yaml
# patches/common.yaml
machine:
  install:
    disk: /dev/sda                        # Or: diskSelector
  time:
    servers: [pool.ntp.org]
cluster:
  allowSchedulingOnControlPlanes: false   # true on a single-node cluster
```

```yaml
# nodes/cp1.yaml — static network (Talos 1.12+ documents)
apiVersion: v1alpha1
kind: HostnameConfig
hostname: talos-cp1
---
apiVersion: v1alpha1
kind: LinkConfig
name: enp0s25                             # talosctl get links -n IP --insecure
addresses:
  - address: 10.10.50.10/24
routes:
  - gateway: 10.10.50.1
---
apiVersion: v1alpha1
kind: ResolverConfig
nameservers:
  - address: 10.10.50.1
```

`machine.network` (old style) still works but is deprecated since 1.12.

### Longhorn disk

```yaml
apiVersion: v1alpha1
kind: UserVolumeConfig
name: longhorn                            # Mounted at /var/mnt/longhorn
provisioning:
  diskSelector:
    match: "!system_disk"                 # e.g. disk.transport == 'nvme' && !system_disk
  grow: false
```

Then: Longhorn Helm value `defaultSettings.defaultDataPath=/var/mnt/longhorn`, and the namespace label `pod-security.kubernetes.io/enforce=privileged`.

---

## Inspect a node

```bash
talosctl dashboard -n IP                 # Live overview (CPU, memory, logs)
talosctl health                          # Whole cluster checks
talosctl version -n IP
talosctl get members                     # Nodes in the cluster

talosctl services -n IP                  # Talos services and their state
talosctl logs kubelet -n IP              # -f follow; also etcd, containerd, apid...
talosctl logs kernel -n IP               # Kernel log (also: talosctl dmesg)
talosctl containers -k -n IP             # Kubernetes containers (-k)
talosctl processes -n IP                 # Like top
talosctl memory -n IP ; talosctl mounts -n IP
talosctl ls /var/log -n IP ; talosctl read /proc/cpuinfo -n IP

talosctl get disks -n IP                 # Disks (add --insecure in maintenance mode)
talosctl get volumestatus -n IP          # Volumes (EPHEMERAL, user volumes)
talosctl get links -n IP                 # Network interfaces
talosctl get addresses -n IP
talosctl get routes -n IP
talosctl get extensions -n IP            # Installed system extensions
talosctl get machineconfig -n IP -o yaml # Current config
talosctl netstat -n IP ; talosctl pcap -i eth0 -n IP
```

`talosctl get rd` lists every resource type you can `get`.

---

## Change the config

```bash
talosctl patch machineconfig -n IP --patch @patch.yaml          # Merge a patch
talosctl patch machineconfig -n IP --patch @patch.yaml --dry-run
talosctl edit machineconfig -n IP                                # In $EDITOR
talosctl apply-config -n IP -f _out/cp1.yaml                     # Replace with a full file
talosctl apply-config -n IP -f cp1.yaml --mode=try               # Rollback after 1 min unless confirmed
```

Modes: `auto` (default: reboot only if needed), `no-reboot`, `reboot`, `staged` (at next reboot), `try`.

Keep the files in Git (without `secrets.yaml` and `talosconfig` in clear) and use `apply-config`: the node then always matches the repo.

---

## Upgrade

```bash
# Talos OS — one node at a time, workers first, then control planes
talosctl upgrade -n 10.10.50.20 \
  --image factory.talos.dev/metal-installer/<schematic-id>:v1.14.4 --wait
talosctl rollback -n IP                  # Back to the previous Talos version

# Kubernetes — run once, against a control plane
talosctl upgrade-k8s -n 10.10.50.10 --to X.Y.Z --dry-run   # Check supported versions in the Talos release notes
talosctl upgrade-k8s -n 10.10.50.10 --to X.Y.Z
```

- Use **your** schematic ID, or the extensions (iscsi-tools...) disappear after the upgrade.
- Upgrade minor versions one by one (1.13.x latest → 1.14.x).
- Since 1.14, installer images only come from the Image Factory (`metal-installer`).

---

## Reboot, shutdown, reset

```bash
talosctl reboot -n IP
talosctl shutdown -n IP
talosctl reset -n IP --graceful --reboot                    # Leave etcd, wipe, back to maintenance
talosctl reset -n IP --system-labels-to-wipe EPHEMERAL --reboot   # Wipe only pods/images data
```

`reset` wipes the node. On a control plane, `--graceful` leaves etcd first.

---

## etcd

```bash
talosctl etcd members -n CP_IP
talosctl etcd status -n CP_IP
talosctl etcd snapshot etcd-$(date +%F).db -n CP_IP     # Backup — do it regularly
talosctl etcd remove-member MEMBER_ID -n CP_IP          # Remove a dead control plane

# Disaster recovery (all control planes lost): reset, apply config, then
talosctl bootstrap -n CP_IP --recover-from=./etcd-2026-10-24.db
```

With one control plane, the etcd snapshot **is** your cluster backup.

---

## Troubleshooting

| Symptom | Check |
|---|---|
| `talosctl` timeout / "connection refused" | Right `--endpoints`? Port 50000 open? `talosctl config info` |
| "certificate signed by unknown authority" | Wrong `talosconfig` (another cluster), or node still in maintenance → `--insecure` |
| Node stuck "waiting for bootstrap" | `talosctl bootstrap` not run (once, one control plane) |
| Node not `Ready` | `talosctl logs kubelet`, CNI pods: `kubectl get pods -n kube-system` |
| Longhorn volumes fail to attach | `talosctl get extensions` → iscsi-tools missing; namespace not privileged |
| Config change ignored | `apply-config` mode `staged`? Check `talosctl get machineconfig -o yaml` |
| Lost access after a network change | Use `--mode=try` next time; console or reset from ISO |

---

## Pitfalls

- No SSH: don't look for it. `talosctl` does logs, files, services, reboot.
- `bootstrap` once, on one control plane only. Twice = two etcd clusters.
- `secrets.yaml` and `talosconfig` give full control of the cluster: never in Git in clear (use SOPS).
- `--nodes` ≠ `--endpoints`.
- Upgrade with your Image Factory schematic, or you lose the extensions.
- Talos enforces Pod Security `baseline`: storage and monitoring namespaces often need `privileged`.
- Default CNI is Flannel: no NetworkPolicy support (use Cilium if you need it).
- `talosctl` client version should match the cluster version.

---

## Links

- [Talos docs](https://docs.siderolabs.com/talos/) · [Image Factory](https://factory.talos.dev) · [Longhorn on Talos](https://docs.siderolabs.com/kubernetes-guides/csi/longhorn)
