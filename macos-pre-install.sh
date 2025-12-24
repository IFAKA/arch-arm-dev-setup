#!/bin/bash
#
# macOS Pre-Install Script for Arch ARM Dev Setup
# Prepares UTM Gallery VM before first boot
#
# Usage: curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/macos-pre-install.sh | bash
#

set -euo pipefail

# Colors for output
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
================================================================
             Arch ARM Dev Setup - macOS Pre-Install            
================================================================

This script will:
  1. Check if UTM is installed
  2. Check if Arch Linux ARM VM exists
  3. Install qemu tools (if needed)
  4. Resize the VM disk to 32GB
  5. Provide instructions for next steps

Press Ctrl+C to cancel, or Enter to continue...
EOF
    read -r
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is for macOS only"
        log_info "Detected OS: $OSTYPE"
        exit 1
    fi
    log_success "Running on macOS"
}

# Check if UTM is installed
check_utm() {
    log_info "Checking for UTM..."
    
    if [ -d "/Applications/UTM.app" ]; then
        log_success "UTM is installed"
        return 0
    fi
    
    log_warning "UTM is not installed in /Applications/"
    log_info ""
    log_info "Please install UTM first:"
    log_info "  1. Visit: https://mac.getutm.app/"
    log_info "  2. Download UTM"
    log_info "  3. Move UTM.app to /Applications/"
    log_info ""
    log_info "After installing UTM, download Arch Linux ARM:"
    log_info "  Visit: https://mac.getutm.app/gallery/archlinux-arm"
    log_info "  Click 'Open in UTM'"
    log_info ""
    log_info "Then run this script again."
    exit 1
}

# Find Arch Linux ARM VM
find_arch_vm() {
    log_info "Looking for Arch Linux ARM VM..."
    
    local possible_locations=(
        "$HOME/Downloads/ArchLinux.utm"
        "$HOME/Library/Containers/com.utmapp.UTM/Data/Documents/ArchLinux.utm"
        "$HOME/Documents/ArchLinux.utm"
    )
    
    for location in "${possible_locations[@]}"; do
        if [ -d "$location" ]; then
            VM_PATH="$location"
            log_success "Found VM at: $VM_PATH"
            return 0
        fi
    done
    
    log_warning "Could not find Arch Linux ARM VM in common locations"
    log_info ""
    log_info "Please download the VM first:"
    log_info "  1. Visit: https://mac.getutm.app/gallery/archlinux-arm"
    log_info "  2. Click 'Open in UTM'"
    log_info "  3. Let it download to ~/Downloads/ArchLinux.utm"
    log_info ""
    log_info "Or if you already downloaded it, please enter the path:"
    read -p "Path to ArchLinux.utm (or press Enter to exit): " custom_path
    
    if [ -z "$custom_path" ]; then
        exit 1
    fi
    
    if [ -d "$custom_path" ]; then
        VM_PATH="$custom_path"
        log_success "Using VM at: $VM_PATH"
        return 0
    else
        log_error "Path does not exist: $custom_path"
        exit 1
    fi
}

# Check if qemu-img is installed
check_qemu() {
    log_info "Checking for qemu-img..."
    
    if command -v qemu-img &> /dev/null; then
        log_success "qemu-img is already installed"
        QEMU_IMG="qemu-img"
        return 0
    fi
    
    log_warning "qemu-img not found"
    log_info "Installing qemu via Homebrew..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is not installed"
        log_info ""
        log_info "Please install Homebrew first:"
        log_info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        log_info ""
        exit 1
    fi
    
    log_info "Running: brew install qemu"
    brew install qemu
    
    log_success "qemu installed successfully"
    QEMU_IMG="qemu-img"
}

# Get current disk info
get_disk_info() {
    log_info "Analyzing VM disk..."
    
    cd "$VM_PATH/Data" || exit 1
    
    # Find the largest .qcow2 file (the main disk)
    DISK_FILE=$(ls -S *.qcow2 2>/dev/null | head -1)
    
    if [ -z "$DISK_FILE" ]; then
        log_error "No .qcow2 disk files found in $VM_PATH/Data"
        exit 1
    fi
    
    log_info "Main disk file: $DISK_FILE"
    
    # Get current size
    CURRENT_INFO=$($QEMU_IMG info "$DISK_FILE")
    CURRENT_SIZE=$(echo "$CURRENT_INFO" | grep "virtual size" | awk '{print $3}')
    
    log_info "Current virtual size: $CURRENT_SIZE"
    
    echo "$CURRENT_INFO"
}

# Resize disk
resize_disk() {
    local target_size="${1:-32G}"
    
    log_info "Resizing disk to $target_size..."
    log_warning "Make sure the VM is NOT running!"
    log_info ""
    read -p "Is the VM shut down? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Please shut down the VM first, then run this script again"
        exit 1
    fi
    
    cd "$VM_PATH/Data" || exit 1
    
    log_info "Running: qemu-img resize \"$DISK_FILE\" $target_size"
    
    if $QEMU_IMG resize "$DISK_FILE" "$target_size"; then
        log_success "Disk resized successfully!"
        echo ""
        log_info "New disk info:"
        $QEMU_IMG info "$DISK_FILE" | grep -E "(file format|virtual size|disk size)"
    else
        log_error "Failed to resize disk"
        exit 1
    fi
}

# Show next steps
show_next_steps() {
    cat << 'EOF'

================================================================
                    Setup Complete!                            
================================================================

Your Arch Linux ARM VM is ready with a 32GB disk.

Next steps:
================================================================

1. Start the VM in UTM
   - Open UTM.app
   - Click on "ArchLinux" VM
   - Click the Play button

2. Login as root
   Username: root
   Password: root

3. Run the installer with ONE command:
   
   curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash

4. Follow the TUI wizard:
   - Enter your username
   - Enter your password
   - Confirm timezone (auto-detected)
   - Confirm hostname
   - Wait ~60 minutes for installation

5. After reboot, login with your new username
   - Sway will start automatically
   - Terminal will open with welcome message
   - Start coding!

================================================================
Need help? Check the documentation:
  https://github.com/IFAKA/arch-arm-dev-setup
================================================================

EOF
}

# Main function
main() {
    show_banner
    check_macos
    check_utm
    find_arch_vm
    check_qemu
    
    echo ""
    log_info "Current disk configuration:"
    echo "================================================================"
    get_disk_info
    echo "================================================================"
    echo ""
    
    # Ask for target size
    log_info "Recommended disk size: 32GB"
    read -p "Enter disk size (default: 32G): " target_size
    target_size="${target_size:-32G}"
    
    resize_disk "$target_size"
    
    show_next_steps
}

# Run main function
main "$@"
