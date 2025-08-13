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

resource "libvirt_pool" "talos_storage_pool" {
  name = "talos_storage_pool"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/talos_storage"
  }
}

resource "libvirt_volume" "base_talos_volume" {
  name   = "base_talos_volume"
  source = var.talos_image_path
  pool   = libvirt_pool.talos_storage_pool.name
}

resource "libvirt_volume" "controller" {
  count          = var.controller_count
  name           = "${var.prefix}_c${count.index}.img"
  pool           = libvirt_pool.talos_storage_pool.name
  base_volume_id = libvirt_volume.base_talos_volume.id
  format         = "qcow2"
  size           = 40 * 1024 * 1024 * 1024 # 40 GB 
}

resource "libvirt_volume" "worker" {
  count          = var.worker_count
  name           = "${var.prefix}_w${count.index}.img"
  pool           = libvirt_pool.talos_storage_pool.name
  base_volume_id = libvirt_volume.base_talos_volume.id
  format         = "qcow2"
  size           = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_data0" {
  count  = var.worker_count
  name   = "${var.prefix}_wd${count.index}.img"
  pool   = libvirt_pool.talos_storage_pool.name
  format = "qcow2"
  size   = var.worker_data0_size * 1024 * 1024 * 1024 # User set size in GB
}

resource "libvirt_domain" "controller" {
  count      = var.controller_count
  name       = "${var.prefix}_cVM${count.index}"
  qemu_agent = true
  machine    = "q35"
  firmware   = "/usr/share/OVMF/OVMF_CODE.fd"
  autostart  = true
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
    bridge         = var.host_bridge_interface
    hostname       = "${var.prefix}-cVM${count.index}"
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
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
  qemu_agent = true
  machine    = "q35"
  firmware   = "/usr/share/OVMF/OVMF_CODE.fd"
  autostart  = true
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
  disk {
    volume_id = libvirt_volume.worker_data0[count.index].id
    scsi      = true
    wwn       = format("000000000000ab%02x", count.index)
  }
  network_interface {
    bridge         = var.host_bridge_interface
    hostname       = "${var.prefix}-wVM${count.index}"
    wait_for_lease = true
  }
  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
  }
  lifecycle {
    ignore_changes = [
      nvram,
      disk[0].wwn
    ]
  }
}
