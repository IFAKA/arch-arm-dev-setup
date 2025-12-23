#!/bin/bash
#
# Phase 1: User Creation
#

phase_create_user() {
    local username="$1"
    local password="$2"
    
    echo "[Phase 1] Creating user: $username"
    
    # Create user with home directory
    useradd -m -G wheel -s /bin/bash "$username"
    
    # Set password
    echo "$username:$password" | chpasswd
    
    # Enable sudo for wheel group
    if [ ! -f /etc/sudoers.d/wheel ]; then
        echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
        chmod 440 /etc/sudoers.d/wheel
    fi
    
    # Optional: Remove/disable alarm user for security
    if id "alarm" &>/dev/null; then
        echo "Disabling default 'alarm' user for security..."
        usermod -L alarm  # Lock the account
        # Optionally delete: userdel -r alarm
    fi
    
    echo "[Phase 1] User created successfully"
}
