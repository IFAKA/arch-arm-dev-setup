#!/bin/bash
#
# Arch Linux ARM Post-Installation Script for UTM
# For aarch64/ARM64 virtual machines
# Based on arch-arm-setup-guide.md
#
# Run this script after first boot of Arch Linux ARM in UTM
# Usage: bash arch-arm-post-install.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Progress bar
show_progress() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run this script as root!"
        log_info "Run as regular user. The script will ask for sudo when needed."
        exit 1
    fi
}

# Prompt for user input
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        eval "$var_name=\${input:-$default}"
    else
        read -p "$prompt: " input
        eval "$var_name=\"$input\""
    fi
}

# Phase 1: System Update and Basic Configuration
phase1_system_update() {
    show_progress "Phase 1: System Update and Basic Configuration"
    
    log_info "Initializing pacman keys..."
    sudo pacman-key --init
    sudo pacman-key --populate archlinuxarm
    
    log_info "Updating system packages (this may take 10-20 minutes)..."
    sudo pacman -Syu --noconfirm
    
    # Install base-devel for AUR packages later
    log_info "Installing base development tools..."
    sudo pacman -S --noconfirm base-devel git
    
    log_success "System update completed!"
}

# Phase 2: Configure timezone and hostname
phase2_system_config() {
    show_progress "Phase 2: System Configuration"
    
    prompt_input "Enter timezone (e.g., America/New_York, Europe/London)" "America/New_York" TIMEZONE
    log_info "Setting timezone to $TIMEZONE..."
    sudo timedatectl set-timezone "$TIMEZONE"
    
    prompt_input "Enter hostname" "devbox" HOSTNAME
    log_info "Setting hostname to $HOSTNAME..."
    sudo hostnamectl set-hostname "$HOSTNAME"
    
    log_success "System configuration completed!"
}

# Phase 3: UTM Guest Tools - SPICE for clipboard and shared folders
phase3_utm_integration() {
    show_progress "Phase 3: UTM Integration (Clipboard & Shared Folders)"
    
    log_info "Installing SPICE guest tools for UTM integration..."
    sudo pacman -S --noconfirm spice-vdagent qemu-guest-agent
    
    log_info "Enabling SPICE vdagent for clipboard sharing..."
    sudo systemctl enable spice-vdagentd.service
    sudo systemctl start spice-vdagentd.service
    
    log_info "Enabling QEMU guest agent..."
    sudo systemctl enable qemu-guest-agent.service
    sudo systemctl start qemu-guest-agent.service
    
    # Install virtiofs support for shared folders
    log_info "Setting up shared folder support..."
    sudo pacman -S --noconfirm fuse3
    
    # Create mount point for shared folder
    sudo mkdir -p /mnt/shared
    
    # Add to fstab (user needs to configure this in UTM first)
    if ! grep -q "shared" /etc/fstab; then
        log_info "Adding shared folder mount to /etc/fstab..."
        echo "# UTM Shared Folder" | sudo tee -a /etc/fstab
        echo "shared /mnt/shared virtiofs defaults,nofail 0 0" | sudo tee -a /etc/fstab
    fi
    
    log_success "UTM integration completed!"
    log_info "Note: Configure shared folder in UTM settings with name 'shared'"
    log_info "After configuring, run: sudo mount -a"
}

# Phase 4: Memory Management (zram)
phase4_memory_management() {
    show_progress "Phase 4: Memory Management (zram)"
    
    log_info "Installing zram-generator..."
    sudo pacman -S --noconfirm zram-generator
    
    log_info "Configuring zram..."
    sudo tee /etc/systemd/zram-generator.conf > /dev/null <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
    
    log_info "Configuring swappiness..."
    sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null <<EOF
vm.swappiness = 10
vm.vfs_cache_pressure = 50
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0.service
    sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
    
    log_success "Memory management configured!"
}

# Phase 5: Display Environment (Sway)
phase5_display_environment() {
    show_progress "Phase 5: Display Environment (Sway + Wayland)"
    
    log_info "Installing Sway and Wayland tools..."
    sudo pacman -S --noconfirm \
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
        light
    
    log_info "Creating Sway configuration..."
    mkdir -p ~/.config/sway
    
    cat > ~/.config/sway/config <<'EOF'
# Sway Configuration - One Window, One Screen
set $mod Mod4
set $term foot
set $menu wofi --show drun

# Output configuration
output * resolution 1920x1080

# Idle configuration
exec swayidle -w \
  timeout 300 'swaylock -f -c 000000' \
  timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
  before-sleep 'swaylock -f -c 000000'

# Key bindings
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exit

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2

# Always fullscreen (one window philosophy)
for_window [app_id=".*"] fullscreen enable
for_window [class=".*"] fullscreen enable

# Floating exceptions
for_window [app_id="pavucontrol"] floating enable
for_window [app_id="wofi"] floating enable

# Status bar
bar {
  swaybar_command waybar
}

# Auto-start
exec_always {
  pkill waybar
  waybar
}

# Minimal appearance
default_border none
default_floating_border none
EOF
    
    log_info "Setting up Sway auto-start on login..."
    # Create .zprofile for auto-start (supports both tty1 and ttyAMA0 for UTM)
    cat > ~/.zprofile <<'PROFILE_EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
PROFILE_EOF

    # Also create .bash_profile for bash compatibility
    cat > ~/.bash_profile <<'PROFILE_EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
PROFILE_EOF
    
    log_info "Creating Waybar configuration..."
    mkdir -p ~/.config/waybar
    
    cat > ~/.config/waybar/config <<'EOF'
{
  "layer": "top",
  "position": "top",
  "height": 24,
  "modules-left": ["sway/workspaces"],
  "modules-center": ["sway/window"],
  "modules-right": ["custom/memory", "cpu", "clock"],
  
  "custom/memory": {
    "format": "MEM {}",
    "interval": 5,
    "exec": "free -h | awk '/^Mem:/ {print $3\"/\"$2}'",
    "tooltip": false
  },
  
  "cpu": {
    "format": "CPU {usage}%",
    "interval": 5
  },
  
  "clock": {
    "format": "{:%H:%M}",
    "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
  }
}
EOF
    
    cat > ~/.config/waybar/style.css <<'EOF'
* {
  font-family: monospace;
  font-size: 12px;
  min-height: 0;
}

window#waybar {
  background: #1a1a1a;
  color: #ffffff;
}

#custom-memory, #cpu, #clock {
  padding: 0 10px;
}
EOF
    
    log_success "Display environment configured!"
}

# Phase 6: Development Tools
phase6_dev_tools() {
    show_progress "Phase 6: Development Tools"
    
    log_info "Installing core development tools..."
    sudo pacman -S --noconfirm \
        curl \
        wget \
        unzip \
        zip \
        ripgrep \
        fd \
        fzf \
        jq \
        htop \
        btop \
        tmux \
        neovim
    
    log_info "Configuring tmux..."
    cat > ~/.tmux.conf <<'EOF'
# Minimal tmux config
set -g default-terminal "screen-256color"
set -g history-limit 5000
set -g base-index 1
setw -g pane-base-index 1

# Prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Status bar
set -g status-style bg=black,fg=white
set -g status-left '[#S] '
set -g status-right 'MEM: #(free -h | awk "/^Mem:/ {print \$3}") | %H:%M'
EOF
    
    log_success "Development tools installed!"
}

# Phase 7: Language Runtimes
phase7_language_runtimes() {
    show_progress "Phase 7: Language Runtimes"
    
    # Node.js via nvm
    log_info "Installing Node.js via nvm..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm use --lts
        npm install -g pnpm
    fi
    
    # Go
    log_info "Installing Go..."
    sudo pacman -S --noconfirm go
    
    # Rust
    log_info "Installing Rust..."
    if [ ! -d "$HOME/.cargo" ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        
        mkdir -p ~/.cargo
        cat > ~/.cargo/config.toml <<'EOF'
[build]
jobs = 2

[profile.dev]
debug = 1

[profile.release]
lto = "thin"
EOF
    fi
    
    # Python
    log_info "Installing Python..."
    sudo pacman -S --noconfirm python python-pip python-virtualenv
    
    # C/C++
    log_info "Installing C/C++ toolchain..."
    sudo pacman -S --noconfirm gcc clang cmake ninja
    
    log_success "Language runtimes installed!"
}

# Phase 8: Docker Setup
phase8_docker() {
    show_progress "Phase 8: Docker Setup"
    
    log_info "Installing Docker..."
    sudo pacman -S --noconfirm docker docker-compose
    
    log_info "Configuring Docker for low memory..."
    sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  },
  "default-shm-size": "128M",
  "storage-driver": "overlay2"
}
EOF
    
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    
    log_info "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    
    log_success "Docker installed! You need to log out and back in for docker group to take effect."
}

# Phase 9: Database Tools
phase9_databases() {
    show_progress "Phase 9: Database Tools"
    
    log_info "Installing database clients..."
    sudo pacman -S --noconfirm postgresql-libs redis
    
    log_info "Creating docker-compose template..."
    cat > ~/docker-compose-template.yml <<'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: dev-postgres
    environment:
      POSTGRES_PASSWORD: devpassword
      POSTGRES_USER: devuser
      POSTGRES_DB: devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    mem_limit: 100m
    mem_reservation: 50m

  redis:
    image: redis:7-alpine
    container_name: dev-redis
    ports:
      - "6379:6379"
    mem_limit: 50m
    mem_reservation: 25m

  mongodb:
    image: mongo:7
    container_name: dev-mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: devuser
      MONGO_INITDB_ROOT_PASSWORD: devpassword
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    mem_limit: 150m
    mem_reservation: 100m

volumes:
  postgres-data:
  mongo-data:
EOF
    
    log_success "Database tools and templates created!"
}

# Phase 10: Utility Scripts
phase10_utility_scripts() {
    show_progress "Phase 10: Utility Scripts"
    
    mkdir -p ~/bin
    
    # Memory check script
    cat > ~/bin/check-mem <<'EOF'
#!/bin/bash
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Top Memory Consumers ==="
ps aux --sort=-%mem | head -11
echo ""
echo "=== zram Status ==="
zramctl
EOF
    chmod +x ~/bin/check-mem
    
    # Docker management scripts
    cat > ~/bin/docker-start <<'EOF'
#!/bin/bash
PROFILE=${1:-frontend}
PROJECT_DIR=${2:-$(pwd)}

cd "$PROJECT_DIR"

case $PROFILE in
  frontend)
    docker-compose up -d postgres redis
    echo "✅ Started: PostgreSQL, Redis (~110MB RAM)"
    ;;
  backend)
    docker-compose up -d postgres redis mongodb
    echo "✅ Started: PostgreSQL, Redis, MongoDB (~210MB RAM)"
    ;;
  fullstack)
    docker-compose up -d postgres redis mongodb
    echo "✅ Started: Full stack (~360MB RAM)"
    ;;
  db-only)
    docker-compose up -d postgres redis
    echo "✅ Started: Databases only (~110MB RAM)"
    ;;
  *)
    echo "❌ Unknown profile: $PROFILE"
    echo "Available: frontend, backend, fullstack, db-only"
    exit 1
    ;;
esac

check-mem
EOF
    chmod +x ~/bin/docker-start
    
    cat > ~/bin/docker-stop <<'EOF'
#!/bin/bash
docker-compose down
echo "✅ All containers stopped"
check-mem
EOF
    chmod +x ~/bin/docker-stop
    
    cat > ~/bin/docker-mem <<'EOF'
#!/bin/bash
echo "=== Docker Container Memory Usage ==="
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
EOF
    chmod +x ~/bin/docker-mem
    
    # Memory pressure detection
    cat > ~/bin/mem-pressure <<'EOF'
#!/bin/bash
AVAILABLE=$(free | grep Mem | awk '{print $7}')
TOTAL=$(free | grep Mem | awk '{print $2}')
PERCENT=$((AVAILABLE * 100 / TOTAL))

if [ $PERCENT -lt 20 ]; then
  echo "⚠️  MEMORY PRESSURE DETECTED!"
  echo "Available: ${PERCENT}%"
  echo ""
  echo "Quick fixes:"
  echo "  1. docker-stop       # Stop all containers"
  echo "  2. pkill -f language # Kill LSP servers"
  echo ""
  check-mem
else
  echo "✅ Memory OK (${PERCENT}% available)"
fi
EOF
    chmod +x ~/bin/mem-pressure
    
    # Workflow scripts
    cat > ~/bin/work-frontend <<'EOF'
#!/bin/bash
echo "🚀 Starting Frontend Development"
echo ""

echo "Current memory:"
free -h | grep Mem
echo ""

echo "Starting databases..."
docker-start db-only

swaymsg 'workspace 1' 2>/dev/null || true

echo ""
echo "✅ Frontend Environment Ready!"
echo "   • Workspace 1: Terminal + nvim"
echo "   • Databases running: PostgreSQL, Redis"
echo ""
echo "📊 Expected RAM: ~620MB"
echo ""
check-mem
EOF
    chmod +x ~/bin/work-frontend
    
    cat > ~/bin/work-fullstack <<'EOF'
#!/bin/bash
echo "🚀 Starting Fullstack Development"
echo ""

echo "Current memory:"
free -h | grep Mem
echo ""

echo "Starting all services..."
docker-start fullstack

swaymsg 'workspace 1' 2>/dev/null || true

echo ""
echo "✅ Fullstack Environment Ready!"
echo "   • Workspace 1: Terminal + nvim"
echo "   • All databases running"
echo ""
echo "📊 Expected RAM: ~1.2GB"
echo ""
check-mem
EOF
    chmod +x ~/bin/work-fullstack
    
    log_success "Utility scripts created!"
}

# Phase 11: Shell Configuration
phase11_shell_config() {
    show_progress "Phase 11: Shell Configuration"
    
    log_info "Configuring bash..."
    
    # Backup existing bashrc
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc ~/.bashrc.backup
    fi
    
    cat >> ~/.bashrc <<'EOF'

# === Post-Installation Configuration ===

# PATH
export PATH="$HOME/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Editor
export EDITOR=nvim
export VISUAL=nvim

# Memory management aliases
alias mem='check-mem'
alias memp='mem-pressure'

# Docker aliases
alias dstart='docker-start'
alias dstop='docker-stop'
alias dmem='docker-mem'

# Workflow aliases
alias wf='work-frontend'
alias wfs='work-fullstack'

# Quick shortcuts
alias nv='nvim'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Enhanced prompt with memory
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] [$(free -h | awk "/^Mem:/ {print \$7}")] \$ '
EOF
    
    log_success "Shell configuration updated!"
}

# Phase 12: Install AUR helper (yay) - Optional
phase12_aur_helper() {
    show_progress "Phase 12: AUR Helper (yay) - Optional"
    
    read -p "Install yay AUR helper? (y/N): " install_yay
    if [[ "$install_yay" =~ ^[Yy]$ ]]; then
        log_info "Installing yay..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        log_success "yay installed!"
    else
        log_info "Skipping yay installation"
    fi
}

# Main installation function
main() {
    clear
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════╗
║   Arch Linux ARM Post-Installation Script for UTM        ║
║   Platform: aarch64/ARM64                                 ║
║   For: Fullstack Development with 4GB RAM                 ║
╚═══════════════════════════════════════════════════════════╝

EOF
    
    check_root
    
    log_warning "This script will configure your system for development."
    log_warning "Estimated time: 1-2 hours depending on internet speed."
    echo ""
    read -p "Continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
    
    echo ""
    log_info "Starting installation..."
    echo ""
    
    # Run all phases
    phase1_system_update
    phase2_system_config
    phase3_utm_integration
    phase4_memory_management
    phase5_display_environment
    phase6_dev_tools
    phase7_language_runtimes
    phase8_docker
    phase9_databases
    phase10_utility_scripts
    phase11_shell_config
    phase12_aur_helper
    
    # Final message
    clear
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════╗
║              Installation Complete! 🎉                    ║
╚═══════════════════════════════════════════════════════════╝

Next steps:

1. LOG OUT AND LOG BACK IN (important for docker group)

2. Mount shared folder (if configured in UTM):
   sudo mount -a

3. Sway will start automatically on next login!
   (Or manually run: sway)

4. Quick reference:
   mem          - Check memory usage
   wf           - Start frontend development
   wfs          - Start fullstack development
   dstart       - Start Docker containers
   dstop        - Stop Docker containers

5. UTM Features:
   ✓ Clipboard sharing (automatic with spice-vdagent)
   ✓ Shared folder at /mnt/shared
   
   To configure shared folder in UTM:
   - VM Settings → Sharing
   - Add a shared directory
   - Set name to "shared"
   - Restart VM and run: sudo mount -a

6. Keybindings in Sway:
   Super+Enter  - Open terminal
   Super+1/2    - Switch workspaces
   Super+Shift+Q - Close window
   Super+Shift+E - Exit Sway

Enjoy your optimized development environment!

For more details, see: arch-arm-setup-guide.md
EOF
    
    log_success "Installation script completed successfully!"
}

# Run main function
main
