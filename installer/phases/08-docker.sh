#!/bin/bash
#
# Phase 8: Docker Setup
#

phase_docker_setup() {
    local username="$1"
    
    echo "[Phase 8] Installing Docker..."
    
    # Install Docker and Docker Compose
    pacman -S --noconfirm docker docker-compose
    
    # Configure Docker for low memory
    cat > /etc/docker/daemon.json <<'EOF'
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  },
  "default-shm-size": "128M",
  "storage-driver": "overlay2"
}
EOF
    
    # Enable and start Docker service
    systemctl enable docker.service
    systemctl start docker.service
    
    # Add user to docker group
    usermod -aG docker "$username"
    
    echo "[Phase 8] Docker installed and configured"
}
