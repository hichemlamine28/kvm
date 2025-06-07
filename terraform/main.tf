terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


resource "null_resource" "activate_pool" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Etat du pool avant:" 
    virsh pool-info vms_dir
    virsh pool-start vms_dir || echo "Échec du démarrage du pool"
    echo "Etat du pool après tentative de démarrage:" 
    virsh pool-info vms_dir
    EOT
  }

  depends_on = [libvirt_pool.vms_dir]
}


resource "libvirt_pool" "vms_dir" {
  name = "vms_dir"
  type = "dir"
  target {
    path = "/home/hichem/vms"
  }

}

resource "libvirt_volume" "system" {
  count  = var.vm_count
  name   = "${var.user_name}${count.index + 1}-system.qcow2"
  pool   = libvirt_pool.vms_dir.name
  source = "/home/hichem/vms/ubuntu-focal-base.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  count    = var.vm_count
  template = <<-EOT
    #cloud-config
    users:
      - name: "ubuntu"              # ${var.user_name}${count.index}
        ssh-authorized-keys:
          - ${var.ssh_pub_key}
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        groups: sudo
        shell: /bin/bash
        lock_passwd: false
        passwd: ${var.user_password_hashed}
    disable_root: true
    ssh_pwauth: true
  EOT
}

data "template_file" "meta_data" {
  count    = var.vm_count
  template = <<-EOT
    instance-id: ${var.user_name}${count.index + 1}
    local-hostname: ${var.user_name}${count.index + 1}
  EOT
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count     = var.vm_count
  name      = "${var.user_name}${count.index +1}-cloudinit.iso"
  pool      = libvirt_pool.vms_dir.name
  user_data = data.template_file.user_data[count.index].rendered
  meta_data = data.template_file.meta_data[count.index].rendered
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.user_name}${count.index + 1}"
  memory = 2048
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.system[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default"
    hostname     = "${var.user_name}${count.index + 1}"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
  }
}
