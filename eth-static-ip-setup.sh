#!/bin/bash
set -e

STATIC_IP="${STATIC_IP:-192.168.0.1}"
SUBNET_MASK="${SUBNET_MASK:-24}"

cat <<EOF >/etc/netplan/50-camera.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [${STATIC_IP}/${SUBNET_MASK}]
EOF

echo "Applying static IP configuration: $STATIC_IP/$SUBNET_MASK"
netplan apply
