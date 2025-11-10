#!/bin/bash
set -e

# echo "Configuring static IP..."
# bash /app/eth-static-ip-setup.sh

echo "Starting Raspberry Pi camera setup container..."
bash /app/auto-camera-setup.sh

echo "✅ Setup complete. Container is now running."
tail -f /dev/null
