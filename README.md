# Raspberry Pi Camera Port Forwarding Automation

This project sets up **automatic port forwarding** on a Raspberry Pi for IP cameras.  
It allows you to connect a camera to the Pi’s Ethernet port (e.g., `192.168.10.50`) and access the camera remotely through the Pi (via Tailscale or local network).

---

## What the Script Does

The setup script:

1. Creates a **systemd service** (`socat-camera-forward.service`) that automatically starts on boot.
2. Forwards the main camera service ports from the Raspberry Pi to the camera:
   - **80 (HTTP)** – Web interface
   - **443 (HTTPS)** – Secure web interface
   - **554 (RTSP)** – Main video stream
   - **8554 (RTSP alternate)** – Some clients use this
   - **1935 (RTMP)** – Streaming
   - **21 (FTP)** – File transfers
   - **25 (SMTP)** – Email alerts
   - **53 (UDP / DNS)**
   - **123 (UDP / NTP)**
   - **161 (UDP / SNMP)**
   - **5004–5005 (UDP / RTP / RTCP)** – Video transport

---

## Requirements

- Raspberry Pi running **Ubuntu** or **Raspberry Pi OS**
- Internet connection (Ethernet or Wi-Fi)
- Installed packages:
  ```bash
  sudo apt update
  sudo apt install socat curl -y
  ```
- (Optional but recommended) [Tailscale](https://tailscale.com) for remote access.

---

## Setup Instructions

1. **Copy the script** (`camera-setup.sh`) to your Pi.

2. **Run the setup:**
   ```bash
   sudo bash camera-setup.sh
   ```

3. The script will:
   - Detect or suggest a static IP for the camera (e.g., `192.168.10.50`)
   - Create `/etc/systemd/system/socat-camera-forward.service`
   - Enable and start the service automatically.

---

## Verifying That It Works

To check if the forwarding service is running:
```bash
sudo systemctl status socat-camera-forward.service
```

To view logs (connections, errors):
```bash
sudo tail -f /var/log/socat-camera-forward.log
```

To test the camera stream from another machine (via Tailscale or LAN):
```bash
vlc rtsp://<pi-address>:8554/   # Example: rtsp://rpi-device-on-demand-1.tailnet.ts.net:8554/
```

---

## Updating or Removing the Service

To restart after edits:
```bash
sudo systemctl daemon-reload
sudo systemctl restart socat-camera-forward.service
```

To disable auto-start:
```bash
sudo systemctl disable --now socat-camera-forward.service
```

To remove completely:
```bash
sudo rm /etc/systemd/system/socat-camera-forward.service
sudo systemctl daemon-reload
```

---

## Notes

- The camera must be reachable from the Pi (e.g., Ethernet IP `192.168.10.50`).
- Make sure **only one camera** is connected per Pi to avoid IP conflicts.
- You can adjust ports or camera IP by editing:
  ```bash
  sudo nano /etc/systemd/system/socat-camera-forward.service
  ```

---

## Author

Developed by **Itamar Fisch** – Raspberry Pi automation for camera bridging via Tailscale.
