
# ✅ Installer Terraform - par défaut (1.12.0)

# 🧼 Rendre exécutable

chmod +x install_terraform.sh

# ✅ Installer la version par défaut (1.12.0)

./install_terraform.sh


# ✅ Installer une autre version (ex. 1.13.0)

./install_terraform.sh 1.13.0



# 🧱 Étape 1 : Préparation de Vault  : Assure-toi que Vault est bien installé et lancé :

vault server -dev

(mode dev à usage local/test, sinon utilise un cluster Vault sécurisé)


# Exporte l'adresse Vault :

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root_token'   # en dev, le token est affiché au démarrage



Ajoute le secret (ex : mot de passe déjà hashé SHA-512) :

exemple:
vault kv put secret/labvm user_password_hashed='$6$CPBD7PJYoXowkski$DvEZej04o2PlZ6ONGxb6hQbOSxejP6u1iHswucqNMt1BPnuqURCJ60CchqO.Lek6/nKL4l5rmw1MY/zfhEhKd0'


export VAULT_TOKEN=$(vault print token)
export TF_VAR_vault_token=$(vault print token)

vault kv get secret/labvm



# Comment lire le mot de passe crypté via vault ou depuis tfvars: 
passwd: ${local.user_password_hashed}                 # il faut declarer locals

passwd: '${data.vault_kv_secret_v2.user_password.data["user_password_hashed"]}'  # sans locals

 ( or just put this if no vault :::  )

passwd: ${var.user_password_hashed}  


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


# List all pools

virsh pool-list --all

virsh pool-define-as --name vms_dir --type dir --target /home/hichem/vms

virsh pool-define-as vms_dir dir --target /home/hichem/vms

virsh pool-build vms_dir
virsh pool-start vms_dir
virsh pool-autostart vms_dir

virsh pool-list --all

virsh pool-destroy vms_dir
virsh pool-undefine vms_dir


# Virsh Net
virsh net-list --all

sudo virsh net-define /usr/share/libvirt/networks/default.xml
sudo virsh net-autostart default
sudo virsh net-start default
