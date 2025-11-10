# Use the same Ubuntu version as on the Raspberry Pi
FROM ubuntu:25.04

# Prevent interactive package configuration dialogs
ENV DEBIAN_FRONTEND=noninteractive

# Update package index and install required dependencies
# - socat: for TCP/UDP port forwarding
# - net-tools, iproute2, iputils-ping: for network configuration and testing
# - netplan.io: for managing static IP configuration
# - systemd: for running services inside the container (if needed)
RUN apt update && apt install -y \
    socat net-tools iproute2 iputils-ping netplan.io systemd \
    && apt clean

# Set working directory
WORKDIR /app

# Copy your scripts into the image
COPY auto-camera-setup.sh entrypoint.sh ./

# Verify files were copied
RUN ls -la /app

# Ensure scripts have execution permission
RUN chmod +x /app/*.sh

# Define what runs when the container starts
ENTRYPOINT ["/app/entrypoint.sh"]
