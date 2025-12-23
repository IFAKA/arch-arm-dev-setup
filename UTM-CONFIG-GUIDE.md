# UTM Configuration Guide for Arch Linux ARM

This guide covers the UTM-specific configuration needed before and after running the post-installation script.

## 📋 Table of Contents

1. [VM Creation in UTM](#vm-creation-in-utm)
2. [Clipboard Sharing](#clipboard-sharing)
3. [Shared Folders](#shared-folders)
4. [Performance Optimization](#performance-optimization)
5. [Troubleshooting](#troubleshooting)

---

## 🖥️ VM Creation in UTM

### Step 1: Create New Virtual Machine

1. Open UTM
2. Click **"+"** → **"Virtualize"**
3. Select **"Linux"**
4. Click **"Browse"** and select your Arch Linux ARM ISO
5. Continue through the wizard

### Step 2: VM Settings (Before First Boot)

#### System Configuration

- **Architecture**: ARM64 (aarch64)
- **Memory**: 4096 MB (4GB)
- **CPU Cores**: 2-4 (depending on your host)

#### Display Configuration

- **Emulated Display Card**: virtio-ramfb-gl (recommended) or virtio-gpu-gl
- **Resolution**: 1920x1080 or your preferred resolution

#### Network Configuration

- **Network Mode**: Shared Network
- This allows internet access and SSH

#### QEMU Settings (Advanced)

Add these arguments for better performance:

```
-device virtio-gpu-pci
-device virtio-keyboard-pci
-device virtio-mouse-pci
-device virtio-tablet-pci
```

---

## 📋 Clipboard Sharing

### How It Works

The post-installation script automatically configures clipboard sharing using **SPICE vdagent**.

### Verification

After running the post-install script and rebooting:

```bash
# Check if spice-vdagent is running
systemctl status spice-vdagentd.service

# Should show: active (running)
```

### Manual Testing

1. **Copy from macOS to VM**:
   - Copy text on your Mac (Cmd+C)
   - In the VM terminal, paste with `Ctrl+Shift+V` or middle-click

2. **Copy from VM to macOS**:
   - Select text in the VM
   - Copy with `Ctrl+Shift+C` in terminal
   - Paste on macOS with `Cmd+V`

### Troubleshooting Clipboard

If clipboard doesn't work:

```bash
# Restart spice-vdagent
sudo systemctl restart spice-vdagentd.service

# Check logs
journalctl -u spice-vdagentd.service -f
```

---

## 📁 Shared Folders

### Configure in UTM (Before mounting in VM)

1. **Open VM Settings** (VM must be shut down)
2. Go to **"Sharing"** section
3. Click **"+"** to add a new shared directory
4. **Browse** to select a folder on your Mac (e.g., `~/Documents/shared`)
5. **Important**: Set the name to exactly **"shared"** (the script expects this name)
6. Enable **"Read Only"** if you want (optional)
7. Save and start the VM

### Mount Shared Folder in VM

The post-installation script automatically adds the mount point to `/etc/fstab`.

After configuring the shared folder in UTM:

```bash
# Mount the shared folder
sudo mount -a

# Verify it's mounted
ls -la /mnt/shared

# Check mount status
df -h | grep shared
```

### Automatic Mounting

The shared folder will automatically mount on boot after configuration.

### Using a Different Name

If you want to use a different name instead of "shared":

```bash
# Edit /etc/fstab
sudo nano /etc/fstab

# Change this line:
shared /mnt/shared virtiofs defaults,nofail 0 0

# To (replace "myshare" with your name):
myshare /mnt/shared virtiofs defaults,nofail 0 0

# Save and mount
sudo mount -a
```

### Create User-Accessible Link

```bash
# Create a symlink in your home directory
ln -s /mnt/shared ~/shared

# Now you can access it easily
cd ~/shared
```

### Permissions

Shared folders are owned by root by default. To make them user-accessible:

```bash
# Option 1: Change ownership (after each mount)
sudo chown -R $USER:$USER /mnt/shared

# Option 2: Add to fstab mount options
sudo nano /etc/fstab

# Change the line to:
shared /mnt/shared virtiofs defaults,nofail,uid=1000,gid=1000 0 0
# Replace 1000 with your user ID (check with: id -u)

# Remount
sudo umount /mnt/shared
sudo mount -a
```

---

## ⚡ Performance Optimization

### Enable Hardware Acceleration

In UTM VM settings:

1. **Display** → Enable **"Retina Mode"** if on Retina display
2. **QEMU** → Add argument: `-device virtio-gpu-pci,max_outputs=1`

### Optimize Memory

Already configured in the post-install script, but you can verify:

```bash
# Check zram is active
zramctl

# Check swap
free -h

# You should see ~2GB zram swap
```

### Optimize Disk I/O

In UTM VM settings:

1. **Drives** → Select your main drive
2. **Interface**: VirtIO
3. **Cache Mode**: Write-back (for better performance)

### Network Performance

```bash
# Install ethtool
sudo pacman -S ethtool

# Check network interface
ip a

# Optimize (replace enp0s1 with your interface)
sudo ethtool -K enp0s1 tx off rx off
```

---

## 🔧 Troubleshooting

### Shared Folder Not Mounting

**Check UTM Settings**:
- VM must be shut down to add/modify shared folders
- Name must match the one in `/etc/fstab`

**Check in VM**:
```bash
# Verify virtiofs module is loaded
lsmod | grep virtiofs

# Check fstab entry
cat /etc/fstab | grep shared

# Try manual mount
sudo mount -t virtiofs shared /mnt/shared

# Check dmesg for errors
dmesg | grep virtiofs
```

**Common fixes**:
```bash
# Install fuse3 if missing
sudo pacman -S fuse3

# Create mount point if missing
sudo mkdir -p /mnt/shared

# Check mount options
sudo mount -v -a
```

### Clipboard Not Working

**Check services**:
```bash
# Check spice-vdagent
systemctl status spice-vdagentd.service

# Check qemu-guest-agent
systemctl status qemu-guest-agent.service

# Restart both
sudo systemctl restart spice-vdagentd.service
sudo systemctl restart qemu-guest-agent.service
```

**In Sway/Wayland**:
```bash
# Make sure wl-clipboard is installed
sudo pacman -S wl-clipboard

# Test clipboard
echo "test" | wl-copy
wl-paste
```

### Screen Resolution Issues

**In Sway**:
```bash
# Edit Sway config
nano ~/.config/sway/config

# Add or modify output configuration
output * resolution 1920x1080

# Or list available modes
swaymsg -t get_outputs

# Reload Sway
Super+Shift+C (or restart Sway)
```

**Available resolutions**:
- 1920x1080 (Full HD)
- 1680x1050
- 1440x900
- 1280x720

### Performance Issues

**Check CPU governor**:
```bash
# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set to performance (temporary)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Monitor resources**:
```bash
# Check memory
mem

# Check CPU/RAM in real-time
htop

# or
btop
```

### Network Issues

**Check connectivity**:
```bash
# Check interface
ip a

# Check routing
ip route

# Test DNS
ping -c 3 8.8.8.8
ping -c 3 archlinux.org

# Restart networking
sudo systemctl restart systemd-networkd
```

---

## 📝 Post-Installation Checklist

After running the post-install script, verify:

- [ ] Clipboard sharing works (copy/paste between host and VM)
- [ ] Shared folder is accessible at `/mnt/shared`
- [ ] Sway starts without errors (`sway` command)
- [ ] Memory management active (`free -h` shows zram)
- [ ] Docker works without sudo (`docker ps`)
- [ ] All aliases work (`mem`, `wf`, `dstart`, etc.)

---

## 🎯 Quick Reference

### Essential Commands

```bash
# Check memory
mem

# Memory pressure check
memp

# Start frontend workflow
wf

# Start fullstack workflow
wfs

# Docker management
dstart frontend    # Start databases only
dstart fullstack   # Start everything
dstop             # Stop all containers

# Shared folder
cd /mnt/shared    # Access shared files
```

### Key Locations

```
/mnt/shared              # Shared folder mount point
~/.config/sway/config    # Sway configuration
~/bin/                   # Utility scripts
~/docker-compose-template.yml  # Database template
```

### UTM Shortcuts

- **Cmd+Ctrl+F**: Toggle fullscreen
- **Cmd+Ctrl+R**: Release mouse capture
- **Cmd+Ctrl+Return**: Send Ctrl+Alt+Delete to VM

---

## 🆘 Getting Help

If you encounter issues:

1. Check system logs:
   ```bash
   journalctl -xe
   ```

2. Check specific service:
   ```bash
   systemctl status <service-name>
   journalctl -u <service-name> -f
   ```

3. Check dmesg for hardware issues:
   ```bash
   dmesg | tail -50
   ```

4. UTM logs: In UTM, select VM → Show in Finder → check `.log` files

---

## 📚 Additional Resources

- UTM Documentation: https://docs.getutm.app/
- Arch Linux ARM: https://archlinuxarm.org/
- Sway WM: https://swaywm.org/
- SPICE: https://www.spice-space.org/

---

**Enjoy your optimized development environment on UTM!** 🚀
