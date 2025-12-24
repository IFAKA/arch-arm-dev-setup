#!/bin/bash
#
# Fix Sway Auto-Start for UTM Serial Console
# Run this if Sway doesn't start automatically after login
#
# Usage: curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/fix-sway-autostart.sh | bash
#

set -euo pipefail

echo "================================================================"
echo "          Fix Sway Auto-Start for UTM/Serial Console           "
echo "================================================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "[ERROR] Please run as your regular user, not root!"
    exit 1
fi

echo "[INFO] Updating .zprofile for Sway auto-start..."

# Backup existing files
[ -f ~/.zprofile ] && cp ~/.zprofile ~/.zprofile.backup.$(date +%Y%m%d-%H%M%S)
[ -f ~/.bash_profile ] && cp ~/.bash_profile ~/.bash_profile.backup.$(date +%Y%m%d-%H%M%S)

# Create new .zprofile with UTM serial console support
cat > ~/.zprofile <<'EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
EOF

# Create new .bash_profile with UTM serial console support
cat > ~/.bash_profile <<'EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
EOF

echo "[✓] Auto-start configuration updated!"
echo ""
echo "================================================================"
echo "                    Fix Applied Successfully!                   "
echo "================================================================"
echo ""
echo "What was fixed:"
echo "  - Updated .zprofile to detect UTM serial console (ttyAMA0)"
echo "  - Updated .bash_profile for Bash compatibility"
echo "  - Backed up old files with timestamp"
echo ""
echo "Next steps:"
echo "  1. Logout: exit"
echo "  2. Log back in"
echo "  3. Sway will start automatically!"
echo ""
echo "Your current TTY: $(tty)"
echo ""
