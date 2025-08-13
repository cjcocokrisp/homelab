output "prefix" {
  description = "a prefix usable for different components"
  value       = var.prefix
}

output "controller_vm_ips" {
  value = [
    for d in data.external.get_ipv4_controller : d.result.ip
  ]
  description = "list of IPs for control node VMs"
}

output "worker_vm_ips" {
  value = [
    for d in data.external.get_ipv4_worker : d.result.ip
  ]
  description = "list of IPs for worker node VMs"
}
