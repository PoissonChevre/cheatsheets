# Kustomize

Customize plain YAML for each environment, without templates. Built into kubectl (`-k`).

[← Back to index](./README.md) · Templates and packages: [helm.md](./helm.md)

---

## How it works

You keep normal YAML files (**base**), and add small changes per environment (**overlays**). Kustomize merges them and outputs the final YAML.

```
app/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        ├── kustomization.yaml
        └── replicas-patch.yaml
```

---

## Commands

```bash
kubectl kustomize overlays/prod              # Show the final YAML
kubectl apply -k overlays/prod               # Apply
kubectl diff -k overlays/prod                # What would change
kubectl delete -k overlays/prod

# Standalone binary (newer than the one inside kubectl)
kustomize build overlays/prod
kustomize build overlays/prod | kubectl apply -f -
kustomize create --autodetect                # kustomization.yaml from the files in this folder
kustomize edit set image web=ghcr.io/poissonchevre/web:1.3.0
kustomize edit add resource ingress.yaml
```

---

## Base

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
labels:
  - pairs:
      app.kubernetes.io/name: web
    includeSelectors: false          # Don't touch selectors (they can't change later)
```

`deployment.yaml` and `service.yaml` are normal manifests (see [manifests.md](./manifests.md)).

---

## Overlay

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base                       # The base (a folder, a file, or a Git URL)
  - ingress.yaml                     # Extra resource only for prod

namespace: prod                      # Set on every resource
namePrefix: prod-                    # web → prod-web (references are updated too)

labels:
  - pairs:
      env: prod

commonAnnotations:
  owner: renaud

images:
  - name: web                        # Image name used in the base
    newName: ghcr.io/poissonchevre/web
    newTag: "1.3.0"

replicas:
  - name: web
    count: 3

configMapGenerator:
  - name: web-config
    literals:
      - LOG_LEVEL=warn
    files:
      - app.conf

secretGenerator:
  - name: db
    envs:
      - db.env                       # KEY=value lines — don't commit real secrets

patches:
  - path: replicas-patch.yaml
```

---

## Patches

### Strategic merge (a partial YAML)

Same `kind` and `name` as the target. Only what changes.

```yaml
# overlays/prod/replicas-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  template:
    spec:
      containers:
        - name: web                  # Lists of containers are merged by name
          resources:
            limits:
              memory: 512Mi
```

### JSON patch (precise operations)

```yaml
patches:
  - target:
      kind: Deployment
      name: web
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: nginx:1.27
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: FEATURE_X
          value: "on"
      - op: remove
        path: /spec/template/spec/containers/0/livenessProbe
```

### One patch for many resources

```yaml
patches:
  - target:
      kind: Deployment
      labelSelector: "tier=backend"  # All matching Deployments
    path: add-sidecar.yaml
```

---

## Generators

`configMapGenerator` and `secretGenerator` add a **hash** to the name (`web-config-7g2b9k`) and update every reference. When the content changes, the name changes, so the pods restart automatically.

```yaml
configMapGenerator:
  - name: web-config
    behavior: merge                  # In an overlay: merge with the base one (or replace)
    literals:
      - LOG_LEVEL=debug

generatorOptions:
  disableNameSuffixHash: true        # No hash (pods won't restart on change)
```

---

## Components (reusable options)

A piece you can add to some overlays only (e.g. monitoring, debug).

```yaml
# components/monitoring/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component
resources:
  - servicemonitor.yaml
patches:
  - path: metrics-port.yaml
```

```yaml
# overlays/prod/kustomization.yaml
components:
  - ../../components/monitoring
```

---

## Helm chart inside Kustomize

```yaml
helmCharts:
  - name: kube-prometheus-stack
    repo: https://prometheus-community.github.io/helm-charts
    version: X.Y.Z
    releaseName: monitoring
    namespace: monitoring
    valuesFile: values.yaml
```

```bash
kustomize build --enable-helm .      # Or: kubectl kustomize --enable-helm .
```

Useful to patch a chart that has no value for what you need.

---

## Helm or Kustomize?

| | Helm | Kustomize |
|---|---|---|
| Method | Templates + values | Plain YAML + patches |
| Install | Separate binary | Inside kubectl |
| Third-party apps | ✅ Most apps ship a chart | Rare |
| Your own apps | OK, but templates get complex | ✅ Simple, readable |
| Releases and rollback | ✅ `helm history`, `helm rollback` | No (use Git / ArgoCD) |
| Learning curve | Go templates | Low |

Common choice: **Helm for third-party apps** (Longhorn, Prometheus, cert-manager), **Kustomize for your own apps**. ArgoCD supports both.

---

## Pitfalls

- The kustomize inside kubectl is older than the standalone binary: some fields may be missing (`kubectl version` shows it).
- `commonLabels` (old) also changes selectors → error on existing Deployments. Use `labels` with `includeSelectors: false`.
- `patchesStrategicMerge`, `patchesJson6902` and `bases` are deprecated: use `patches` and `resources`.
- A strategic merge patch needs the exact `kind` and `name` of the target (before `namePrefix`).
- Generators add a hash: reference the base name, Kustomize updates it.
- `secretGenerator` with files in Git = secrets in Git. Use SOPS or Sealed Secrets.
- Check the output with `kubectl kustomize` before `apply -k`.
