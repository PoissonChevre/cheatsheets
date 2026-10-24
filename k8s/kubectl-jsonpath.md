# kubectl — JSONPath, custom-columns and jq

Get exactly the fields you need from kubectl output. JSONPath is built into kubectl (no extra tool, OK in the CKA exam). jq does what JSONPath cannot: regex, sort, count.

[← Back to index](./README.md) · Commands: [kubectl.md](./kubectl.md)

jq syntax: see [utilities.md](../linux/utilities.md#jq).

---

## Find the field path first

```bash
kubectl get pod web -o yaml              # See the real structure
kubectl explain pod.spec.containers      # Documentation of a field
```

---

## JSONPath

```bash
kubectl get pods -o jsonpath='{.items[*].metadata.name}'          # All pod names (one line)
kubectl get pod web -o jsonpath='{.spec.nodeName}'                # One field of one resource
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}'

# One line per pod
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Filter
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'

kubectl get secret db -o jsonpath='{.data.password}' | base64 -d  # Decode a secret value
kubectl config view -o jsonpath='{.contexts[*].name}'             # List contexts
```

---

## custom-columns and sort

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
kubectl get pods -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image
kubectl get pods --sort-by=.metadata.creationTimestamp            # By age
kubectl get pv --sort-by=.spec.capacity.storage                   # By size
```

---

## kubectl + jq

For what JSONPath cannot do.

```bash
# Pods not running
kubectl get pods -o json | jq -r '.items[] | select(.status.phase != "Running") | .metadata.name'

# Restarts per pod
kubectl get pods -o json | jq -r '.items[] | "\(.metadata.name)\t\(.status.containerStatuses[0].restartCount)"'

# Pods per node
kubectl get pods -A -o json | jq -r '.items | group_by(.spec.nodeName)[] | "\(.[0].spec.nodeName): \(length)"'

# Unique images in the cluster
kubectl get pods -A -o json | jq -r '[.items[].spec.containers[].image] | unique[]'

# Decode all keys of a secret
kubectl get secret db -o json | jq '.data | map_values(@base64d)'
```

---

## JSONPath vs jq

| Task | JSONPath (kubectl) | jq |
|---|---|---|
| All items | `{.items[*]}` | `.items[]` |
| Field of each | `{.items[*].metadata.name}` | `.items[].metadata.name` |
| Filter | `{.items[?(@.x=="y")]}` | `.items[] \| select(.x=="y")` |
| Loop + new line | `{range .items[*]}...{"\n"}{end}` | `.items[] \| "..."` |
| Count, sort, regex | No | `length`, `sort_by`, `test()` |

---

[← Back to index](./README.md) · [kubectl JSONPath docs](https://kubernetes.io/docs/reference/kubectl/jsonpath/)
