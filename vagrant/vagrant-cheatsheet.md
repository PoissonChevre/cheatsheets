# Vagrant — Cheat Sheet

Infrastructure provisioning and VM management with Vagrant

---

## Installation & Setup

```bash
vagrant --version # Check Vagrant installation and version
vagrant init hashicorp/bionic # Initialize new Vagrantfile with specified box
vagrant box add hashicorp/bionic # Add a box to local storage
vagrant box list # List all downloaded boxes
vagrant box remove hashicorp/bionic # Remove a box from local storage
```

---

## VM Lifecycle

```bash
vagrant up # Create and start VM(s) defined in Vagrantfile
## Runs provisioners if VM is new, otherwise just starts it

vagrant up --provider=libvirt # Specify provider (virtualbox, libvirt, etc)
vagrant status # Check status of VM(s)
vagrant halt # Gracefully shutdown VM(s)
vagrant suspend # Pause VM(s) (preserves memory state)
vagrant resume # Resume suspended VM(s)
vagrant reload # Restart VM(s) and reload Vagrantfile changes
vagrant destroy # Delete VM(s) and cleanup
vagrant destroy -f # Force destroy without confirmation
```

---

## SSH & Access

```bash
vagrant ssh # Connect to VM via SSH
vagrant ssh -c 'command' # Run command on VM without interactive shell
vagrant ssh-config # Display SSH configuration
vagrant port # Display port mappings
```

---

## Vagrantfile Configuration

```ruby
# Basic Vagrantfile structure
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic" # Box to use
  config.vm.hostname = "myvm" # Set VM hostname
  
  # Provider configuration (VirtualBox)
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048 # RAM in MB
    vb.cpus = 2 # Number of CPUs
    vb.name = "my-vm" # VirtualBox display name
  end
  
  # Provider configuration (Libvirt)
  config.vm.provider "libvirt" do |lb|
    lb.memory = 2048
    lb.cpus = 2
  end
  
  # Synced folders (share host directory with VM)
  config.vm.synced_folder ".", "/vagrant" # Default: host current dir to /vagrant
  config.vm.synced_folder "./data", "/data", owner: "vagrant", group: "vagrant"
  ## Use create: true to auto-create target directory
  
  # Shell provisioning
  config.vm.provision "shell" do |s|
    s.inline = "apt-get update && apt-get install -y nginx"
  end
  
  # Ansible provisioning
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
```

---

## Networking

```ruby
# Private network (host-only, accessible only from host)
config.vm.network "private_network", ip: "192.168.33.10"

# Public network (bridged, accessible from external network)
config.vm.network "public_network", ip: "192.168.1.100"
## Prompts for bridge interface on vagrant up

# Forwarded ports
config.vm.network "forwarded_ports", guest: 80, host: 8080
## Maps VM port to host port
config.vm.network "forwarded_ports", guest: 443, host: 8443, protocol: "tcp"
```

---

## Provisioning

```bash
vagrant provision # Run provisioners on running VM
vagrant provision --provision-with shell # Run specific provisioner
```

```ruby
# Shell provisioning (inline)
config.vm.provision "shell", inline: "apt-get update && apt-get install -y curl"

# Shell provisioning (script file)
config.vm.provision "shell", path: "scripts/setup.sh"
## Script runs as root; use 'vagrant' user explicitly if needed

# Ansible provisioning
config.vm.provision "ansible" do |ansible|
  ansible.playbook = "site.yml"
  ansible.inventory_path = "hosts"
  ansible.tags = "deploy"
end
```

---

## Snapshots

```bash
vagrant snapshot save # Save VM state with default name
vagrant snapshot save checkpoint-1 # Save named snapshot
vagrant snapshot list # List all snapshots
vagrant snapshot restore checkpoint-1 # Restore to specific snapshot
vagrant snapshot delete checkpoint-1 # Delete a snapshot
vagrant snapshot delete --all # Delete all snapshots
```

---

## Multi-machine Setup

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "hashicorp/bionic"
    web.vm.network "private_network", ip: "192.168.33.10"
  end
  
  config.vm.define "db" do |db|
    db.vm.box = "hashicorp/bionic"
    db.vm.network "private_network", ip: "192.168.33.11"
  end
end
```

```bash
vagrant up # Start all machines
vagrant up web # Start specific machine
vagrant ssh web # SSH into specific machine
vagrant status # Show status of all machines
```

---

## Plugins

```bash
vagrant plugin list # List installed plugins
vagrant plugin install vagrant-libvirt # Install plugin
vagrant plugin update # Update all plugins
vagrant plugin uninstall vagrant-libvirt # Remove plugin
```

**Useful plugins:**
- `vagrant-libvirt` — KVM/Libvirt provider for Linux hosts
- `vagrant-hostmanager` — Auto-manage /etc/hosts entries
- `vagrant-vbguest` — Auto-sync VirtualBox Guest Additions
- `vagrant-disksize` — Resize disk on box creation
- `vagrant-env` — Load environment variables from .vagrant.env

---

## Troubleshooting

```bash
vagrant up --debug # Run with debug output
vagrant validate # Check Vagrantfile syntax
vagrant global-status # Show all VMs on system
vagrant global-status --prune # Remove stale entries
```

**Common issues:**

- **Network unreachable from host:**
  - Check private_network IP is not in use
  - Verify bridge interface for public_network
  - Check firewall rules on host

- **Synced folders not working:**
  - Verify VirtualBox Guest Additions version matches
  - Use `vagrant-vbguest` plugin to auto-sync
  - Check folder permissions

- **SSH key permission errors:**
  - Private key should have 600 permissions
  - Run `vagrant ssh-config` to verify key path
  - Use `vagrant ssh -c 'command'` if login fails

- **Port already in use:**
  - Change forwarded port in Vagrantfile
  - Kill process using port: `lsof -i :8080` then `kill -9 <PID>`
  - Increment port numbers if multiple VMs use same ports
