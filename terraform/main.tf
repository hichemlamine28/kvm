terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


provider "vault" {
  address = "http://127.0.0.1:8200" # adapte si besoin
  skip_tls_verify = true
  # Le token sera pris automatiquement depuis VAULT_TOKEN dans l'environnement si vous avez deja fait export
  token   = var.vault_token
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


# Copie et resize de l’image avant attachement
resource "null_resource" "resized_image" {
  count = var.vm_count

  triggers = {
    index       = count.index
    resized_img = "${var.base_path}/${var.host_name}${count.index + 1}-resized.qcow2"
    size_gb     = var.disk_size_gb
  }

  provisioner "local-exec" {
    command = <<EOT
      cp ${var.base_path}/${var.source_image} ${self.triggers.resized_img}
      qemu-img resize ${self.triggers.resized_img} ${self.triggers.size_gb}G
    EOT
  }
}

resource "libvirt_volume" "system" {
  count  = var.vm_count
  name   = "${var.host_name}${count.index + 1}-system.qcow2"
  pool   = libvirt_pool.vms_dir.name
  source = null_resource.resized_image[count.index].triggers.resized_img
  format = "qcow2"
}



resource "libvirt_pool" "vms_dir" {
  name = "vms_dir"
  type = "dir"
  target {
    path = "/home/hichem/vms"
  }

}

# data "template_file" "user_data" {
#   count    = var.vm_count
#   template = <<-EOT
#     #cloud-config
#     users:
#       - name: "ubuntu"              # ${var.host_name}${count.index}
#         ssh-authorized-keys:
#           - ${var.ssh_pub_key}
#         sudo: ['ALL=(ALL) NOPASSWD:ALL']
#         groups: sudo
#         shell: /bin/bash
#         lock_passwd: false
#         passwd: '${data.vault_kv_secret_v2.user_password.data["user_password_hashed"]}'
#     disable_root: true
#     ssh_pwauth: true
#   EOT
# }

data "template_file" "user_data" {
  count    = var.vm_count
  template = <<-EOT
    #cloud-config
    users:
      - name: "ubuntu"
        ssh-authorized-keys:
          - ${var.ssh_pub_key}
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        groups: sudo
        shell: /bin/bash
        lock_passwd: false
        passwd: '${data.vault_kv_secret_v2.user_password.data["user_password_hashed"]}'
    disable_root: true
    ssh_pwauth: true

    locale: fr_FR.UTF-8
    keyboard:
      layout: fr
      variant: oss

    packages:
      - console-data

    runcmd:
      - loadkeys fr
  EOT
}

data "template_file" "meta_data" {
  count    = var.vm_count
  template = <<-EOT
    instance-id: ${var.host_name}${count.index + 1}
    local-hostname: ${var.host_name}${count.index + 1}
  EOT
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count     = var.vm_count
  name      = "${var.host_name}${count.index +1}-cloudinit.iso"
  pool      = libvirt_pool.vms_dir.name
  user_data = data.template_file.user_data[count.index].rendered
  meta_data = data.template_file.meta_data[count.index].rendered
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.host_name}${count.index + 1}"
  memory = 2048
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.system[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default"
    hostname     = "${var.host_name}${count.index + 1}"
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

# Lire depuis Vault
data "vault_kv_secret_v2" "user_password" {
  mount = "secret"
  name = "labvm"
  # path = "secret"
}

locals {
  user_password_hashed = data.vault_kv_secret_v2.user_password.data["user_password_hashed"]
}