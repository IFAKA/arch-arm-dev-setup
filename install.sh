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
        pacman -S --noconfirm --needed parted &>/dev/null || {
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
    local glibc_version=$(ldd --version | head -1 | awk '{print $NF}')
    local needs_upgrade=false
    
    # Simple version check - if glibc is 2.3x where x < 8, we need upgrade
    if [[ $glibc_version =~ ^2\.3[0-7] ]] || [[ $glibc_version =~ ^2\.[0-2] ]]; then
        needs_upgrade=true
    fi
    
    if [ "$needs_upgrade" = false ]; then
        log_info "System packages are up to date"
        return 0
    fi
    
    log_warning "Outdated system detected (glibc $glibc_version < 2.38)"
    log_info "Upgrading system packages (this will take 5-10 minutes)..."
    echo "      This is necessary for UTM Gallery images which are outdated."
    echo "      Your disk has been expanded, so there's plenty of space now."
    echo ""
    
    # Clean /boot to prevent "no space left" errors during kernel upgrade
    log_info "Cleaning /boot partition..."
    rm -f /boot/initramfs-linux-fallback.img.old 2>/dev/null || true
    rm -f /boot/initramfs-linux.img.old 2>/dev/null || true
    rm -f /boot/vmlinuz-linux.old 2>/dev/null || true
    
    # Show available space
    local boot_avail=$(df -h /boot | awk 'NR==2 {print $4}')
    log_info "/boot partition has $boot_avail available"
    
    # Full system upgrade
    pacman -Syu --noconfirm || {
        log_error "System upgrade failed"
        log_info "Attempting to continue anyway..."
        return 0
    }
    
    log_success "System upgrade complete!"
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
    
    pacman -S --noconfirm libnewt
    log_success "Whiptail installed (91.9 KB)"
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
