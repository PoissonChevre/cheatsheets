# Azure CLI Cheat Sheet
*Manage Microsoft Azure resources from the terminal with the `az` command*

## Install & Login
*Install the CLI and select a subscription*

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash  # Install on Debian/Ubuntu
az upgrade  # Update CLI
az login  # Login through the browser
az login --use-device-code  # Login from a headless server
az account list -o table  # List subscriptions
az account set -s "<subscription-name-or-id>"  # Switch subscription
az account show -o table  # Current subscription and tenant
```

## Defaults & Output
*Save typing and format results*

```bash
az config set defaults.location=belgiumcentral defaults.group=labo-rg1  # Default region and RG
az vm list -o table  # Output as table (also: json, tsv, yaml)
az vm list --query "[].{name:name, size:hardwareProfile.vmSize}" -o table  # Filter with JMESPath
az vm show -n vm0 --query id -o tsv  # Get a single value (for scripts)
az find "az vm create"  # Examples for a command
## az interactive  # Shell with autocompletion
```

## Resource Groups
*Containers for resources — deleting the group deletes everything inside*

```bash
az group create -n labo-rg1 -l belgiumcentral  # Create RG
az group list -o table  # List RGs
az resource list -g labo-rg1 -o table  # List resources in RG
az group delete -n labo-rg1 --yes --no-wait  # Delete RG and all its content
```

## Virtual Machines
*Create, size and power-manage VMs*

```bash
az vm create -g labo-rg1 -n vm1 --image Ubuntu2404 --size Standard_D2als_v6 \
  --admin-username renaud --generate-ssh-keys  # Create Linux VM
az vm list -d -o table  # List VMs with power state and IPs
az vm start -g labo-rg1 -n vm1  # Start
az vm deallocate -g labo-rg1 -n vm1  # Stop AND stop billing compute
az vm resize -g labo-rg1 -n vm1 --size Standard_D4als_v6  # Change size
az vm list-ip-addresses -g labo-rg1 -o table  # Public and private IPs
az vm run-command invoke -g labo-rg1 -n vm1 --command-id RunShellScript --scripts "uptime"  # Run command without SSH
## "az vm stop" keeps billing the VM → always use deallocate
```

**Sizes, images and quotas:**
```bash
az vm list-usage -l belgiumcentral -o table  # vCPU quota per family (0 = unusable)
az vm list-skus -l belgiumcentral --size Standard_D2 -o table  # Sizes available in region
az vm image list-skus -l belgiumcentral -p MicrosoftWindowsDesktop -f windows-11 -o table  # Image SKUs
```

## Networking
*VNets, NSGs, public IPs*

```bash
az network vnet create -g labo-rg1 -n vnet1 --address-prefix 10.10.0.0/16 \
  --subnet-name subnet1 --subnet-prefix 10.10.10.0/24  # VNet + subnet
az network nsg create -g labo-rg1 -n nsg1  # Create NSG
az network nsg rule create -g labo-rg1 --nsg-name nsg1 -n allow-ssh --priority 100 \
  --source-address-prefixes $(curl -s ifconfig.me) --destination-port-ranges 22 \
  --access Allow --protocol Tcp  # Allow SSH from my IP only
az network public-ip create -g labo-rg1 -n vm1-ip --sku Standard  # Public IP
az network nic ip-config update -g labo-rg1 --nic-name vm1-nic -n ipconfig1 \
  --public-ip-address vm1-ip  # Attach public IP to a NIC
az network nic list-effective-nsg -g labo-rg1 -n vm1-nic  # Effective NSG rules
```

## Storage
*Accounts, blobs and SAS*

```bash
az storage account create -g labo-rg1 -n stlab$RANDOM --sku Standard_LRS  # Storage account (global unique name)
az storage container create --account-name <sa> -n data --auth-mode login  # Blob container
az storage blob upload --account-name <sa> -c data -f file.txt --auth-mode login  # Upload
az storage blob list --account-name <sa> -c data -o table --auth-mode login  # List blobs
az storage container generate-sas --account-name <sa> -n data --permissions rl \
  --expiry 2026-12-31 --as-user --auth-mode login  # Read/list SAS token (Entra-signed)
## --auth-mode login uses your Entra identity → needs "Storage Blob Data Contributor" role
```

## Identity & Access
*Entra ID users and RBAC*

```bash
az ad user list --query "[].userPrincipalName" -o tsv  # List users
az ad group create --display-name grp-lab --mail-nickname grp-lab  # Create group
az role assignment create --assignee user@tenant.onmicrosoft.com \
  --role "Virtual Machine Contributor" -g labo-rg1  # Grant role on RG
az role assignment list -g labo-rg1 -o table  # Who has access
az vm identity assign -g labo-rg1 -n vm1  # Enable managed identity on VM
```

## Templates (ARM / Bicep)
*Infrastructure as Code*

```bash
az deployment group create -g labo-rg1 --template-file main.bicep  # Deploy Bicep or ARM JSON
az deployment group create -g labo-rg1 --template-file main.bicep \
  --parameters vmCount=2  # Override parameters
az deployment group what-if -g labo-rg1 --template-file main.bicep  # Preview changes
az bicep build --file main.bicep  # Bicep → ARM JSON
az bicep decompile --file template.json  # ARM JSON → Bicep
az group export -n labo-rg1 > export.json  # Export existing resources as template
```

## Monitoring & Cost
*Logs and spending*

```bash
az monitor activity-log list -g labo-rg1 --offset 1d -o table  # Who did what (last 24h)
az consumption usage list --top 10 -o table  # Recent usage and cost
az lock create -n nodelete -g labo-rg1 --lock-type CanNotDelete  # Protect RG from deletion
```

## Troubleshooting
*Common errors*

```bash
# SkuNotAvailable → no capacity in region: try another size or region
# QuotaExceeded   → vCPU quota reached: deallocate VMs or request increase
# AuthorizationFailed → missing RBAC role on the scope
az vm list --debug  # Full HTTP trace of a command
```

## References
- [Azure CLI documentation](https://learn.microsoft.com/cli/azure/)
- [JMESPath queries](https://learn.microsoft.com/cli/azure/query-azure-cli)
- [Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
