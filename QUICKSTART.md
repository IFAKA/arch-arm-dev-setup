# ⚡ Quick Start Guide

Get up and running in **under 30 minutes** (after Arch Linux ARM is installed).

---

## 📋 Prerequisites

- Arch Linux ARM installed on ARM64/aarch64 device or UTM VM
- Internet connection
- 4GB RAM minimum

---

## 🚀 Installation (Copy-Paste Method)

### Step 1: Initial System Setup

Login as `alarm` (password: `alarm`), then:

```bash
# Become root
su
# Password: root

# Initialize pacman
pacman-key --init
pacman-key --populate archlinuxarm

# Update system
pacman -Syu --noconfirm

# Install git
pacman -S --noconfirm git sudo

# Create your user (replace 'dev' with your username)
useradd -m -G wheel -s /bin/bash dev
passwd dev
# Enter your password twice

# Enable sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# Exit to login as new user
exit
exit
```

### Step 2: Login as Your New User

Login with the username you created above.

### Step 3: Run the Installer

```bash
# Clone this repository
git clone https://github.com/IFAKA/arch-arm-dev-setup.git

# Enter directory
cd arch-arm-dev-setup

# Run the installer
./arch-arm-post-install.sh
```

The script will ask you some questions:
- Timezone (e.g., `America/New_York`)
- Hostname (e.g., `devbox`)
- Whether to install yay (AUR helper)

Then it will automatically install everything. **Go make coffee!** ☕

### Step 4: Finalize

After installation completes:

```bash
# Log out and back in (important for docker group)
exit
# Login again

# Start Sway window manager
sway
```

---

## 🎯 First Commands to Try

Press `Super+Enter` (Windows key + Enter) to open a terminal in Sway.

```bash
# Check memory
mem

# Start frontend development workflow
wf

# Check Docker status
docker ps

# Access shared folder (if configured in UTM)
ls /mnt/shared
```

---

## 🖥️ For UTM Users

### Before Running the Script

1. **Configure Shared Folder** (optional):
   - Shut down VM
   - VM Settings → Sharing
   - Add a folder from your Mac
   - Set name to: **`shared`**
   - Save and start VM

2. **After Script Completes**:
   ```bash
   # Mount shared folder
   sudo mount -a
   
   # Verify
   ls /mnt/shared
   ```

### Test Clipboard Sharing

- **Copy from Mac → VM**: Copy on Mac (Cmd+C), paste in VM terminal (Ctrl+Shift+V)
- **Copy from VM → Mac**: Copy in VM (Ctrl+Shift+C), paste on Mac (Cmd+V)

---

## 🎨 Sway Keybindings

| Key | Action |
|-----|--------|
| `Super+Enter` | Open terminal |
| `Super+d` | Application launcher |
| `Super+1` | Switch to workspace 1 |
| `Super+2` | Switch to workspace 2 |
| `Super+Shift+Q` | Close current window |
| `Super+Shift+E` | Exit Sway |
| `Super+Shift+C` | Reload Sway config |

---

## 🔥 Essential Aliases

The script creates these helpful aliases:

```bash
# Memory management
mem              # Check memory usage
memp             # Check memory pressure

# Docker
dstart frontend  # Start PostgreSQL + Redis
dstart fullstack # Start all databases
dstop            # Stop all containers
dmem             # Show container memory

# Workflows
wf               # Frontend workflow
wfs              # Fullstack workflow

# Shortcuts
nv               # Neovim
gs               # Git status
```

---

## 🧪 Test Your Setup

### Create a Test Project

```bash
# Create project directory
mkdir -p ~/projects/test-app
cd ~/projects/test-app

# Initialize Node.js project
npm init -y

# Copy Docker Compose template
cp ~/docker-compose-template.yml docker-compose.yml

# Start databases
dstart frontend

# Check what's running
docker ps

# Check memory
mem
```

### Test Languages

```bash
# Node.js
node --version
npm --version

# Go
go version

# Rust
rustc --version
cargo --version

# Python
python --version
```

---

## 📊 Expected Resource Usage

After installation:

```bash
mem
```

You should see:
- **Idle**: ~300MB used
- **With databases**: ~620MB used
- **Total available**: ~6GB (with zram compression)

---

## ⚠️ Troubleshooting

### Script fails with "Permission denied"

```bash
chmod +x arch-arm-post-install.sh
./arch-arm-post-install.sh
```

### Can't use docker without sudo

```bash
# Log out and back in
exit
# Login again
```

### Shared folder not mounting (UTM)

1. Verify in UTM Settings → Sharing that folder name is exactly `shared`
2. Restart VM
3. Try: `sudo mount -a`

### Clipboard not working (UTM)

```bash
sudo systemctl restart spice-vdagentd.service
```

### More help?

See [UTM-CONFIG-GUIDE.md](UTM-CONFIG-GUIDE.md) for detailed troubleshooting.

---

## ✅ Verification Checklist

Make sure everything works:

- [ ] `sway` starts without errors
- [ ] `mem` shows memory status
- [ ] `docker ps` works without sudo
- [ ] `node --version` shows version
- [ ] `Super+Enter` opens terminal in Sway
- [ ] Clipboard sharing works (if on UTM)
- [ ] `/mnt/shared` accessible (if configured in UTM)

---

## 🎉 Next Steps

1. **Read the full guide**: [arch-arm-setup-guide.md](arch-arm-setup-guide.md)
2. **Customize your setup**: Edit `~/.config/sway/config`, `~/.bashrc`, etc.
3. **Start coding**: Create projects in `~/projects/`
4. **Practice workflows**: Try `wf` and `wfs` commands

---

**You're ready to code!** 🚀

For the complete manual setup process, see [arch-arm-setup-guide.md](arch-arm-setup-guide.md).
