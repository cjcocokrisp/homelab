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
