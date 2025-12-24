#!/bin/bash
#
# Arch ARM Dev Setup - One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
#
# This is the bootstrap script that:
# 1. Performs pre-flight checks
# 2. Installs whiptail (libnewt) for beautiful TUI
# 3. Downloads and runs the main installer
#

set -euo pipefail

# Colors for basic output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Banner
show_banner() {
    clear
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   █████╗ ██████╗  ██████╗██╗  ██╗    █████╗ ██████╗ ███╗ ║
║  ██╔══██╗██╔══██╗██╔════╝██║  ██║   ██╔══██╗██╔══██╗████║ ║
║  ███████║██████╔╝██║     ███████║   ███████║██████╔╝╚███║ ║
║  ██╔══██║██╔══██╗██║     ██╔══██║   ██╔══██║██╔══██╗ ███║ ║
║  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║  ██║██║  ██║ ███║ ║
║  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝ ║
║                                                           ║
║            Development Environment Setup                 ║
║              One Command. Zero Friction.                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF
}

# Wrapper for pacman that handles Landlock/sandbox errors automatically
safe_pacman() {
    local output_file="/tmp/pacman-safe-$$.log"
    local exit_code=0
    
    # Try normal pacman first
    "$@" 2>&1 | tee "$output_file"
    exit_code=${PIPESTATUS[0]}
    
    # If successful, clean up and return
    if [ $exit_code -eq 0 ]; then
        rm -f "$output_file"
        return 0
    fi
    
    # Check if it was a Landlock/sandbox error
    if grep -qi "landlock.*not supported\|sandbox.*failed" "$output_file" 2>/dev/null; then
        echo "[WARN] Pacman sandbox not supported on this kernel, retrying with --disable-sandbox"
        
        # Build new command with --disable-sandbox flag
        # Need to insert it after 'pacman' command but before operation flags
        local cmd_array=("$@")
        local new_cmd=()
        local found_pacman=false
        
        for arg in "${cmd_array[@]}"; do
            new_cmd+=("$arg")
            # Add --disable-sandbox right after pacman command
            if [[ "$arg" == *"pacman"* ]] && [ "$found_pacman" = false ]; then
                new_cmd+=("--disable-sandbox")
                found_pacman=true
            fi
        done
        
        # Try with --disable-sandbox
        if "${new_cmd[@]}" 2>&1; then
            rm -f "$output_file"
            return 0
        fi
    fi
    
    # Command failed for other reasons - preserve exit code
    rm -f "$output_file"
    return $exit_code
}

# Auto-expand disk if running in VM (before disk space check)
auto_expand_disk() {
    log_info "Checking for expandable disk space..."
    
    # Detect virtualization
    local virt_type="none"
    if command -v systemd-detect-virt &>/dev/null && systemd-detect-virt -v &>/dev/null; then
        virt_type=$(systemd-detect-virt)
    elif grep -qi qemu /proc/cpuinfo 2>/dev/null; then
        virt_type="qemu"
    fi
    
    if [ "$virt_type" = "none" ]; then
        log_info "Not running in VM, skipping disk expansion"
        return 0
    fi
    
    log_info "Detected VM environment: $virt_type"
    
    # Find root device first
    local root_mount=$(findmnt -n -o SOURCE /)
    local root_device=""
    
    if [[ $root_mount =~ ^/dev/([sv]d[a-z]|nvme[0-9]+n[0-9]+)p?[0-9]+$ ]]; then
        root_device=$(echo "$root_mount" | sed -E 's/p?[0-9]+$//')
    else
        log_warning "Could not determine root device, skipping expansion"
        return 0
    fi
    
    local part_num=$(echo "$root_mount" | grep -o '[0-9]*$')
    
    # Check unallocated space using lsblk (works without parted)
    local disk_size=$(blockdev --getsize64 "$root_device" 2>/dev/null || echo "0")
    local part_size=$(lsblk -b -n -o SIZE "$root_mount" 2>/dev/null || echo "0")
    
    if [ "$disk_size" = "0" ] || [ "$part_size" = "0" ]; then
        log_warning "Could not determine disk sizes, skipping expansion"
        return 0
    fi
    
    # Calculate unallocated space (disk size - partition size)
    local unallocated=$((disk_size - part_size))
    local unallocated_gb=$((unallocated / 1024 / 1024 / 1024))
    
    # Only proceed if there's significant unallocated space
    if [ $unallocated -le 524288000 ]; then
        log_info "No unallocated space found"
        return 0
    fi
    
    log_info "Found ${unallocated_gb}GB unallocated space - expanding now..."
    
    # Expand partition using sfdisk (always available, no packages needed)
    log_info "Expanding partition ${part_num} on ${root_device}..."
    echo ", +" | sfdisk --no-reread -N "$part_num" "$root_device" &>/dev/null || {
        log_warning "sfdisk failed, trying parted method..."
        
        # Fallback: install parted (but don't upgrade system first)
        safe_pacman pacman -S --noconfirm --needed parted &>/dev/null || {
            log_warning "Could not install parted, skipping expansion"
            return 0
        }
        
        parted -s "$root_device" resizepart "$part_num" 100% &>/dev/null || {
            log_warning "Partition expansion failed"
            return 0
        }
    }
    
    # Reload partition table
    partprobe "$root_device" &>/dev/null || partx -u "$root_device" &>/dev/null || true
    
    # Expand filesystem
    local fs_type=$(findmnt -n -o FSTYPE "$root_mount")
    log_info "Expanding ${fs_type} filesystem..."
    case "$fs_type" in
        ext4|ext3|ext2)
            resize2fs "$root_mount" &>/dev/null || {
                log_warning "Filesystem expansion failed"
                return 0
            }
            ;;
        xfs)
            xfs_growfs "$root_mount" &>/dev/null || {
                log_warning "Filesystem expansion failed"
                return 0
            }
            ;;
        btrfs)
            btrfs filesystem resize max "$root_mount" &>/dev/null || {
                log_warning "Filesystem expansion failed"
                return 0
            }
            ;;
        *)
            log_warning "Unknown filesystem type: $fs_type"
            return 0
            ;;
    esac
    
    local new_size=$(df -h / | awk 'NR==2 {print $2}')
    log_success "Disk expanded successfully! New size: ${new_size}"
}

# Pre-flight checks
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root (or use 'su' to become root)"
        log_info "Example: su -c \"curl -fsSL ... | bash\""
        exit 1
    fi
    
    # Check internet connectivity
    log_info "Checking internet connection..."
    if ! ping -c 1 -W 3 archlinux.org &> /dev/null; then
        log_error "No internet connection detected"
        log_info "Please check your network and try again"
        exit 1
    fi
    log_success "Internet connection OK"
    
    # Auto-expand disk if needed (BEFORE disk space check)
    auto_expand_disk
    
    # Check available disk space (need at least 8GB free)
    AVAILABLE_GB=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    if [ "$AVAILABLE_GB" -lt 8 ]; then
        log_error "Insufficient disk space: ${AVAILABLE_GB}GB available, need at least 8GB"
        exit 1
    fi
    log_success "Disk space OK (${AVAILABLE_GB}GB available)"
    
    # Check if already installed
    if [ -f "/etc/arch-arm-dev-setup-installed" ]; then
        log_warning "This system appears to already have arch-arm-dev-setup installed"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
        log_warning "This script is designed for ARM64/aarch64 systems"
        log_warning "Detected architecture: $ARCH"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    log_success "Architecture OK ($ARCH)"
    
    log_success "All pre-flight checks passed!"
    echo
}

# Initialize pacman if needed
init_pacman() {
    log_info "Initializing package manager..."
    
    if ! pacman-key --list-keys | grep -q "archlinuxarm"; then
        log_info "Initializing pacman keys (first time setup)..."
        pacman-key --init
        pacman-key --populate archlinuxarm
        log_success "Pacman keys initialized"
    else
        log_success "Pacman already initialized"
    fi
    
    # Update package database
    log_info "Updating package database..."
    pacman -Sy --noconfirm
    log_success "Package database updated"
}

# Upgrade system packages (required for outdated UTM Gallery images)
upgrade_system() {
    # Check if system is severely outdated (glibc < 2.38)
    local glibc_version=$(ldd --version 2>/dev/null | head -1 | awk '{print $NF}')
    local needs_upgrade=false
    
    # Handle case where ldd is not available or fails
    if [ -z "$glibc_version" ]; then
        log_warning "Could not detect glibc version, will attempt upgrade"
        needs_upgrade=true
    elif [[ $glibc_version =~ ^2\.3[0-7] ]] || [[ $glibc_version =~ ^2\.[0-2] ]]; then
        needs_upgrade=true
    fi
    
    if [ "$needs_upgrade" = false ]; then
        log_info "System packages are up to date"
        return 0
    fi
    
    log_warning "Outdated system detected (glibc ${glibc_version:-unknown} < 2.38)"
    log_info "Upgrading system packages (this will take 5-10 minutes)..."
    echo "      This is necessary for UTM Gallery images which are outdated."
    echo "      Your disk has been expanded, so there's plenty of space now."
    echo ""
    
    # Clean /boot to prevent "no space left" errors during kernel upgrade
    log_info "Cleaning /boot partition..."
    
    # Verify /boot exists and is mounted
    if ! mountpoint -q /boot 2>/dev/null && [ ! -d /boot ]; then
        log_warning "/boot is not a separate partition (using root partition)"
        # Continue - /boot is part of root filesystem
    fi
    
    # Safety check: verify /boot is writable
    if [ ! -w /boot ]; then
        log_error "/boot is not writable - may be read-only filesystem"
        log_info "Attempting to remount read-write..."
        mount -o remount,rw /boot 2>/dev/null || {
            log_error "Failed to remount /boot as read-write"
            exit 1
        }
        log_success "/boot remounted as read-write"
    fi
    
    # Remove old backup files if they exist (from previous upgrades)
    local cleaned_old=false
    if [ -f /boot/initramfs-linux-fallback.img.old ] || \
       [ -f /boot/initramfs-linux.img.old ] || \
       [ -f /boot/vmlinuz-linux.old ]; then
        rm -f /boot/initramfs-linux-fallback.img.old 2>/dev/null || true
        rm -f /boot/initramfs-linux.img.old 2>/dev/null || true
        rm -f /boot/vmlinuz-linux.old 2>/dev/null || true
        cleaned_old=true
        log_info "Removed old kernel backup files"
    fi
    
    # Get /boot space info (handle both separate partition and directory)
    local boot_avail_mb boot_avail_human
    if df /boot &>/dev/null; then
        boot_avail_mb=$(df /boot 2>/dev/null | awk 'NR==2 {print int($4/1024)}')
        boot_avail_human=$(df -h /boot 2>/dev/null | awk 'NR==2 {print $4}')
    else
        # Fallback if df fails
        boot_avail_mb=0
        boot_avail_human="unknown"
    fi
    
    # Handle case where df returns empty (corrupted filesystem, etc.)
    if [ -z "$boot_avail_mb" ] || [ "$boot_avail_mb" = "0" ]; then
        log_warning "Could not determine /boot space, attempting upgrade anyway"
        boot_avail_mb=200  # Assume sufficient space
    fi
    
    # If still insufficient, remove fallback image (will be recreated during upgrade)
    if [ "$boot_avail_mb" -lt 100 ]; then
        log_info "Insufficient space (${boot_avail_human}), removing fallback initramfs..."
        log_info "It will be automatically recreated during system upgrade"
        
        if [ -f /boot/initramfs-linux-fallback.img ]; then
            # Get size before removing (handle case where du fails)
            local fallback_size=$(du -h /boot/initramfs-linux-fallback.img 2>/dev/null | awk '{print $1}')
            fallback_size=${fallback_size:-"unknown size"}
            
            # Verify we can actually remove it
            if rm -f /boot/initramfs-linux-fallback.img 2>/dev/null; then
                log_success "Removed fallback image (${fallback_size})"
            else
                log_error "Failed to remove fallback image - permission denied or I/O error"
                exit 1
            fi
        else
            log_warning "Fallback image not found, may have been removed already"
        fi
        
        # Re-check space after removal
        if df /boot &>/dev/null; then
            boot_avail_mb=$(df /boot 2>/dev/null | awk 'NR==2 {print int($4/1024)}')
            boot_avail_human=$(df -h /boot 2>/dev/null | awk 'NR==2 {print $4}')
        fi
    fi
    
    # Final space check (only if we can determine space)
    if [ -n "$boot_avail_mb" ] && [ "$boot_avail_mb" != "0" ] && [ "$boot_avail_mb" -lt 100 ]; then
        log_error "/boot partition critically low on space: ${boot_avail_human} available"
        log_error "Need at least 100MB for kernel upgrade"
        echo ""
        echo "Current /boot contents:"
        ls -lh /boot/ 2>/dev/null | tail -n +2 || echo "  (unable to list /boot contents)"
        echo ""
        echo "Disk usage breakdown:"
        du -sh /boot/* 2>/dev/null | sort -rh | head -10 || echo "  (unable to show disk usage)"
        echo ""
        echo "Manual cleanup options:"
        echo "  1. Remove fallback image (will be recreated):"
        echo "     rm -f /boot/initramfs-linux-fallback.img"
        echo ""
        echo "  2. Remove all old kernels (dangerous - know what you're doing):"
        echo "     rm -f /boot/*.old /boot/initramfs-linux-fallback.img"
        echo ""
        echo "  3. Resize /boot partition to 300MB+ (recommended for long-term):"
        echo "     https://github.com/IFAKA/arch-arm-dev-setup/blob/main/TROUBLESHOOTING.md#15"
        echo ""
        echo "Then re-run this script."
        exit 1
    fi
    
    # Show success message (only if we have valid space info)
    if [ -n "$boot_avail_human" ] && [ "$boot_avail_human" != "unknown" ]; then
        log_success "/boot partition has ${boot_avail_human} available (${boot_avail_mb}MB)"
    else
        log_info "Proceeding with system upgrade"
    fi
    
    # Full system upgrade with enhanced error handling
    log_info "Running pacman -Syu (this may take several minutes)..."
    if ! safe_pacman pacman -Syu --noconfirm 2>&1 | tee /tmp/pacman-upgrade.log; then
        log_error "System upgrade failed"
        echo ""
        
        # Check for common failure patterns
        if grep -qi "no space left" /tmp/pacman-upgrade.log 2>/dev/null; then
            log_error "Failure caused by: No space left on device"
            
            # Determine which partition is full
            if df /boot &>/dev/null; then
                local boot_free=$(df /boot 2>/dev/null | awk 'NR==2 {print int($4/1024)}')
                local root_free=$(df / 2>/dev/null | awk 'NR==2 {print int($4/1024/1024)}')
                
                echo "Disk space status:"
                echo "  /boot: ${boot_free}MB free"
                echo "  /    : ${root_free}GB free"
            fi
            
            echo ""
            echo "Recovery steps:"
            echo "  1. Clean /boot:"
            echo "     rm -f /boot/*.old /boot/initramfs-linux-fallback.img"
            echo "  2. Clean pacman cache:"
            echo "     pacman -Sc --noconfirm"
            echo "  3. Re-run upgrade:"
            echo "     pacman -Syu --noconfirm"
            echo "  4. Re-run this installer"
            echo ""
            exit 1
        elif grep -qi "could not get lock" /tmp/pacman-upgrade.log 2>/dev/null; then
            log_error "Failure caused by: Another package manager is running"
            echo ""
            echo "Recovery steps:"
            echo "  1. Wait for other package operations to complete"
            echo "  2. Or remove stale lock:"
            echo "     rm -f /var/lib/pacman/db.lck"
            echo "  3. Re-run this installer"
            echo ""
            exit 1
        elif grep -qi "keyring" /tmp/pacman-upgrade.log 2>/dev/null; then
            log_error "Failure caused by: Package signing key issues"
            echo ""
            echo "Recovery steps:"
            echo "  1. Reinitialize pacman keys:"
            echo "     pacman-key --init"
            echo "     pacman-key --populate archlinuxarm"
            echo "  2. Re-run this installer"
            echo ""
            exit 1
        else
            # Generic failure - check if /boot might be an issue
            if df /boot &>/dev/null; then
                local boot_free=$(df /boot 2>/dev/null | awk 'NR==2 {print int($4/1024)}')
                if [ -n "$boot_free" ] && [ "$boot_free" -lt 50 ]; then
                    log_error "Failure likely caused by insufficient /boot space"
                    echo ""
                    echo "Recovery steps:"
                    echo "  1. Clean /boot manually:"
                    echo "     rm -f /boot/*.old /boot/initramfs-linux-fallback.img"
                    echo "  2. Re-run the upgrade:"
                    echo "     pacman -Syu --noconfirm"
                    echo "  3. Re-run this installer"
                    echo ""
                    exit 1
                fi
            fi
            
            # Unknown error
            log_warning "Unknown upgrade failure - attempting to continue with existing packages"
            log_warning "Some features may not work correctly"
            echo ""
            echo "Last 20 lines of upgrade log:"
            tail -20 /tmp/pacman-upgrade.log 2>/dev/null || echo "  (log unavailable)"
            echo ""
            echo "You may want to investigate and fix the issue manually, then re-run this installer"
            sleep 5
            return 0
        fi
    fi
    
    # Verify upgrade actually worked
    local new_glibc=$(ldd --version 2>/dev/null | head -1 | awk '{print $NF}')
    if [ -n "$new_glibc" ]; then
        log_success "System upgrade complete! (glibc ${glibc_version:-unknown} → ${new_glibc})"
    else
        log_success "System upgrade complete!"
    fi
    
    # Clean up log
    rm -f /tmp/pacman-upgrade.log 2>/dev/null || true
}

# Install whiptail (libnewt) for beautiful TUI
install_whiptail() {
    log_info "Installing TUI framework (whiptail)..."
    
    if command -v whiptail &> /dev/null; then
        # Verify whiptail actually works (not just installed)
        if whiptail --version &>/dev/null; then
            log_success "Whiptail already installed and working"
            return 0
        else
            log_warning "Whiptail installed but not working, reinstalling..."
        fi
    fi
    
    # Use safe_pacman wrapper that handles Landlock automatically
    if safe_pacman pacman -S --noconfirm libnewt 2>&1 | tee /tmp/whiptail-install.log; then
        log_success "Whiptail installed"
        rm -f /tmp/whiptail-install.log
        return 0
    fi
    
    # If safe_pacman failed, try manual extraction as last resort
    log_warning "Standard install failed, attempting manual package extraction..."
    if safe_pacman pacman -Sw --noconfirm --cachedir /tmp/pkg-cache libnewt 2>/dev/null; then
        if ls /tmp/pkg-cache/libnewt-*.pkg.tar.* &>/dev/null; then
            cd /
            tar -xf /tmp/pkg-cache/libnewt-*.pkg.tar.* 2>/dev/null
            
            if command -v whiptail &>/dev/null; then
                log_success "Whiptail installed (manual extraction)"
                rm -rf /tmp/pkg-cache /tmp/whiptail-install.log
                return 0
            fi
        fi
    fi
    
    # If we got here, installation failed
    log_error "Failed to install whiptail"
    cat /tmp/whiptail-install.log 2>/dev/null
    echo ""
    log_info "You can try installing manually after reboot:"
    log_info "  pacman -S libnewt"
    exit 1
}

# Download installer
download_installer() {
    log_info "Downloading main installer..."
    
    INSTALL_DIR="/tmp/arch-arm-installer-$$"
    mkdir -p "$INSTALL_DIR"
    
    REPO_URL="https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main"
    
    # Download main installer script
    curl -fsSL "$REPO_URL/installer/main.sh" -o "$INSTALL_DIR/main.sh" || {
        log_error "Failed to download installer"
        log_info "Please check your internet connection and try again"
        exit 1
    }
    
    # Download UI library
    curl -fsSL "$REPO_URL/installer/ui.sh" -o "$INSTALL_DIR/ui.sh" || {
        log_error "Failed to download UI library"
        exit 1
    }
    
    # Download all phase scripts
    mkdir -p "$INSTALL_DIR/phases"
    for phase in 00-welcome 01-user 02-system 03-utm 04-memory 05-sway 06-devtools 07-languages 08-docker 09-databases 10-utilities 11-shell 12-complete; do
        curl -fsSL "$REPO_URL/installer/phases/${phase}.sh" -o "$INSTALL_DIR/phases/${phase}.sh" 2>/dev/null || {
            log_warning "Optional phase ${phase}.sh not found, will use fallback"
        }
    done
    
    chmod +x "$INSTALL_DIR/main.sh"
    
    log_success "Installer downloaded to $INSTALL_DIR"
}

# Main installation flow
main() {
    show_banner
    
    log_info "Starting Arch ARM Development Environment Setup"
    echo
    
    preflight_checks
    init_pacman
    upgrade_system
    install_whiptail
    download_installer
    
    echo
    log_success "Bootstrap complete! Launching installer..."
    echo
    sleep 2
    
    # Launch main installer
    cd "$INSTALL_DIR"
    exec bash "$INSTALL_DIR/main.sh"
}

# Run main function
main "$@"
