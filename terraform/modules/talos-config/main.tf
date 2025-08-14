terraform {
  required_version = ">= 1.12.1"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}

resource "talos_machine_secrets" "talos" {
  talos_version = "v${var.talos_version}"
}

data "talos_machine_configuration" "controller" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  talos_version      = talos_machine_secrets.talos.talos_version
  kubernetes_version = var.kubernetes_version
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  talos_version      = talos_machine_secrets.talos.talos_version
  kubernetes_version = var.kubernetes_version
}

data "talos_client_configuration" "talos" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [for node in var.controller_ips : node]
}

resource "talos_machine_configuration_apply" "controller" {
  count                       = var.controller_count
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  endpoint                    = var.controller_ips[count.index]
  node                        = var.controller_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.prefix}-cVM${count.index}"
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  count                       = var.worker_count
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  endpoint                    = var.worker_ips[count.index]
  node                        = var.worker_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.prefix}-wVM${count.index}"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = var.controller_ips[0]
  node                 = var.controller_ips[0]
  depends_on = [
    talos_machine_configuration_apply.controller
  ]
}
