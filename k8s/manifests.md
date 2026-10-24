# Manifests

YAML reference: workloads, services, ingress, config, storage, autoscaling, RBAC, network policies.

[← Back to index](./README.md) · Commands: [kubectl.md](./kubectl.md)

Generate a starting point instead of typing: `kubectl create deployment web --image=nginx --dry-run=client -o yaml > deploy.yaml`

---

## apiVersion by kind

| apiVersion | Kinds |
|---|---|
| `v1` | Pod, Service, ConfigMap, Secret, Namespace, PersistentVolume(Claim), ServiceAccount, ResourceQuota, LimitRange |
| `apps/v1` | Deployment, StatefulSet, DaemonSet, ReplicaSet |
| `batch/v1` | Job, CronJob |
| `networking.k8s.io/v1` | Ingress, NetworkPolicy |
| `rbac.authorization.k8s.io/v1` | Role, ClusterRole, RoleBinding, ClusterRoleBinding |
| `autoscaling/v2` | HorizontalPodAutoscaler |
| `storage.k8s.io/v1` | StorageClass |

Not sure? `kubectl explain KIND` shows the version.

---

## Deployment (complete example)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: dev
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web                   # Must match the template labels (can't change later)
  strategy:
    type: RollingUpdate          # Or Recreate (stop all, then start)
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: ghcr.io/poissonchevre/web:1.2.0    # Pin a tag, avoid :latest
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8080
          env:
            - name: APP_ENV
              value: prod
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: web-config
                  key: LOG_LEVEL
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db
                  key: password
          envFrom:
            - configMapRef:
                name: web-config          # All keys as variables
          resources:
            requests:                     # Used by the scheduler
              cpu: 100m
              memory: 128Mi
            limits:                       # Max (memory over limit = OOMKilled)
              memory: 256Mi
          readinessProbe:                 # Not ready = no traffic from the Service
            httpGet:
              path: /ready
              port: http
            periodSeconds: 5
          livenessProbe:                  # Fails = container restarted
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
          volumeMounts:
            - name: config
              mountPath: /etc/web
            - name: data
              mountPath: /data
      volumes:
        - name: config
          configMap:
            name: web-config              # Each key = one file
        - name: data
          persistentVolumeClaim:
            claimName: web-data
      imagePullSecrets:
        - name: ghcr                      # For private registries
```

### Units and probes

| | Examples |
|---|---|
| CPU | `100m` = 0.1 core, `1` = 1 core |
| Memory | `128Mi`, `1Gi` (powers of 2), `128M` (powers of 10) |

| Probe | Fails → | Use |
|---|---|---|
| `startupProbe` | Restart | Slow-starting apps (other probes wait for it) |
| `readinessProbe` | Removed from Service endpoints | Not ready to serve yet |
| `livenessProbe` | Container restarted | App stuck |

Probe types: `httpGet`, `tcpSocket`, `exec` (`command: [cat, /tmp/ok]`), `grpc`.

### Minimal Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test
  labels:
    app: test
spec:
  containers:
    - name: test
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3600"]
```

---

## Other workloads

| Kind | Use |
|---|---|
| **StatefulSet** | Stable names (`db-0`, `db-1`) and one PVC per pod (`volumeClaimTemplates`) — databases |
| **DaemonSet** | One pod on every node — log agents, node exporters, CNI |
| **Job** | Run to completion — migrations, backups |
| **CronJob** | Job on a schedule |

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: "0 2 * * *"            # Cron syntax, cluster time zone (or timeZone: Europe/Brussels)
  concurrencyPolicy: Forbid        # Don't start if the previous one still runs
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backoffLimit: 2              # Retries
      template:
        spec:
          restartPolicy: OnFailure # Never or OnFailure for Jobs
          containers:
            - name: backup
              image: busybox:1.36
              command: ["sh", "-c", "echo backup done"]
```

---

## Services

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: ClusterIP                  # Default
  selector:
    app: web                       # Pods with this label get the traffic
  ports:
    - name: http
      port: 80                     # Port of the Service
      targetPort: http             # Port of the pod (number or name)
```

| Type | Reachable from | Notes |
|---|---|---|
| `ClusterIP` | Inside the cluster | DNS `web.dev.svc.cluster.local` |
| `NodePort` | `NODE_IP:30000-32767` | Add `nodePort: 30080` to fix the port |
| `LoadBalancer` | External IP | Cloud, or MetalLB / kube-vip on bare metal |
| `ExternalName` | — | DNS alias: `externalName: db.example.com` |
| Headless | — | `clusterIP: None`: DNS returns pod IPs (StatefulSet) |

---

## Ingress

HTTP routing by host and path. Needs an ingress controller (Traefik, HAProxy, NGINX...).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
spec:
  ingressClassName: traefik        # kubectl get ingressclass
  tls:
    - hosts: [web.example.com]
      secretName: web-tls          # Secret type kubernetes.io/tls (or cert-manager)
  rules:
    - host: web.example.com
      http:
        paths:
          - path: /
            pathType: Prefix       # Prefix or Exact
            backend:
              service:
                name: web
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 3000
```

The Gateway API (`Gateway`, `HTTPRoute`) is the newer alternative to Ingress.

---

## ConfigMap and Secret

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
data:
  LOG_LEVEL: info
  app.conf: |                      # A whole file
    listen 8080
    workers 4
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db
type: Opaque
stringData:                        # Plain text, Kubernetes encodes it
  username: app
  password: changeme
# data:                            # Or base64 yourself: echo -n 'changeme' | base64
#   password: Y2hhbmdlbWU=
```

Secrets are only **base64**, not encrypted. Don't commit them to Git: use Sealed Secrets, SOPS or External Secrets.

Ways to use them in a pod: `env.valueFrom` (one key), `envFrom` (all keys), `volumes` (files). See the Deployment example.

---

## Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-data
spec:
  accessModes: [ReadWriteOnce]     # One node read-write
  storageClassName: longhorn       # kubectl get storageclass (empty = default class)
  resources:
    requests:
      storage: 5Gi
```

| Access mode | Meaning |
|---|---|
| `ReadWriteOnce` (RWO) | Read-write, one node |
| `ReadOnlyMany` (ROX) | Read-only, many nodes |
| `ReadWriteMany` (RWX) | Read-write, many nodes (NFS, CephFS, Longhorn RWX) |
| `ReadWriteOncePod` | Read-write, one pod |

Dynamic provisioning: the StorageClass creates the PV when the PVC is created. `reclaimPolicy: Delete` (default) deletes the data with the PVC; `Retain` keeps it.

Temporary volumes: `emptyDir: {}` (lives with the pod), `hostPath` (node folder — avoid outside labs).

---

## Autoscaling (HPA)

Needs metrics-server and `resources.requests` on the containers.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80   # % of the CPU request
```

---

## Namespace limits

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota
  namespace: dev
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.memory: 16Gi
    pods: "50"
    persistentvolumeclaims: "10"
---
apiVersion: v1
kind: LimitRange                   # Default requests/limits for containers without them
metadata:
  name: defaults
  namespace: dev
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      default:
        memory: 256Mi
```

With a ResourceQuota on CPU/memory, pods **must** have requests/limits (or a LimitRange that sets them).

---

## RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app
  namespace: dev
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role                         # Namespace scope (ClusterRole = whole cluster)
metadata:
  name: pod-reader
  namespace: dev
rules:
  - apiGroups: [""]                # "" = core group (pods, services, configmaps...)
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-reads-pods
  namespace: dev
subjects:
  - kind: ServiceAccount
    name: app
    namespace: dev
  # - kind: User
  #   name: jane
  #   apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Use the ServiceAccount in a pod: `spec.serviceAccountName: app`. Check: `kubectl auth can-i list pods --as=system:serviceaccount:dev:app -n dev`.

---

## NetworkPolicy

Needs a CNI that supports it (Calico, Cilium, Flannel does **not**).

```yaml
# 1. Block all incoming traffic in the namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: dev
spec:
  podSelector: {}                  # All pods
  policyTypes: [Ingress]
---
# 2. Allow web → db on 5432
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-from-web
  namespace: dev
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: web
      ports:
        - protocol: TCP
          port: 5432
```

Policies only **add** allowed traffic. With `Egress` in `policyTypes`, also allow DNS (UDP/TCP 53) or names stop resolving.

---

## Pitfalls

- `selector.matchLabels` must match `template.metadata.labels`, and can't be changed after creation.
- Service `selector` must match the pod labels: check `kubectl get endpoints`.
- `targetPort` = container port, `port` = Service port.
- No memory limit = a pod can take the whole node. Memory over the limit = OOMKilled.
- A liveness probe that is too strict restarts healthy pods: start with a readiness probe.
- Secrets are not encrypted: never commit them.
- PVC `Pending`: no default StorageClass or wrong name.
- `:latest` + `IfNotPresent` = old image stays on the node.
