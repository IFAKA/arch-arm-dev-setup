#!/bin/bash
#
# Phase 2: System Configuration
#

phase_system_update() {
    local username="$1"
    local timezone="$2"
    local hostname="$3"
    
    echo "[Phase 2] Updating system and configuring basics..."
    
    # Update system packages
    echo "Updating system packages (this may take 10-20 minutes)..."
    pacman -Syu --noconfirm
    
    # Install base-devel for building packages
    pacman -S --noconfirm base-devel git
    
    # Set timezone
    echo "Setting timezone to $timezone..."
    timedatectl set-timezone "$timezone"
    
    # Set hostname
    echo "Setting hostname to $hostname..."
    hostnamectl set-hostname "$hostname"
    
    # Update /etc/hosts
    cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF
    
    echo "[Phase 2] System update and configuration complete"
}
