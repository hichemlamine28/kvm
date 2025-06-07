#!/bin/bash
# Script d'installation pour KVM/QEMU/libvirt sur Ubuntu et CentOS
# Auteur : Hichem (approche DevOps senior)

set -e

OS=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

if [[ "$OS" == "ubuntu" ]]; then
  echo "[+] Installation pour Ubuntu..."
  sudo apt update
  sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
    bridge-utils virtinst virt-manager libguestfs-tools
  sudo systemctl enable --now libvirtd
  sudo usermod -aG libvirt $(whoami)

elif [[ "$OS" == "centos" ]]; then
  echo "[+] Installation pour CentOS..."
  sudo dnf install -y @virtualization
  sudo systemctl enable --now libvirtd
  sudo usermod -aG libvirt $(whoami)
  sudo dnf install libguestfs-tools-c

else
  echo "[-] OS non supporté automatiquement. Installez les paquets KVM manuellement."
  exit 1
fi

# Test de support CPU
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
  echo "[+] Virtualisation matérielle activée."
else
  echo "[-] Votre CPU ne supporte pas la virtualisation ou elle est désactivée dans le BIOS."
  exit 1
fi


python3 -m venv venv
source venv/bin/activate
pip install ansible
pip install passlib
ansible-galaxy collection install community.libvirt
sudo apt install pkg-config libvirt-dev python3-dev -y
pip3 install libvirt-python



# Création du dossier d'images si besoin
mkdir -p ~/vms

# Message final
echo "[+] Installation terminée. Déconnectez-vous / reconnectez-vous pour activer les droits libvirt."
