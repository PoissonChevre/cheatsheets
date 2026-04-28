# 🌍 Terraform + Incus — Cheat Sheet
*Terraform provider for managing Incus containers and virtual machines.*

---

## 🔌 Provider Setup & Authentication
*Configure the Incus provider and authentication credentials.*

```hcl
terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"  # Official Incus provider
      version = "~> 0.1"
    }
  }
}

provider "incus" {
  remote = "local"  # Remote name (from lxc remote list)
  accept_remote_certificate = true  # Accept self-signed certs
}

# Multiple remotes
provider "incus" {
  alias  = "prod"  # Provider alias for multiple remotes
  remote = "prod-server"
}

provider "incus" {
  alias  = "dev"
  remote = "dev-server"
}

# Use provider
resource "incus_instance" "prod" {
  provider = incus.prod  # Use prod remote
  # ...
}
```

---

## 🐳 incus_instance (Container & VM)
*Create and manage Incus containers and virtual machines.*

```hcl
# Create a container
resource "incus_instance" "web" {
  name      = "web-server"  # Container name
  image     = "images:ubuntu/22.04"  # Base image
  type      = "container"  # Type: container or virtual-machine
  ephemeral = false  # Persistent instance

  profiles = ["default"]  # Apply profiles
  
  config = {
    "limits.cpu"    = "2"  # CPU cores
    "limits.memory" = "2GB"  # Memory limit
    "user.data"     = "#!/bin/bash\napt-get update"  # Cloud-init user data
  }

  device {
    name = "eth0"  # Device name
    type = "nic"  # Device type
    properties = {
      nictype = "bridged"  # Bridged network
      parent  = "lxdbr0"  # Parent network
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"  # Mount point
      pool = "default"  # Storage pool
    }
  }
}

# Create a virtual machine
resource "incus_instance" "vm" {
  name  = "ubuntu-vm"
  image = "images:ubuntu/22.04"
  type  = "virtual-machine"  # VM instead of container
  
  config = {
    "limits.cpu"    = "4"
    "limits.memory" = "8GB"
  }
}

# Instance with provisioner
resource "incus_instance" "app" {
  name  = "app-server"
  image = "images:ubuntu/22.04"
  
  provisioner "file" {
    source      = "app.conf"  # Local file
    destination = "/tmp/app.conf"  # Remote path
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app.conf /etc/app.conf",  # Run commands
      "sudo systemctl restart app"
    ]
  }
}
```

---

## 🌐 incus_network
*Create and configure Incus networks.*

```hcl
# Create a managed bridge network
resource "incus_network" "custom" {
  name = "custom-net"  # Network name
  type = "bridge"  # Network type

  config = {
    "ipv4.address"   = "10.0.100.1/24"  # IPv4 subnet
    "ipv4.nat"       = "true"  # Enable NAT
    "ipv6.address"   = "fd00:100::1/64"  # IPv6 subnet
    "ipv6.nat"       = "true"  # Enable NAT for IPv6
    "dns.mode"       = "managed"  # DNS mode
    "dns.domain"     = "example.com"  # DNS domain
  }
}

# Attach instance to network
resource "incus_instance" "web" {
  name  = "web"
  image = "images:ubuntu/22.04"
  
  device {
    name = "custom-eth0"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = incus_network.custom.name  # Reference network
      ipv4.address = "10.0.100.50"  # Static IP
    }
  }
}
```

---

## 💾 incus_storage_pool & incus_volume
*Create storage pools and manage volumes.*

```hcl
# Create storage pool
resource "incus_storage_pool" "local" {
  name   = "storage-pool"  # Pool name
  driver = "dir"  # Storage driver: dir, lvm, btrfs, zfs, ceph
  
  config = {
    "source" = "/var/lib/incus/storage-pools/custom"  # Pool location
  }
}

# Create storage volume
resource "incus_volume" "data" {
  name  = "data-volume"  # Volume name
  pool  = incus_storage_pool.local.name  # Pool reference
  type  = "custom"  # Volume type
  size  = "50GB"  # Volume size
  
  config = {
    "size" = "50GB"
  }
}

# Attach volume to instance
resource "incus_instance" "app" {
  name  = "app"
  image = "images:ubuntu/22.04"
  
  device {
    name = "data"
    type = "disk"
    properties = {
      source = incus_volume.data.name  # Volume reference
      path   = "/data"  # Mount point
    }
  }
}

# Snapshot storage volume
resource "incus_volume_snapshot" "backup" {
  name             = "backup-$(formatdate("YYYY-MM-DD", timestamp()))"  # Snapshot name with date
  volume_name      = incus_volume.data.name
  pool             = incus_storage_pool.local.name
  expiration_date  = "2026-12-31T00:00:00Z"  # Expiration date
}
```

---

## 👤 incus_profile
*Create and manage instance profiles.*

```hcl
# Create a profile
resource "incus_profile" "web" {
  name = "web-profile"  # Profile name
  
  config = {
    "limits.cpu"    = "2"  # CPU limits
    "limits.memory" = "2GB"  # Memory limits
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = "lxdbr0"  # Default bridge
    }
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "default"
    }
  }
}

# Create a GPU profile
resource "incus_profile" "gpu" {
  name = "gpu-profile"
  
  device {
    name = "gpu"
    type = "gpu"  # GPU device
    properties = {
      productid = "2489"  # GPU product ID
      vendorid  = "10de"  # GPU vendor ID (NVIDIA)
    }
  }
}

# Apply profile to instance
resource "incus_instance" "compute" {
  name     = "gpu-compute"
  image    = "images:ubuntu/22.04"
  profiles = ["default", incus_profile.gpu.name]  # Multiple profiles
}
```

---

## 🌍 Remote Management
*Manage instances across multiple remote Incus servers.*

```hcl
# Multiple remotes in configuration
provider "incus" {
  alias  = "local"
  remote = "local"
}

provider "incus" {
  alias  = "remote1"
  remote = "server1"
}

provider "incus" {
  alias  = "remote2"
  remote = "server2"
}

# Create resources on different remotes
resource "incus_instance" "local_instance" {
  provider = incus.local
  name     = "local-web"
  image    = "images:ubuntu/22.04"
}

resource "incus_instance" "remote1_instance" {
  provider = incus.remote1
  name     = "remote1-web"
  image    = "images:ubuntu/22.04"
}

# Configure remote access
resource "incus_instance" "remote_access" {
  provider = incus.remote2
  name     = "accessible"
  image    = "images:ubuntu/22.04"
  
  config = {
    "raw.lxc" = "lxc.net.0.type=none"  # Custom LXC config for remote
  }
}

# Variable for remote selection
variable "deployment_target" {
  type    = string
  default = "local"  # Options: local, remote1, remote2
}

locals {
  provider_alias = var.deployment_target  # Map variable to provider
}

resource "incus_instance" "dynamic" {
  provider = incus.local  # Would need dynamic provider selection
  name     = "app"
  image    = "images:ubuntu/22.04"
}
```

---

## 📋 Full Examples
*Complete working examples for common scenarios.*

```hcl
# Example 1: Create a web server container with custom network and storage
resource "incus_network" "app_net" {
  name = "app-network"
  type = "bridge"
  
  config = {
    "ipv4.address" = "10.50.0.1/24"
    "ipv4.nat"     = "true"
  }
}

resource "incus_storage_pool" "app_storage" {
  name   = "app-pool"
  driver = "dir"
  
  config = {
    "source" = "/var/lib/incus/storage-pools/app"
  }
}

resource "incus_volume" "app_data" {
  name = "app-data"
  pool = incus_storage_pool.app_storage.name
  size = "100GB"
}

resource "incus_instance" "webserver" {
  name  = "webserver"
  image = "images:ubuntu/22.04"
  
  config = {
    "limits.cpu"    = "2"
    "limits.memory" = "2GB"
    "user.data"     = base64encode(file("${path.module}/cloud-init.yaml"))  # Cloud-init script
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = incus_network.app_net.name
      ipv4.address = "10.50.0.10"
    }
  }

  device {
    name = "data"
    type = "disk"
    properties = {
      source = incus_volume.app_data.name
      path   = "/var/www"
    }
  }
}

# Example 2: Create a high-performance VM with profile
resource "incus_profile" "vm_performance" {
  name = "vm-perf"
  
  config = {
    "limits.cpu"      = "4"
    "limits.memory"   = "8GB"
    "limits.disk"     = "100GB"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = "lxdbr0"
    }
  }
}

resource "incus_instance" "database_vm" {
  name     = "postgresql-db"
  image    = "images:ubuntu/22.04"
  type     = "virtual-machine"  # VM instead of container
  profiles = ["vm_performance"]
  
  config = {
    "user.data" = <<-EOT
      #cloud-config
      packages:
        - postgresql-14
      runcmd:
        - systemctl enable postgresql
        - systemctl start postgresql
    EOT
  }
}

# Example 3: Multi-instance deployment with load balancing
resource "incus_instance" "web_cluster" {
  for_each = toset(["web1", "web2", "web3"])  # Create 3 instances
  
  name  = each.value
  image = "images:ubuntu/22.04"
  
  config = {
    "limits.cpu"    = "1"
    "limits.memory" = "1GB"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      nictype = "bridged"
      parent  = "lxdbr0"
    }
  }
}

output "web_cluster_ips" {
  value = {
    for instance in incus_instance.web_cluster : instance.name => instance.ip_address
  }
}
```

## Useful Patterns
*Common Terraform patterns for Incus management.*

```hcl
# Conditional instance creation
variable "enable_monitoring" {
  type    = bool
  default = true
}

resource "incus_instance" "monitoring" {
  count = var.enable_monitoring ? 1 : 0  # Create only if enabled
  
  name  = "prometheus"
  image = "images:ubuntu/22.04"
}

# Instance templating with variables
variable "instances" {
  type = list(object({
    name   = string
    cpu    = number
    memory = string
  }))
}

resource "incus_instance" "templated" {
  for_each = { for inst in var.instances : inst.name => inst }
  
  name = each.value.name
  
  config = {
    "limits.cpu"    = tostring(each.value.cpu)
    "limits.memory" = each.value.memory
  }
}

# Data source to reference existing instances
data "incus_instance" "existing" {
  name = "my-existing-instance"  # Query existing instance
}

output "existing_instance_ip" {
  value = data.incus_instance.existing.ip_address
}
```
