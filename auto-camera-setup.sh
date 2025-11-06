#!/bin/bash
set -e

echo "=== Raspberry Pi Camera Auto-Setup ==="

# 1 etect next free subnet in 192.168.10–50 range
BASE_NET=192.168
for i in {10..50}; do
    if ! ping -c1 -W1 ${BASE_NET}.${i}.1 &>/dev/null; then
        SUBNET="${BASE_NET}.${i}"
        break
    fi
done

PI_IP="${SUBNET}.1"
CAMERA_IP="${SUBNET}.50"

echo "✅ Selected subnet: ${SUBNET}.0/24"
echo "   Pi will be ${PI_IP}"
echo "   Camera should be ${CAMERA_IP}"

# 2 configure static IP on eth0
NETPLAN_FILE="/etc/netplan/50-camera.yaml"
bash -c "cat > $NETPLAN_FILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [${PI_IP}/24]
EOF

netplan apply
echo "✅ Static IP ${PI_IP} configured on eth0"

# 3 create systemd service for camera port forwarding
SERVICE_FILE="/etc/systemd/system/socat-camera-forward.service"
bash -c "cat > $SERVICE_FILE" <<'EOF'
[Unit]
Description=Socat Camera Port Forwarding
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/bin/bash -c '
CAMERA_IP=${CAMERA_IP:-192.168.10.50}

# HTTP
/usr/bin/socat TCP-LISTEN:80,reuseaddr,fork TCP:$CAMERA_IP:80 &
# HTTPS
/usr/bin/socat TCP-LISTEN:443,reuseaddr,fork TCP:$CAMERA_IP:443 &
# RTSP
/usr/bin/socat TCP-LISTEN:554,reuseaddr,fork TCP:$CAMERA_IP:554 &
# Alternate RTSP
/usr/bin/socat TCP-LISTEN:8554,reuseaddr,fork TCP:$CAMERA_IP:554 &
# RTMP
/usr/bin/socat TCP-LISTEN:1935,reuseaddr,fork TCP:$CAMERA_IP:1935 &
# FTP
/usr/bin/socat TCP-LISTEN:21,reuseaddr,fork TCP:$CAMERA_IP:21 &
# SMTP
/usr/bin/socat TCP-LISTEN:25,reuseaddr,fork TCP:$CAMERA_IP:25 &
# DNS
/usr/bin/socat UDP-LISTEN:53,reuseaddr,fork UDP:$CAMERA_IP:53 &
# NTP
/usr/bin/socat UDP-LISTEN:123,reuseaddr,fork UDP:$CAMERA_IP:123 &
# SNMP
/usr/bin/socat UDP-LISTEN:161,reuseaddr,fork UDP:$CAMERA_IP:161 &
# RTP / RTCP
/usr/bin/socat UDP-LISTEN:5004,reuseaddr,fork UDP:$CAMERA_IP:5004 &
/usr/bin/socat UDP-LISTEN:5005,reuseaddr,fork UDP:$CAMERA_IP:5005 &
wait
'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Replace CAMERA_IP variable dynamically in the service
sed -i "s|CAMERA_IP:-192.168.10.50|CAMERA_IP:-${CAMERA_IP}|" $SERVICE_FILE

systemctl daemon-reload
systemctl enable --now socat-camera-forward.service

echo ""
echo "✅ Camera forwarding service is running"
echo "-------------------------------------------"
echo "📷 CAMERA NETWORK CONFIGURATION"
echo "IP Address : ${CAMERA_IP}"
echo "Subnet Mask: 255.255.255.0"
echo "Gateway    : ${PI_IP}"
echo "-------------------------------------------"
echo "🔗 Access RTSP via Pi: rtsp://${PI_IP}:8554/"
