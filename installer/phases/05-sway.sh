#!/bin/bash
#
# Phase 5: Sway Window Manager with Auto-Start
# This delivers the BEST DX: auto-starts GUI on login, terminal ready immediately
#

phase_install_sway() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 5] Installing Sway and Wayland environment..."
    
    # Install Sway and essential tools
    pacman -S --noconfirm \
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
        yt-dlp \
        imv
    
    echo "[Phase 5] Creating Sway configuration..."
    
    # Create config directory
    mkdir -p "$user_home/.config/sway"
    
    # Create Sway config with auto-terminal
    cat > "$user_home/.config/sway/config" <<'EOF'
# Sway Configuration - Optimized for Development
# One Window, One Screen Philosophy

set $mod Mod4
set $term foot
set $menu wofi --show drun

# Output configuration
output * resolution 1920x1080

# Idle configuration (screen timeout)
exec swayidle -w \
  timeout 600 'swaylock -f -c 000000' \
  timeout 900 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
  before-sleep 'swaylock -f -c 000000'

# Key bindings - Basic
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exit

# Applications
bindsym $mod+w exec firefox
bindsym $mod+n exec $term -e nvim

# Window cycling (like Alt+Tab)
bindsym $mod+Tab focus next
bindsym $mod+Shift+Tab focus prev

# Movement
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# Resize mode (Super+r to enter, arrow keys to resize, Escape to exit)
mode "resize" {
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4

# Fullscreen mode (one window philosophy)
bindsym $mod+f fullscreen

# Floating windows
floating_modifier $mod normal
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

# Floating exceptions
for_window [app_id="pavucontrol"] floating enable
for_window [app_id="wofi"] floating enable

# Status bar
bar {
  swaybar_command waybar
}

# Auto-start applications
exec_always {
  pkill waybar
  waybar
}

# 🚀 BEST DX: Auto-open terminal on startup with welcome message
exec foot -e zsh -c 'if [ -f ~/.first-login ]; then cat ~/.welcome-message.txt; echo ""; echo "Press Enter to continue..."; read; rm ~/.first-login; fi; exec zsh'

# Minimal appearance
default_border pixel 2
default_floating_border pixel 2
gaps inner 5
gaps outer 0

# Colors (minimal dark theme)
client.focused          #4c7899 #285577 #ffffff #2e9ef4 #285577
client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
client.unfocused        #333333 #222222 #888888 #292d2e #222222
EOF

    # Create Waybar config
    mkdir -p "$user_home/.config/waybar"
    
    cat > "$user_home/.config/waybar/config" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["sway/workspaces", "sway/mode"],
  "modules-center": ["sway/window"],
  "modules-right": ["custom/memory", "cpu", "battery", "clock"],
  
  "sway/workspaces": {
    "disable-scroll": false,
    "all-outputs": true,
    "format": "{name}"
  },
  
  "custom/memory": {
    "format": "MEM {}",
    "interval": 5,
    "exec": "free -h | awk '/^Mem:/ {print $3\"/\"$2}'",
    "tooltip": false
  },
  
  "cpu": {
    "format": "CPU {usage}%",
    "interval": 5,
    "tooltip": false
  },
  
  "battery": {
    "format": "BAT {capacity}%",
    "format-charging": "CHG {capacity}%",
    "format-discharging": "BAT {capacity}%",
    "format-full": "FULL",
    "interval": 30,
    "states": {
      "warning": 30,
      "critical": 15
    }
  },
  
  "clock": {
    "format": "{:%H:%M}",
    "format-alt": "{:%Y-%m-%d %H:%M:%S}",
    "tooltip-format": "{:%Y-%m-%d | %H:%M:%S}"
  }
}
EOF
    
    cat > "$user_home/.config/waybar/style.css" <<'EOF'
* {
  font-family: monospace;
  font-size: 13px;
  min-height: 0;
}

window#waybar {
  background: #1a1a1a;
  color: #ffffff;
  border-bottom: 2px solid #285577;
}

#workspaces button {
  padding: 0 8px;
  background: transparent;
  color: #ffffff;
  border: none;
}

#workspaces button.focused {
  background: #285577;
}

#workspaces button.urgent {
  background: #c9545d;
}

#custom-memory, #cpu, #battery, #clock, #mode, #window {
  padding: 0 10px;
}

#battery.warning {
  color: #ff9900;
}

#battery.critical {
  color: #ff0000;
}
EOF
    
    # 🚀 BEST DX: Auto-start Sway on login to tty1
    # Create .bash_profile (for Bash fallback compatibility)
    cat > "$user_home/.bash_profile" <<'EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
EOF
    
    # Create .zprofile (for Zsh - the default shell)
    cat > "$user_home/.zprofile" <<'EOF'
# Auto-start Sway on login (tty1 or ttyAMA0 for UTM serial console)
if [ -z "$WAYLAND_DISPLAY" ]; then
    local current_tty=$(tty)
    if [ "$current_tty" = "/dev/tty1" ] || [ "$current_tty" = "/dev/ttyAMA0" ]; then
        echo "Starting Sway..."
        exec sway
    fi
fi
EOF
    
    # Create welcome message (shown once on first login)
    cat > "$user_home/.welcome-message.txt" <<'EOF'
================================================================
             Welcome to Your Development Environment!            
================================================================

  Shell: Zsh with Starship prompt (git-aware, beautiful)
  Editor: Neovim with VimZap (12ms startup, LazyVim DX)

  Quick Commands:
  ----------------------------------------------------------------
  v, vi, vim    Open Neovim (press Space for menu)
  help          Show all commands and keybindings
  wf            Start frontend dev (Postgres + Redis)
  wfs           Start fullstack dev (all databases)
  mem           Check memory usage
  dstart        Start Docker containers
  dstop         Stop Docker containers

  Neovim (VimZap) Quick Start:
  ----------------------------------------------------------------
  Space         Command menu (shows all keybindings)
  Space + e     File explorer
  Space + ff    Find files (fuzzy search)
  Space + fg    Grep in files
  Space + gg    LazyGit
  Space + ?     Show all keymaps

  Sway Keybindings:
  ----------------------------------------------------------------
  Super+Enter          Open new terminal
  Super+w              Open Firefox browser
  Super+n              Open Neovim in terminal
  Super+d              Application launcher
  Super+Tab            Switch between windows
  Super+1/2/3/4        Switch to workspace 1/2/3/4
  Super+f              Toggle fullscreen
  Super+r              Resize mode
  Super+Shift+Q        Close window
  Super+Shift+E        Exit Sway

  Media Commands:
  ----------------------------------------------------------------
  ytplay <url>         Watch YouTube in mpv
  ytsearch <terms>     Search and play YouTube
  web                  Open Firefox

  Documentation:
  ----------------------------------------------------------------
  ~/QUICKSTART.md      Comprehensive guide
  help                 Quick command reference

  This message will only show once.
  Type 'help' anytime to see all commands.

================================================================
EOF
    
    # Create first-login marker (will be deleted after first display)
    touch "$user_home/.first-login"
    
    # Configure mpv for memory-efficient video playback
    echo "Configuring mpv..."
    mkdir -p "$user_home/.config/mpv"
    
    cat > "$user_home/.config/mpv/mpv.conf" <<'EOF'
# mpv Configuration - Memory-Optimized for 4GB RAM
# ═══════════════════════════════════════════════════

# Video settings (720p max to save memory)
ytdl-format=bestvideo[height<=720]+bestaudio/best[height<=720]

# Hardware decoding (if available)
hwdec=auto

# Cache settings (memory-friendly)
cache=yes
demuxer-max-bytes=50M
demuxer-max-back-bytes=20M

# Performance
vo=gpu
profile=gpu-hq
scale=bilinear
cscale=bilinear

# Audio
volume=70
volume-max=100

# OSD settings
osd-level=1
osd-duration=2000

# Screenshot
screenshot-format=png
screenshot-directory=~/Pictures

# Keep window open after playback
keep-open=yes
EOF
    
    # Set ownership
    chown -R "$username:$username" "$user_home/.config"
    chown "$username:$username" "$user_home/.bash_profile"
    chown "$username:$username" "$user_home/.zprofile"
    chown "$username:$username" "$user_home/.welcome-message.txt"
    chown "$username:$username" "$user_home/.first-login"
    
    echo "[Phase 5] Sway installed and configured with auto-start"
    echo "  ✓ Auto-start configured for both Bash and Zsh"
    echo "  ✓ Firefox, mpv, and yt-dlp installed"
    echo "  ✓ Window switching (Super+Tab) configured"
}
