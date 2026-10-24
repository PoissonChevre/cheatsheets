# Helm

Package manager for Kubernetes: install charts, manage values, upgrade and roll back, write your own chart, publish to an OCI registry.

[← Back to index](./README.md) · Alternative without templates: [kustomize.md](./kustomize.md)

---

## Words

| Word | Meaning |
|---|---|
| **Chart** | A package: templates + default values |
| **Values** | Settings you give to the chart (`values.yaml`, `-f`, `--set`) |
| **Release** | One installed copy of a chart, with a name, in a namespace |
| **Revision** | Version of a release (+1 at each upgrade or rollback) |
| **Repository** | Where charts are published (HTTP repo or OCI registry) |

---

## Repositories and search

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add longhorn https://charts.longhorn.io
helm repo update                                  # Before install/upgrade
helm repo list
helm repo remove longhorn

helm search repo prometheus                       # In added repos
helm search repo longhorn/longhorn --versions     # All versions
helm search hub cert-manager                      # Artifact Hub

helm show values longhorn/longhorn > values.yaml  # Default values = your starting point
helm show chart longhorn/longhorn                 # Chart and app versions
helm show readme longhorn/longhorn
helm pull longhorn/longhorn --untar               # Download the chart to read it
```

---

## Install and upgrade

```bash
helm install longhorn longhorn/longhorn \
  -n longhorn-system --create-namespace \
  --version 1.7.2 \
  -f values.yaml

# Install or upgrade with the same command (scripts, CI)
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values.yaml -f values-prod.yaml \
  --wait --timeout 10m

helm upgrade longhorn longhorn/longhorn -n longhorn-system --version 1.7.3 -f values.yaml
```

Always pin `--version`: without it, you get the latest chart.

### Values: who wins?

```
chart values.yaml  <  -f file1.yaml  <  -f file2.yaml  <  --set key=value
     (lowest)                                              (highest)
```

```bash
--set replicaCount=3
--set image.tag=1.2.0
--set-string image.tag=1.20          # Keep it as text (not the number 1.2)
--set ingress.hosts[0]=web.example.com
--set-file config=./app.conf         # Value from a file
```

On upgrade, values you don't pass again go back to the chart defaults. Keep your values in a file in Git and pass it every time.
(`--reuse-values` reuses the last values, but can miss new chart settings.)

---

## Inspect releases

```bash
helm list -n monitoring              # -A = all namespaces, -a = also failed ones
helm status monitoring -n monitoring # State + notes
helm get values monitoring -n monitoring          # Values you gave (-a = all computed values)
helm get manifest monitoring -n monitoring        # YAML really applied
helm get notes monitoring -n monitoring
helm history monitoring -n monitoring
```

## Roll back and uninstall

```bash
helm rollback monitoring 3 -n monitoring      # To revision 3 (creates a new revision)
helm rollback monitoring -n monitoring        # To the previous revision
helm uninstall monitoring -n monitoring       # --keep-history to keep the history
```

`helm uninstall` does not delete PVCs created by StatefulSets, nor CRDs: clean them yourself if needed.

---

## Test before applying

```bash
helm template monitoring prometheus-community/kube-prometheus-stack -f values.yaml > out.yaml   # Render locally
helm install monitoring ./chart --dry-run --debug -n monitoring    # Rendered + checked by the cluster
helm lint ./chart                                                   # Check your chart
helm diff upgrade monitoring prometheus-community/kube-prometheus-stack -f values.yaml   # Plugin helm-diff
```

---

## Write a chart

```bash
helm create web                      # Skeleton with deployment, service, ingress, HPA...
helm lint web
helm template web ./web
helm install web ./web -n dev --create-namespace
```

```
web/
├── Chart.yaml           # Name, versions, dependencies
├── values.yaml          # Default values
├── charts/              # Downloaded dependencies
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── _helpers.tpl     # Reusable snippets (names, labels)
    └── NOTES.txt        # Text shown after install
```

```yaml
# Chart.yaml
apiVersion: v2
name: web
description: Demo web app
type: application
version: 0.1.0           # Version of the CHART — increase it at every change
appVersion: "1.2.0"      # Version of the APP (often the image tag)
dependencies:
  - name: redis
    version: "1.x.x"                       # Range allowed
    repository: https://charts.example.com # Or oci://...
    condition: redis.enabled               # Install only if redis.enabled=true
```

```bash
helm dependency update ./web         # Download dependencies into charts/
```

### Template syntax

```yaml
# templates/deployment.yaml (extract)
metadata:
  name: {{ include "web.fullname" . }}
  labels:
    {{- include "web.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: web
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          {{- with .Values.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if .Values.env }}
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          {{- end }}
```

| Syntax | Meaning |
|---|---|
| `.Values.x` | Value from values.yaml / `-f` / `--set` |
| `.Release.Name`, `.Release.Namespace` | Release info |
| `.Chart.Name`, `.Chart.AppVersion` | From Chart.yaml |
| `{{- ... }}` / `{{ ... -}}` | Remove spaces/new lines before / after |
| `default "x" .Values.y` | Default value |
| `required "msg" .Values.y` | Fail if missing |
| `quote`, `upper`, `b64enc` | Functions |
| `toYaml . \| nindent 4` | Insert a YAML block with indentation |
| `if` / `with` / `range` | Condition / change scope / loop |
| `include "name" .` | Use a snippet from `_helpers.tpl` |

---

## Package and publish (OCI)

```bash
helm package ./web                                   # → web-0.1.0.tgz
echo "$GITHUB_TOKEN" | helm registry login ghcr.io -u poissonchevre --password-stdin
helm push web-0.1.0.tgz oci://ghcr.io/poissonchevre/charts

helm install web oci://ghcr.io/poissonchevre/charts/web --version 0.1.0
helm show values oci://ghcr.io/poissonchevre/charts/web --version 0.1.0
```

OCI registries have no `helm repo add` and no `helm search repo`: use the full `oci://` address.

---

## Plugins

```bash
helm plugin list
helm plugin install https://github.com/databus23/helm-diff     # helm diff upgrade
helm plugin install https://github.com/jkroepke/helm-secrets   # Values encrypted with SOPS
helm secrets edit values-secret.yaml
helm upgrade --install web ./web -f secrets://values-secret.yaml
```

---

## Pitfalls

- Pin `--version` for every chart.
- Keep your values in Git, pass `-f` at every upgrade.
- `--set` with numbers or versions: use `--set-string`.
- `version` (chart) ≠ `appVersion` (app).
- CRDs are installed once and not upgraded by `helm upgrade`: check the chart notes.
- `helm uninstall` leaves PVCs and CRDs.
- Many charts need `-n NAMESPACE` on every command: without it, Helm looks in `default`.
- Template whitespace: use `{{-` and `nindent`, check with `helm template`.
