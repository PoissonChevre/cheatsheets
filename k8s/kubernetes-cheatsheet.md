# ☸️ Kubernetes — Cheat Sheet
*Container orchestration platform for automated deployment, scaling, and management of containerized applications.*

---

## 🔧 Context & Config
*Manage cluster connections and authentication.*

```bash
kubectl config view  # Show current kubeconfig
kubectl config view --flatten  # Show merged kubeconfig from all sources
kubectl config get-contexts  # List all configured contexts
kubectl config current-context  # Show active context

kubectl config use-context prod-cluster  # Switch to different cluster
## Changes default context for subsequent commands

kubectl config set-context --current --namespace=prod  # Set default namespace
## Avoid typing --namespace flag for every command

kubectl cluster-info  # Show cluster API server and services
kubectl version  # Show client and server versions

kubectl auth can-i get pods --as=user@example.com  # Check permissions (RBAC)
## Useful for debugging access issues
```

## kubeconfig file structure
[~/.kube/config stores clusters, users, contexts, and current-context]

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: prod-cluster
    cluster:
      server: https://api.prod.example.com:6443
      certificate-authority-data: LS0t...  # Base64 encoded CA cert
users:
  - name: prod-user
    user:
      client-certificate-data: LS0t...
      client-key-data: LS0t...
contexts:
  - name: prod-context
    context:
      cluster: prod-cluster
      user: prod-user
      namespace: default
current-context: prod-context
```

---

## 📦 Pods
*Single or multi-container application units.*

```bash
kubectl run nginx --image=nginx:latest  # Create pod from image
## Quick way to test deployments; ephemeral

kubectl get pods  # List pods in current namespace
kubectl get pods -A  # List all pods in all namespaces
kubectl get pods -o wide  # Show additional columns (node, IP, status)
kubectl get pods --sort-by=.metadata.creationTimestamp  # Sort by creation time

kubectl describe pod nginx  # Detailed pod information
## Shows events, status, resource usage, volumes

kubectl logs nginx  # View container logs
kubectl logs -f nginx  # Follow logs (tail -f)
kubectl logs nginx -c container-name  # Logs from specific container

kubectl exec -it nginx -- /bin/sh  # Execute command in pod
## -- separates kubectl args from container command

kubectl delete pod nginx  # Remove pod (recreated if in Deployment)
## For pods in Deployments, delete the Deployment instead
```

## Pod manifest
[Define pod structure with containers, volumes, and metadata]

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: default
  labels:
    app: myapp
    version: "1.0"
spec:
  containers:
    - name: app
      image: myapp:1.0
      imagePullPolicy: IfNotPresent  # Always, IfNotPresent, Never
      ports:
        - containerPort: 3000
          name: http
      env:
        - name: APP_ENV
          value: "production"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
      resources:
        requests:  # Minimum guaranteed resources
          memory: "256Mi"
          cpu: "100m"
        limits:  # Maximum allowed resources
          memory: "512Mi"
          cpu: "500m"
      livenessProbe:  # Restart if unhealthy
        httpGet:
          path: /health
          port: 3000
        initialDelaySeconds: 10
        periodSeconds: 10
      readinessProbe:  # Remove from service if not ready
        httpGet:
          path: /ready
          port: 3000
        initialDelaySeconds: 5
        periodSeconds: 5
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      emptyDir: {}  # Ephemeral storage per pod
```

---

## 🚀 Deployments
*Manage replicated, versioned pod sets.*

```bash
kubectl create deployment myapp --image=myapp:1.0  # Create Deployment
kubectl create deployment myapp --image=myapp:1.0 --replicas=3  # With replicas

kubectl get deployments  # List Deployments
kubectl describe deployment myapp  # Show Deployment details
kubectl rollout status deployment/myapp  # Check rollout progress

kubectl set image deployment/myapp myapp=myapp:2.0  # Update image
## Triggers rolling update to new version

kubectl rollout history deployment/myapp  # Show revision history
kubectl rollout undo deployment/myapp  # Rollback to previous revision
kubectl rollout undo deployment/myapp --to-revision=2  # Rollback to specific revision

kubectl scale deployment myapp --replicas=5  # Change replica count
## Manual scaling; autoscaling uses HPA

kubectl delete deployment myapp  # Delete Deployment (also deletes pods)
```

## Deployment manifest
[Declarative pod management with rolling updates and history]

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  labels:
    app: myapp
spec:
  replicas: 3  # Desired number of pods
  strategy:
    type: RollingUpdate  # Recreate alternative (delete then create)
    rollingUpdate:
      maxUnavailable: 1  # Max pods unavailable during update
      maxSurge: 1  # Max extra pods during update
  selector:
    matchLabels:
      app: myapp  # Pods must match this label
  template:  # Pod template
    metadata:
      labels:
        app: myapp
        version: "1.0"
    spec:
      containers:
        - name: app
          image: myapp:1.0
          ports:
            - containerPort: 3000
          env:
            - name: APP_ENV
              value: "prod"
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

---

## ⚙️ Services
*Expose pods with stable IP and DNS name.*

```bash
kubectl expose deployment myapp --type=ClusterIP --port=80 --target-port=3000  # Create Service
kubectl get services  # List Services
kubectl describe service myapp  # Show Service details

kubectl port-forward service/myapp 8080:80  # Forward local port to service
## Useful for testing without exposing service externally
```

## Service types
[ClusterIP (internal), NodePort (node port), LoadBalancer (cloud), ExternalName (DNS)]

```yaml
---
# ClusterIP: internal cluster communication
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: ClusterIP  # Default type
  selector:
    app: myapp  # Select pods by label
  ports:
    - name: http
      port: 80  # Service port
      targetPort: 3000  # Pod port
      protocol: TCP

---
# NodePort: accessible on node IPs
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 3000
      nodePort: 30080  # Port on all nodes (30000-32767)

---
# LoadBalancer: cloud load balancer
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 3000

---
# ExternalName: DNS alias
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.example.com  # External hostname
```

---

## 🔑 ConfigMaps & Secrets
*Manage application configuration and sensitive data.*

```bash
# ConfigMap
kubectl create configmap app-config --from-literal=APP_ENV=prod --from-literal=LOG_LEVEL=info
## Key-value pairs from CLI

kubectl create configmap app-config --from-file=config.yaml
## Load entire file as single value

kubectl get configmaps  # List ConfigMaps
kubectl describe configmap app-config  # Show contents
kubectl delete configmap app-config  # Remove ConfigMap

# Secret
kubectl create secret generic db-secret --from-literal=password=secret123
## Generic secret stores arbitrary data

kubectl create secret docker-registry docker-creds --docker-server=registry.com --docker-username=user --docker-password=pass
## Docker registry credentials for image pull

kubectl get secrets  # List Secrets
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d  # Decode secret value
```

## ConfigMap manifest
[For non-sensitive configuration; readable in etcd]

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  nginx.conf: |  # Multiline config file
    server {
      listen 80;
      server_name _;
    }
```

## Secret manifest
[For sensitive data; base64 encoded (not encrypted by default)]

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque  # generic key-value; also docker-registry, tls, service-account-token
data:
  username: dXNlcg==  # Base64 encoded "user"
  password: cGFzc3dvcmQxMjM=  # Base64 encoded "password123"
```

## Using ConfigMap and Secret in pods
[Mount as files or environment variables]

```yaml
spec:
  containers:
    - name: app
      env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_ENV
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
      volumeMounts:
        - name: config
          mountPath: /etc/config  # Mount ConfigMap as files
  volumes:
    - name: config
      configMap:
        name: app-config
```

---

## 📍 Namespaces
*Isolate resources and projects within cluster.*

```bash
kubectl get namespaces  # List namespaces
kubectl create namespace prod  # Create new namespace
kubectl get pods -n prod  # List pods in specific namespace
kubectl get pods --all-namespaces  # Pods in all namespaces

kubectl config set-context --current --namespace=prod  # Set default namespace
## Avoid --namespace flag for every command

kubectl delete namespace prod  # Delete namespace (also deletes resources)
```

## Namespace manifest
[Resource isolation and quota management]

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod
```

## ResourceQuota
[Limit total resource usage per namespace]

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: prod
spec:
  hard:
    requests.cpu: "10"  # Total CPU requests
    requests.memory: "20Gi"  # Total memory requests
    limits.cpu: "20"  # Total CPU limits
    limits.memory: "40Gi"  # Total memory limits
    pods: "100"  # Max pods
    services: "10"
```

---

## 📋 Logs & Debug
*Troubleshoot pod and cluster issues.*

```bash
kubectl logs deployment/myapp  # Logs from all pods in Deployment
kubectl logs -f pod/myapp  # Follow logs

kubectl debug pod/myapp -it --image=busybox  # Debug container with different image
kubectl debug node/worker-1 -it --image=ubuntu  # Debug node

kubectl describe node worker-1  # Node resources and conditions
kubectl top node  # Node resource usage
kubectl top pod  # Pod resource usage
kubectl top pod --sort-by=memory  # Sort by memory consumption

kubectl get events -A  # Cluster events (pod creation, failures, etc.)
kubectl get events --sort-by='.lastTimestamp'  # Events sorted by time

kubectl apply -f deployment.yaml --dry-run=client -o yaml  # Preview without applying
## Useful for validating manifests before deployment
```

---

## 🔄 Scaling
*Adjust pod replica counts and autoscaling.*

```bash
kubectl scale deployment myapp --replicas=5  # Manual scaling
## Useful for quick adjustments; use HPA for automatic

kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=80
## Auto-scaling based on CPU usage

kubectl get hpa  # List HorizontalPodAutoscalers
kubectl describe hpa myapp  # Show HPA metrics and status
```

## HorizontalPodAutoscaler manifest
[Automatically adjust replicas based on metrics]

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80  # Scale up at 80% CPU
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 85  # Scale up at 85% memory
```

---

## 🔐 RBAC
*Manage access control and permissions.*

```bash
kubectl auth can-i get pods  # Check own permissions
kubectl auth can-i get pods --as=user@example.com  # Check user permissions
## Useful for debugging access denied errors

kubectl get roles  # List roles in current namespace
kubectl get rolebindings  # List role bindings

kubectl get clusterroles  # Cluster-wide roles
kubectl get clusterrolebindings  # Cluster-wide role bindings
```

## Role manifest
[Namespace-scoped permissions]

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups: [""]  # Core API group
    resources: ["pods"]
    verbs: ["get", "list", "watch"]  # Actions allowed
  - apiGroups: [""]
    resources: ["pods/logs"]
    verbs: ["get"]
```

## RoleBinding manifest
[Grant role to user/service account]

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
  - kind: User
    name: user@example.com
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## 🌐 Ingress
*Route external traffic to services.*

```bash
kubectl get ingress  # List Ingress resources
kubectl describe ingress myapp  # Show Ingress configuration
```

## Ingress manifest
[HTTP/HTTPS routing rules]

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  ingressClassName: nginx  # Ingress controller (nginx, traefik, etc.)
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
    - host: api.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 3000
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls  # TLS certificate secret
```

---

## 📦 Helm Basics
*Package manager for Kubernetes.*

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami  # Add chart repository
helm repo update  # Fetch latest chart metadata

helm search repo mysql  # Search for charts
helm show values bitnami/mysql  # Show configurable values

helm install my-db bitnami/mysql  # Install chart release
helm install my-db bitnami/mysql -f values.yaml  # With custom values

helm list  # List installed releases
helm status my-db  # Show release status

helm upgrade my-db bitnami/mysql  # Upgrade to new version
helm rollback my-db 1  # Rollback to previous release

helm uninstall my-db  # Remove release
```

## Chart structure
[Reusable Kubernetes application templates]

```
mychart/
├── Chart.yaml  # Chart metadata (name, version, dependencies)
├── values.yaml  # Default configuration values
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl  # Template helpers
└── charts/  # Subchart dependencies
```

---

## 📝 Manifest Management
*Work with YAML files effectively.*

```bash
kubectl apply -f deployment.yaml  # Create or update resource
## Declarative; compares with current state

kubectl apply -f .  # Apply all YAMLs in directory
kubectl apply -f deployment.yaml --dry-run=client  # Preview changes without applying

kubectl get deployment myapp -o yaml  # Export resource as YAML
kubectl diff -f deployment.yaml  # Show differences before applying

kubectl delete -f deployment.yaml  # Delete resource from file
kubectl delete deployment myapp  # Delete by name

kubectl replace -f deployment.yaml  # Replace entire resource
## Destructive; use apply instead for safer updates
```

## Multi-file application
[Organize related resources together]

```bash
# Directory structure
manifests/
├── deployment.yaml
├── service.yaml
├── configmap.yaml
└── namespace.yaml

kubectl apply -f manifests/  # Apply all at once
```
