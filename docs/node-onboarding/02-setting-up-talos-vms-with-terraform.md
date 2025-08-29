# 02: Setting Up Talos VMs with Terraform

This guide will explain how to set up Talos Linux VMs to act as the Kubernetes nodes.

## Prerequisites

There are none on the node you are setting up! All of the required packages should be installed to the system thanks to bootc along with cloning the homelab repo.

However, on your workstation have talosctl installed. This will be needed to interact with the talos VMs to get information like configs. 

## Step 1: Creating Terraform Environment for Node

The first step to onboarding a new node in the Kubernetes cluster is to create the Terraform environment for the device. To do this create a new directory within `terraform/environments/` based on the name of the device. Inside that directory should be a `main.tf` and `outputs.tf` file. 

The environment should follow this structure:
```hcl
# Example from terraform/environments/bastion/main.tf
terraform {
  required_version = ">= 1.12.1"
}

module "libvirt-vms" {
  source            = "../../modules/libvirt-vms"
  prefix            = "bastion"
  worker_data0_size = 320
  controller_vcpu   = 2
  worker_vcpu       = 2
  worker_memory     = 10
}

module "talos-config" {
  source           = "../../modules/talos-config"
  prefix           = module.libvirt-vms.prefix
  cluster_name     = "regatta"
  controller_ips   = module.libvirt-vms.controller_vm_ips
  worker_ips       = module.libvirt-vms.worker_vm_ips
  cluster_ip       = module.libvirt-vms.controller_vm_ips[0]
  cluster_endpoint = "https://${module.libvirt-vms.controller_vm_ips[0]}:6443"
  depends_on = [
    module.libvirt-vms
  ]
}
```
The two blocks define the libvirt-vms and the configuration for Talos. To see what variables need to be set take a look at each module in the `terraform/modules/`. Figure out settings you need to set for this node. 

It is also recommended to set some outputs for the environment as well. Below is what is recommended. These outputs will let you get the talosconfig later and know the IPs of the VMs without having to go into your router's settings. 
```hcl
output "talosconfig" {
  value     = module.talos-config.talosconfig 
  sensitive = true
}

output "controller_ips" {
  value = module.libvirt-vms.controller_vm_ips
}

output "worker_ips" {
  value = module.libvirt-vms.worker_vm_ips
}

```

## Step 2: Configure VM Bridge with nmstate

To configure the bridge for the VMs to be able to have IP addresses on the LAN, nmstate is used. To apply the bridge with nmstate first cd into the `/usr/share/homelab` directory, this is where the repo has been cloned. 

Run the following command.
```
nmstatectl apply nmstate/vm-bridge.yaml
```
If you get an error about the interface not existing you will need to edit the file. Sometimes the interface will be named something different depending on what was picked up. So to do this copy the `vm-bridge.yaml` file to your home directory, edit it, then run apply with that file. 

## Step 3: Deploying with Terraform

The next step involves deployikng the terraform environment created in step 1. This is done by copying the terraform directory from the homelab repo into your home directory and then cding into the environment and running the following commands.

```bash
terraform init
terraform apply
```

This will take a couple of minutes and after the VMs should be created. To check their IPs you can check the output and it should display when it's finished running.

## Step 4: Getting Kubeconfig & Talosconfig

The next step is to get the talosconfig and kubeconfig if you are doing this on a fresh cluster. To get the talosconfig run the following command in the host machine or through ssh while in the environments directory then create a file with the output.
```bash
terraform output -raw <NAME_OF_TALOSCONFIG_OUTPUT>
```

To get the kubeconfig once you have the talosconfig run the following command:
```
talosctl -n <IP_OF_CONTROL_PLANE> kubeconfig <OUTPUT_PATH> --talosconfig <PATH_TO_TALOS_CONFIG>
```

It is also recommended to set the paths of the files to the environment variables `KUBECONFIG` and `TALOSCONFIG`.

## Step 5: Giving New Node a Label

For new worker nodes, it is recommended to give the node a label. This can be accomplished by doing the following:
```bash
kubectl label nodes <NODE_NAME> <KEY>=<LABEL>
```

I like to use the `machine` label and then have the value be the name of the device. This is just to help with placing certain services on certain nodes.

## Conclusion:

And with that, you have your new node onboarded! More information will be added to this section has the process changes. 

## Improvements to Make

Below are some improvements I want to make to this page and process in general. 

#### Actual Process 

[ ] - Potential automation of terraform and bridge deployments

#### Docs Page

[ ] - Screenshots

