#!/bin/bash
set -e

echo "=== Raspberry Pi Camera Auto-Setup ==="

# 1️⃣ Get Pi's IP dynamically
PI_IP=$(hostname -I | awk '{print $1}')
echo "✅ Detected Pi IP: ${PI_IP}"

# 2️⃣ Set camera IP
# Example: last octet 50
CAMERA_IP="${PI_IP%.*}.50"
echo "✅ Camera should be set to static IP: ${CAMERA_IP}"

# 3️⃣ Start port forwarding directly with socat
echo "🚀 Starting port forwarding..."
/usr/bin/socat TCP-LISTEN:80,reuseaddr,fork TCP:$CAMERA_IP:80 &
/usr/bin/socat TCP-LISTEN:443,reuseaddr,fork TCP:$CAMERA_IP:443 &
/usr/bin/socat TCP-LISTEN:554,reuseaddr,fork TCP:$CAMERA_IP:554 &
/usr/bin/socat TCP-LISTEN:8554,reuseaddr,fork TCP:$CAMERA_IP:554 &
/usr/bin/socat TCP-LISTEN:1935,reuseaddr,fork TCP:$CAMERA_IP:1935 &
/usr/bin/socat TCP-LISTEN:21,reuseaddr,fork TCP:$CAMERA_IP:21 &
/usr/bin/socat TCP-LISTEN:25,reuseaddr,fork TCP:$CAMERA_IP:25 &
/usr/bin/socat UDP-LISTEN:53,reuseaddr,fork UDP:$CAMERA_IP:53 &
/usr/bin/socat UDP-LISTEN:123,reuseaddr,fork UDP:$CAMERA_IP:123 &
/usr/bin/socat UDP-LISTEN:161,reuseaddr,fork UDP:$CAMERA_IP:161 &
/usr/bin/socat UDP-LISTEN:5004,reuseaddr,fork UDP:$CAMERA_IP:5004 &
/usr/bin/socat UDP-LISTEN:5005,reuseaddr,fork UDP:$CAMERA_IP:5005 &

echo "✅ Port forwarding started"
echo "-------------------------------------------"
echo "📷 CAMERA NETWORK CONFIGURATION"
echo "Camera IP  : ${CAMERA_IP}"
echo "Pi IP      : ${PI_IP}"
echo "Access RTSP: rtsp://${PI_IP}:8554/"
echo "-------------------------------------------"

# Wait for all background processes
wait
