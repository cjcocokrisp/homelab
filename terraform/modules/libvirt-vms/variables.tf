variable "prefix" {
  description = "a prefix for components to have"
  type        = string
  default     = "cluster_node_default"
}

variable "host_bridge_interface" {
  description = "Host bridge interface connected to LAN"
  type        = string
  default     = "br0"
}

# variable "cluster_node_domain" {
#  description = "the DNS domain of the cluster nodes"
#  type        = string
#  default     = "cluster.cjcocokrisp.lan"
# }

# variable "cluster_node_network" {
#  description = "the IP network of the cluster nodes"
#  type        = string
#  default     = "192.168.0.0/24"
# }

variable "controller_count" {
  description = "amount of control nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.controller_count >= 1
    error_message = "you must have more then one control node"
  }
}

variable "worker_count" {
  description = "amount of worker nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.worker_count >= 1
    error_message = "you must have more then one worker node"
  }
}

variable "worker_data0_size" {
  description = "amount of size in GB you want the worker data volumes to be"
  type        = number
  default     = 50
  validation {
    condition     = var.worker_data0_size >= 1
    error_message = "you must have the volume be greater then 1 GB"
  }
}

variable "talos_libvirt_base_volume_name" {
  description = "base_name of the libvirt drive"
  type        = string
  default     = "talos.qcow2"
  validation {
    condition     = can(regex(".\\.qcow2+$", var.talos_libvirt_base_volume_name))
    error_message = "Must be a name with the .qcow2 extension"
  }
}

variable "controller_vcpu" {
  description = "Amount of vCPUs to have for one controller VM"
  type        = number
  default     = 4
  validation {
    condition     = var.controller_vcpu >= 1
    error_message = "Must be greater then 1"
  }
}

variable "controller_memory" {
  description = "Amount in GB of memory to give to one controller VM"
  type        = number
  default     = 4
  validation {
    condition     = var.controller_memory >= 1
    error_message = "Must be greater then 1"
  }
}

variable "worker_vcpu" {
  description = "Amount of vCPUs to have for one worker VM"
  type        = number
  default     = 4
  validation {
    condition     = var.worker_vcpu >= 1
    error_message = "Must be greater then 1"
  }
}

variable "worker_memory" {
  description = "Amount in GB of memory to give to one worker VM"
  type        = number
  default     = 4
  validation {
    condition     = var.worker_memory >= 1
    error_message = "Must be greater then 1"
  }
}
