#!/bin/bash
#
# Arch ARM Dev Setup - Main Installer
# This orchestrates the entire installation process with beautiful TUI
#

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source UI library
source "$SCRIPT_DIR/ui.sh"

# Installation state
INSTALL_LOG="/var/log/arch-arm-setup.log"
INSTALL_STATE="/tmp/arch-arm-install-state.$$"

# User configuration (collected via TUI)
declare -g NEW_USERNAME=""
declare -g NEW_PASSWORD=""
declare -g TIMEZONE=""
declare -g HOSTNAME=""
declare -g SETUP_UTM=false

# Log to file
log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALL_LOG"
}

# Detect if running in UTM/QEMU
detect_utm() {
    if grep -qi qemu /proc/cpuinfo 2>/dev/null || [ -e /dev/vport* ] 2>/dev/null; then
        SETUP_UTM=true
        log_to_file "Detected UTM/QEMU environment"
    else
        SETUP_UTM=false
        log_to_file "Not running in UTM/QEMU"
    fi
}

# Welcome screen
show_welcome() {
    ui_welcome "Welcome to Arch ARM Dev Setup" \
"🚀 Transform your Arch Linux ARM into a complete development environment!

What you'll get:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Complete Development Stack
  • Node.js (LTS via nvm) + pnpm
  • Go, Rust, Python, C/C++
  • Docker with memory optimization
  
✓ Beautiful Window Manager
  • Sway (Wayland) - minimal & battery-optimized
  • Auto-starts on login (zero setup)
  • Terminal ready immediately
  
✓ Databases & Tools
  • PostgreSQL, Redis, MongoDB (Docker)
  • Neovim, tmux, ripgrep, fzf, btop
  
✓ Memory Efficiency
  • zram compression (~6GB effective memory)
  • Optimized for 4GB RAM systems
  • Smart resource management
  
✓ Developer Experience
  • Instant productivity after install
  • Smart aliases and commands
  • Discoverable help system

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Time required: ~60 minutes
Disk space: ~4GB
Internet: Required

Press OK to continue..."

    log_to_file "User accepted welcome screen"
}

# Collect user information
collect_user_info() {
    local username_valid=false
    
    # Get username
    while [ "$username_valid" = false ]; do
        NEW_USERNAME=$(ui_input "Create User Account" \
"Enter your username:

Requirements:
• Lowercase letters, numbers, - or _
• Must start with a letter
• No spaces

This will be your main user account." "dev")
        
        if [ -z "$NEW_USERNAME" ]; then
            ui_msgbox "Error" "Username cannot be empty. Please try again."
            continue
        fi
        
        if ! validate_username "$NEW_USERNAME"; then
            ui_msgbox "Error" "Invalid username: '$NEW_USERNAME'\n\nMust be lowercase, start with a letter, and contain only letters, numbers, - or _\n\nAlso, this user must not already exist."
            continue
        fi
        
        username_valid=true
    done
    
    log_to_file "Username: $NEW_USERNAME"
    
    # Get password
    local password_valid=false
    while [ "$password_valid" = false ]; do
        NEW_PASSWORD=$(ui_password "Create User Account" "Enter password for $NEW_USERNAME:")
        
        if [ -z "$NEW_PASSWORD" ]; then
            ui_msgbox "Error" "Password cannot be empty. Please try again."
            continue
        fi
        
        if [ ${#NEW_PASSWORD} -lt 4 ]; then
            ui_msgbox "Error" "Password must be at least 4 characters long."
            continue
        fi
        
        local password_confirm=$(ui_password "Create User Account" "Confirm password:")
        
        if [ "$NEW_PASSWORD" != "$password_confirm" ]; then
            ui_msgbox "Error" "Passwords do not match. Please try again."
            continue
        fi
        
        password_valid=true
    done
    
    log_to_file "Password set for user"
}

# Collect system configuration
collect_system_config() {
    # Get timezone
    local timezone_valid=false
    while [ "$timezone_valid" = false ]; do
        TIMEZONE=$(ui_input "System Configuration" \
"Enter your timezone:

Examples:
• America/New_York
• Europe/London
• Asia/Tokyo
• UTC

Find yours at: /usr/share/zoneinfo/" "America/New_York")
        
        if validate_timezone "$TIMEZONE"; then
            timezone_valid=true
        else
            ui_msgbox "Error" "Invalid timezone: $TIMEZONE\n\nPlease check /usr/share/zoneinfo/ for valid options."
        fi
    done
    
    log_to_file "Timezone: $TIMEZONE"
    
    # Get hostname
    local hostname_valid=false
    while [ "$hostname_valid" = false ]; do
        HOSTNAME=$(ui_input "System Configuration" "Enter hostname for this machine:\n\n(lowercase, numbers, and - only)" "devbox")
        
        if validate_hostname "$HOSTNAME"; then
            hostname_valid=true
        else
            ui_msgbox "Error" "Invalid hostname: $HOSTNAME\n\nMust contain only lowercase letters, numbers, and hyphens."
        fi
    done
    
    log_to_file "Hostname: $HOSTNAME"
}

# Show configuration summary
show_summary() {
    local utm_status="No"
    [ "$SETUP_UTM" = true ] && utm_status="Yes (clipboard + shared folders will be configured)"
    
    ui_yesno "Confirm Settings" \
"Please review your configuration:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
User Account:
  Username: $NEW_USERNAME
  Password: (hidden)

System:
  Timezone: $TIMEZONE
  Hostname: $HOSTNAME
  
Environment:
  UTM/QEMU detected: $utm_status
  
Installation Profile:
  Complete Development Stack
  (Node.js, Go, Rust, Python, C/C++, Docker)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Estimated time: ~60 minutes

Ready to begin?" || return 1
    
    return 0
}

# Run installation phases with progress
run_installation() {
    log_to_file "Starting installation phases"
    
    {
        # Phase 1: System update (0-15%)
        echo "0"
        echo "XXX"
        echo "Phase 1/12: Updating system packages...\nThis may take 10-15 minutes."
        echo "XXX"
        source "$SCRIPT_DIR/phases/02-system.sh"
        phase_system_update "$NEW_USERNAME" "$TIMEZONE" "$HOSTNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "15"
        echo "XXX"
        echo "Phase 2/12: Creating user account..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/01-user.sh"
        phase_create_user "$NEW_USERNAME" "$NEW_PASSWORD" >> "$INSTALL_LOG" 2>&1
        
        echo "20"
        echo "XXX"
        echo "Phase 3/12: Configuring UTM integration..."
        echo "XXX"
        if [ "$SETUP_UTM" = true ]; then
            source "$SCRIPT_DIR/phases/03-utm.sh"
            phase_utm_integration >> "$INSTALL_LOG" 2>&1
        fi
        
        echo "25"
        echo "XXX"
        echo "Phase 4/12: Setting up memory management (zram)..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/04-memory.sh"
        phase_memory_management >> "$INSTALL_LOG" 2>&1
        
        echo "35"
        echo "XXX"
        echo "Phase 5/12: Installing Sway window manager...\nThis will auto-start on login."
        echo "XXX"
        source "$SCRIPT_DIR/phases/05-sway.sh"
        phase_install_sway "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "45"
        echo "XXX"
        echo "Phase 6/12: Installing development tools...\n(neovim, tmux, ripgrep, fzf, etc.)"
        echo "XXX"
        source "$SCRIPT_DIR/phases/06-devtools.sh"
        phase_dev_tools "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "55"
        echo "XXX"
        echo "Phase 7/12: Installing language runtimes...\n(Node.js, Go, Rust, Python, C/C++)"
        echo "XXX"
        source "$SCRIPT_DIR/phases/07-languages.sh"
        phase_language_runtimes "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "70"
        echo "XXX"
        echo "Phase 8/12: Setting up Docker..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/08-docker.sh"
        phase_docker_setup "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "80"
        echo "XXX"
        echo "Phase 9/12: Installing database tools..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/09-databases.sh"
        phase_database_tools "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "85"
        echo "XXX"
        echo "Phase 10/12: Creating utility scripts..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/10-utilities.sh"
        phase_utility_scripts "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "90"
        echo "XXX"
        echo "Phase 11/12: Configuring shell and aliases..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/11-shell.sh"
        phase_shell_config "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "95"
        echo "XXX"
        echo "Phase 12/12: Finalizing setup..."
        echo "XXX"
        source "$SCRIPT_DIR/phases/12-complete.sh"
        phase_complete "$NEW_USERNAME" >> "$INSTALL_LOG" 2>&1
        
        echo "100"
        echo "XXX"
        echo "Installation complete! 🎉"
        echo "XXX"
        
    } | whiptail --title "Installing Development Environment" --gauge "Starting installation..." 10 70 0
    
    log_to_file "Installation completed successfully"
}

# Show completion and reboot
show_completion() {
    local countdown=10
    
    ui_welcome "Installation Complete! 🎉" \
"Your development environment is ready!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What happens next:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. System will reboot automatically
2. Login as: $NEW_USERNAME
3. Sway will start automatically
4. Terminal opens with welcome message
5. Start coding immediately!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quick Commands (available after login):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

help     Show all commands and keybindings
wf       Start frontend development workflow
wfs      Start fullstack development workflow
mem      Check memory usage
dstart   Start Docker containers
dstop    Stop Docker containers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sway Keybindings:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Super+Enter      Open terminal
Super+d          Application launcher
Super+1/2        Switch workspaces
Super+Shift+Q    Close window
Super+Shift+E    Exit Sway

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The system will reboot in ${countdown} seconds..."

    # Countdown and reboot
    for ((i=countdown; i>0; i--)); do
        sleep 1
    done
    
    # Mark installation as complete
    touch /etc/arch-arm-dev-setup-installed
    echo "$NEW_USERNAME" > /etc/arch-arm-dev-setup-user
    
    log_to_file "Rebooting system"
    
    # Reboot
    systemctl reboot
}

# Main installation flow
main() {
    # Initialize logging
    mkdir -p "$(dirname "$INSTALL_LOG")"
    log_to_file "=== Arch ARM Dev Setup Installation Started ==="
    log_to_file "Script directory: $SCRIPT_DIR"
    
    # Detect environment
    detect_utm
    
    # TUI flow
    show_welcome
    collect_user_info
    collect_system_config
    
    # Confirm before proceeding
    if ! show_summary; then
        ui_msgbox "Installation Cancelled" "Setup has been cancelled. No changes were made to your system."
        log_to_file "Installation cancelled by user"
        exit 0
    fi
    
    # Run installation
    run_installation || {
        ui_error_and_exit "Installation Failed" "An error occurred during installation." "$INSTALL_LOG"
    }
    
    # Show completion and reboot
    show_completion
}

# Run main
main "$@"
