#!/bin/bash
set -e

echo "Starting Raspberry Pi camera setup container..."
bash /app/auto-camera-setup.sh #/app/??

echo "✅ Setup complete. Container is now running."
tail -f /dev/null
