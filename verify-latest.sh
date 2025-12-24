#!/bin/bash
# Quick script to verify you're downloading the latest installer

echo "🔍 Checking latest installer version..."
echo ""

# Fetch the script
SCRIPT_URL="https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh"
TEMP_FILE="/tmp/verify-installer-$$.sh"

if ! curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE" 2>/dev/null; then
    echo "❌ Failed to download installer"
    echo "   Check your internet connection"
    exit 1
fi

# Extract version info
VERSION=$(grep "^INSTALLER_VERSION=" "$TEMP_FILE" | cut -d'"' -f2)
DATE=$(grep "^INSTALLER_DATE=" "$TEMP_FILE" | cut -d'"' -f2)
COMMIT=$(grep "^# Commit:" "$TEMP_FILE" | awk '{print $3}')

# Check for key features
HAS_SAFE_PACMAN=$(grep -c "safe_pacman()" "$TEMP_FILE")
HAS_BOOT_CLEANUP=$(grep -c "initramfs-linux-fallback.img" "$TEMP_FILE")
HAS_AUTO_EXPAND=$(grep -c "auto_expand_disk()" "$TEMP_FILE")

echo "📦 Latest Installer Info:"
echo "   Version: $VERSION"
echo "   Date: $DATE"
echo "   Commit: $COMMIT"
echo ""

echo "🛡️  Features Detected:"
if [ "$HAS_SAFE_PACMAN" -gt 0 ]; then
    echo "   ✓ Landlock/sandbox auto-recovery (safe_pacman)"
else
    echo "   ✗ Missing: safe_pacman wrapper"
fi

if [ "$HAS_BOOT_CLEANUP" -gt 0 ]; then
    echo "   ✓ /boot partition cleanup"
else
    echo "   ✗ Missing: /boot cleanup"
fi

if [ "$HAS_AUTO_EXPAND" -gt 0 ]; then
    echo "   ✓ Automatic disk expansion"
else
    echo "   ✗ Missing: auto disk expansion"
fi

echo ""

# Compare with local file if exists
if [ -f "$1" ]; then
    echo "📊 Comparing with local file: $1"
    LOCAL_VERSION=$(grep "^INSTALLER_VERSION=" "$1" 2>/dev/null | cut -d'"' -f2)
    
    if [ -n "$LOCAL_VERSION" ]; then
        if [ "$LOCAL_VERSION" = "$VERSION" ]; then
            echo "   ✓ Local file is up to date (v$VERSION)"
        else
            echo "   ⚠️  Local file is outdated (v$LOCAL_VERSION → v$VERSION)"
        fi
    else
        echo "   ⚠️  Local file has no version info (very old)"
    fi
    echo ""
fi

# Show recommended command
echo "✅ To run latest installer:"
echo ""
echo "   curl -fsSL \"$SCRIPT_URL?$(date +%s)\" | bash"
echo ""
echo "   (The ?timestamp prevents CDN caching)"
echo ""

# Show what will happen
echo "📋 This installer will:"
echo "   1. Auto-expand disk to 32GB (if in VM)"
echo "   2. Clean /boot partition (remove fallback initramfs if needed)"
echo "   3. Upgrade system (glibc 2.35 → 2.42+, kernel 5.10 → 6.18+)"
echo "   4. Handle Landlock/sandbox errors automatically"
echo "   5. Install whiptail (TUI framework)"
echo "   6. Launch interactive installer wizard"
echo ""

rm -f "$TEMP_FILE"

if [ "$HAS_SAFE_PACMAN" -gt 0 ] && [ "$HAS_BOOT_CLEANUP" -gt 0 ] && [ "$HAS_AUTO_EXPAND" -gt 0 ]; then
    echo "✅ All critical features present - safe to run!"
    exit 0
else
    echo "⚠️  Some features missing - may be outdated"
    exit 1
fi
