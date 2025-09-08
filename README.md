# homelab

Repository of various configuration files and other stuff for my homelab. For years I have wanted to start my own homelab where I self host various services for me to use. My set-up is defintely overkill for my needs but I created it this way to experiment and learn new technologies. 

## Architecture

At the currently moment, my homelab uses Kubernetes where the nodes are running through Talos Linux VMs using libvirt. Those VMs are provisoned through Terraform and hosted on Fedora bootc systems.

Bootc is used to make the host OSes for the lab declarative. Bootc is a technology that I wanted to try out due to it being new and interesting. To flash the bootc systems I use Fedora CoreOS as a base and then have a systemd service switch the system to the bootc image on first boot. With this it lets me easily be ready to provision VMs on the machines that will be apart of the cluster. I also have GitHub action set up to automatically update the bootc image when relevant directories and files are updated. Having this lets bootc auto updates make sure the packages on all the systems are always in sync.

Terraform is used to provision the libvirt vms that run Talos Linux. Talos Linux is a stripped down Linux distribution designed for running Kubernetse. Through the libvirt and Talos providers this is accomplished making creating new nodes easy and declaritive.

Inside the cluster, I use Argo CD for GitOps based deployments of applications. Argo CD lets me easily update manifests for an application I would like to host by automatically syncing with my repo. 

All networking related stuff is handled on a Raspberry Pi. Pihole is used for local-dns which routes everything with the `*.cjcocokrisp.lan` domain to an instance of Nginx Proxy Manager which is running on the Pi. NPM then routes anything that is not specifcally defined to the clusters Nginx Ingress Controller to then be routed to a service in the cluster. For outside of my LAN access, I use Tailscale with the Raspberry Pi as an exit node with routing set up so I can access my local-dns while using Tailscale.  

## Repository Contents

This section describes what each folder contains.

`argocd` - Argo CD manifests including app of apps manifest and various application manifests 

`bootc` - Bootc Containerfile, ignition generator Python script for Fedora Core OS, and related systemd units 

`docs` - Documentation for processes in the homelab

`k8s` - Kubernetes manifests for applications hosted in the cluster

`nmstate` - Nmstate configuration files

`pi` - Various files related to the Raspberry Pi

`terraform` - Terraform files for the homelab

## Hardware

This section will describe the current hardware in the homelab.

### OASLOA Mini PC

CPU: 12th Generation Alder Lake (4 Cores)

RAM: 16 GB

GPU: Integrated

Disk: 512 GB Capacity

[Amazon Link](https://a.co/d/g3CmKBP)

### HP 17.3 Laptop

CPU: Intel Core i5 (8 Cores)

RAM: 8 GB

GPU: Integrated

Disk: 1 TB Capacity

### Raspberry Pi 5

RAM: 8 GB 

Accessories:
- [3D Printed Case](https://www.printables.com/model/742926-raspberry-pi-5-case) (STL Files in `pi` directory)
- [Active Cooler](https://a.co/d/1FEPwjf)

### TP Link AX1800 Router

[Amazon Link](https://a.co/d/27WME6d)

## Diagram

Below is a diagram of the architecture of my homelab. It also shows what services are running on what nodes for some insight on what services are running in my cluster. 

![Homelab Diagram](docs/diagram.png)