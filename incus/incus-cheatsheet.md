# Incus Cheat Sheet
*Linux container and VM management platform (LXD fork)*

## Instance Management
*Create, start, stop, and manage containers/VMs*

```bash
incus list  # Show all instances
incus list --format=json  # List instances as JSON
incus create image-name instance-name  # Create instance from image
incus start instance-name  # Start instance
incus stop instance-name  # Stop instance gracefully
incus restart instance-name  # Restart instance
incus delete instance-name  # Delete instance
incus delete instance-name --force  # Force delete running instance
incus shell instance-name  # Open interactive shell
incus shell instance-name -- command  # Execute command in instance
incus file push /local/path instance-name/remote/path  # Copy file to instance
incus file pull instance-name/remote/path /local/path  # Copy file from instance
```

## Images
*Manage container/VM images*

```bash
incus image list  # List available images
incus image list images:  # List images from image server
incus image search ubuntu  # Search for image
incus image import image.tar.gz --alias myimage  # Import local image
incus image delete image-name  # Delete image
incus image info image-name  # Show image details
incus image copy images:ubuntu/22.04 --alias ubuntu22  # Copy from remote server
incus publish instance-name --alias custom-image  # Create image from instance
```

## Profiles
*Manage instance profiles for configuration templates*

```bash
incus profile list  # List profiles
incus profile show default  # Show profile configuration
incus profile create myprofile  # Create new profile
incus profile edit myprofile  # Edit profile
incus profile delete myprofile  # Delete profile
incus profile assign instance-name myprofile  # Assign profile to instance
incus launch image-name instance-name -p myprofile  # Launch with profile
incus profile device add myprofile root disk path=/ pool=default  # Add device to profile
```

## Networking
*Configure network interfaces and connectivity*

```bash
incus network list  # List networks
incus network show network-name  # Show network details
incus network create mynet  # Create new network
incus network delete mynet  # Delete network
incus config device add instance-name eth1 nic network=mynet  # Attach network to instance
incus config device remove instance-name eth0  # Remove network device
incus exec instance-name -- ip addr show  # Show instance IP addresses
incus network attach mynet instance-name  # Attach existing network to instance
incus config get instance-name environment.HTTP_PROXY  # Show instance environment
```

## Storage
*Manage storage pools and volumes*

```bash
incus storage list  # List storage pools
incus storage show pool-name  # Show pool details
incus storage create mypool dir source=/mnt/storage  # Create directory pool
incus storage create mypool lvm source=vg-name lvm.vg_name=vg-name  # Create LVM pool
incus storage delete mypool  # Delete pool
incus storage volume list pool-name  # List volumes in pool
incus storage volume create mypool myvolume  # Create volume
incus config device add instance-name data disk pool=mypool source=myvolume path=/mnt/data  # Attach volume
```

## Snapshots
*Create and restore instance snapshots*

```bash
incus snapshot create instance-name snapshot-name  # Create snapshot
incus snapshot list instance-name  # List instance snapshots
incus snapshot delete instance-name snapshot-name  # Delete snapshot
incus snapshot restore instance-name snapshot-name  # Restore from snapshot
incus copy instance-name@snapshot-name new-instance  # Create instance from snapshot
incus snapshot info instance-name snapshot-name  # Show snapshot details
```

## Migration
*Move instances between hosts*

```bash
incus move instance-name --target=remote-host  # Migrate to another host
incus copy instance-name new-name --target=remote-host  # Copy instance to remote
incus remote add remote-name https://host:8443  # Add remote server
incus remote list  # List configured remotes
incus remote remove remote-name  # Remove remote
```
