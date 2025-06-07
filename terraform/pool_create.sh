#!/bin/bash
POOL_NAME="vms_dir"
POOL_PATH="/var/lib/libvirt/images/$POOL_NAME"

sudo mkdir -p "$POOL_PATH"
sudo chown libvirt-qemu:kvm "$POOL_PATH"
sudo chmod 770 "$POOL_PATH"

read -r -d '' POOL_XML <<EOF
<pool type='dir'>
  <name>$POOL_NAME</name>
  <target>
    <path>$POOL_PATH</path>
  </target>
</pool>
EOF

echo "$POOL_XML" | sudo virsh pool-define /dev/stdin
sudo virsh pool-start "$POOL_NAME"
sudo virsh pool-autostart "$POOL_NAME"

echo "Storage pool $POOL_NAME créé dans $POOL_PATH"
