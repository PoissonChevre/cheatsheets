# jq & kubectl JSONPath Cheat Sheet
*Query JSON from the command line — jq for any JSON, JSONPath / custom-columns for kubectl*

## jq Basics
*Read and navigate JSON*

```bash
sudo apt install jq  # Install
jq . file.json  # Pretty-print
jq -r '.name' file.json  # Raw string (no quotes) → for scripts
jq -c '.items[]' file.json  # Compact, one object per line
jq '.spec.replicas' file.json  # Nested key
jq '.items[0]' file.json  # First element
jq '.items[]' file.json  # Iterate array
jq '.items[].name' file.json  # Field of each element
jq '[.items[].name]' file.json  # Same, collected into an array
jq '.items | length' file.json  # Count elements
jq 'keys' file.json  # List keys of an object
```

## jq Filters & Transform
*Select, reshape and format*

```bash
jq '.items[] | select(.status == "Running")' f.json  # Filter
jq '.items[] | select(.name | test("^web"))' f.json  # Regex filter
jq '.items[] | {name, ip: .status.ip}' f.json  # Build new object
jq -r '.items[] | "\(.name)\t\(.status)"' f.json  # String interpolation (tab-separated)
jq -r '.items[] | [.name, .status] | @tsv' f.json  # Table output (also @csv)
jq '.items | sort_by(.age)' f.json  # Sort
jq '[.items[].image] | unique' f.json  # Unique values
jq '.items | group_by(.node) | map({node: .[0].node, count: length})' f.json  # Group & count
jq '.name // "unknown"' f.json  # Default value if null
jq --arg n web1 '.items[] | select(.name == $n)' f.json  # Pass shell variable
jq '.spec.replicas = 3' f.json  # Modify a value
jq 'del(.metadata.annotations)' f.json  # Remove a key
```

## kubectl JSONPath
*Built into kubectl — no extra tool needed (CKA-friendly)*

```bash
kubectl get pods -o jsonpath='{.items[*].metadata.name}'  # All pod names (one line)
kubectl get pod web -o jsonpath='{.spec.nodeName}'  # One field of one resource
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'  # One line per pod
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'  # Filter
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}'  # All images
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'  # Node IPs
kubectl get secret db -o jsonpath='{.data.password}' | base64 -d  # Decode a secret value
kubectl config view -o jsonpath='{.contexts[*].name}'  # List contexts
## JSONPath has no regex, no sort, no count → use jq for that
```

## kubectl custom-columns & sort
*Readable tables without jq*

```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
kubectl get pods -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image
kubectl get pods --sort-by=.metadata.creationTimestamp  # Sort by age
kubectl get pv --sort-by=.spec.capacity.storage  # Sort by size
kubectl explain pod.spec.containers  # Find the field path you need
kubectl get pod web -o yaml  # See the real structure before querying
```

## kubectl + jq
*Things JSONPath can't do*

```bash
kubectl get pods -o json | jq -r '.items[] | select(.status.phase != "Running") | .metadata.name'  # Not running
kubectl get pods -o json | jq -r '.items[] | "\(.metadata.name)\t\(.status.containerStatuses[0].restartCount)"'  # Restarts
kubectl get pods -A -o json | jq -r '.items | group_by(.spec.nodeName)[] | "\(.[0].spec.nodeName): \(length)"'  # Pods per node
kubectl get pods -A -o json | jq -r '[.items[].spec.containers[].image] | unique[]'  # Unique images
kubectl get secret db -o json | jq '.data | map_values(@base64d)'  # Decode ALL keys of a secret
```

## Cloud CLIs + jq
*Same idea for az / aws*

```bash
az vm list -o json | jq -r '.[] | "\(.name)\t\(.hardwareProfile.vmSize)"'  # Azure VMs and sizes
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "\(.InstanceId)\t\(.State.Name)"'  # EC2 state
## az and aws also have --query (JMESPath) built in — no jq needed for simple cases
```

## JSONPath vs jq
*Same query, two syntaxes*

```
Task                 JSONPath (kubectl)                 jq
All items            {.items[*]}                        .items[]
Field of each        {.items[*].metadata.name}          .items[].metadata.name
Filter               {.items[?(@.x=="y")]}              .items[] | select(.x=="y")
Loop + newline       {range .items[*]}...{"\n"}{end}    .items[] | "..."
Count / sort / regex ✗                                  length / sort_by / test()
```

## References
- [jq manual](https://jqlang.org/manual/)
- [kubectl JSONPath support](https://kubernetes.io/docs/reference/kubectl/jsonpath/)
- [jq playground](https://jqplay.org/)
