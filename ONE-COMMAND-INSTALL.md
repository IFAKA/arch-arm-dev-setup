# ⚡ One-Command Installation

**The entire setup is now fully autonomous.** Just run one command and walk away.

## 🚀 Quick Start (30 seconds)

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
```

That's it. Go grab coffee.

---

## 📋 What Happens Automatically

### **Phase 1: Bootstrap (5-10 minutes)**

The script automatically handles:

1. ✅ **Disk Expansion**
   - Expands root partition to use all 32GB
   - No manual `fdisk` needed

2. ✅ **/boot Cleanup**
   - Detects 97MB free space issue
   - Removes fallback initramfs (auto-recreated during upgrade)
   - Ensures 100MB+ free before upgrade

3. ✅ **System Upgrade**
   - Upgrades glibc 2.35 → 2.42+
   - Upgrades kernel 5.10 → 6.18+
   - Downloads ~800MB of packages
   - Handles all edge cases automatically

4. ✅ **Landlock/Sandbox Workaround**
   - Detects pacman 7.1.0 sandbox requirement
   - Old kernel doesn't support Landlock LSM
   - Automatically retries with `--disable-sandbox`
   - Installs whiptail successfully

5. ✅ **Installer Launch**
   - Downloads main TUI installer
   - Starts interactive wizard

### **Phase 2: Main Installation (15-20 minutes)**

Interactive TUI wizard appears. You select:

- Username & password
- Window manager (Sway)
- Development tools
- Languages (Go/Python/Rust/Node)
- Databases (PostgreSQL/Redis)
- Shell (Zsh + Starship)

Then it installs everything and reboots.

---

## 🎯 System Requirements

**macOS Side:**
- UTM installed
- Arch Linux ARM from UTM Gallery
- 4GB RAM allocated to VM
- 32GB disk (auto-expanded by script)

**Before Running:**
1. Download Arch ARM from UTM Gallery
2. Boot VM
3. Login as `root` (password: `root`)
4. Run the one-liner above

---

## ⏱️ Total Time

- **Automated bootstrap:** 5-10 minutes
- **Interactive TUI:** 15-20 minutes
- **Total:** ~25-30 minutes

---

## 🛡️ What Makes It Bulletproof?

The script handles **22 edge cases** automatically:

### **Whiptail Install (4 cases)**
- Pacman sandbox/Landlock errors
- Missing `--disable-sandbox` support
- Broken whiptail binary
- Network failures

### **System Upgrade (18 cases)**
- Missing glibc version
- /boot not mounted / read-only / corrupted
- Insufficient space in /boot
- Missing .old files
- pacman errors (lock, keyring, space)
- Command failures (df, du, rm)
- Verification failures

Full list: [EDGE-CASES-COVERED.md](EDGE-CASES-COVERED.md)

---

## 📊 What Gets Installed?

**After TUI wizard completes:**

- Sway (tiling window manager)
- Kitty terminal + Nerd Font
- Git, Docker, Docker Compose
- Go 1.23, Python 3.12, Rust, Node.js 22
- PostgreSQL 17, Redis
- Zsh + Oh My Zsh + Starship prompt
- Neovim + lazygit
- All packages configured and ready

---

## 🔧 If Something Fails

The script **auto-recovers** from all known failures. But if you hit a new edge case:

1. Check error message (it's descriptive)
2. Run manual recovery step shown
3. Re-run the one-liner
4. Report issue at: https://github.com/IFAKA/arch-arm-dev-setup/issues

---

## 🎬 Next Steps After Install

After reboot, you'll have:

- Login screen for your user
- Sway ready to launch
- All dev tools configured
- Ready to code!

See [DAILY-USAGE-GUIDE.md](DAILY-USAGE-GUIDE.md) for workflow tips.

---

## 🧪 Verification

To verify the installer is fully autonomous:

```bash
./test-autonomous-install.sh
```

Should show:
```
✓ Script is fully autonomous!
```

---

## 📚 More Docs

- [QUICKSTART.md](QUICKSTART.md) - Detailed walkthrough
- [INSTALL-FROM-UTM-GALLERY.md](INSTALL-FROM-UTM-GALLERY.md) - Mac setup
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues
- [EDGE-CASES-COVERED.md](EDGE-CASES-COVERED.md) - All 22 edge cases

---

**TL;DR:** One command. Walk away. Come back to fully configured dev environment.
