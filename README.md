# 🚀 Arch ARM Dev Setup

**One-command setup for a complete fullstack development environment on Arch Linux ARM (aarch64)**

Perfect for UTM virtual machines on Apple Silicon Macs or physical ARM devices like Raspberry Pi with 4GB RAM.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: ARM64](https://img.shields.io/badge/Platform-ARM64%2Faarch64-green.svg)]()
[![Optimized: 4GB RAM](https://img.shields.io/badge/RAM-4GB%20Optimized-orange.svg)]()

---

## ⚡ TL;DR - Get Started in 30 Seconds

### 🍎 For Mac Users (UTM - Recommended!)

**📖 Complete step-by-step guide:** [**INSTALL-FROM-UTM-GALLERY.md**](INSTALL-FROM-UTM-GALLERY.md) ⭐

```bash
# 1. Download Arch Linux ARM from UTM Gallery
#    https://mac.getutm.app/gallery/archlinux-arm

# 2. Resize disk BEFORE first boot (32GB recommended):
brew install qemu
cd ~/Downloads/ArchLinux.utm/Data
# Automatically find and resize the largest disk (your main disk)
qemu-img resize "$(ls -S *.qcow2 | head -1)" 32G

# 3. Start VM, login as root/root, then run ONE command:
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
# ✨ The installer will automatically expand your disk to use all 32GB!
```

### 🐧 For Existing Arch Linux ARM Systems

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
```

---

**🎁 What You Get:**

- ✅ **Zsh** + **Starship** prompt (beautiful, git-aware, fast)
- ✅ **VimZap Neovim** (12ms startup, full IDE experience)
- ✅ **Node.js** + **Go** + **Rust** + **Python** + **C/C++**
- ✅ **Docker** + **PostgreSQL** + **Redis** + **MongoDB**
- ✅ **Auto-starts GUI** on login - zero manual setup needed!
- ✅ **Automatic disk expansion** in VMs (UTM/QEMU)

**💾 Memory:** ~300MB idle, ~1.2GB fullstack dev (works great on 4GB RAM)

**⚡ Result:** Login → Sway starts → Terminal opens → Start coding! ✨

---

## 📋 Table of Contents

<details>
<summary>Click to expand full navigation</summary>

- [✨ What This Gives You](#-what-this-gives-you)
- [🎯 Quick Start](#-quick-start)
- [📋 For UTM on macOS](#-for-utm-on-macos)
- [📋 For Physical ARM Devices](#-for-physical-arm-devices)
- [💻 After Installation](#-after-installation---amazing-dx)
- [🛠️ What Gets Installed](#️-what-gets-installed)
- [📊 Resource Usage](#-resource-usage)
- [🐛 Troubleshooting](#-troubleshooting)
- [📚 Documentation](#-documentation)
- [🔧 Customization](#-customization)

</details>

---

## ✨ What This Gives You

### 🖥️ **Modern Shell Experience**

| Feature            | What You Get                           |
| ------------------ | -------------------------------------- |
| **Shell**          | Zsh with Starship prompt               |
| **Visual**         | Git-aware, beautiful, blazing fast     |
| **Smart Features** | Auto-suggestions + syntax highlighting |
| **Completion**     | Case-insensitive, context-aware        |
| **Config**         | Shared between Zsh and Bash            |

### ⚡ **VimZap Neovim Config**

| Feature        | Benefit                                      |
| -------------- | -------------------------------------------- |
| **Startup**    | 12ms - instant launch                        |
| **Experience** | LazyVim DX - just works                      |
| **Discovery**  | Press `Space` for command menu               |
| **LSP**        | Node.js, TypeScript, Go, Rust, Python, C++   |
| **Tools**      | File explorer, fuzzy finder, Git integration |

### 🔧 **Complete Development Stack**

```
Languages:    Node.js (nvm) · Go · Rust · Python · C/C++
Containers:   Docker (memory-optimized)
Databases:    PostgreSQL · Redis · MongoDB (Docker)
CLI Tools:    ripgrep · fd · fzf · jq · btop
```

### 🎯 **Amazing Developer Experience**

- ✅ **Auto-starts GUI on login** - No manual commands needed
- ✅ **Terminal ready immediately** - Welcome message shows all commands
- ✅ **Smart workflow commands** - `wf`, `wfs`, `help` - discoverable and intuitive
- ✅ **Zero friction** - Just login and start coding
- ✅ **Aliases everywhere** - `v`/`vi`/`vim` → neovim, `gs` → git status, etc.

### 🖼️ **UTM Integration** (for macOS users)

- ✅ Clipboard sharing (copy/paste between host and VM)
- ✅ Shared folders support
- ✅ Optimized display configuration

### 💾 **Memory Efficiency**

| Scenario      | RAM Usage | Effective Memory       |
| ------------- | --------- | ---------------------- |
| **Idle**      | ~300MB    | zram gives you ~6GB    |
| **Coding**    | ~620MB    | from 4GB physical RAM  |
| **Fullstack** | ~1.2GB    | Compressed efficiently |

### 🪟 **Sway Window Manager**

- ✅ Minimal Wayland compositor
- ✅ One-window, one-screen workflow
- ✅ Battery-optimized configuration
- ✅ **Auto-starts on login** - zero setup!

### 🛠️ **Smart Utilities**

- ✅ Memory monitoring and management
- ✅ Docker workflow automation
- ✅ Development environment launchers
- ✅ Discoverable help system

---

## 🎯 Quick Start

### **📦 One-Line Installation**

```bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Boot Arch Linux ARM
# Step 2: Login as root (password: root)
# Step 3: Run this ONE command:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# That's it! The installer will:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ✅ Show a beautiful TUI wizard
# ✅ Ask for username, password, timezone, hostname
# ✅ Install everything (~60 minutes)
# ✅ Reboot automatically
# ✅ You login and Sway starts automatically!
```

### **🔄 Complete Flow** (Visual Timeline)

```
┌─────────────────────────────────────────────────────────────┐
│ 1️⃣  Download Arch Linux ARM from archlinuxarm.org          │
├─────────────────────────────────────────────────────────────┤
│ 2️⃣  Create UTM VM (4GB RAM, 2-4 CPU cores)                 │
├─────────────────────────────────────────────────────────────┤
│ 3️⃣  Boot and login as root                                 │
├─────────────────────────────────────────────────────────────┤
│ 4️⃣  Run the one-line install command ☝️                     │
├─────────────────────────────────────────────────────────────┤
│ 5️⃣  Answer 4 quick questions                               │
│    • Username                                               │
│    • Password                                               │
│    • Timezone                                               │
│    • Hostname                                               │
├─────────────────────────────────────────────────────────────┤
│ 6️⃣  Wait ~60 minutes (get coffee! ☕)                       │
├─────────────────────────────────────────────────────────────┤
│ 7️⃣  System reboots automatically                           │
├─────────────────────────────────────────────────────────────┤
│ 8️⃣  Login with your new username                           │
├─────────────────────────────────────────────────────────────┤
│ 9️⃣  Sway GUI starts automatically                          │
├─────────────────────────────────────────────────────────────┤
│ 🔟 Terminal opens with welcome message                     │
├─────────────────────────────────────────────────────────────┤
│ 🎉 Start coding immediately!                               │
└─────────────────────────────────────────────────────────────┘
```

### **✨ What Makes This Special?**

**Zero Manual Steps After Install:**

| Feature                         | Status |
| ------------------------------- | ------ |
| Sway auto-starts when you login | ✅     |
| Terminal auto-opens in Sway     | ✅     |
| Welcome message shows (once)    | ✅     |
| All commands discoverable       | ✅     |
| Type `help` anytime             | ✅     |

**🧠 ADHD-Friendly:** No memorization needed - everything is discoverable!

---

## 📋 For UTM on macOS

> **⭐ NEW! Complete Installation Guide for Mac Users**
> 
> **[📖 INSTALL-FROM-UTM-GALLERY.md](INSTALL-FROM-UTM-GALLERY.md)** - Step-by-step guide from UTM Gallery to working dev environment!
> 
> Includes: Disk resizing, automatic expansion, troubleshooting, and more!

### Quick Start for UTM

### 1️⃣ **Get Arch Linux ARM**

**Easiest method:**
- Go to https://mac.getutm.app/gallery/archlinux-arm
- Click "Open in UTM"
- **IMPORTANT:** Resize disk to 32GB+ before first boot ([see guide](INSTALL-FROM-UTM-GALLERY.md#step-2-resize-the-disk-important))

**Or create manually:**
- 📥 **Download** [Arch Linux ARM](https://archlinuxarm.org/platforms/armv8/generic)
- ⚙️ **Configure**: 4GB RAM, 2-4 CPU cores, **16GB+ disk**
- 📖 **Details**: See [UTM Configuration Guide](UTM-CONFIG-GUIDE.md)

### 2️⃣ **First Boot**

```bash
# Login credentials
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Username: root
Password: root

# Test internet connection
ping -c 3 archlinux.org

# Run installer - it will automatically expand your disk!
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
```

**✨ The installer automatically detects and expands your disk** - no manual partition/filesystem commands needed!

### 3️⃣ **Configure Shared Folder** (Optional)

**Before or after installation:**

1. **Open** VM Settings → Sharing
2. **Add** a folder from your Mac
3. **Name** it: `shared`
4. **Access** at `/mnt/shared` in VM

---

## 📋 For Physical ARM Devices

**✅ Works on:**

- Raspberry Pi 4/5 (4GB+ model)
- Other ARM64/aarch64 devices

```bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# After installing Arch Linux ARM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# SSH or login directly, then run:
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash

# ✅ UTM-specific features will be auto-detected and skipped
```

---

## 💻 After Installation - Amazing DX!

### **🎉 Your First Login**

```
[youruser@devbox login:] youruser
[Password:] ********

→ Sway starts automatically! ✨
→ Terminal opens with Zsh + Starship! ✨
→ Welcome message appears (once):

╔═══════════════════════════════════════════════════════════╗
║  🚀 Welcome to Your Development Environment!              ║
╠═══════════════════════════════════════════════════════════╣
║  Shell: Zsh with Starship prompt (git-aware, beautiful)  ║
║  Editor: Neovim with VimZap (12ms startup, LazyVim DX)   ║
║                                                           ║
║  Quick Commands:                                          ║
║  • v, vi, vim  - Open Neovim (press Space for menu)      ║
║  • help        - Show all commands                        ║
║  • wf          - Start frontend dev workflow              ║
║  • wfs         - Start fullstack dev workflow             ║
║  • mem         - Check memory usage                       ║
╚═══════════════════════════════════════════════════════════╝

❯ █
```

**That's it! Start coding immediately - no manual setup needed!** 🎊

---

### **⚡ Quick Command Reference**

<details>
<summary><strong>📝 Essential Commands (Click to expand)</strong></summary>

#### **🎨 Neovim with VimZap**

```bash
v myfile.js      # Open file in Neovim
vi myfile.js     # Same (alias)
vim myfile.js    # Same (alias)
```

**In Neovim**: Press `Space` for command menu

| Key          | Action                |
| ------------ | --------------------- |
| `Space + e`  | File explorer         |
| `Space + ff` | Find files            |
| `Space + fg` | Grep in files         |
| `Space + gg` | LazyGit (full Git UI) |
| `Space + ?`  | Show all keymaps      |

#### **🛠️ Development Workflows**

```bash
help             # Show all commands
wf               # Start frontend (Postgres + Redis)
wfs              # Start fullstack (all databases)
mem              # Check memory usage
```

#### **🐳 Docker Management**

```bash
dstart frontend  # Start databases
dstop            # Stop all containers
dmem             # Check container memory
dps              # Show running containers
```

#### **📦 Project Management**

```bash
mkproject my-app # Create new project
dev myproject    # Start tmux session
projects         # cd ~/projects
```

#### **🎬 Media & Browser**

```bash
web              # Open Firefox
ytplay <url>     # Watch YouTube in mpv (720p max - memory friendly)
ytsearch <term>  # Search and play YouTube
yt <url>         # Download YouTube video
yta <url>        # Download audio only
```

</details>

---

### **⌨️ Neovim (VimZap) Keybindings**

**Open Neovim** with `v`, `vi`, or `vim`:

<details>
<summary><strong>🎹 Press Space to see command menu - here are the highlights:</strong></summary>

#### **File Management**

| Key          | Action                       |
| ------------ | ---------------------------- |
| `Space`      | **Command menu** (shows all) |
| `Space + e`  | File explorer (toggle)       |
| `Space + ff` | Find files (fuzzy)           |
| `Space + fg` | Grep in files                |
| `Space + fb` | Find buffers                 |
| `Space + fr` | Recent files                 |

#### **Code Actions (LSP)**

| Key          | Action           |
| ------------ | ---------------- |
| `Space + ca` | Code action      |
| `Space + cr` | Rename symbol    |
| `Space + cf` | Format code      |
| `gd`         | Go to definition |
| `gr`         | Go to references |
| `K`          | Hover docs       |

#### **Git Integration**

| Key          | Action            |
| ------------ | ----------------- |
| `Space + gg` | LazyGit (full UI) |
| `Space + gf` | Git files         |
| `Space + gs` | Git status        |

#### **Help**

| Key         | Action           |
| ----------- | ---------------- |
| `Space + ?` | Show all keymaps |

</details>

**💡 Pro Tip:** VimZap provides a complete IDE experience. Just press `Space` to discover everything!

---

### **🪟 Sway Window Manager - Complete Guide**

**All keybindings work immediately after login:**

<details>
<summary><strong>🎮 Window Manager Controls (Click to expand)</strong></summary>

#### **Applications**

| Key           | Action                      |
| ------------- | --------------------------- |
| `Super+Enter` | Open new terminal           |
| `Super+w`     | Open Firefox browser        |
| `Super+n`     | Open Neovim in terminal     |
| `Super+d`     | Application launcher (wofi) |

#### **Window Navigation**

| Key                   | Action                                |
| --------------------- | ------------------------------------- |
| `Super+Tab`           | Switch between windows (like Alt+Tab) |
| `Super+Shift+Tab`     | Switch windows backwards              |
| `Super+Arrows`        | Move focus between windows            |
| `Super+1/2/3/4`       | Switch to workspace 1/2/3/4           |
| `Super+Shift+1/2/3/4` | Move window to workspace              |

#### **Window Management**

| Key             | Action                                            |
| --------------- | ------------------------------------------------- |
| `Super+f`       | Toggle fullscreen                                 |
| `Super+r`       | Enter resize mode (arrows to resize, Esc to exit) |
| `Super+Space`   | Toggle floating mode                              |
| `Super+Shift+Q` | Close current window                              |

#### **System**

| Key             | Action                        |
| --------------- | ----------------------------- |
| `Super+Shift+C` | Reload Sway configuration     |
| `Super+Shift+E` | Exit Sway (drops to terminal) |

_Super key = Windows key / Command key_

**💡 Pro Tips:**

- **If you close Sway** (`Super+Shift+E`): Just type `sway` to restart it
- **Windows persist**: Your open windows will be restored
- **Auto-restart on reboot**: Sway starts automatically when you login
- **One workspace per task**: Use workspaces 1-4 for different projects

</details>

---

## 🛠️ What Gets Installed

<details>
<summary><strong>📦 Click to see complete installation list</strong></summary>

### **System Components**

| Component          | Details                      |
| ------------------ | ---------------------------- |
| **Shell**          | Zsh + Starship prompt        |
| **Window Manager** | Sway (Wayland) - auto-starts |
| **Terminal**       | Foot - auto-opens            |
| **Launcher**       | Wofi                         |
| **Status Bar**     | Waybar                       |
| **Memory**         | zram with zstd compression   |

### **Development Tools**

**Editor**: Neovim with VimZap config

- ⚡ 12ms startup time
- 📁 File explorer (neo-tree)
- 🔍 Fuzzy finder (telescope)
- 🧠 LSP support (Node, TS, Go, Rust, Python, C++)
- 🌿 Git integration (LazyGit)
- ✨ Auto-completion (nvim-cmp)
- 🎨 Syntax highlighting (treesitter)

**Multiplexer**: tmux with vim keybindings

**CLI Tools**: ripgrep · fd · fzf · jq · htop · btop

**Zsh Plugins**:

- zsh-autosuggestions
- zsh-syntax-highlighting

### **Language Runtimes**

| Language    | Version Manager             | Path       |
| ----------- | --------------------------- | ---------- |
| **Node.js** | nvm (latest LTS) + pnpm     | `~/.nvm`   |
| **Go**      | Latest from official repos  | System     |
| **Rust**    | rustup (latest stable)      | `~/.cargo` |
| **Python**  | Python 3 + pip + virtualenv | System     |
| **C/C++**   | gcc, clang, cmake, ninja    | System     |

### **Containerization**

- **Docker**: Memory-optimized configuration
- **Docker Compose**: Multi-container apps

### **Database Clients**

- PostgreSQL client libraries
- Redis CLI
- MongoDB tools (via Docker)

### **UTM Integration** (when detected)

- SPICE vdagent (clipboard sharing)
- QEMU guest agent
- virtiofs (shared folders)

### **Smart Utilities**

```bash
help        # Show all commands
wf / wfs    # Development workflows
mem / memp  # Memory monitoring
dstart / dstop  # Docker management
mkproject   # Quick project creation
dev         # Tmux session management
```

</details>

---

## 📊 Resource Usage

### **💾 Memory Usage by Scenario**

| Scenario            | RAM Usage | What's Running                  |
| ------------------- | --------- | ------------------------------- |
| **🏠 Idle**         | ~300MB    | Sway + terminal                 |
| **💻 Coding**       | ~620MB    | + Neovim + LSPs + databases     |
| **🌐 With Browser** | ~970MB    | + Chromium (3 tabs)             |
| **🚀 Fullstack**    | ~1.2GB    | + all containers                |
| **🔨 Compiling**    | ~810MB    | Browser closed, compiler active |

### **🔋 Battery Life** (estimated for portable devices)

| Activity              | Estimated Hours |
| --------------------- | --------------- |
| **Coding only**       | 16-25 hours     |
| **With browser**      | 8-12 hours      |
| **Heavy compilation** | 6-10 hours      |

**💡 Tip:** Use `mem` and `memp` commands to monitor and optimize!

---

## 🐛 Troubleshooting

### **🔍 Top 3 Most Common Issues**

<details>
<summary><strong>1️⃣ Installation fails</strong></summary>

```bash
# Check the log
cat /var/log/arch-arm-setup.log

# The installer is idempotent - safe to re-run
curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash
```

</details>

<details>
<summary><strong>2️⃣ Sway doesn't auto-start</strong></summary>

```bash
# Check if auto-start is configured (should see Sway auto-start code)
cat ~/.zprofile    # For Zsh (default)
cat ~/.bash_profile  # For Bash

# Manually start Sway
sway
```

</details>

<details>
<summary><strong>3️⃣ Clipboard not working (UTM)</strong></summary>

```bash
# Restart the clipboard service
sudo systemctl restart spice-vdagentd.service
```

</details>

### **📚 More Help**

**See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for:**

- Shared folder mounting issues
- Docker permission problems
- Out of memory errors
- Network configuration
- And much more!

---

## 📚 Documentation

| Document                                                               | Description                                               |
| ---------------------------------------------------------------------- | --------------------------------------------------------- |
| **[INSTALL-FROM-UTM-GALLERY.md](INSTALL-FROM-UTM-GALLERY.md)** ⭐     | **Complete Mac/UTM installation guide (START HERE!)**     |
| **[QUICKSTART.md](QUICKSTART.md)**                                     | Quick reference (also at `~/QUICKSTART.md` after install) |
| **[UTM-CONFIG-GUIDE.md](UTM-CONFIG-GUIDE.md)**                         | UTM-specific configuration                                |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**                           | Common issues and solutions                               |
| **[arch-arm-setup-guide.md](arch-arm-setup-guide.md)**                 | Complete manual setup guide                               |

---

## 🔧 Customization

**Everything is customizable after installation:**

<details>
<summary><strong>🎨 Configuration Files (Click to expand)</strong></summary>

```bash
# Sway window manager configuration
nvim ~/.config/sway/config

# Shell aliases and functions (shared by Zsh and Bash)
nvim ~/.shell_common

# Zsh-specific configuration
nvim ~/.zshrc

# Bash-specific configuration
nvim ~/.bashrc

# Starship prompt configuration
nvim ~/.config/starship.toml

# Neovim (VimZap) configuration
nvim ~/.config/nvim/

# Docker memory limits
nvim ~/docker-compose-template.yml

# Tmux configuration
nvim ~/.tmux.conf
```

</details>

---

## 🤝 Contributing

**Contributions welcome!** Please feel free to submit issues or pull requests.

### **🎯 Areas for Improvement**

- [ ] Additional language runtime installers
- [ ] More workflow automation scripts
- [ ] Alternative window manager configs
- [ ] Performance optimizations
- [ ] Documentation improvements

---

## 📝 License

**MIT License** - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **[Arch Linux ARM](https://archlinuxarm.org/)** - Excellent ARM port
- **[Sway](https://swaywm.org/)** - Minimal Wayland compositor
- **[UTM](https://getutm.app/)** - Amazing virtualization for macOS
- **[whiptail/newt](https://pagure.io/newt)** - Beautiful TUI framework
- **Community contributors and testers**

---

## ⭐ Star History

**If this project helped you, please consider giving it a star!**

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/IFAKA/arch-arm-dev-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/IFAKA/arch-arm-dev-setup/discussions)

---

<div align="center">

**Built with ❤️ for the best developer experience on ARM**

**One command. Zero friction. Pure productivity.** 💪

</div>
