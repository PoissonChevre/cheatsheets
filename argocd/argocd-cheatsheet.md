# Argo CD — Cheat Sheet

GitOps for Kubernetes: Git is the source of truth, Argo CD keeps the cluster equal to the repo.

[Kubernetes cheat sheets](../k8s/README.md) · [Helm](../k8s/helm.md) · [Kustomize](../k8s/kustomize.md)

---

## Words

| Word | Meaning |
|---|---|
| **Application** | One app: a Git source (plain YAML, Kustomize or Helm) → a cluster + namespace |
| **Sync** | Apply Git to the cluster |
| **Sync status** | `Synced` (cluster = Git) or `OutOfSync` |
| **Health** | `Healthy`, `Progressing`, `Degraded`, `Missing`, `Suspended` |
| **Prune** | Delete resources that are no longer in Git |
| **Self-heal** | Undo manual changes made in the cluster |
| **AppProject** | Group of apps with limits (allowed repos, clusters, namespaces) |
| **ApplicationSet** | Generates many Applications from one template |

---

## Install

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Or with Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f values.yaml

# CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd
```

### First login

```bash
argocd admin initial-password -n argocd              # Initial admin password
kubectl port-forward svc/argocd-server -n argocd 8080:443   # UI: https://localhost:8080
argocd login localhost:8080 --username admin --insecure
argocd account update-password
kubectl -n argocd delete secret argocd-initial-admin-secret  # After changing it
```

---

## CLI

```bash
argocd app list
argocd app get web                       # Status, health, resources
argocd app diff web                      # Git vs cluster
argocd app sync web                      # Apply now (--prune to delete extra resources)
argocd app sync web --resource apps:Deployment:web   # Only one resource
argocd app wait web --health --timeout 300
argocd app history web
argocd app rollback web 3                # Only when auto-sync is off
argocd app set web --revision v1.2.0     # Follow another branch/tag
argocd app terminate-op web              # Stop a stuck sync
argocd app delete web                    # Also deletes the resources (cascade)

argocd repo add https://github.com/PoissonChevre/homelab-infra.git        # Public repo
argocd repo add git@github.com:PoissonChevre/private.git --ssh-private-key-path ~/.ssh/argocd
argocd repo list
argocd cluster list
argocd proj list
```

Create an app from the CLI (quick tests — prefer YAML in Git):

```bash
argocd app create web \
  --repo https://github.com/PoissonChevre/homelab-infra.git \
  --path apps/web/overlays/dev \
  --dest-server https://kubernetes.default.svc --dest-namespace dev \
  --sync-policy automated --auto-prune --self-heal --sync-option CreateNamespace=true
```

---

## Application (YAML)

### Kustomize or plain YAML from Git

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web
  namespace: argocd                      # Applications always live in the argocd namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io   # Delete the resources when the app is deleted
spec:
  project: default
  source:
    repoURL: https://github.com/PoissonChevre/homelab-infra.git
    targetRevision: main                 # Branch, tag or commit
    path: apps/web/overlays/dev          # kustomization.yaml found → Kustomize
  destination:
    server: https://kubernetes.default.svc   # The cluster Argo CD runs in
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true             # Big CRDs (kube-prometheus-stack...)
```

### Helm chart from a repository

```yaml
spec:
  source:
    repoURL: https://charts.longhorn.io
    chart: longhorn
    targetRevision: 1.7.2                # Chart version — always pin it
    helm:
      releaseName: longhorn
      valuesObject:
        defaultSettings:
          defaultDataPath: /var/mnt/longhorn
  destination:
    server: https://kubernetes.default.svc
    namespace: longhorn-system
```

### Helm chart + values file from your Git repo

```yaml
spec:
  sources:
    - repoURL: https://prometheus-community.github.io/helm-charts
      chart: kube-prometheus-stack
      targetRevision: X.Y.Z
      helm:
        valueFiles:
          - $values/apps/monitoring/values.yaml
    - repoURL: https://github.com/PoissonChevre/homelab-infra.git
      targetRevision: main
      ref: values                        # Gives the name $values
```

---

## App of apps

One "root" Application points to a folder full of Application files. Add a file in Git → a new app appears.

```
homelab-infra/
├── bootstrap/
│   └── root-app.yaml        # kubectl apply -f this one, once
└── apps/
    ├── argocd/              # Argo CD can manage itself
    ├── longhorn.yaml
    ├── monitoring.yaml
    └── web.yaml
```

```yaml
# bootstrap/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/PoissonChevre/homelab-infra.git
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated: { prune: true, selfHeal: true }
```

## ApplicationSet (one app per folder)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: apps
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - git:
        repoURL: https://github.com/PoissonChevre/homelab-infra.git
        revision: main
        directories:
          - path: apps/*
  template:
    metadata:
      name: '{{.path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/PoissonChevre/homelab-infra.git
        targetRevision: main
        path: '{{.path.path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{.path.basename}}'
      syncPolicy:
        automated: { prune: true, selfHeal: true }
        syncOptions: [CreateNamespace=true]
```

Other generators: `list`, `cluster`, `matrix`, `pullRequest` (preview environments).

---

## Sync order and hooks

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"          # Lower waves first (default 0): CRDs, namespaces...
    argocd.argoproj.io/hook: PreSync            # Job before the sync (DB migration); also Sync, PostSync, SyncFail
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
    argocd.argoproj.io/sync-options: Prune=false   # Never delete this resource
```

### Ignore fields changed by the cluster

```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas          # Managed by an HPA
```

---

## GitOps flow with CI

```
git push (code) → GitHub Actions: test, build, push image to GHCR
              → CI updates the image tag in the GitOps repo (kustomize edit set image / values.yaml)
              → Argo CD sees the commit → sync → new pods
```

The CI never runs `kubectl apply`: it only commits. Argo CD Image Updater can also update tags automatically.

---

## Troubleshooting

| Symptom | Check |
|---|---|
| `OutOfSync` all the time | A controller changes a field (replicas, defaults) → `ignoreDifferences` |
| `Progressing` forever | `kubectl describe` the Deployment/pods, readiness probe |
| `Degraded` | Pods crash: `kubectl logs`, events |
| `ComparisonError` / repo error | `argocd repo list` (credentials), path or revision wrong |
| Manual change reverted | `selfHeal: true` — change Git instead |
| CRD "metadata.annotations: Too long" | `ServerSideApply=true` |
| App deleted, resources stay | No `resources-finalizer` |

```bash
argocd app get web --refresh             # Force Argo CD to re-read Git now
kubectl -n argocd logs deploy/argocd-repo-server        # Render errors (Helm/Kustomize)
kubectl -n argocd logs statefulset/argocd-application-controller
```

---

## Pitfalls

- With `selfHeal`, `kubectl edit` is undone in seconds: Git is the only place to change things.
- `prune` is off by default: removed files stay in the cluster until you prune.
- `argocd app rollback` doesn't work with auto-sync: revert the commit in Git.
- Never put plain Secrets in Git: Sealed Secrets, SOPS or External Secrets.
- Pin chart versions (`targetRevision`) and image tags, never `latest`.
- Application resources must be in the `argocd` namespace.
- Big CRDs need `ServerSideApply=true`.
- Delete the `argocd-initial-admin-secret` after changing the admin password.

---

## Links

- [Argo CD docs](https://argo-cd.readthedocs.io/) · [ApplicationSet](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/) · [Helm chart](https://github.com/argoproj/argo-helm)
