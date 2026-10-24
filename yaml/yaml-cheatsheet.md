# YAML — Cheat Sheet

The format of Kubernetes manifests, Ansible playbooks, Docker Compose, GitHub Actions, Talos and Argo CD configs. Syntax, traps, and tools to check and edit it.

---

## Basics

```yaml
# Comment
name: web                    # key: value (space after the colon!)
replicas: 3
enabled: true
nothing: null                # Or ~

server:                      # Nested map: indent with SPACES (2 is usual)
  host: 10.10.50.10
  port: 6443
```

- **Spaces only**, never tabs.
- The indentation level defines the structure: one space off = different meaning or error.
- Keys are case-sensitive: `Name` ≠ `name`.

---

## Lists

```yaml
ports:                       # List of values
  - 80
  - 443

ports: [80, 443]             # Same, inline

containers:                  # List of maps (Kubernetes style)
  - name: web
    image: nginx:1.27
    ports:
      - containerPort: 80
  - name: sidecar
    image: busybox:1.36

labels: {app: web, env: dev} # Inline map
```

In a list of maps, the `-` starts a new item; the keys of that item are aligned under the first key (`name`, `image`).

---

## Strings and quotes

```yaml
plain: hello world           # No quotes needed most of the time
single: 'no \n escape, it''s literal'     # '' = one quote
double: "escapes work: \n \t \"quoted\""
```

**Quote** a value when it:

| Case | Example | Without quotes |
|---|---|---|
| Looks like a boolean | `"yes"`, `"no"`, `"on"`, `"off"`, `"true"` | Becomes `true`/`false` (YAML 1.1 tools) |
| Looks like a number | `"1.20"`, `"0755"`, `"8080"` when a string is expected | `1.2`, octal, or integer |
| Contains `: ` or ` #` | `"url: http://x"`, `"color #fff"` | Broken map or cut comment |
| Starts with a special char | `"*"`, `"&x"`, `"@user"`, `"{x}"`, `"[x]"`, `"!x"`, `"%x"` | Syntax error |
| Is empty | `""` | `null` |

Kubernetes examples: `version: "1.20"`, label values `"true"`, env values `value: "3000"` (env values must be strings).

---

## Multi-line strings

```yaml
script: |                    # Keep new lines (scripts, config files)
  #!/bin/sh
  echo start
  exec app

description: >               # Fold: new lines become spaces (long text)
  This is a long sentence
  on several lines.

key: |-                      # |- = remove the last new line
  value
```

| | New lines | Final new line |
|---|---|---|
| `\|` | Kept | One |
| `\|-` | Kept | Removed |
| `>` | Folded into spaces | One |
| `>-` | Folded into spaces | Removed |

The content must be indented more than the key.

---

## Several documents in one file

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
---                          # Separator
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
  namespace: dev
```

Used by `kubectl apply -f`, Helm output, Talos config patches.

---

## Anchors and aliases (reuse)

```yaml
defaults: &defaults          # & = define
  restart: unless-stopped
  logging:
    driver: json-file

services:
  web:
    <<: *defaults            # Merge the map, then add/override
    image: nginx
  api:
    <<: *defaults
    image: myapi
    restart: always          # Override
```

Works in Docker Compose (also `x-` keys for blocks to reuse), Ansible and kubectl. Check that the tool supports it before using it.

---

## Tools

### Check

```bash
yamllint file.yaml                       # Syntax + style (pip install yamllint)
yamllint -d relaxed .                    # Less strict rules
python3 -c 'import sys, yaml; list(yaml.safe_load_all(sys.stdin))' < file.yaml && echo OK

kubectl apply --dry-run=client -f k8s.yaml      # Kubernetes: valid objects?
kubeconform -summary k8s/                       # Kubernetes schemas, offline
docker compose config                           # Compose: show the final file
ansible-playbook --syntax-check site.yml
```

### yq (read and edit, like jq for YAML)

Use the Go version (mikefarah/yq): there is also a different Python `yq`.

```bash
yq '.spec.replicas' deploy.yaml                          # Read
yq '.spec.template.spec.containers[0].image' deploy.yaml
yq '.items[].metadata.name' list.yaml
yq -i '.spec.replicas = 3' deploy.yaml                   # Edit in place
yq -i '.spec.template.spec.containers[0].image = "nginx:1.27"' deploy.yaml
yq -i 'del(.metadata.annotations)' deploy.yaml
yq 'select(.kind == "Service")' all.yaml                 # One kind from a multi-doc file
yq -o json deploy.yaml                                   # YAML → JSON
yq -P file.json                                          # JSON → YAML
yq ea '. as $i ireduce ({}; . * $i)' base.yaml prod.yaml # Merge files (prod wins)
```

### Editor

- VS Code: extension "YAML" (Red Hat) — validation and auto-complete for Kubernetes, Compose, GitHub Actions.
- Show whitespace to spot tabs. `.editorconfig`:

```ini
[*.{yml,yaml}]
indent_style = space
indent_size = 2
```

---

## Common errors

| Error | Cause |
|---|---|
| `found character that cannot start any token` | A tab, or a special character at the start of a value |
| `mapping values are not allowed here` | `: ` inside an unquoted value, or wrong indentation |
| `did not find expected key` / `- ` problem | Item not aligned in a list |
| `cannot unmarshal number into ... string` | Number where a string is needed: add quotes |
| `json: cannot unmarshal string into ... bool` | `"true"` quoted where a boolean is needed |
| Value silently wrong (`no` → false, `1.10` → 1.1) | Missing quotes |
| Last key wins, no error | Duplicate key in the same map |

---

## Pitfalls

- Tabs are forbidden: configure your editor.
- `key:value` without a space is a string, not a map.
- Quote versions, octal-looking values, `yes`/`no`/`on`/`off`.
- Indentation of `-` lists must be consistent in the whole file.
- Comments `#` need a space before them when on the same line as a value.
- A duplicate key is not always an error: the last one silently wins.
- `.yml` and `.yaml` are the same; pick one per project.
