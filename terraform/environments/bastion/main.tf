terraform {
  required_version = ">= 1.12.1"
}

module "libvirt-vms" {
  source = "../../modules/libvirt-vms"

  prefix            = "bastion"
  worker_data0_size = 320
  controller_vcpu   = 2
  worker_vcpu       = 2
  worker_memory     = 10
}
