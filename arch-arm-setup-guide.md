# 🚀 Arch Linux ARM Setup Guide
## For 4GB RAM Fullstack Development with Discipline

> **ADHD-Friendly Guide**: Each section has clear checkboxes. Complete one section at a time. Take breaks between phases!

---

## 📋 Table of Contents

1. [Pre-Installation Checklist](#-pre-installation-checklist)
2. [Phase 1: Base System Installation](#-phase-1-base-system-installation-1-hour)
3. [Phase 2: Memory Management](#-phase-2-memory-management-30-min)
4. [Phase 3: Display Environment (Sway)](#-phase-3-display-environment-sway-1-hour)
5. [Phase 4: Browser Setup](#-phase-4-browser-setup-30-min)
6. [Phase 5: Development Tools](#-phase-5-development-tools-1-hour)
7. [Phase 6: Language Runtimes](#-phase-6-language-runtimes-2-hours)
8. [Phase 7: Docker Setup](#-phase-7-docker-setup-1-hour)
9. [Phase 8: Databases](#-phase-8-databases-30-min)
10. [Phase 9: Power Optimization](#-phase-9-power-optimization-30-min)
11. [Phase 10: Workflow Scripts](#-phase-10-workflow-automation-1-hour)
12. [Daily Usage Guide](#-daily-usage-guide)

**Total Time: 4-6 hours** (spread over multiple sessions is OK!)

---

## 🎯 Pre-Installation Checklist

### What You Need

- [ ] ARM device (Raspberry Pi 4/5 or similar) with 4GB RAM
- [ ] SD card (32GB minimum, 64GB+ recommended)
- [ ] SD card reader
- [ ] Another computer to flash the SD card
- [ ] Internet connection (Ethernet recommended for setup)
- [ ] Keyboard and display
- [ ] 2-3 hours of uninterrupted time for initial setup

### ⚠️ WARNING: This Will Erase Your SD Card

**BACKUP ANY IMPORTANT DATA FIRST!**

### What This Setup Gives You

✅ Minimal RAM usage (~300MB idle)  
✅ One-window, one-screen workflow  
✅ Docker with discipline (stop/start as needed)  
✅ Browser that closes when compiling  
✅ All languages: TypeScript, Go, Rust, Python, C/C++  
✅ All databases: PostgreSQL, MongoDB, Redis, SQLite  
✅ Maximum battery life (16h on 200Wh possible)  

---

## 🔧 Phase 1: Base System Installation (1 hour)

### Step 1.1: Download Arch Linux ARM

**On your other computer:**

- [ ] Go to https://archlinuxarm.org/
- [ ] Find your device (likely Raspberry Pi 4 or 5)
- [ ] Download the `.tar.gz` file
- [ ] Verify the download completed (check file size)

**Expected file:** `ArchLinuxARM-aarch64-latest.tar.gz` (~500MB)

---

### Step 1.2: Prepare SD Card

**⚠️ CAREFUL: This erases everything on the SD card!**

#### On Linux/macOS:

```bash
# 1. Insert SD card and identify it (CAREFUL!)
lsblk

# Look for your SD card (usually /dev/mmcblk0 or /dev/sdX)
# It should match your SD card size

# 2. Unmount if mounted
sudo umount /dev/mmcblk0p1
sudo umount /dev/mmcblk0p2

# 3. Create partitions
sudo fdisk /dev/mmcblk0
```

**In fdisk, type these commands exactly:**

```
o       (create new DOS partition table)
n       (new partition)
p       (primary)
1       (partition number)
[Enter] (default first sector)
+200M   (200MB for boot)
t       (change type)
c       (W95 FAT32)
n       (new partition)
p       (primary)
2       (partition number)
[Enter] (default first sector)
[Enter] (default last sector - use remaining space)
w       (write changes and exit)
```

**Checkpoint:** 
- [ ] You should see two partitions: `mmcblk0p1` and `mmcblk0p2`

---

### Step 1.3: Format Partitions

```bash
# Format boot partition (FAT32)
sudo mkfs.vfat /dev/mmcblk0p1

# Format root partition (ext4)
sudo mkfs.ext4 /dev/mmcblk0p2
```

**Checkpoint:**
- [ ] Both commands completed without errors

---

### Step 1.4: Mount and Extract

```bash
# Create mount points
sudo mkdir -p /mnt/arch-arm
sudo mount /dev/mmcblk0p2 /mnt/arch-arm
sudo mkdir -p /mnt/arch-arm/boot
sudo mount /dev/mmcblk0p1 /mnt/arch-arm/boot

# Extract Arch Linux ARM (this takes 5-10 minutes)
cd ~/Downloads  # Or wherever you downloaded the file
sudo tar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C /mnt/arch-arm

# Sync to ensure all data is written
sync

# Unmount
sudo umount /mnt/arch-arm/boot
sudo umount /mnt/arch-arm
```

**Checkpoint:**
- [ ] Extraction completed without errors
- [ ] Unmount completed without errors

---

### Step 1.5: First Boot

- [ ] Insert SD card into your ARM device
- [ ] Connect Ethernet cable
- [ ] Connect keyboard and display
- [ ] Power on

**Wait for login prompt** (takes 1-2 minutes first boot)

**Default credentials:**
- Username: `alarm`
- Password: `alarm`

**Root password:** `root`

---

### Step 1.6: Initial Configuration

**Login as alarm, then become root:**

```bash
# Login as alarm (password: alarm)

# Switch to root
su
# Password: root
```

**Now run these commands one by one:**

```bash
# 1. Initialize pacman
pacman-key --init
pacman-key --populate archlinuxarm

# 2. Update system (this takes 10-20 minutes)
pacman -Syu
# Press Y when asked

# 3. Set timezone (change to yours)
timedatectl set-timezone America/New_York

# 4. Set hostname
hostnamectl set-hostname devbox

# 5. Create your user (replace 'yourname' with your username)
useradd -m -G wheel -s /bin/bash yourname
passwd yourname
# Enter your password twice

# 6. Enable sudo
pacman -S sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# 7. Reboot
reboot
```

**Checkpoint:**
- [ ] System rebooted successfully
- [ ] You can login with your new username

**🎉 BREAK TIME! Stretch, hydrate, celebrate Phase 1 completion!**

---

## 💾 Phase 2: Memory Management (30 min)

**Goal:** Setup compressed RAM to get effective ~6GB total memory

### Step 2.1: Install zram

```bash
# Install zram-generator
sudo pacman -S zram-generator
```

---

### Step 2.2: Configure zram

```bash
# Create config file
sudo nano /etc/systemd/zram-generator.conf
```

**Paste this (Ctrl+Shift+V):**

```
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### Step 2.3: Enable zram

```bash
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service

# Verify it worked
free -h
zramctl
```

**Checkpoint:**
- [ ] You should see ~2GB zram in `free -h`
- [ ] `zramctl` shows zram0 device

---

### Step 2.4: Optimize Swappiness

```bash
# Create config file
sudo nano /etc/sysctl.d/99-swappiness.conf
```

**Paste this:**

```
vm.swappiness = 10
vm.vfs_cache_pressure = 50
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Apply immediately
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

---

### Step 2.5: Create Memory Check Script

```bash
# Create bin directory
mkdir -p ~/bin

# Create script
nano ~/bin/check-mem
```

**Paste this:**

```bash
#!/bin/bash
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Top Memory Consumers ==="
ps aux --sort=-%mem | head -11
echo ""
echo "=== zram Status ==="
zramctl
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Make executable
chmod +x ~/bin/check-mem

# Add to PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Test it
check-mem
```

**Checkpoint:**
- [ ] `check-mem` shows your memory status
- [ ] Total memory appears higher than 4GB

**🎉 BREAK TIME! Memory management is done!**

---

## 🎨 Phase 3: Display Environment (Sway) (1 hour)

**Goal:** Install minimal Wayland compositor with one-window workflow

### Step 3.1: Install Sway and Tools

```bash
sudo pacman -S \
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
```

**This takes 5-10 minutes. Wait for it to complete.**

**Checkpoint:**
- [ ] All packages installed without errors

---

### Step 3.2: Configure Sway

```bash
# Create config directory
mkdir -p ~/.config/sway

# Create config file
nano ~/.config/sway/config
```

**Paste this entire config:**

```
# Sway Configuration - One Window, One Screen
set $mod Mod4
set $term foot
set $menu wofi --show drun

# Output configuration
output * resolution 1920x1080

# Idle configuration (screen off after 5 minutes)
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
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### Step 3.3: Configure Waybar

```bash
# Create waybar directory
mkdir -p ~/.config/waybar

# Create config
nano ~/.config/waybar/config
```

**Paste this:**

```json
{
  "layer": "top",
  "position": "top",
  "height": 24,
  "modules-left": ["sway/workspaces"],
  "modules-center": ["sway/window"],
  "modules-right": ["custom/memory", "cpu", "battery", "clock"],
  
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
  
  "battery": {
    "format": "BAT {capacity}%",
    "format-charging": "CHG {capacity}%",
    "format-plugged": "PWR {capacity}%"
  },
  
  "clock": {
    "format": "{:%H:%M}",
    "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
  }
}
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Create style
nano ~/.config/waybar/style.css
```

**Paste this:**

```css
* {
  font-family: monospace;
  font-size: 12px;
  min-height: 0;
}

window#waybar {
  background: #1a1a1a;
  color: #ffffff;
}

#custom-memory, #cpu, #battery, #clock {
  padding: 0 10px;
}
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### Step 3.4: Start Sway

```bash
# From the terminal, type:
sway
```

**You should see:**
- Black screen with waybar at top
- Press `Super+Enter` (Windows key + Enter) to open terminal

**Checkpoint:**
- [ ] Sway launched successfully
- [ ] Waybar shows at top with memory/CPU/time
- [ ] Super+Enter opens terminal
- [ ] Super+1 and Super+2 switch workspaces

**To exit Sway:** Press `Super+Shift+E`

**🎉 BREAK TIME! Display environment is working!**

---

## 🌐 Phase 4: Browser Setup (30 min)

**Goal:** Install lightweight browser with Wayland support

### Step 4.1: Install AUR Helper (yay)

```bash
# Install dependencies
sudo pacman -S base-devel git

# Clone yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay

# Build and install
makepkg -si
# Press Y when asked
```

**Checkpoint:**
- [ ] yay installed successfully
- [ ] `yay --version` shows version number

---

### Step 4.2: Install Ungoogled Chromium

```bash
# This takes 10-20 minutes on ARM
yay -S ungoogled-chromium-bin

# Press Y when asked
```

---

### Step 4.3: Create Browser Config

```bash
# Create config directory
mkdir -p ~/.config

# Create flags file
nano ~/.config/chromium-flags.conf
```

**Paste this:**

```
--ozone-platform=wayland
--enable-features=VaapiVideoDecoder
--enable-zero-copy
--process-per-site
--disable-sync
--disable-background-networking
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### Step 4.4: Create Browser Scripts

```bash
# Browser launcher
nano ~/bin/browser
```

**Paste:**

```bash
#!/bin/bash
chromium $(cat ~/.config/chromium-flags.conf | grep -v '^#' | tr '\n' ' ')
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/browser
```

---

```bash
# Browser close script
nano ~/bin/browser-close
```

**Paste:**

```bash
#!/bin/bash
pkill -15 chromium
echo "Browser closed. ~350MB RAM freed!"
check-mem
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/browser-close
```

---

```bash
# Quick launch on workspace 2
nano ~/bin/browser-quick
```

**Paste:**

```bash
#!/bin/bash
swaymsg 'workspace 2'
~/bin/browser &
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/browser-quick
```

**Checkpoint:**
- [ ] `browser` command launches Chromium
- [ ] Browser opens in fullscreen
- [ ] `browser-close` kills browser

**🎉 BREAK TIME! Browser is ready!**

---

## 🛠️ Phase 5: Development Tools (1 hour)

**Goal:** Install essential development tools

### Step 5.1: Core Tools

```bash
sudo pacman -S \
  git \
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
```

**Checkpoint:**
- [ ] All packages installed successfully

---

### Step 5.2: Configure tmux

```bash
nano ~/.tmux.conf
```

**Paste:**

```
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
```

**Save:** Ctrl+O, Enter, Ctrl+X

**Test:** Type `tmux` and you should see tmux session

---

### Step 5.3: Setup Neovim (Your vimzap)

**If you have vimzap on another machine:**

```bash
# Option A: Clone from your repo
git clone YOUR_VIMZAP_REPO_URL ~/.config/nvim

# Option B: Copy from your other computer
# Use scp or USB drive
```

**If starting fresh:**

```bash
# Clone a minimal config (or skip if you have vimzap)
git clone https://github.com/yourusername/vimzap ~/.config/nvim
```

**Install Mason and LSPs on first nvim use:**

```bash
# Open nvim
nvim

# Mason will auto-install on first run
# Wait for LSP servers to install (5-10 minutes)
# Then quit: :q
```

**Checkpoint:**
- [ ] nvim opens without errors
- [ ] Mason installed LSP servers

**🎉 BREAK TIME! Core tools ready!**

---

## 🔨 Phase 6: Language Runtimes (2 hours)

**This is the longest phase. You can do it in chunks!**

### Step 6.1: Node.js (via nvm)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Add to bashrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Reload shell
source ~/.bashrc

# Install Node.js LTS (takes 5-10 min on ARM)
nvm install --lts
nvm use --lts

# Install pnpm
npm install -g pnpm

# Verify
node --version
npm --version
pnpm --version
```

**Checkpoint:**
- [ ] Node.js version shows (v20.x or newer)
- [ ] npm and pnpm work

**Take a 5 minute break!**

---

### Step 6.2: Go

```bash
sudo pacman -S go

# Configure environment
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# Verify
go version
```

**Checkpoint:**
- [ ] Go version shows (1.21 or newer)

---

### Step 6.3: Rust

```bash
# Install rustup (takes 10-15 min on ARM)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Select: 1 (default installation)
# Wait for installation...

# Load environment
source $HOME/.cargo/env

# Configure for low memory
mkdir -p ~/.cargo
nano ~/.cargo/config.toml
```

**Paste:**

```toml
[build]
jobs = 2

[profile.dev]
debug = 1

[profile.release]
lto = "thin"
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Verify
rustc --version
cargo --version
```

**Checkpoint:**
- [ ] Rust version shows (1.70+ or newer)

**Take a 10 minute break! Rust compilation is heavy.**

---

### Step 6.4: Python

```bash
sudo pacman -S python python-pip python-virtualenv

# Verify
python --version
pip --version
```

**Checkpoint:**
- [ ] Python 3.x shows

---

### Step 6.5: C/C++ Toolchain

```bash
sudo pacman -S gcc clang cmake ninja

# Verify
gcc --version
clang --version
```

**Checkpoint:**
- [ ] gcc and clang show versions

**🎉 BIG BREAK TIME! All languages installed!**

---

## 🐳 Phase 7: Docker Setup (1 hour)

**Goal:** Setup Docker with memory discipline

### Step 7.1: Install Docker

```bash
sudo pacman -S docker docker-compose

# Enable and start
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Add your user to docker group
sudo usermod -aG docker $USER
```

**⚠️ IMPORTANT: You must log out and log back in for docker group to work!**

```bash
# Log out and back in, then verify:
docker --version
docker ps
```

**Checkpoint:**
- [ ] docker commands work without sudo

---

### Step 7.2: Configure Docker for Low Memory

```bash
sudo nano /etc/docker/daemon.json
```

**Paste:**

```json
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
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Restart Docker
sudo systemctl restart docker
```

---

### Step 7.3: Create Docker Management Scripts

```bash
# Docker start script
nano ~/bin/docker-start
```

**Paste:**

```bash
#!/bin/bash
# Usage: docker-start <profile>

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
    docker-compose up -d postgres redis mongodb backend
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
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/docker-start
```

---

```bash
# Docker stop script
nano ~/bin/docker-stop
```

**Paste:**

```bash
#!/bin/bash
docker-compose down
echo "✅ All containers stopped"
check-mem
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/docker-stop
```

---

```bash
# Docker memory check
nano ~/bin/docker-mem
```

**Paste:**

```bash
#!/bin/bash
echo "=== Docker Container Memory Usage ==="
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/docker-mem
```

**Checkpoint:**
- [ ] docker-start, docker-stop, docker-mem scripts created

**🎉 BREAK TIME! Docker is ready!**

---

## 🗄️ Phase 8: Databases (30 min)

**Goal:** Create Docker Compose template for databases

### Step 8.1: Create docker-compose Template

```bash
# Create template
nano ~/docker-compose-template.yml
```

**Paste:**

```yaml
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
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### Step 8.2: Install Database Clients

```bash
sudo pacman -S postgresql-libs redis
yay -S mongodb-tools-bin
```

**Checkpoint:**
- [ ] psql, redis-cli, mongo commands available

**🎉 BREAK TIME! Databases configured!**

---

## ⚡ Phase 9: Power Optimization (30 min)

**Goal:** Maximize battery life

### Step 9.1: Install TLP

```bash
sudo pacman -S tlp tlp-rdw
```

---

### Step 9.2: Configure TLP

```bash
sudo nano /etc/tlp.conf
```

**Find and change these lines (Ctrl+W to search):**

```
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_BOOST_ON_BAT=0
RUNTIME_PM_ON_BAT=auto
USB_AUTOSUSPEND=1
DISK_IDLE_SECS_ON_BAT=2
SOUND_POWER_SAVE_ON_BAT=1
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
# Enable TLP
sudo systemctl enable tlp.service
sudo systemctl start tlp.service

# Check status
sudo tlp-stat -s
```

**Checkpoint:**
- [ ] TLP service is running

**🎉 BREAK TIME! Power optimization complete!**

---

## 🤖 Phase 10: Workflow Automation (1 hour)

**Goal:** Create scripts for disciplined workflow

### Step 10.1: Frontend Workflow Script

```bash
nano ~/bin/work-frontend
```

**Paste:**

```bash
#!/bin/bash
echo "🚀 Starting Frontend Development"
echo ""

# Show memory
echo "Current memory:"
free -h | grep Mem
echo ""

# Start databases
echo "Starting databases..."
docker-start db-only

# Switch to workspace 1
swaymsg 'workspace 1'

# Launch tmux
foot -e tmux new-session -s frontend "cd ~/projects && nvim" &

echo ""
echo "✅ Frontend Environment Ready!"
echo "   • Workspace 1: Terminal + nvim"
echo "   • Workspace 2: Browser (Super+2, then type 'browser-quick')"
echo "   • Databases running: PostgreSQL, Redis"
echo ""
echo "📊 Expected RAM: ~620MB (without browser)"
echo ""
check-mem
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/work-frontend
```

---

### Step 10.2: Fullstack Workflow Script

```bash
nano ~/bin/work-fullstack
```

**Paste:**

```bash
#!/bin/bash
echo "🚀 Starting Fullstack Development"
echo ""

# Show memory
echo "Current memory:"
free -h | grep Mem
echo ""

# Start all services
echo "Starting all services..."
docker-start fullstack

# Switch to workspace 1
swaymsg 'workspace 1'

# Launch tmux
foot -e tmux new-session -s fullstack "cd ~/projects && nvim" &

echo ""
echo "✅ Fullstack Environment Ready!"
echo "   • Workspace 1: Terminal + nvim"
echo "   • Workspace 2: Browser (when needed)"
echo "   • All databases running"
echo ""
echo "⚠️  REMEMBER: Close browser before Rust compilation!"
echo "   Use: browser-close"
echo ""
echo "📊 Expected RAM: ~1.2GB (without browser)"
echo ""
check-mem
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/work-fullstack
```

---

### Step 10.3: Compilation Prep Script

```bash
nano ~/bin/work-compile
```

**Paste:**

```bash
#!/bin/bash
echo "🔨 Preparing for Heavy Compilation"
echo ""

# Close browser if running
if pgrep -x chromium > /dev/null; then
  echo "🌐 Closing browser to free memory..."
  browser-close
  sleep 2
fi

echo ""
echo "Available memory:"
free -h | grep Mem
echo ""
echo "✅ Ready for compilation!"
echo "📊 Expected available: ~3GB"
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/work-compile
```

---

### Step 10.4: Memory Pressure Detection

```bash
nano ~/bin/mem-pressure
```

**Paste:**

```bash
#!/bin/bash
AVAILABLE=$(free | grep Mem | awk '{print $7}')
TOTAL=$(free | grep Mem | awk '{print $2}')
PERCENT=$((AVAILABLE * 100 / TOTAL))

if [ $PERCENT -lt 20 ]; then
  echo "⚠️  MEMORY PRESSURE DETECTED!"
  echo "Available: ${PERCENT}%"
  echo ""
  echo "Quick fixes:"
  echo "  1. browser-close     # Close browser"
  echo "  2. docker-stop       # Stop all containers"
  echo "  3. pkill -f language # Kill LSP servers"
  echo ""
  check-mem
else
  echo "✅ Memory OK (${PERCENT}% available)"
fi
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
chmod +x ~/bin/mem-pressure
```

---

### Step 10.5: Update .bashrc with Aliases

```bash
nano ~/.bashrc
```

**Add at the end:**

```bash
# Environment
export EDITOR=nvim
export VISUAL=nvim

# Memory management aliases
alias mem='check-mem'
alias memp='mem-pressure'

# Docker aliases
alias dstart='docker-start'
alias dstop='docker-stop'
alias dmem='docker-mem'

# Browser aliases
alias browser='browser-quick'
alias bclose='browser-close'

# Workflow aliases
alias wf='work-frontend'
alias wfs='work-fullstack'
alias wc='work-compile'

# Quick shortcuts
alias nv='nvim'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Enhanced prompt with memory
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] [$(free -h | awk "/^Mem:/ {print \$7}")] \$ '
```

**Save:** Ctrl+O, Enter, Ctrl+X

```bash
source ~/.bashrc
```

**Checkpoint:**
- [ ] All aliases work (try `mem`, `memp`, etc.)

**🎉 HUGE BREAK! You're almost done!**

---

## 📚 Daily Usage Guide

### Starting Your Day

```bash
# 1. Start Sway
sway

# 2. Open terminal (Super+Enter)

# 3. Check memory status
mem

# 4. Start your workflow
wf          # Frontend work
# OR
wfs         # Fullstack work
```

---

### Discipline Rules (IMPORTANT!)

#### ✅ DO:

1. **Close browser before compiling Rust**
   ```bash
   wc              # Automatically closes browser
   cargo build     # Now compile
   ```

2. **Stop Docker when not developing**
   ```bash
   dstop           # Frees ~500MB+
   ```

3. **Check memory before heavy tasks**
   ```bash
   memp            # Shows memory pressure
   ```

4. **Use workspaces**
   - Workspace 1 (Super+1): Coding
   - Workspace 2 (Super+2): Browser

#### ❌ DON'T:

1. **Don't open 10+ browser tabs** (limit: 3 tabs)
2. **Don't compile with browser open** (will swap heavily)
3. **Don't run all Docker containers** (start only what you need)
4. **Don't ignore memory warnings** (check with `memp`)

---

### Common Workflows

#### Frontend Development

```bash
# Start
wf

# Work in workspace 1 (Super+1)
# Code, commit, etc.

# Need to test in browser?
# Switch to workspace 2 (Super+2)
browser

# Done with browser?
# Switch back to workspace 1 (Super+1)
bclose
```

#### Rust Development

```bash
# Coding
wfs                  # Start fullstack

# Ready to compile?
wc                   # Closes browser, checks memory
cargo build          # Compile

# Done compiling?
browser              # Reopen browser if needed
```

#### Docker Management

```bash
# Start only what you need
dstart frontend      # Just DB for frontend work
dstart fullstack     # Everything

# Check what's running
docker ps

# Check memory usage
dmem

# Stop everything
dstop
```

---

### Keybindings Reference

| Key | Action |
|-----|--------|
| `Super+Enter` | Open terminal |
| `Super+d` | Application launcher |
| `Super+Shift+Q` | Close window |
| `Super+1` | Workspace 1 (coding) |
| `Super+2` | Workspace 2 (browser) |
| `Super+Shift+E` | Exit Sway |
| `Super+Shift+C` | Reload Sway config |

---

### Troubleshooting

#### "Out of memory" errors

```bash
# Check what's using memory
mem

# Check memory pressure
memp

# Quick fixes:
bclose              # Close browser
dstop               # Stop Docker
pkill -f language   # Kill LSP servers
```

#### Browser won't start

```bash
# Check if already running
pgrep chromium

# Kill and restart
pkill chromium
browser
```

#### Docker won't start containers

```bash
# Check Docker service
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Try again
dstart frontend
```

#### Sway won't start

```bash
# Check config
sway -C ~/.config/sway/config

# View logs
journalctl -xe | grep sway
```

---

## 📊 Expected Resource Usage

### Memory Budget

| Scenario | RAM Usage | What's Running |
|----------|-----------|----------------|
| **Idle** | 300MB | Just Sway + terminal |
| **Coding** | 620MB | + nvim + LSPs + databases |
| **With Browser** | 970MB | + Chromium (3 tabs) |
| **Fullstack** | 1.2GB | + all containers |
| **Compiling** | 810MB | Browser closed, Rust active |

### Battery Life Estimates

**With 100Wh internal battery:**
- Coding only: 16-25 hours ✅
- With browser: 8-12 hours ✅
- Heavy compilation: 6-10 hours ✅

**With +100Wh power bank (200Wh total):**
- All-day work (16h): ✅ Achievable!

---

## ✅ Final Checklist

Before you start using this system daily, verify:

- [ ] `sway` starts and shows waybar
- [ ] `Super+1` and `Super+2` switch workspaces
- [ ] `mem` shows memory status
- [ ] `browser` opens Chromium
- [ ] `docker ps` works (no sudo needed)
- [ ] `wf` launches frontend environment
- [ ] `nvim` opens with your vimzap config
- [ ] `node`, `go`, `rustc`, `python` all work

---

## 🎉 Congratulations!

You've built a minimal, disciplined, battery-optimized development environment!

### Quick Reference Card (Print This!)

```
=== DAILY COMMANDS ===
sway              Start graphical environment
mem               Check memory
memp              Memory pressure warning
wf                Frontend workflow
wfs               Fullstack workflow
wc                Prepare for compilation
browser           Open browser (workspace 2)
bclose            Close browser
dstart <profile>  Start Docker containers
dstop             Stop all containers
dmem              Docker memory usage

=== KEYBINDINGS ===
Super+Enter       Terminal
Super+1           Workspace 1 (coding)
Super+2           Workspace 2 (browser)
Super+Shift+Q     Close window
Super+Shift+E     Exit Sway
```

---

## 📖 What's Next?

1. **Create a test project**
   ```bash
   mkdir -p ~/projects/test-app
   cd ~/projects/test-app
   npm init -y
   ```

2. **Copy docker-compose template**
   ```bash
   cp ~/docker-compose-template.yml ~/projects/test-app/docker-compose.yml
   ```

3. **Practice the workflow**
   - Start with `wf`
   - Code something
   - Test in browser
   - Use `wc` before compiling

4. **Monitor your memory usage**
   - Check `mem` frequently
   - Learn your patterns
   - Adjust discipline as needed

---

## 🆘 Need Help?

If you get stuck:

1. **Check memory first**: `memp`
2. **Check logs**: `journalctl -xe`
3. **Restart services**: `sudo systemctl restart <service>`
4. **Reboot**: Sometimes the simplest fix!

---

**Created for:** Enterprise fullstack development on 4GB ARM device  
**Philosophy:** Discipline > Resources  
**Goal:** Maximum productivity, minimum bloat  

Good luck! 🚀
