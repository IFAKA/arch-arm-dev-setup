#!/bin/bash
#
# Phase 4: Memory Management (zram)
#

phase_memory_management() {
    echo "[Phase 4] Configuring memory management with zram..."
    
    # Install zram-generator
    pacman -S --noconfirm zram-generator
    
    # Configure zram (half of RAM as compressed swap)
    cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
    
    # Configure swappiness for better performance
    cat > /etc/sysctl.d/99-swappiness.conf <<EOF
vm.swappiness = 10
vm.vfs_cache_pressure = 50
EOF
    
    # Apply configuration
    systemctl daemon-reload
    systemctl start systemd-zram-setup@zram0.service
    sysctl -p /etc/sysctl.d/99-swappiness.conf
    
    echo "[Phase 4] Memory management configured (~6GB effective RAM from 4GB)"
}
