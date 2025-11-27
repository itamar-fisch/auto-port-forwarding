#!/bin/bash
# Usage: ./set_camera_ip.sh <VLAN_ID>
# Example: ./set_camera_ip.sh 102

echo "=== Raspberry Pi Camera Auto-Setup ==="

VLAN_ID=$1
if [ -z "$VLAN_ID" ]; then
    echo "Usage: $0 <VLAN_ID>"
    exit 1
fi

# Dynamically set VLAN interface
VLAN_IF="eth0.$VLAN_ID"

# ✅ Check if the interface exists
if ! ip link show "$VLAN_IF" &>/dev/null; then
    echo "❌ Interface $VLAN_IF does not exist!"
    exit 1
fi

# Get Pi's IP on this VLAN
PI_VLAN_IP=$(ip -4 addr show $VLAN_IF | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$PI_VLAN_IP" ]; then
    echo "❌ Could not detect IP on interface $VLAN_IF"
    exit 1
fi

echo "✅ Detected Pi VLAN IP ($VLAN_IF): ${PI_VLAN_IP}"

# Set camera IP (last octet = 50)
CAMERA_IP="${PI_VLAN_IP%.*}.50"
echo "✅ Camera should be set to static IP: ${CAMERA_IP}"

# ✅ Kill existing socat processes to avoid conflicts
pkill -f "socat TCP-LISTEN" 2>/dev/null || true
pkill -f "socat UDP-LISTEN" 2>/dev/null || true

# 3️⃣ Start port forwarding directly with socat
echo "🚀 Starting port forwarding..."

/usr/bin/socat TCP-LISTEN:80,reuseaddr,fork TCP:$CAMERA_IP:80 &
/usr/bin/socat TCP-LISTEN:443,reuseaddr,fork TCP:$CAMERA_IP:443 &
/usr/bin/socat TCP-LISTEN:554,reuseaddr,fork TCP:$CAMERA_IP:554 &
/usr/bin/socat TCP-LISTEN:8554,reuseaddr,fork TCP:$CAMERA_IP:554 &
/usr/bin/socat TCP-LISTEN:1935,reuseaddr,fork TCP:$CAMERA_IP:1935 &
/usr/bin/socat TCP-LISTEN:21,reuseaddr,fork TCP:$CAMERA_IP:21 &
/usr/bin/socat TCP-LISTEN:25,reuseaddr,fork TCP:$CAMERA_IP:25 &
/usr/bin/socat TCP-LISTEN:7681,reuseaddr,fork TCP:$CAMERA_IP:7681 &
/usr/bin/socat UDP-LISTEN:53,reuseaddr,fork UDP:$CAMERA_IP:53 &
/usr/bin/socat UDP-LISTEN:123,reuseaddr,fork UDP:$CAMERA_IP:123 &
/usr/bin/socat UDP-LISTEN:161,reuseaddr,fork UDP:$CAMERA_IP:161 &
/usr/bin/socat UDP-LISTEN:5004,reuseaddr,fork UDP:$CAMERA_IP:5004 &
/usr/bin/socat UDP-LISTEN:5005,reuseaddr,fork UDP:$CAMERA_IP:5005 &
/usr/bin/socat UDP-LISTEN:9008,reuseaddr,fork UDP:$CAMERA_IP:9008 &


echo "✅ Port forwarding started"
echo "-------------------------------------------"
echo "📷 CAMERA NETWORK CONFIGURATION"
echo "Camera IP  : ${CAMERA_IP}"
echo "Pi IP      : ${PI_VLAN_IP}"
echo "Access RTSP: rtsp://${PI_VLAN_IP}:8554/"
echo "-------------------------------------------"

# Wait for all background processes
wait
