# 🧪 Lab Virtualisé KVM avec Ansible

# 🧪 Infrastructure KVM avec Ansible

![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible)
![KVM](https://img.shields.io/badge/KVM-ready-6600cc?logo=linux)
![License](https://img.shields.io/badge/license-MIT-blue)

---

Ce guide permet de provisionner dynamiquement des machines virtuelles via **KVM/QEMU/libvirt**, en utilisant **Ansible** et un inventaire dynamique.

---

## ⚙️ Pré-requis : Installation des dépendances Python et Libvirt

```bash
python -m venv venv
source venv/bin/activate
pip install ansible
pip install passlib
ansible-galaxy collection install community.libvirt
sudo apt install pkg-config libvirt-dev python3-dev
pip3 install libvirt-python
```

---

## 🛠️ Étape 1 : Script d'installation de l'environnement KVM

Rends le script exécutable et lance-le :

```bash
chmod +x kvm_lab_setup.sh
./kvm_lab_setup.sh
```

---

## 🚀 Étape 2 : Provisionnement dynamique de VMs via Ansible

### ✅ Lancer le playbook de provisionnement

- **Provisionner 2 VMs Ubuntu (par défaut)** :

```bash
ansible-playbook lab_provision.yml --ask-vault-pass
```

- **Provisionnement personnalisé (ex. : 3 VMs nommées `devvm` avec une autre image)** :

```bash
ansible-playbook lab_provision.yml -e "vm_count=3" --ask-vault-pass
```

---

## 📦 Étape 3 : Inventaire dynamique avec libvirt

### 🔧 Rendre le script d’inventaire exécutable :

```bash
chmod +x dynamic_inventory.py
```

### 📋 Utiliser le script avec Ansible :

```bash
ansible -i ./inventory_dynamic.py all -m ping
```

💡 Tu peux également référencer ce script directement dans `ansible.cfg`.

---

## 🧨 Étape 4 : Destruction des VMs

### 🗑 Détruire les VMs créées

- **Par défaut (2 VMs nommées `labvm`)** :

```bash
ansible-playbook lab_destroy.yml --ask-vault-pass
```

- **Détruire une configuration personnalisée (ex. : 3 VMs)** :

```bash
ansible-playbook lab_destroy.yml -e "vm_count=3" --ask-vault-pass
```

---

## 🧼 Astuce : Nettoyage complet rapide (hors Ansible)

Pour supprimer manuellement toutes les VMs créées dans `~/vms/` :

```bash
virsh list --all --name | grep '^labvm' | xargs -r -n1 virsh destroy
virsh list --all --name | grep '^labvm' | xargs -r -n1 virsh undefine
rm -f ~/vms/labvm*
```
