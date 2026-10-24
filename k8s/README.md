# Kubernetes — Cheat Sheets

Kubernetes commands, manifests and tools. Built while preparing the CKA and running a homelab cluster (Talos, Longhorn, ArgoCD).

| File | Content |
|---|---|
| [kubectl.md](./kubectl.md) | Setup, contexts, get/describe, imperative create, apply, logs, exec, rollouts, nodes, RBAC checks, troubleshooting |
| [manifests.md](./manifests.md) | YAML reference: Deployment, probes, workloads, Service, Ingress, ConfigMap, Secret, PVC, HPA, quotas, RBAC, NetworkPolicy |
| [kubectl-jsonpath.md](./kubectl-jsonpath.md) | JSONPath, custom-columns, kubectl + jq |
| [helm.md](./helm.md) | Repos, install/upgrade, values, rollback, writing a chart, OCI registries |
| [kustomize.md](./kustomize.md) | Base and overlays, patches, generators, components, Helm vs Kustomize |

Each file ends with a **Pitfalls** section.

## Conventions

- `k` = `kubectl` (alias in [kubectl.md](./kubectl.md#setup)).
- `$do` = `--dry-run=client -o yaml` to generate YAML.
- Examples use the namespace `dev` and the app `web`.

## Related

- [Argo CD](../argocd/argocd-cheatsheet.md) · [Talos Linux](../talos/talos-cheatsheet.md) · [YAML](../yaml/yaml-cheatsheet.md)
- [Docker](../docker/docker-cheatsheet.md)
- [Linux](../linux/README.md)
- [Kubernetes docs](https://kubernetes.io/docs/home/) · [kubectl quick reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
