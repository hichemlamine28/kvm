#!/bin/bash

# On Ubuntu

sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
sudo usermod -aG libvirt $(whoami)



Sur une distribution basée sur RHEL/Fedora :

# sudo dnf install -y @virtualization
# sudo systemctl enable --now libvirtd
# sudo usermod -aG libvirt $(whoami)




ansible-galaxy collection install community.libvirt

pip install passlib
sudo apt install pkg-config libvirt-dev python3-dev -y
pip3 install libvirt-python