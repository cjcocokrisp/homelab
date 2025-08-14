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
