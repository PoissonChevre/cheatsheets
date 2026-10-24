# Vagrant — Cheat Sheet

Vagrant creates and manages virtual machines from one file, the `Vagrantfile`. Everybody in the team gets the same environment: `vagrant up` reads the file and builds the VMs.

![Vagrant workflow](./images/vagrant1.png)

Example lab with 2 VMs: [templates/Vagrantfile](./templates/Vagrantfile)

---

## Installation & Setup

```bash
vagrant --version # Check Vagrant installation and version
vagrant init bento/ubuntu-24.04 # Initialize new Vagrantfile with specified box
vagrant box add bento/ubuntu-24.04 # Add a box to local storage
vagrant box list # List all downloaded boxes
vagrant box remove bento/ubuntu-24.04 # Remove a box from local storage
```

---

## VM Lifecycle

![Vagrant commands](./images/vagrant2.png)

```bash
vagrant up  # Create and start VMs (provisioning runs only the first time)

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

![Vagrantfile](./images/vagrant3.png)

```ruby
# Basic Vagrantfile structure
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04" # Box to use
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
  # Use create: true to auto-create target directory

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

## Boxes

A box is a VM image for Vagrant. You can find boxes on the [HashiCorp Vagrant registry](https://portal.cloud.hashicorp.com/vagrant/discover) and download them with:

```bash
vagrant box add <box-name>
```

Each box works only with some providers. Check that the box is compatible with your provider (VirtualBox, libvirt/KVM, Hyper-V, VMware).

### The HCP Vagrant registry is closing

HashiCorp will stop HCP Vagrant, the public registry of boxes (the old name was Vagrant Cloud). Short box names like `bento/ubuntu-24.04` are downloaded from this registry. When it closes, Vagrantfiles that use these names will not work anymore. The Vagrant command line tool will continue to work.

| Step | Date |
|---|---|
| No more new boxes | December 14, 2026 |
| End of support | March 15, 2027 |
| Registry closed, boxes deleted | June 7, 2027 |

Source: [HCP Vagrant deprecation notice](https://developer.hashicorp.com/hcp/docs/vagrant/hcp-vagrant-eol)

**Solution:** save a copy of your boxes and host them yourself (shared folder, web server, S3 bucket).

```bash
# List the boxes on your computer
vagrant box list

# Save a box in a .box file
vagrant box repackage <box-name> <provider> <version>

# Add the box again later, from a file or a URL
vagrant box add my-box ./package.box
```

In the `Vagrantfile`, use your own box:

```ruby
config.vm.box = "my-box"
config.vm.box_url = "https://my-server/boxes/package.box"
```

---

## Networking

```ruby
# Private network (host-only, accessible only from host)
config.vm.network "private_network", ip: "192.168.33.10"

# Public network (bridged, accessible from external network)
config.vm.network "public_network", ip: "192.168.1.100"
# Prompts for bridge interface on vagrant up

# Forwarded ports
config.vm.network "forwarded_port", guest: 80, host: 8080
config.vm.network "forwarded_port", guest: 443, host: 8443, protocol: "tcp"
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
# Script runs as root; use 'vagrant' user explicitly if needed

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
    web.vm.box = "bento/ubuntu-24.04"
    web.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.define "db" do |db|
    db.vm.box = "bento/ubuntu-24.04"
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

---

## Pitfalls

- The HCP Vagrant box registry closes in 2027: keep a local copy of your boxes (`vagrant box repackage`).
- The box must support your provider (`bento/*` boxes have no libvirt version).
- Provisioning runs only at the first `vagrant up`: then `vagrant provision` or `vagrant reload --provision`.
- `vagrant destroy` deletes the VM disks. Files in the synced folder stay on the host.
- The option is `forwarded_port` (singular).
- VirtualBox host-only networks use 192.168.56.0/21 by default.
- VMs created with one provider can't be started with another: destroy first.

---

## Resources

**Official**  

- [HashiCorp tutorials](https://developer.hashicorp.com/vagrant/tutorials)
- [Vagrant on GitHub](https://github.com/hashicorp/vagrant)
- [Cheat sheet](https://gist.github.com/wpscholar/a49594e2e2b918f4d0c4)

**Tutorials (English)**  

- [devopscube — Vagrant tutorial for beginners](https://devopscube.com/vagrant-tutorial-beginners/)
- [Installation, setup and cheat sheet](https://learningdevops.hashnode.dev/chapter-3-about-vagrant-installation-and-setup-vagrant-cheat-sheet)
- [Vagrant libvirt plugin for KVM on Ubuntu](https://www.youtube.com/watch?v=PywnhhboKyQ) (video)

**Tutorials (French)**  

- [Stéphane Robert — Maîtriser Vagrant](https://blog.stephane-robert.info/docs/infra-as-code/provisionnement/vagrant/introduction/)
- [Eazytraining — Full Vagrant course for DevOps](https://www.youtube.com/watch?v=z4209uoIbmk) (video) · [labs](https://github.com/eazytrainingfr/vagrant-for-devops)
- [Xavki — Vagrant K8s series](https://www.youtube.com/watch?v=2P8jQIN5hr0) (video) · [code](https://gitlab.com/vagrant3/vagrant-k8s)

**Examples**  

- [DevOps Journey — Vagrant labs](https://github.com/devopsjourney1/vagrant-labs)
- [Vagrantfile examples](https://github.com/patrickdlee/vagrant-examples)
