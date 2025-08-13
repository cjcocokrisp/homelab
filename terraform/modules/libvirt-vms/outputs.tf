output "prefix" {
  description = "a prefix usable for different components"
  value       = var.prefix
}

output "controller_vm_ips" {
  value = [
    for domain in libvirt_domain.controller :
    domain.network_interface[0].addresses[0]
  ]
  description = "list of IPs for control node VMs"
}

output "worker_vm_ips" {
  value = [
    for domain in libvirt_domain.worker :
    domain.network_interface[0].addresses[0]
  ]
  description = "list of IPs for worker node VMs"
}
