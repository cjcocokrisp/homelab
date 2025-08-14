output "talosconfig" {
  value     = data.talos_client_configuration.talos.talos_config
  sensitive = true
}
