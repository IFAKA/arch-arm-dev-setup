#!/bin/bash
#
# Fix script for when .zprofile tries to start sway but it's not installed
# Run this as root on the VM
#

set -e

echo "=== Sway Auto-Start Fix ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    echo "  sudo bash $0"
    exit 1
fi

# Find the user (should be 'dev')
USER_NAME=$(ls /home | grep -v lost+found | head -1)

if [ -z "$USER_NAME" ]; then
    echo "Error: No user found in /home"
    exit 1
fi

echo "Found user: $USER_NAME"
USER_HOME="/home/$USER_NAME"

# Check if .zprofile exists and tries to start sway
if [ -f "$USER_HOME/.zprofile" ] && grep -q "sway" "$USER_HOME/.zprofile"; then
    echo "✓ Found .zprofile with sway auto-start"
else
    echo "✗ No sway auto-start found in .zprofile"
    exit 0
fi

# Check if sway is installed
if command -v sway &>/dev/null; then
    echo "✓ Sway is already installed"
    echo ""
    echo "If sway still doesn't start, check:"
    echo "  1. Is your user in 'seat' group? (groups $USER_NAME)"
    echo "  2. Are you logging in on the console (not SSH)?"
    echo "  3. Check logs: journalctl -xe"
    exit 0
fi

echo "✗ Sway is NOT installed"
echo ""
echo "Options:"
echo "  1. Install Sway and GUI environment (recommended)"
echo "  2. Disable sway auto-start (use terminal only)"
echo ""
read -p "Choose [1/2]: " choice

case $choice in
    1)
        echo ""
        echo "Installing Sway and Wayland environment..."
        echo "This will take 5-10 minutes..."
        echo ""
        
        # Use safe_pacman if available, otherwise regular pacman
        PACMAN_CMD="pacman"
        if grep -q "Landlock" /var/log/pacman.log 2>/dev/null; then
            PACMAN_CMD="pacman --disable-sandbox"
            echo "[INFO] Using --disable-sandbox for pacman (Landlock workaround)"
        fi
        
        $PACMAN_CMD -S --noconfirm \
            sway \
            swaylock \
            swayidle \
            waybar \
            foot \
            wofi \
            wl-clipboard \
            grim \
            slurp \
            mako \
            xdg-desktop-portal-wlr \
            polkit \
            light \
            firefox \
            mpv \
            imv \
            ttf-dejavu \
            ttf-liberation \
            noto-fonts
        
        echo ""
        echo "✓ Sway installed successfully!"
        echo ""
        echo "Creating basic Sway configuration..."
        
        # Create config directory
        mkdir -p "$USER_HOME/.config/sway"
        
        # Basic Sway config
        cat > "$USER_HOME/.config/sway/config" <<'SWAYEOF'
# Sway Configuration
set $mod Mod4
set $term foot
set $menu wofi --show drun

# Output configuration
output * resolution 1920x1080

# Autostart terminal
exec foot

# Key bindings
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'

# Moving around
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5

# Move containers to workspace
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3

# Layout
bindsym $mod+f fullscreen toggle
bindsym $mod+v split toggle

# Status bar
bar {
    position top
    status_command while date +'%Y-%m-%d %H:%M:%S'; do sleep 1; done
}
SWAYEOF
        
        chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config"
        
        echo "✓ Configuration created"
        echo ""
        echo "All set! Login again and Sway will start automatically."
        echo ""
        echo "Sway keyboard shortcuts:"
        echo "  Super+Enter       - Open terminal"
        echo "  Super+D           - Application launcher"
        echo "  Super+Shift+Q     - Close window"
        echo "  Super+Shift+E     - Exit sway"
        ;;
        
    2)
        echo ""
        echo "Disabling sway auto-start..."
        
        # Comment out sway auto-start in .zprofile
        sed -i 's/^[^#]*sway$/# &/' "$USER_HOME/.zprofile"
        
        echo "✓ Sway auto-start disabled"
        echo ""
        echo "You can now login and use the terminal."
        echo "To start sway manually later: just type 'sway'"
        ;;
        
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Done!"
