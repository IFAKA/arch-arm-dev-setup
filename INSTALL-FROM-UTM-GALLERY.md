# Complete Installation Guide: Arch Linux ARM Dev Environment on Mac (UTM)

**Start to finish guide for setting up a complete development environment on Apple Silicon Macs using UTM.**

---

## 📋 What You'll Get

After following this guide, you'll have:

- ✅ Arch Linux ARM running on your Mac (Apple Silicon M1/M2/M3)
- ✅ Full development stack: Node.js, Go, Rust, Python, C/C++, Docker
- ✅ Beautiful Sway window manager (auto-starts on login)
- ✅ Optimized for 4GB RAM with zram compression
- ✅ Clipboard sharing between Mac and VM
- ✅ Shared folders between Mac and VM
- ✅ All tools installed and ready to code immediately

**Total time: ~90 minutes** (mostly automated)

---

## 📦 Prerequisites

- **Mac with Apple Silicon** (M1, M2, M3, etc.)
- **10GB free disk space** (20GB+ recommended)
- **Stable internet connection**
- **UTM installed** - Download from: https://mac.getutm.app/

---

## 🚀 Step-by-Step Installation

### Step 1: Download Arch Linux ARM from UTM Gallery

1. **Open your web browser**
2. Go to: **https://mac.getutm.app/gallery/archlinux-arm**
3. Click **"Open in UTM"** button
   - This will download the `.utm` file (ArchLinux.utm)
   - Default location: `~/Downloads/ArchLinux.utm`
4. UTM will open automatically and import the VM

**OR manually import:**
1. Download the `.utm` file
2. Open UTM
3. Click **"+"** → **"Open..."**
4. Select the `ArchLinux.utm` file

---

### Step 2: Resize the Disk (IMPORTANT!)

⚠️ **The default disk size is only 9GB - too small for development!**

We'll resize it to **32GB** (or your preferred size) BEFORE first boot.

#### Option A: Using Terminal (Recommended - Precise Control)

1. **Install QEMU tools** (if not already installed):
   ```bash
   brew install qemu
   ```

2. **Find your VM location:**
   
   If you downloaded from UTM Gallery, it's likely in:
   ```bash
   # Check Downloads folder
   ls ~/Downloads/ArchLinux.utm/Data/*.qcow2
   
   # Or search for it
   mdfind -name "ArchLinux.utm"
   ```

3. **Navigate to the VM disk location:**
   ```bash
   # For UTM Gallery downloads (most common)
   cd ~/Downloads/ArchLinux.utm/Data
   
   # OR if you imported it to UTM's library
   cd ~/Library/Containers/com.utmapp.UTM/Data/Documents/ArchLinux.utm/Data
   ```

4. **Find the main disk file:**
   ```bash
   # List all qcow2 files with sizes
   ls -lh *.qcow2
   
   # The largest one is usually the main disk
   # It will have a UUID name like: BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2
   ```

5. **Check current disk size:**
   ```bash
   # Replace with your actual filename
   qemu-img info BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2
   ```
   
   You should see: `virtual size: 9.77 GiB`

6. **Resize the disk to 32GB:**
   ```bash
   # Replace with your actual filename
   qemu-img resize BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2 32G
   ```

7. **Verify the new size:**
   ```bash
   qemu-img info BB208CBD-BFB4-4895-9542-48527C9E5473.qcow2 | grep "virtual size"
   ```
   
   You should now see: `virtual size: 32 GiB`

**Want a different size?** Just change the final size:
- For 16GB: `qemu-img resize FILENAME.qcow2 16G`
- For 40GB: `qemu-img resize FILENAME.qcow2 40G`
- For 64GB: `qemu-img resize FILENAME.qcow2 64G`

#### Option B: Using UTM GUI (If Available)

1. In UTM, **right-click** the ArchLinux VM → **Edit**
2. Go to **"Drives"** tab
3. Select **"IDE Drive"** or the main disk
4. Look for **"Resize"** button or size slider
5. Set to **32GB** (or your preferred size)
6. Click **"Save"**

**Note:** Some UTM versions may not show a resize option in the GUI. If you don't see it, use Option A (Terminal method).

---

### Step 3: First Boot and Login

1. **Start the VM** in UTM (click the play button)
2. Wait for the boot process (may take 1-2 minutes first time)
3. **Login with default credentials:**
   - Username: `root`
   - Password: `root`

You should see a terminal prompt:
```
[root@archlinux ~]#
```

---

### Step 4: Download and Run the Installer

1. **Update the package database:**
   ```bash
   pacman -Sy
   ```

2. **Install git:**
   ```bash
   pacman -S --noconfirm git
   ```

3. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/arch-arm-dev-setup.git
   cd arch-arm-dev-setup
   ```
   
   **Don't have the repo online yet?** Use `curl` to download the installer:
   ```bash
   curl -L https://raw.githubusercontent.com/YOUR-USERNAME/arch-arm-dev-setup/main/install.sh -o install.sh
   chmod +x install.sh
   ```

4. **Run the installer:**
   ```bash
   bash install.sh
   # OR if you have the full repo:
   bash installer/main.sh
   ```

---

### Step 5: Follow the Interactive Installer

The installer will guide you through configuration with a beautiful text UI:

#### 5.1 Welcome Screen
- Read the welcome message
- Press **OK** to continue

#### 5.2 Create User Account
- **Username**: Enter your desired username (e.g., `dev`, `john`, etc.)
  - Must be lowercase
  - Only letters, numbers, `-` or `_`
- **Password**: Enter a password (minimum 4 characters)
- **Confirm password**: Re-enter the same password

#### 5.3 System Configuration
- **Timezone**: Enter your timezone
  - Examples: `America/New_York`, `Europe/London`, `Asia/Tokyo`, `UTC`
  - Find yours at: `/usr/share/zoneinfo/`
- **Hostname**: Enter a name for your machine (e.g., `devbox`, `archvm`)

#### 5.4 Confirm Settings
- Review all your settings
- Press **Yes** to start installation
- Press **No** to cancel

#### 5.5 Installation Progress
The installer will now run through 12 phases (takes ~60 minutes):

1. ✅ **Disk expansion** (auto-detects and uses your 32GB)
2. ✅ System package updates
3. ✅ User account creation
4. ✅ UTM integration (clipboard + shared folders)
5. ✅ Memory management (zram)
6. ✅ Sway window manager
7. ✅ Development tools (neovim, tmux, fzf, etc.)
8. ✅ Language runtimes (Node.js, Go, Rust, Python, C/C++)
9. ✅ Docker setup
10. ✅ Database tools
11. ✅ Utility scripts
12. ✅ Shell configuration

**What to expect:**
- Phase 1 (System Update): **15-20 minutes** (slowest part)
- Phase 7 (Languages): **10-15 minutes** (downloading runtimes)
- Other phases: **1-5 minutes each**

You'll see a progress bar showing which phase is running.

#### 5.6 Automatic Reboot
- When installation completes, the system will reboot automatically in 10 seconds
- You'll see a completion message with quick reference commands

---

### Step 6: First Login After Installation

1. **VM will reboot** and show a login prompt
2. **Login with YOUR new username** (NOT root):
   ```
   login: dev          # (or whatever username you created)
   password: ********  # (your password)
   ```

3. **Sway will auto-start!** 🎉
   - You'll see the Sway window manager
   - A terminal will be open and ready
   - Waybar status bar at the top

---

### Step 7: Verify Everything Works

#### Check Disk Space
```bash
df -h /
```

You should see your full disk size (32GB), not just 9GB!

Example output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        32G  3.2G   27G  11% /
```

#### Check Memory
```bash
mem
```

This shows memory usage and zram status.

#### Check Installed Tools
```bash
# Node.js
node --version
npm --version

# Go
go version

# Rust
rustc --version

# Python
python --version

# Docker
docker --version
docker ps
```

All should work without errors!

---

## 🎯 Quick Reference Commands

After installation, these commands are available:

### Development Workflows
```bash
help         # Show all available commands
wf           # Start frontend development (PostgreSQL + Redis)
wfs          # Start fullstack development (all databases)
```

### Memory Management
```bash
mem          # Check memory usage
memp         # Check for memory pressure
```

### Docker Management
```bash
dstart frontend    # Start databases for frontend work
dstart fullstack   # Start all databases
dstop              # Stop all containers
dmem               # Check Docker memory usage
```

### General Shortcuts
```bash
nv           # Open neovim
gs           # git status
ga           # git add
gc           # git commit
gp           # git push
```

---

## ⌨️ Sway Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Enter` | Open new terminal |
| `Super + D` | Application launcher (wofi) |
| `Super + 1/2` | Switch to workspace 1 or 2 |
| `Super + Shift + 1/2` | Move window to workspace 1 or 2 |
| `Super + Shift + Q` | Close focused window |
| `Super + Shift + C` | Reload Sway config |
| `Super + Shift + E` | Exit Sway (logout) |

**Note:** `Super` = `Command` key on Mac keyboard

---

## 🔗 Setting Up Shared Folders (Optional)

Share files between your Mac and the VM:

### On macOS (UTM):

1. **Shut down the VM completely**
2. Right-click the VM → **Edit**
3. Go to **"Sharing"** section
4. Click **"+"** to add a new shared directory
5. **Browse** to select a folder on your Mac (e.g., `~/Documents/shared`)
6. **Set the name** to exactly: `shared`
7. Click **"Save"**
8. **Start the VM**

### In the VM:

```bash
# Mount the shared folder
sudo mount -a

# Verify it's mounted
ls -la /mnt/shared

# Create a symlink in your home directory for easy access
ln -s /mnt/shared ~/shared

# Now you can access it easily
cd ~/shared
```

The shared folder will auto-mount on every boot.

---

## 🎨 Customizing Your Environment

### Change Sway Configuration
```bash
nvim ~/.config/sway/config
# Make your changes
# Press: Super + Shift + C to reload
```

### Change Waybar (Status Bar)
```bash
nvim ~/.config/waybar/config
# Make your changes
# Press: Super + Shift + C to reload
```

### Change Shell Aliases
```bash
nvim ~/.bashrc
# Add your custom aliases
source ~/.bashrc  # Reload
```

---

## 🛠️ Troubleshooting

### Disk Still Shows 9GB After Installation

Check if the disk was actually resized:

**On macOS:**
```bash
cd ~/Library/Containers/com.utmapp.UTM/Data/Documents/ArchLinux.utm/Data
/Applications/UTM.app/Contents/MacOS/qemu-img info disk-0.qcow2
```

If it shows 9GB, you need to resize it:
```bash
/Applications/UTM.app/Contents/MacOS/qemu-img resize disk-0.qcow2 +23G
```

Then **in the VM**, manually expand:
```bash
# Find your disk
lsblk

# Expand partition (assuming /dev/vda1)
sudo growpart /dev/vda 1

# Expand filesystem
sudo resize2fs /dev/vda1

# Verify
df -h /
```

### Clipboard Sharing Not Working

```bash
# Check spice-vdagent service
systemctl status spice-vdagentd.service

# Restart it
sudo systemctl restart spice-vdagentd.service

# Make sure wl-clipboard is installed
sudo pacman -S wl-clipboard
```

### Shared Folder Not Mounting

```bash
# Check if it's configured in UTM (VM must be shut down)
# Then try mounting manually:
sudo mount -t virtiofs shared /mnt/shared

# Check for errors
dmesg | grep virtiofs

# Verify fstab entry
cat /etc/fstab | grep shared
```

### Can't Login After Installation

If you can't login with your new username:

1. Login as `root` / `root` (old credentials)
2. Check if user was created:
   ```bash
   id YOUR_USERNAME
   ```
3. If user doesn't exist, create manually:
   ```bash
   useradd -m -G wheel,docker -s /bin/bash YOUR_USERNAME
   passwd YOUR_USERNAME
   ```

### Sway Won't Start

```bash
# Check for errors
cat ~/.local/share/sway/sway.log

# Try starting manually
sway

# If it fails, check dependencies
pacman -S sway swaylock swayidle waybar foot
```

### Out of Memory

```bash
# Check memory pressure
memp

# Stop Docker containers
dstop

# Check what's using memory
mem

# Kill language servers if needed
pkill -f rust-analyzer
pkill -f node
```

---

## 📊 Resource Usage

Expected RAM usage after installation:

| Scenario | RAM Usage |
|----------|-----------|
| Just booted (Sway running) | ~500MB |
| + Terminal + Neovim | ~550MB |
| + Frontend work (Postgres + Redis) | ~800MB |
| + Fullstack (all databases) | ~1.2GB |
| + Heavy development | ~1.5-2GB |

With 4GB RAM + zram compression, you effectively have ~6GB available!

---

## 🎓 Next Steps

### Start Your First Project

```bash
# Create a project directory
mkdir ~/projects
cd ~/projects

# Initialize a Node.js project
mkdir my-app
cd my-app
npm init -y

# Install dependencies
npm install express

# Start coding!
nvim index.js
```

### Set Up Databases

```bash
# Copy the docker-compose template
cp ~/docker-compose-template.yml ~/projects/my-app/docker-compose.yml

# Start databases
cd ~/projects/my-app
dstart frontend

# Connect to PostgreSQL
psql -h localhost -U devuser -d devdb
# Password: devpassword
```

### Learn Sway Window Manager

```bash
# Read the Sway documentation
man sway

# Explore Sway commands
man sway-bar
man sway-input
man sway-output

# Test commands
swaymsg -t get_outputs  # List displays
swaymsg -t get_inputs   # List input devices
```

---

## 📚 Additional Resources

- **UTM Documentation**: https://docs.getutm.app/
- **Arch Linux ARM Wiki**: https://archlinuxarm.org/
- **Sway WM Guide**: https://github.com/swaywm/sway/wiki
- **This Project's Guides**:
  - `QUICKSTART.md` - Quick command reference
  - `DAILY-USAGE-GUIDE.md` - Tips for daily development
  - `TROUBLESHOOTING.md` - Common issues and fixes
  - `UTM-CONFIG-GUIDE.md` - Advanced UTM configuration

---

## ✅ Installation Complete Checklist

After following this guide, verify:

- [ ] VM disk shows full size (32GB+), not 9GB
- [ ] Can login with your new username
- [ ] Sway auto-starts on login
- [ ] Terminal opens with `Super + Enter`
- [ ] Clipboard sharing works (copy/paste Mac ↔ VM)
- [ ] `mem` command shows memory status
- [ ] `node --version` works
- [ ] `go version` works
- [ ] `rustc --version` works
- [ ] `docker ps` works (without sudo)
- [ ] `wf` command starts frontend workflow
- [ ] Shared folder accessible (if configured)

---

## 🎉 You're All Set!

You now have a complete, optimized development environment running on your Mac!

**Happy coding!** 🚀

---

## 📝 Credits

- **UTM**: https://getutm.app - Amazing macOS virtualization
- **Arch Linux ARM**: https://archlinuxarm.org - Lightweight Linux distro
- **Sway**: https://swaywm.org - Tiling Wayland compositor

---

## 🤝 Contributing

Found an issue or have suggestions? 

- Open an issue: https://github.com/YOUR-USERNAME/arch-arm-dev-setup/issues
- Submit a PR: https://github.com/YOUR-USERNAME/arch-arm-dev-setup/pulls

---

**Last Updated**: December 2024
