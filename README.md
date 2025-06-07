# kvm

## #######################
python -m venv venv
source venv/bin/activate
pip install ansible
pip install passlib
ansible-galaxy collection install community.libvirt
sudo apt install pkg-config libvirt-dev python3-dev
pip3 install libvirt-python


## #######################

🛠️ 1. Script d'installation KVM/Linux natif

chmod +x kvm_lab_setup.sh


./kvm_lab_setup.sh

## #######################


📦 2. Playbook Ansible pour créer dynamiquement N VM


✅ Provisionner les VMs
▶️ Par défaut (2 VMs Ubuntu) :


ansible-playbook lab_provision.yml --ask-vault-pass


Avec options personnalisées (ex : 3 VMs appelées devvm avec une autre image) :

ansible-playbook lab_provision.yml -e "vm_count=3" --ask-vault-pass



## ###############################



📜 3. Inventaire dynamique Ansible avec libvirt

# Ce script génère un inventaire JSON que tu peux utiliser avec Ansible :
# Rendre le script python exécutable:

chmod +x dynamic_inventory.py

# Utiliser avec Ansible :

./inventory_dynamic.py --count 3 --prefix labvm


# Tu peux dans ton ansible.cfg ou en ligne de commande appeler cet inventaire dynamique :

ansible -i ./inventory_dynamic.py all -m ping



./inventory_dynamic.py

Utilise-le comme inventaire dans ansible :

ansible -i ./inventory_dynamic.py all -m ping




🔥 Pour détruire les VMs :
🗑 Détruire les VMs
Par défaut (2 VMs nommées labvm) :

ansible-playbook lab_destroy.yml --ask-vault-pass


Avec les mêmes options personnalisées que le provisionnement (ex : devvm × 3) :

ansible-playbook lab_destroy.yml -e "vm_count=3" --ask-vault-pass




🧼 Astuce : Nettoyage global rapide
Si tu veux détruire tout ce qui est dans ~/vms/, tu peux aussi le faire ainsi (si plus rapide que le playbook pour un reset complet) :


virsh list --all --name | grep '^labvm' | xargs -r -n1 virsh destroy
virsh list --all --name | grep '^labvm' | xargs -r -n1 virsh undefine
rm -f ~/vms/labvm*


