variable "talos_version" {
  default     = "1.10.6"
  type        = string
  description = "Talos version used"
}

variable "kubernetes_version" {
  default     = "1.33.3"
  type        = string
  description = "The version of Kubernetes to use"
}

variable "cluster_name" {
  default     = "cluster"
  type        = string
  description = "Name of the cluster"
}

variable "cluster_ip" {
  default     = "https://127.0.0.1"
  type        = string
  description = "IP address of the Kubernetes API server should be synced with cluster_endpoint"
}

variable "cluster_endpoint" {
  default     = "https://127.0.0.1:6443"
  type        = string
  description = "IP address of the Kubernetes API server should be synced with cluster_ip"
}

variable "controller_count" {
  default     = 1
  type        = string
  description = "Amount of controllers"
}

variable "worker_count" {
  default     = 1
  type        = string
  description = "Amount of workers"
}

variable "prefix" {
  default     = "cluster"
  type        = string
  description = "prefix for named things"
}

variable "controller_ips" {
  default     = ["127.0.0.1"]
  type        = list(string)
  description = "List of ips of controllers"
}

variable "worker_ips" {
  default     = ["127.0.0.1"]
  type        = list(string)
  description = "List of ips of workers"
}
