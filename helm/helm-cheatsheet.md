# 🛠 Helm — Cheat Sheet
*Package manager for Kubernetes that streamlines chart versioning, installation, and rollback.*

---

## 📦 Repo Management
*Add, update, and manage Helm chart repositories.*

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami  # Add new repository
## Use --force-update to overwrite existing repo with same name

helm repo list  # List all configured repositories
## Shows repo name, URL, and update status

helm repo update  # Fetch latest chart metadata from all repos
## Run before install/upgrade to ensure latest versions available

helm repo remove bitnami  # Remove a repository
## Safe operation — doesn't affect installed releases

helm search repo mysql  # Search for charts in repositories
## Use -l to list all versions available

helm search repo mysql --versions  # Show all versions of a chart
## Useful for pinning specific versions in deployments
```

---

## 📥 Install & Upgrade
*Install new charts and upgrade existing releases.*

```bash
helm install my-release bitnami/mysql  # Install chart with release name
## Creates release in default namespace; use -n to specify different namespace

helm install my-release bitnami/mysql -f values.yaml  # Install with custom values file
## Values in file override chart defaults

helm install my-release bitnami/mysql --set key=value  # Override values via CLI
## Use --set-string for string values that might be interpreted as numbers

helm install my-release bitnami/mysql --namespace prod --create-namespace  # Create namespace if needed
## --create-namespace is available in Helm 3.2+

helm upgrade my-release bitnami/mysql  # Upgrade existing release
## If chart doesn't exist, use --install to create if missing

helm upgrade my-release bitnami/mysql -f values.yaml  # Upgrade with new values
## Previous values persist unless explicitly overridden

helm upgrade my-release bitnami/mysql --values values1.yaml --values values2.yaml  # Multiple values files
## Later files override earlier ones

helm get values my-release  # Show values used in current release
## See what's actually deployed, not just the defaults
```

---

## ↩️ Rollback & Uninstall
*Manage release history and remove deployments.*

```bash
helm history my-release  # Show all release revisions
## Lists revision number, app version, chart version, status

helm rollback my-release 2  # Rollback to specific revision
## New revision created; original revision not modified

helm rollback my-release  # Rollback to previous revision
## Useful for quick fixes after bad upgrade

helm uninstall my-release  # Delete a release
## Removes all associated resources; release history kept by default

helm uninstall my-release --keep-history  # Uninstall but keep release history
## Allows rollback even after uninstall

helm delete my-release  # Alias for uninstall (older Helm versions)
## In Helm 3, use 'uninstall' instead
```

---

## 🔍 Chart Inspection
*Examine chart structure and documentation.*

```bash
helm show chart bitnami/mysql  # Display chart metadata
## Shows apiVersion, appVersion, dependencies, description

helm show values bitnami/mysql  # Show all available values with defaults
## Essential for understanding configuration options

helm show readme bitnami/mysql  # Display chart's README
## Often contains important setup instructions

helm show all bitnami/mysql  # Combine chart, values, and readme
## Quick overview of everything a chart provides

helm fetch bitnami/mysql --untar  # Download and extract chart locally
## Useful for customizing chart or inspecting file structure

helm lint ./my-chart  # Validate chart syntax and structure
## Catches common mistakes before publishing
```

---

## 🎯 Values & Overrides
*Manage configuration for charts.*

```bash
helm get values my-release  # Show values from deployed release
## See what's currently in use

helm get values my-release -o yaml  # Output in YAML format
## Easier to read and edit

helm upgrade my-release bitnami/mysql --reuse-values  # Keep previous values
## Useful when only upgrading chart version

helm upgrade my-release bitnami/mysql --reset-values  # Reset to defaults
## Dangerous — use only when intentionally resetting config

helm install my-release bitnami/mysql --set-string image.tag=8.0.29  # Set string value
## --set-string prevents numeric strings from being interpreted as numbers

helm install my-release bitnami/mysql --set persistence.enabled=true --set persistence.size=50Gi  # Multiple overrides
## Chain --set flags for multiple values
```

---

## 🔨 Templating & Debugging
*Preview and troubleshoot chart rendering.*

```bash
helm template my-release bitnami/mysql  # Render chart templates locally
## Shows what YAML will be applied without connecting to cluster

helm template my-release bitnami/mysql -f values.yaml  # Render with custom values
## Useful for testing values before installation

helm template my-release bitnami/mysql --debug  # Enable debug output
## Shows additional diagnostic information

helm get manifest my-release  # Show actual rendered manifests in cluster
## Compares what was deployed vs what template generates

helm diff upgrade my-release bitnami/mysql  # Preview upgrade changes
## Requires helm-diff plugin; shows exact YAML diff

helm install my-release bitnami/mysql --dry-run --debug  # Test install without deploying
## Perfect for catching issues before actual deployment
```

---

## 🔐 Helm Secrets
*Manage sensitive data in Helm charts.*

```bash
helm secrets enc values-prod.yaml  # Encrypt values file
## Requires helm-secrets plugin; protects sensitive data

helm secrets dec values-prod.yaml  # Decrypt values file for viewing
## Use carefully; unencrypts to stdout

helm install my-release ./chart -f secrets://values-prod.yaml  # Use encrypted values in install
## Plugin automatically decrypts during deployment

helm secrets view values-prod.yaml  # View encrypted file without decrypting to disk
## Safer than dec for quick viewing

helm plugin install https://github.com/jkroepke/helm-secrets  # Install secrets plugin
## Enables encryption/decryption of values files
```

---

## 🐳 OCI Registries
*Work with Helm charts stored in OCI registries.*

```bash
helm registry login registry.example.com  # Login to OCI registry
## Required for private registries

helm push ./my-chart oci://registry.example.com/charts  # Push chart to OCI registry
## Requires chart to be packaged; pushes to OCI instead of Helm repo

helm install my-release oci://registry.example.com/charts/mysql  # Install from OCI registry
## Works like regular Helm repo but uses OCI protocol

helm pull oci://registry.example.com/charts/mysql  # Pull chart from OCI registry
## Downloads chart locally for inspection

helm search repo registry.example.com/charts  # Search OCI registry
## Lists available charts in registry (if registry supports it)

helm package ./my-chart  # Package chart into tar.gz
## Creates versioned artifact ready for pushing
```

---

## 📋 Common Operations
*Frequently used Helm commands.*

```bash
helm list  # List all releases in current namespace
## Use -A for all namespaces, -n for specific namespace

helm list --all-namespaces  # List releases across all namespaces
## Useful for getting complete deployment picture

helm status my-release  # Check release status
## Shows deployment status and notes

helm test my-release  # Run chart's test suite
## Some charts include tests for validation

helm get all my-release  # Show complete release information
## Combines values, manifest, hooks, and notes
```
