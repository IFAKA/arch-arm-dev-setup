# 🔧 Troubleshooting Guide

Common issues and their solutions.

---

## 🚨 Common Issues

### 1. Script Permission Denied

**Error:**
```
bash: ./arch-arm-post-install.sh: Permission denied
```

**Solution:**
```bash
chmod +x arch-arm-post-install.sh
./arch-arm-post-install.sh
```

---

### 2. Docker Requires Sudo

**Error:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add user to docker group (script does this, but requires re-login)
sudo usermod -aG docker $USER

# IMPORTANT: Log out completely and log back in
exit

# Verify
docker ps
# Should work without sudo now
```

---

### 3. Clipboard Sharing Not Working (UTM)

**Symptoms:**
- Can't copy/paste between macOS and VM

**Solutions:**

```bash
# 1. Check if spice-vdagent is running
systemctl status spice-vdagentd

# 2. Restart the service
sudo systemctl restart spice-vdagentd

# 3. Check logs
journalctl -u spice-vdagentd -n 50

# 4. In Sway, make sure wl-clipboard is installed
sudo pacman -S wl-clipboard

# 5. Test clipboard
echo "test" | wl-copy
wl-paste
```

**If still not working:**
- Restart the VM completely
- Check UTM version (update if old)
- Verify SPICE display is selected in UTM settings

---

### 4. Shared Folder Not Mounting (UTM)

**Symptoms:**
- `/mnt/shared` is empty or doesn't mount

**Solutions:**

```bash
# 1. Check if folder is configured in UTM
# - Shut down VM
# - VM Settings → Sharing
# - Verify folder name is exactly "shared"
# - Start VM

# 2. Check fstab entry
cat /etc/fstab | grep shared
# Should show: shared /mnt/shared virtiofs defaults,nofail 0 0

# 3. Try manual mount
sudo mount -t virtiofs shared /mnt/shared

# 4. Check mount status
df -h | grep shared

# 5. Check for errors
dmesg | grep virtiofs
journalctl -xe | grep mount

# 6. Verify virtiofs module
lsmod | grep virtiofs
```

**If mounting fails:**
```bash
# Install fuse3 if missing
sudo pacman -S fuse3

# Create mount point if missing
sudo mkdir -p /mnt/shared

# Try mounting with verbose output
sudo mount -v -t virtiofs shared /mnt/shared
```

---

### 5. Out of Memory Errors

**Symptoms:**
- Process killed with "Out of memory"
- System freezing
- Compilation fails

**Solutions:**

```bash
# 1. Check current memory usage
mem

# 2. Check memory pressure
memp

# 3. Free up memory immediately
# Stop Docker containers
dstop

# Close browser (if running)
pkill chromium

# Kill language servers (if not actively coding)
pkill -f 'rust-analyzer|tsserver|gopls'

# 4. Check what's using memory
ps aux --sort=-%mem | head -20

# 5. For compilation, prepare system first
wc  # Closes browser, checks memory
# Then compile
cargo build --release
```

**Prevent future OOM:**
```bash
# Use fewer parallel jobs for compilation
# For Rust:
export CARGO_BUILD_JOBS=1

# For Node.js:
NODE_OPTIONS=--max-old-space-size=512 npm run build

# Check zram is working
zramctl
free -h  # Should show ~2GB swap
```

---

### 6. Sway Won't Start

**Error:**
```
Failed to create backend
```

**Solutions:**

```bash
# 1. Check Sway config syntax
sway -C ~/.config/sway/config

# 2. View detailed error
sway -d 2>&1 | tee sway-debug.log

# 3. Check logs
journalctl -xe | grep sway

# 4. Make sure you're not in a graphical session already
# Exit any existing session first

# 5. Check if required packages are installed
pacman -Q sway waybar foot wofi

# 6. Reset config to default
mv ~/.config/sway/config ~/.config/sway/config.backup
# Re-run the post-install script or recreate config
```

---

### 7. Display Resolution Issues

**Symptoms:**
- Wrong resolution in Sway
- Display too small/large

**Solutions:**

```bash
# 1. List available outputs
swaymsg -t get_outputs

# 2. Set specific resolution (in terminal)
swaymsg 'output * resolution 1920x1080'

# 3. Make permanent: edit config
nano ~/.config/sway/config

# Add or modify:
output * resolution 1920x1080

# Or for specific output:
output Virtual-1 resolution 1920x1080

# 4. Reload Sway config
# Press: Super+Shift+C
# Or from terminal:
swaymsg reload
```

**Common resolutions:**
- 1920x1080 (Full HD)
- 1680x1050
- 1440x900
- 1280x720

---

### 8. Network Not Working

**Symptoms:**
- Can't ping internet
- Package installation fails

**Solutions:**

```bash
# 1. Check network interface
ip a

# 2. Check if interface is up
ip link set <interface> up
# Replace <interface> with your interface name (e.g., enp0s1)

# 3. Test connectivity
ping -c 4 8.8.8.8  # Test IP
ping -c 4 google.com  # Test DNS

# 4. Check routing
ip route

# 5. Restart networking
sudo systemctl restart systemd-networkd

# 6. Check DNS
resolvectl status

# 7. If DNS fails, set manually
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

---

### 9. Language Runtime Issues

#### Node.js / nvm

```bash
# nvm command not found
source ~/.bashrc
# Or
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Node not found after installing
nvm use --lts
nvm alias default node
```

#### Rust

```bash
# cargo command not found
source $HOME/.cargo/env

# Compilation too slow
# Edit ~/.cargo/config.toml
[build]
jobs = 1  # Reduce parallel jobs

# Out of memory during build
cargo clean
cargo build  # Without --release first
```

#### Go

```bash
# go command not found
source ~/.bashrc
# Or
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```

---

### 10. Docker Container Won't Start

**Symptoms:**
- `dstart` fails
- Container exits immediately

**Solutions:**

```bash
# 1. Check Docker daemon
sudo systemctl status docker

# 2. Restart Docker
sudo systemctl restart docker

# 3. Check container logs
docker logs <container-name>

# 4. Check if port is already in use
sudo netstat -tlnp | grep <port>
# Or
sudo lsof -i :<port>

# 5. Remove and recreate containers
docker-compose down
docker-compose up -d

# 6. Check Docker disk space
docker system df
docker system prune  # Clean up if needed
```

---

### 11. Waybar Not Showing / Crashing

**Solutions:**

```bash
# 1. Kill and restart
pkill waybar
waybar &

# 2. Check config syntax
# Waybar config is JSON, check for syntax errors
cat ~/.config/waybar/config | jq .

# 3. View waybar logs
waybar -l debug

# 4. Reset to default config
mv ~/.config/waybar ~/.config/waybar.backup
# Re-run post-install script or recreate config
```

---

### 12. System Running Slow

**Solutions:**

```bash
# 1. Check what's using resources
btop
# Or
htop

# 2. Check memory
mem
memp

# 3. Check disk I/O
iostat -x 1

# 4. Check CPU frequency
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq

# 5. Optimize (temporary)
# Stop unnecessary services
dstop
pkill chromium

# 6. Clean up disk space
docker system prune -a
sudo pacman -Sc  # Clean package cache
```

---

### 13. Can't SSH Into VM

**Solutions:**

```bash
# 1. Install SSH server (not installed by default)
sudo pacman -S openssh

# 2. Enable and start SSH
sudo systemctl enable sshd
sudo systemctl start sshd

# 3. Check status
sudo systemctl status sshd

# 4. Find VM IP address
ip a

# 5. From macOS
ssh yourusername@<VM-IP>

# 6. For UTM, may need to configure port forwarding
# VM Settings → Network → Port Forward
# Host: 2222 → Guest: 22
# Then: ssh -p 2222 yourusername@localhost
```

---

### 14. Pacman Key Issues

**Error:**
```
signature from "..." is unknown trust
```

**Solutions:**

```bash
# 1. Reinitialize keys
sudo pacman-key --init
sudo pacman-key --populate archlinuxarm

# 2. Update keys
sudo pacman-key --refresh-keys

# 3. If still fails, update archlinux-keyring
sudo pacman -Sy archlinux-keyring --noconfirm
sudo pacman -Su
```

---

### 15. System Upgrade Failed - /boot Partition Full

**Error:**
```
gzip: stdout: No space left on device
bsdtar: Write error
==> ERROR: Initcpio image generation FAILED
error: failed to commit transaction (failed to retrieve some files)
```

**Cause:** The /boot partition (200MB) fills up during kernel upgrades because old kernel images are kept as backups.

**Solution:**

```bash
# 1. Check /boot space
df -h /boot

# 2. List files taking up space
ls -lh /boot/

# 3. Remove old kernel images
sudo rm -f /boot/initramfs-linux-fallback.img.old
sudo rm -f /boot/initramfs-linux.img.old
sudo rm -f /boot/vmlinuz-linux.old

# 4. Verify space freed
df -h /boot
# Should now have 100MB+ free

# 5. Complete the system upgrade
sudo pacman -Syu --noconfirm

# 6. Re-run the installer
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
```

**Prevention:** The installer now automatically cleans /boot before upgrades. This issue should only affect systems that started the upgrade before this fix was added (commit bbfc61e).

---

### 16. System Won't Boot

**If you can access recovery:**

```bash
# 1. Check journal for errors
journalctl -xb

# 2. Check failed services
systemctl --failed

# 3. Boot into safe mode
# At boot, select fallback kernel if available

# 4. Reset to working state
# If you modified system files, restore from backup
```

---

## 🔍 Diagnostic Commands

### Full System Check

Run these to gather diagnostic info:

```bash
# System info
uname -a
hostnamectl

# Memory
free -h
zramctl
cat /proc/meminfo | head -20

# Disk
df -h
lsblk

# Services
systemctl --failed
systemctl list-units --type=service --state=running

# Network
ip a
ip route
cat /etc/resolv.conf

# Logs (last 100 lines)
journalctl -n 100 --no-pager

# Docker
docker ps -a
docker system df
```

---

## 📝 Getting Help

### Before Asking for Help

Collect this information:

```bash
# 1. System info
uname -a > debug-info.txt
echo "---" >> debug-info.txt

# 2. Script version
git log --oneline -1 >> debug-info.txt
echo "---" >> debug-info.txt

# 3. Error messages
journalctl -xe --no-pager >> debug-info.txt

# 4. Memory status
mem >> debug-info.txt
echo "---" >> debug-info.txt

# 5. Docker status (if relevant)
docker ps -a >> debug-info.txt
```

### Where to Get Help

1. **GitHub Issues**: https://github.com/IFAKA/arch-arm-dev-setup/issues
2. **Arch Linux ARM Forums**: https://archlinuxarm.org/forum
3. **UTM Community**: https://github.com/utmapp/UTM/discussions

---

## 🆘 Emergency Recovery

### System Unresponsive

```bash
# 1. Force kill processes
sudo pkill -9 chromium
sudo pkill -9 docker

# 2. Emergency sync and reboot
sudo sync
sudo reboot -f
```

### Can't Login Graphically

```bash
# 1. Switch to TTY
# Press: Ctrl+Alt+F2

# 2. Login as your user

# 3. Check what's wrong
journalctl -xe | grep -i error

# 4. Kill Sway if stuck
pkill -9 sway

# 5. Try starting again
sway
```

### Out of Disk Space

```bash
# Find large files
sudo du -h --max-depth=1 / | sort -rh | head -20

# Clean Docker
docker system prune -a -f

# Clean package cache
sudo pacman -Sc --noconfirm

# Clean logs
sudo journalctl --vacuum-size=50M
```

---

## ✅ Verification Checklist

After fixing issues, verify:

```bash
# Memory
mem  # Should show reasonable usage

# Docker
docker ps  # Should work without sudo

# Sway
sway  # Should launch without errors

# Languages
node --version
go version
rustc --version
python --version

# UTM (if applicable)
ls /mnt/shared  # Should be accessible
# Test clipboard by copying/pasting
```

---

**Still having issues?** Open an issue on GitHub with:
1. Error message
2. Output of diagnostic commands
3. What you've tried so far
