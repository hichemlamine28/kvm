
# ✅ Installer Terraform - par défaut (1.12.0)

# 🧼 Rendre exécutable

chmod +x install_terraform.sh

# ✅ Installer la version par défaut (1.12.0)

./install_terraform.sh


# ✅ Installer une autre version (ex. 1.13.0)

./install_terraform.sh 1.13.0



# List all pools

virsh pool-list --all

virsh pool-define-as --name vms_dir --type dir --target /home/hichem/vms
virsh pool-build vms_dir 
virsh pool-start vms_dir 
virsh pool-autostart vms_dir 

virsh pool-list --all


## ###################################################################

virsh pool-define-as vms_dir dir --target /home/hichem/vms
virsh pool-build vms_dir
virsh pool-start vms_dir
virsh pool-autostart vms_dir
virsh pool-list --all


## ###################################################################


# cloud-init/user-data
#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ssh-rsa AAAA...ton_clef_publique...
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash

# Crée un fichier meta-data vide :

touch cloud-init/meta-data

# Génère l’ISO cloud-init :

genisoimage -output /home/hichem/vms/cloud-init.iso -volid cidata -joliet -rock cloud-init/user-data cloud-init/meta-data


# Pour crypter / hasher le password 
python3 -c "import crypt; print(crypt.crypt('devops', crypt.mksalt(crypt.METHOD_SHA512)))"

ou bien

sudo apt-get install -y whois
mkpasswd --method=sha-512



# Virsh Net
virsh net-list --all

sudo virsh net-define /usr/share/libvirt/networks/default.xml
sudo virsh net-autostart default
sudo virsh net-start default