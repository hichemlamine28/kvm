#  🚀 🧪 Lab Virtualisé KVM avec Terraform + KVM/QEMU/Libvirt

[![GitHub repo size](https://img.shields.io/github/repo-size/hichemlamine28/kvm?style=flat-square)](https://github.com/hichemlamine28/kvm)
[![GitHub issues](https://img.shields.io/github/issues/hichemlamine28/kvm?style=flat-square)](https://github.com/hichemlamine28/kvm/issues)
[![GitHub forks](https://img.shields.io/github/forks/hichemlamine28/kvm?style=flat-square)](https://github.com/hichemlamine28/kvm/network)
[![GitHub stars](https://img.shields.io/github/stars/hichemlamine28/kvm?style=flat-square)](https://github.com/hichemlamine28/kvm/stargazers)
[![GitHub license](https://img.shields.io/github/license/hichemlamine28/kvm?style=flat-square)](LICENSE)


![Terraform](https://img.shields.io/badge/Terraform-1.12.0-5F43E9?logo=terraform)
![KVM](https://img.shields.io/badge/KVM-integrated-6600cc?logo=linux)
![License](https://img.shields.io/badge/license-MIT-blue)

---

Ce guide décrit l'installation de Terraform, la configuration de Vault, la génération d'images cloud-init, et la gestion des pools & réseaux `virsh` pour créer des VMs locales avec Terraform.

---

## ✅ Installation de Terraform

### 🔧 Rendre le script d’installation exécutable

```bash
chmod +x install_terraform.sh
```

### 📦 Installer la version par défaut (1.12.0)

```bash
./install_terraform.sh
```

### 🔁 Installer une autre version de Terraform (ex. : 1.13.0)

```bash
./install_terraform.sh 1.13.0
```

---

## 🔐 Génération de mot de passe hashé (SHA-512)

### 📜 Avec Python

```bash
python3 -c "import crypt; print(crypt.crypt('you-password-here', crypt.mksalt(crypt.METHOD_SHA512)))"
```

### 📦 Avec `whois` / `mkpasswd`

```bash
sudo apt-get install -y whois
mkpasswd --method=sha-512
```

---

## 🧱 Étape 1 : Configuration de Vault

### 🔐 Lancer Vault en mode développement (usage local/test uniquement)

```bash
vault server -dev
```

> Pour une utilisation en production, il est recommandé d’utiliser un cluster Vault sécurisé.

### 🌍 Exporter les variables d’environnement nécessaires

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root_token'  # (le token est affiché lors du démarrage de Vault en mode dev)
```

### 🔑 Ajouter un secret dans Vault (ex. : mot de passe hashé SHA-512)

```bash
vault kv put secret/labvm user_password_hashed='$6$CPBD7PJYoXowkski$.......O.Lek6/nKL4l5rmw1MY/zf...Kd0'
```

### 🔄 Exporter le token pour Terraform

```bash
export VAULT_TOKEN=$(vault print token)
export TF_VAR_vault_token=$(vault print token)
```

### 🔍 Vérifier la présence du secret

```bash
vault kv get secret/labvm
```

---

## 🔎 Lecture du mot de passe dans Terraform

Différentes façons d'utiliser le mot de passe dans Terraform :

```hcl
# Avec local :
passwd: ${local.user_password_hashed}

# Avec data source Vault :
passwd: '${data.vault_kv_secret_v2.user_password.data["user_password_hashed"]}'

# Sans Vault :
passwd: ${var.user_password_hashed}
```

---

## ⚙️ cloud-init : Configuration utilisateur

Fichier `cloud-init/user-data` :

<pre><code>##cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ssh-rsa AAAA...ton_clef_publique...
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
</code></pre>

### 📄 Créer un fichier `meta-data` vide

```bash
touch cloud-init/meta-data
```

### 📀 Générer un ISO cloud-init

```bash
genisoimage -output /home/hichem/vms/cloud-init.iso -volid cidata -joliet -rock cloud-init/user-data cloud-init/meta-data
```

---

## 🗂️ Gestion des pools de stockage avec `virsh`

### 🔍 Lister tous les pools

```bash
virsh pool-list --all
```

### 📁 Créer un nouveau pool nommé `vms_dir`

```bash
virsh pool-define-as --name vms_dir --type dir --target /home/hichem/vms
```

OU :

```bash
virsh pool-define-as vms_dir dir --target /home/hichem/vms
```

### ▶️ Initialiser et activer le pool

```bash
virsh pool-build vms_dir
virsh pool-start vms_dir
virsh pool-autostart vms_dir
```

### 🧹 Supprimer le pool

```bash
virsh pool-destroy vms_dir
virsh pool-undefine vms_dir
```

---

## 🌐 Gestion du réseau avec `virsh`

### 🔍 Lister les réseaux disponibles

```bash
virsh net-list --all
```

### 🌐 Définir et démarrer le réseau `default`

```bash
sudo virsh net-define /usr/share/libvirt/networks/default.xml
sudo virsh net-autostart default
sudo virsh net-start default
```

---

> ✅ Tous les outils sont maintenant prêts pour exécuter vos plans Terraform avec KVM/libvirt et Vault.












