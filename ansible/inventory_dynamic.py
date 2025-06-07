#!/usr/bin/env python3

import libvirt
import json
import xml.etree.ElementTree as ET
import re
import sys

def get_domain_ips(domain):
    """
    Tente de récupérer les IPs des interfaces réseau d'une VM via la méthode dom.interfaceAddresses().
    Retourne une liste d'adresses IP (IPv4 uniquement).
    """
    ips = []
    try:
        # FLAGS = 0 ou VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LEASE
        ifaces = domain.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LEASE)
        for (name, val) in ifaces.items():
            if val['addrs']:
                for addr in val['addrs']:
                    if addr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                        ips.append(addr['addr'])
    except Exception as e:
        # Pas d'info IP dispo
        pass
    return ips

def main():
    # Connexion à libvirt (local par défaut)
    try:
        conn = libvirt.open('qemu:///system')
    except libvirt.libvirtError as e:
        print(f"Erreur connexion libvirt: {e}", file=sys.stderr)
        sys.exit(1)

    inventory = {
        "all": {
            "hosts": [],
            "vars": {}
        },
        "_meta": {
            "hostvars": {}
        }
    }

    # Parcours des domaines (VMs)
    for id in conn.listDomainsID():
        dom = conn.lookupByID(id)
        name = dom.name()
        ips = get_domain_ips(dom)
        inventory["all"]["hosts"].append(name)

        # On prend la première IP IPv4 récupérée ou None
        ip = ips[0] if ips else None

        inventory["_meta"]["hostvars"][name] = {
            "ansible_host": ip if ip else "UNKNOWN",
            "ansible_user": "ubuntu",  # adapter si besoin
            "libvirt_id": id,
            "state": dom.info()[0]  # état de la VM
        }

    # Pour les VMs éteintes, si tu veux, on peut aussi les récupérer ici
    # Par exemple, lister toutes les VMs et retirer celles déjà listées
    all_domains = [conn.lookupByID(id).name() for id in conn.listDomainsID()]
    defined_domains = conn.listDefinedDomains()
    all_domains += defined_domains

    # On ignore les déjà ajoutés (actives)
    inactive_domains = [d for d in all_domains if d not in inventory["all"]["hosts"]]

    for name in inactive_domains:
        dom = conn.lookupByName(name)
        inventory["all"]["hosts"].append(name)
        inventory["_meta"]["hostvars"][name] = {
            "ansible_host": "OFFLINE",
            "ansible_user": "ubuntu",
            "libvirt_id": None,
            "state": dom.info()[0]  # état
        }

    print(json.dumps(inventory, indent=2))

    conn.close()

if __name__ == "__main__":
    main()
