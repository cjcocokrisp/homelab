terraform {
  required_version = ">= 1.12.1"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "controller" {
  count            = var.controller_count
  name             = "${var.prefix}_c${count.index}.img"
  base_volume_name = var.talos_libvirt_base_volume_name
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB 
}

resource "libvirt_volume" "worker" {
  count            = var.worker_count
  name             = "${var.prefix}_w${count.index}.img"
  base_volume_name = var.talos_libvirt_base_volume_name
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_data0" {
  count  = var.worker_count
  name   = "${var.prefix}_c${count.index}.img"
  format = "qcow2"
  size   = var.worker_data0_size * 1024 * 1024 * 1024 # User set size in GB
}

resource "libvirt_domain" "controller" {
  count      = var.controller_count
  name       = "${var.prefix}_cVM${count.index}"
  qemu_agent = false
  machine    = "q35"
  firmware   = "/usr/share/OVMF/OVMF_CODE.fd"
  cpu {
    mode = "host-passthrough"
  }
  vcpu   = var.controller_vcpu
  memory = var.controller_memory * 1024
  video {
    type = "qxl"
  }
  disk {
    volume_id = libvirt_volume.controller[count.index].id
    scsi      = true
  }
  network_interface {
    bridge   = var.host_bridge_interface
    hostname = "${var.prefix}-cVM${count.index}"
  }
  lifecycle {
    ignore_changes = [
      nvram,
      disk[0].wwn
    ]
  }
}

resource "libvirt_domain" "worker" {
  count      = var.worker_count
  name       = "${var.prefix}_wVM${count.index}"
  qemu_agent = false
  machine    = "q35"
  firmware   = "usr/share/OVMF/OVMF_CODE.fd"
  cpu {
    mode = "host-passthrough"
  }
  vcpu   = var.worker_vcpu
  memory = var.worker_memory * 1024
  video {
    type = "qxl"
  }
  disk {
    volume_id = libvirt_volume.worker[count.index].id
    scsi      = true
  }
  network_interface {
    bridge   = var.host_bridge_interface
    hostname = "${var.prefix}-wVM${count.index}"
  }
  lifecycle {
    ignore_changes = [
      nvram,
      disk[0].wwn
    ]
  }
}
