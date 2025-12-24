# 📦 Project Summary

## Repository: arch-arm-dev-setup

**GitHub URL:** https://github.com/IFAKA/arch-arm-dev-setup

**Purpose:** Automated post-installation setup for Arch Linux ARM on aarch64/ARM64 devices, optimized for UTM virtual machines and 4GB RAM systems.

---

## 📁 Repository Structure

```
arch-arm-dev-setup/
├── README.md                      # Main project documentation
├── QUICKSTART.md                  # Quick start guide (30 min setup)
├── SETUP-FLOW.md                  # Visual setup flow and architecture
├── COMMANDS.md                    # Complete command reference
├── TROUBLESHOOTING.md             # Common issues and solutions
├── arch-arm-post-install.sh       # Main installation script ⭐
├── arch-arm-setup-guide.md        # Detailed manual setup guide
├── UTM-CONFIG-GUIDE.md            # UTM-specific configuration
├── LICENSE                        # MIT License
└── .gitignore                     # Git ignore rules
```

---

## 🎯 Quick Usage

### For New Users (Complete Setup)

```bash
# On fresh Arch Linux ARM installation:
git clone https://github.com/IFAKA/arch-arm-dev-setup.git
cd arch-arm-dev-setup
./arch-arm-post-install.sh
```

### For Existing Users (Updates)

```bash
cd arch-arm-dev-setup
git pull
# Review any new features or changes
```

---

## 📚 Documentation Breakdown

### 1. README.md
- **Target Audience:** Everyone
- **Content:** Overview, features, quick start, usage examples
- **When to read:** First time seeing the project

### 2. QUICKSTART.md
- **Target Audience:** Users who want to get running fast
- **Content:** Step-by-step installation in ~30 minutes
- **When to read:** When you're ready to install

### 3. arch-arm-setup-guide.md
- **Target Audience:** Users who want to understand every step
- **Content:** Complete manual setup guide with explanations
- **When to read:** If you want to learn or customize

### 4. UTM-CONFIG-GUIDE.md
- **Target Audience:** macOS users running UTM
- **Content:** UTM-specific setup (clipboard, shared folders)
- **When to read:** After installation, to enable UTM features

### 5. SETUP-FLOW.md
- **Target Audience:** Visual learners
- **Content:** Flowcharts, architecture diagrams, memory usage
- **When to read:** To understand the system architecture

### 6. COMMANDS.md
- **Target Audience:** Daily users
- **Content:** All available commands and shortcuts
- **When to read:** Keep as reference while working

### 7. TROUBLESHOOTING.md
- **Target Audience:** Users facing issues
- **Content:** Common problems and solutions
- **When to read:** When something doesn't work

---

## 🔧 Main Script: arch-arm-post-install.sh

### What It Does

Automates 12 phases of installation:

1. **System Update** - Updates all packages
2. **System Configuration** - Sets timezone, hostname
3. **UTM Integration** - Clipboard and shared folders
4. **Memory Management** - zram setup
5. **Display Environment** - Sway + Waybar
6. **Development Tools** - CLI tools, editors
7. **Language Runtimes** - Node.js, Go, Rust, Python, C/C++
8. **Docker Setup** - Containerization platform
9. **Database Tools** - PostgreSQL, Redis, MongoDB clients
10. **Utility Scripts** - Workflow automation
11. **Shell Configuration** - Aliases and environment
12. **AUR Helper** - yay (optional)

### Runtime

- **Minimum:** ~45 minutes (with fast internet)
- **Typical:** ~1-2 hours
- **Maximum:** ~3 hours (with slow connection)

### User Interaction

Script asks for:
- Timezone (e.g., America/New_York)
- Hostname (e.g., devbox)
- Whether to install yay AUR helper

Everything else is automated.

---

## 🎨 What Gets Installed

### System Layer
- **OS:** Arch Linux ARM (aarch64)
- **Display:** Sway (Wayland compositor)
- **Terminal:** Foot
- **Launcher:** Wofi
- **Status Bar:** Waybar

### Development Stack
- **Languages:** Node.js, Go, Rust, Python, C/C++
- **Containers:** Docker + Docker Compose
- **Databases:** PostgreSQL, Redis, MongoDB (as containers)
- **Editors:** Neovim
- **Tools:** tmux, ripgrep, fd, fzf, jq, htop, btop

### UTM Integration (if on UTM)
- **Clipboard:** spice-vdagent
- **Guest Agent:** qemu-guest-agent
- **Shared Folders:** virtiofs

### Memory Management
- **zram:** 2GB compressed swap
- **Total Effective:** ~6GB (from 4GB physical)

---

## 💡 Key Features

### Memory Optimization
- Idle: ~300MB
- Coding: ~620MB (without browser)
- Fullstack: ~1.2GB
- Compiles Rust projects with 4GB RAM

### Utility Scripts Created

```bash
mem                # Check memory status
memp               # Memory pressure detection
dstart <profile>   # Start Docker containers
dstop              # Stop Docker containers
dmem               # Docker memory usage
wf                 # Frontend workflow
wfs                # Fullstack workflow
wc                 # Prepare for compilation
```

### One-Window Workflow
- Workspace 1: Coding (terminal + editor)
- Workspace 2: Browser (when needed)
- Fullscreen by default
- Minimal distractions

---

## 🚀 Use Cases

### Perfect For:
✅ Fullstack development on ARM devices  
✅ Learning system administration  
✅ Battery-efficient portable coding  
✅ UTM virtual machines on Apple Silicon Macs  
✅ Raspberry Pi 4/5 development  
✅ Memory-constrained environments  
✅ Disciplined, focused development workflow  

### Not Ideal For:
❌ Heavy IDE usage (VS Code, IntelliJ)  
❌ Multiple simultaneous browsers  
❌ Video editing or graphics work  
❌ Running 10+ Docker containers  
❌ Extensive multitasking  

---

## 🔄 Typical Workflow

### Morning Setup
```bash
sway               # Start environment
wf                 # Launch frontend workflow
mem                # Check memory status
cd ~/projects/myapp
nvim .             # Start coding
```

### During Development
```bash
# Workspace 1: Code
npm run dev        # Development server

# Switch to Workspace 2 (Super+2)
# browser          # Test in browser

# Back to Workspace 1 (Super+1)
```

### Before Heavy Compilation
```bash
wc                 # Close browser, free memory
cargo build        # Compile Rust
# or
npm run build      # Build Node.js project
```

### End of Day
```bash
dstop              # Stop Docker containers
# Log out or leave running
```

---

## 📊 Resource Usage

### Disk Space
- **After installation:** ~8-10GB
- **With projects:** ~15-20GB recommended
- **SD card:** 32GB minimum, 64GB recommended

### Network
- **Initial download:** ~2-3GB (packages + Docker images)
- **Bandwidth:** Fast internet recommended

### CPU
- **Minimum:** 2 cores
- **Recommended:** 4 cores
- **Works on:** Raspberry Pi 4/5, UTM on M1/M2/M3 Macs

---

## 🎓 Learning Path

### Beginner Path
1. Read: README.md
2. Follow: QUICKSTART.md
3. Run: `./arch-arm-post-install.sh`
4. Reference: COMMANDS.md
5. If issues: TROUBLESHOOTING.md

### Advanced Path
1. Read: arch-arm-setup-guide.md
2. Study: SETUP-FLOW.md
3. Customize: Edit script before running
4. Optimize: Tune for your specific needs

### UTM Users
1. Read: README.md
2. Read: UTM-CONFIG-GUIDE.md
3. Follow: QUICKSTART.md
4. Configure: Shared folders + clipboard
5. Enjoy: Seamless macOS integration

---

## 🔐 Security Considerations

### Default Passwords (Change These!)
- **PostgreSQL:** devuser / devpassword
- **MongoDB:** devuser / devpassword

To change:
```bash
# Edit docker-compose.yml
nano ~/docker-compose-template.yml
# Update POSTGRES_PASSWORD and MONGO_INITDB_ROOT_PASSWORD
```

### SSH Access
- SSH server NOT installed by default
- Install manually if needed: `sudo pacman -S openssh`

---

## 🌟 Success Stories (Potential Use Cases)

1. **Student Developer**
   - Raspberry Pi 4 setup
   - Learns fullstack development
   - 20+ hour battery with power bank

2. **Remote Worker**
   - UTM on MacBook Air M2
   - Isolated dev environment
   - Quick snapshots for testing

3. **Nomadic Developer**
   - Portable ARM device
   - Low power consumption
   - Works offline with Docker

4. **Learning Systems**
   - Teaches Linux administration
   - Practices Docker
   - Understands resource management

---

## 🤝 Contributing

### Ways to Contribute
1. Report bugs in GitHub Issues
2. Suggest improvements
3. Add new language runtimes
4. Improve documentation
5. Share your setup/tweaks

### Before Contributing
- Test on actual ARM hardware or UTM
- Verify memory usage stays within limits
- Update documentation
- Follow existing script style

---

## 📈 Future Roadmap (Ideas)

- [ ] Additional language support (Java, PHP, Ruby)
- [ ] Alternative window managers (i3, Hyprland)
- [ ] Browser profiles (Firefox option)
- [ ] Automated backups
- [ ] SSH remote development setup
- [ ] Kubernetes (k3s) lightweight option
- [ ] CI/CD tools (Gitea, Drone)
- [ ] Monitoring dashboards

---

## 📞 Support

### Getting Help
1. **Check docs first:** TROUBLESHOOTING.md
2. **Search issues:** GitHub Issues (closed issues too)
3. **Ask community:** GitHub Discussions
4. **Report bug:** Open new issue with details

### Providing Help
- Answer questions in Discussions
- Help troubleshoot issues
- Improve documentation
- Share your workflow

---

## 🏆 Credits

### Built With
- **Arch Linux ARM** - Base OS
- **Sway** - Window manager
- **Docker** - Containerization
- **UTM** - macOS virtualization
- **Open Source Community** - Everything!

### Inspired By
- Minimal Linux setups
- Developer productivity tools
- Memory-efficient workflows
- Battery-conscious computing

---

## 📄 License

MIT License - Free to use, modify, and distribute.

See [LICENSE](LICENSE) for full text.

---

## 🎯 Project Goals

✅ **Simplicity:** One command to setup  
✅ **Efficiency:** Maximum productivity on minimum RAM  
✅ **Discipline:** Encourage focused development  
✅ **Education:** Teach resource management  
✅ **Accessibility:** Work on affordable ARM hardware  
✅ **Sustainability:** Low power, long battery life  

---

## 🚀 Recent Improvements (Dec 2025)

### Two-Script Installation System
- **macOS Pre-Install Script:** Automatic UTM VM detection, disk resizing, fully automated
- **VM Bootstrap Script:** One-line installer with disk expansion, system upgrade, TUI wizard

### Disk & System Management
- ✅ **Automatic Disk Expansion:** Detects unallocated space, expands before packages
- ✅ **/boot Space Verification:** Pre-checks 100MB+ free space before kernel upgrades
- ✅ **System Upgrade Detection:** Auto-upgrades outdated UTM Gallery images (glibc 2.36→2.38)
- ✅ **Recovery Instructions:** Clear error messages with specific fix commands

### UX Improvements
- ✅ **Automatic Timezone Detection:** IP geolocation with user confirmation
- ✅ **Clean ASCII TUI:** No emoji/Unicode issues in serial consoles
- ✅ **Kernel Message Suppression:** `dmesg -n 1` prevents log spam during install
- ✅ **Sway Auto-Start:** Works on both tty1 and ttyAMA0 (UTM serial console)
- ✅ **Zero-Prompt Automation:** Mac script runs without user input

### Error Prevention
- ✅ **sfdisk Fallback:** Disk expansion works without pre-installing parted
- ✅ **/boot Cleanup:** Auto-removes old kernel images before upgrade
- ✅ **Space Verification:** Fails early with instructions if insufficient
- ✅ **VM Running Detection:** macOS script detects active VM automatically

**Latest Commits:**
- `7772f61` - /boot space verification + error recovery (Dec 24, 2025)
- `bbfc61e` - Clean /boot before system upgrade (Dec 24, 2025)
- `7e4f0ca` - Fully automatic macOS pre-install (Dec 23, 2025)
- `acd11ac` - UX fixes: ASCII TUI, timezone, Sway autostart (Dec 23, 2025)

---

**Repository:** https://github.com/IFAKA/arch-arm-dev-setup

**Star the repo if it helped you!** ⭐
