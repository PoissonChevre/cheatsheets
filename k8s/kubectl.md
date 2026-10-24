# kubectl

Contexts, get and describe, create, apply, logs, exec, rollouts, nodes, troubleshooting.

[← Back to index](./README.md) · YAML: [manifests.md](./manifests.md) · Query output: [kubectl-jsonpath.md](./kubectl-jsonpath.md)

---

## Setup

```bash
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k          # Completion for the alias

export do="--dry-run=client -o yaml"             # k run web --image=nginx $do > pod.yaml
export now="--force --grace-period=0"            # k delete pod web $now (fast, for labs)

kubectl explain deployment.spec.strategy         # Field documentation
kubectl explain pod.spec --recursive | less      # All fields
kubectl api-resources                            # Kinds, short names, namespaced or not
```

---

## Contexts and namespaces

```bash
kubectl config get-contexts
kubectl config current-context
kubectl config use-context prod
kubectl config set-context --current --namespace=dev    # Default namespace
kubectl config view --minify                            # Only the current context

kubectl get ns
kubectl create ns dev
kubectl get pods -n dev
kubectl get pods -A                                     # All namespaces

kubectl cluster-info
kubectl version
```

Kubeconfig: `~/.kube/config`, or the files listed in `$KUBECONFIG` (separated by `:`).

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: homelab
    cluster:
      server: https://192.168.1.10:6443
      certificate-authority-data: LS0t...
users:
  - name: admin
    user:
      client-certificate-data: LS0t...
      client-key-data: LS0t...
contexts:
  - name: homelab
    context:
      cluster: homelab
      user: admin
      namespace: default
current-context: homelab
```

---

## Read

```bash
kubectl get pods                         # -o wide = node + IP
kubectl get pods -o yaml                 # -o json, -o name
kubectl get pods --show-labels
kubectl get pods -l app=web,tier!=db     # Label selector
kubectl get pods --field-selector status.phase=Running
kubectl get pods -w                      # Watch changes
kubectl get all                          # Pods, services, deployments, replicasets
kubectl get deploy,svc,ing               # Several kinds

kubectl describe pod web                 # Details + EVENTS (read them first)
kubectl get events --sort-by=.lastTimestamp
kubectl top node ; kubectl top pod --sort-by=memory   # Needs metrics-server
```

Short names: `po` pods, `deploy`, `svc`, `ing`, `cm`, `ns`, `no` nodes, `pv`, `pvc`, `sa`, `ds`, `sts`, `cj`.

---

## Create (imperative)

Fast for tests and exams. Add `$do > file.yaml` to get the YAML instead.

```bash
kubectl run web --image=nginx                                  # Pod
kubectl run tmp --rm -it --image=busybox -- sh                 # Temporary pod with a shell
kubectl create deployment web --image=nginx --replicas=3
kubectl expose deployment web --port=80 --target-port=8080     # ClusterIP service
kubectl expose deployment web --type=NodePort --port=80
kubectl create configmap app --from-literal=LOG_LEVEL=info --from-file=app.conf
kubectl create secret generic db --from-literal=password=changeme
kubectl create secret tls web-tls --cert=tls.crt --key=tls.key
kubectl create job backup --image=busybox -- echo done
kubectl create cronjob backup --image=busybox --schedule="0 2 * * *" -- echo done
kubectl create serviceaccount app
kubectl create role pod-reader --verb=get,list,watch --resource=pods
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=dev:app
kubectl create ingress web --rule="web.example.com/*=web:80"
```

---

## Apply and change

```bash
kubectl apply -f app.yaml                # Create or update (declarative)
kubectl apply -f manifests/              # All files of a folder (-R = recursive)
kubectl apply -k overlays/prod           # Kustomize — see kustomize.md
kubectl diff -f app.yaml                 # What would change
kubectl apply -f app.yaml --dry-run=server   # Validated by the API server, not saved

kubectl edit deploy web                  # Edit live in $EDITOR
kubectl patch deploy web -p '{"spec":{"replicas":2}}'
kubectl replace --force -f pod.yaml      # Delete + recreate (fields you can't change live)

kubectl delete -f app.yaml
kubectl delete pod web
kubectl delete pods -l app=web
```

---

## Labels and annotations

```bash
kubectl label pod web env=prod
kubectl label pod web env=dev --overwrite
kubectl label pod web env-                       # Remove the label
kubectl annotate deploy web owner=renaud
kubectl label node worker-1 disktype=ssd
```

---

## Logs, exec, copy, port-forward

```bash
kubectl logs web                         # -f follow, --tail=50, --since=1h
kubectl logs web -c sidecar              # One container of the pod
kubectl logs web --previous              # Container before the last restart (crash)
kubectl logs deploy/web                  # One pod of the deployment
kubectl logs -l app=web --all-containers --prefix   # All pods with this label

kubectl exec -it web -- sh               # Shell (-- separates kubectl args from the command)
kubectl exec web -- cat /etc/hosts
kubectl cp web:/var/log/app.log ./app.log
kubectl cp ./config.yaml web:/tmp/

kubectl port-forward svc/web 8080:80     # http://localhost:8080
kubectl port-forward pod/web 8080:80

kubectl debug -it web --image=busybox --target=web     # Debug container in the pod
kubectl debug node/worker-1 -it --image=busybox        # Shell on a node (host in /host)
```

---

## Deployments

```bash
kubectl scale deploy web --replicas=5
kubectl set image deploy/web nginx=nginx:1.27          # container=image
kubectl rollout status deploy/web
kubectl rollout history deploy/web
kubectl rollout undo deploy/web                        # --to-revision=2
kubectl rollout restart deploy/web                     # Recreate pods (new config/secret)
kubectl rollout pause deploy/web ; kubectl rollout resume deploy/web
kubectl autoscale deploy web --min=2 --max=10 --cpu-percent=80   # HPA (needs metrics-server)
```

---

## Nodes

```bash
kubectl get nodes -o wide
kubectl describe node worker-1           # Capacity, allocated resources, conditions, taints
kubectl cordon worker-1                  # No new pods
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data   # Move pods away (maintenance)
kubectl uncordon worker-1
kubectl taint nodes worker-1 dedicated=db:NoSchedule
kubectl taint nodes worker-1 dedicated=db:NoSchedule-     # Remove the taint
```

---

## RBAC checks

```bash
kubectl auth can-i create deployments
kubectl auth can-i list pods --as=jane -n dev
kubectl auth can-i '*' '*' --as=system:serviceaccount:dev:app
kubectl auth can-i --list --as=jane
kubectl auth whoami
```

---

## Troubleshooting

Order: `get` → `describe` (events) → `logs` (`--previous`) → `exec` / `debug`.

| Status | Likely cause | Check |
|---|---|---|
| `Pending` | No node fits: resources, taints, nodeSelector, PVC not bound | `describe pod` events, `get pvc` |
| `ImagePullBackOff` | Wrong image name/tag, private registry without secret | `describe pod` |
| `CrashLoopBackOff` | The app exits | `logs --previous` |
| `OOMKilled` | Memory limit too low | `describe pod` (Last State), raise `limits.memory` |
| `CreateContainerConfigError` | Missing ConfigMap or Secret | `describe pod` |
| `Running` but not ready | Readiness probe fails | `describe pod`, probe path/port |
| Service doesn't answer | Selector doesn't match pod labels, wrong targetPort | `get endpoints SVC`, `get pods --show-labels` |

```bash
kubectl get endpoints web                # Empty = selector matches no ready pod
kubectl run tmp --rm -it --image=busybox -- wget -qO- http://web.dev.svc.cluster.local
kubectl run tmp --rm -it --image=busybox -- nslookup web.dev
kubectl get pods -n kube-system          # Control plane, DNS, CNI healthy?
```

Service DNS: `<service>.<namespace>.svc.cluster.local` (just `<service>` in the same namespace).

---

## Pitfalls

- Read the **events** in `describe` before anything else.
- `kubectl logs` of a crashing pod: add `--previous`.
- Deleting a pod of a Deployment: it comes back. Scale or delete the Deployment.
- `kubectl edit` can't change some fields (pod spec): use `replace --force`.
- Changing a ConfigMap or Secret does not restart pods: `rollout restart`.
- `drain` needs `--ignore-daemonsets`.
- Always check the context and namespace before `delete`.
