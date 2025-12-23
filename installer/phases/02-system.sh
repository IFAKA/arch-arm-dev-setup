#!/bin/bash
#
# Phase 2: System Configuration
#

# Detect if running in a virtual machine
detect_virtualization() {
    if systemd-detect-virt -v &>/dev/null; then
        local virt_type=$(systemd-detect-virt)
        echo "$virt_type"
        return 0
    elif grep -qi qemu /proc/cpuinfo 2>/dev/null; then
        echo "qemu"
        return 0
    elif [ -e /dev/vport* ] 2>/dev/null; then
        echo "qemu"
        return 0
    elif dmesg | grep -qi "hypervisor detected" 2>/dev/null; then
        echo "unknown-vm"
        return 0
    else
        echo "none"
        return 1
    fi
}

# Auto-expand disk if running in VM and disk has unallocated space
auto_expand_disk() {
    local virt_type=$(detect_virtualization)
    
    if [ "$virt_type" = "none" ]; then
        echo "Not running in a VM, skipping disk expansion check"
        return 0
    fi
    
    echo "Detected virtualization: $virt_type"
    echo "Checking for expandable disk space..."
    
    # Install required tools if not present
    pacman -S --noconfirm --needed cloud-guest-utils parted e2fsprogs &>/dev/null || true
    
    # Find the root device
    local root_mount=$(findmnt -n -o SOURCE /)
    local root_device=""
    
    # Extract the base device (e.g., /dev/vda from /dev/vda1)
    if [[ $root_mount =~ ^/dev/([sv]d[a-z]|nvme[0-9]+n[0-9]+)p?[0-9]+$ ]]; then
        # Handle both /dev/vda1 and /dev/nvme0n1p1 formats
        root_device=$(echo "$root_mount" | sed -E 's/p?[0-9]+$//')
    else
        echo "Could not determine root device from: $root_mount"
        return 1
    fi
    
    echo "Root partition: $root_mount"
    echo "Root device: $root_device"
    
    # Get partition number
    local part_num=$(echo "$root_mount" | grep -o '[0-9]*$')
    
    # Check if there's unallocated space
    local disk_size=$(blockdev --getsize64 "$root_device" 2>/dev/null || echo "0")
    local part_end=$(parted -s "$root_device" unit B print | grep "^ $part_num" | awk '{print $3}' | sed 's/B//')
    
    if [ "$disk_size" = "0" ] || [ -z "$part_end" ]; then
        echo "Could not determine disk sizes, skipping expansion"
        return 0
    fi
    
    local unallocated=$((disk_size - part_end))
    local unallocated_gb=$((unallocated / 1024 / 1024 / 1024))
    
    echo "Total disk size: $((disk_size / 1024 / 1024 / 1024)) GB"
    echo "Partition end: $((part_end / 1024 / 1024 / 1024)) GB"
    echo "Unallocated space: ${unallocated_gb} GB"
    
    # If more than 500MB unallocated, expand
    if [ $unallocated -gt 524288000 ]; then
        echo "Found ${unallocated_gb}GB unallocated space! Expanding disk..."
        
        # Expand the partition
        echo "Expanding partition ${part_num}..."
        if command -v growpart &>/dev/null; then
            growpart "$root_device" "$part_num" || {
                echo "growpart failed, trying parted..."
                parted -s "$root_device" resizepart "$part_num" 100%
            }
        else
            parted -s "$root_device" resizepart "$part_num" 100%
        fi
        
        # Expand the filesystem
        echo "Expanding filesystem..."
        local fs_type=$(findmnt -n -o FSTYPE "$root_mount")
        
        case "$fs_type" in
            ext4|ext3|ext2)
                resize2fs "$root_mount"
                ;;
            xfs)
                xfs_growfs "$root_mount"
                ;;
            btrfs)
                btrfs filesystem resize max "$root_mount"
                ;;
            *)
                echo "Unknown filesystem type: $fs_type, skipping filesystem expansion"
                return 1
                ;;
        esac
        
        echo "✅ Disk expanded successfully!"
        echo "New disk space:"
        df -h "$root_mount" | tail -1
        return 0
    else
        echo "No significant unallocated space found (< 500MB), skipping expansion"
        df -h "$root_mount" | tail -1
        return 0
    fi
}

phase_system_update() {
    local username="$1"
    local timezone="$2"
    local hostname="$3"
    
    echo "[Phase 2] Updating system and configuring basics..."
    
    # Auto-expand disk if in VM with unallocated space
    echo ""
    echo "=== Checking for expandable disk space ==="
    auto_expand_disk || echo "Disk expansion skipped or failed (non-critical)"
    echo ""
    
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
