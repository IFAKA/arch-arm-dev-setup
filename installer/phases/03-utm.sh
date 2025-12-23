#!/bin/bash
#
# Phase 3: UTM Integration (clipboard + shared folders)
#

phase_utm_integration() {
    echo "[Phase 3] Installing UTM integration tools..."
    
    # Install SPICE guest tools for clipboard sharing
    pacman -S --noconfirm spice-vdagent qemu-guest-agent
    
    # Enable and start services
    systemctl enable spice-vdagentd.service
    systemctl start spice-vdagentd.service
    
    systemctl enable qemu-guest-agent.service
    systemctl start qemu-guest-agent.service
    
    # Install virtiofs support for shared folders
    pacman -S --noconfirm fuse3
    
    # Create mount point
    mkdir -p /mnt/shared
    
    # Add to fstab (will mount if configured in UTM)
    if ! grep -q "shared" /etc/fstab; then
        echo "# UTM Shared Folder" >> /etc/fstab
        echo "shared /mnt/shared virtiofs defaults,nofail 0 0" >> /etc/fstab
    fi
    
    echo "[Phase 3] UTM integration complete"
}
