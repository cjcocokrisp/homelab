terraform {
  required_version = ">= 1.12.1"
}

module "libvirt-vms" {
  source            = "../../modules/libvirt-vms"
  prefix            = "beacon"
  worker_data0_size = 900
  controller_count  = 0
  worker_vcpu       = 8
  worker_memory     = 6
}

module "talos-config" {
  source           = "../../modules/talos-config"
  prefix           = module.libvirt-vms.prefix
  cluster_name     = "regatta"
  worker_ips       = module.libvirt-vms.worker_vm_ips
  cluster_ip       = 192.168.0.240
  cluster_endpoint = "https://192.168.0.240:6443"
  depends_on = [
    module.libvirt-vms
  ]
}
