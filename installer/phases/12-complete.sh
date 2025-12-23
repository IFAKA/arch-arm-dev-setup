#!/bin/bash
#
# Phase 12: Finalization and Documentation
# Create QUICKSTART.md and finalize setup
#

phase_complete() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 12] Finalizing installation..."
    
    # Create comprehensive QUICKSTART.md
    cat > "$user_home/QUICKSTART.md" <<'EOF'
# 🚀 Quick Start Guide

Your Arch ARM development environment is ready! This guide will help you get started.

## 🎯 First Steps

### Your Environment

- **Shell**: Zsh with Starship prompt
  - Git-aware, beautiful, fast
  - Auto-suggestions and syntax highlighting
  - Smart completion
  
- **Editor**: Neovim with VimZap
  - 12ms startup time
  - LazyVim developer experience
  - File explorer, fuzzy finder, LSP, Git integration built-in
  - Press `Space` in Neovim for command menu

- **GUI**: Sway window manager (Wayland)
  - Starts automatically when you login
  - Minimal, fast, battery-optimized
  
- **Terminal**: Foot terminal emulator
  - Opens automatically on Sway start
  - Fast and lightweight

- **Memory**: zram compression enabled
  - ~6GB effective memory from 4GB RAM
  - Optimized for development workloads

## ⌨️ Essential Keybindings

### Sway Window Manager

| Keybinding | Action |
|------------|--------|
| `Super+Enter` | Open new terminal |
| `Super+d` | Application launcher |
| `Super+1/2/3/4` | Switch to workspace 1/2/3/4 |
| `Super+Shift+1/2/3/4` | Move window to workspace |
| `Super+f` | Toggle fullscreen |
| `Super+Shift+Q` | Close window |
| `Super+Shift+E` | Exit Sway |
| `Super+Shift+C` | Reload configuration |

**Note**: `Super` key = Windows key / Command key

### Neovim (VimZap) - 12ms Startup, LazyVim DX

Open Neovim with any of these commands:
```bash
v myfile.js
vi myfile.js
vim myfile.js
nvim myfile.js
```

| Keybinding | Action |
|------------|--------|
| `Space` | **Command menu** (shows all available commands) |
| `Space + e` | File explorer (toggle) |
| `Space + ff` | Find files (fuzzy search) |
| `Space + fg` | Grep in files (search content) |
| `Space + fb` | Find buffers |
| `Space + fr` | Recent files |
| `Space + ca` | Code action (LSP) |
| `Space + cr` | Rename symbol (LSP) |
| `Space + cf` | Format code |
| `Space + gg` | LazyGit (full Git UI) |
| `Space + gf` | Git files |
| `Space + gs` | Git status |
| `Space + ?` | Show all keymaps |

#### LSP Navigation (Language Server)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `[d` / `]d` | Previous/next diagnostic |
| `[h` / `]h` | Previous/next git hunk |

#### File Explorer (Inside neo-tree)

| Key | Action |
|-----|--------|
| `a` | Add file/folder (end with `/` for folder) |
| `d` | Delete |
| `r` | Rename |
| `m` | Move |
| `c` | Copy |
| `q` | Close explorer |

**Pro Tip**: VimZap comes with LSP support for Node.js, TypeScript, Go, Rust, Python, and more. Just open a file and start coding - autocomplete and diagnostics work automatically!

## 🛠️ Development Commands

### Workflows

```bash
# Frontend development (Postgres + Redis)
wf

# Fullstack development (all databases)
wfs

# Prepare for compilation (frees memory)
wc
```

### Docker Management

```bash
# Start containers
dstart frontend    # Start Postgres + Redis
dstart fullstack   # Start all databases

# Stop all containers
dstop

# Check container memory usage
dmem

# View running containers
dps

# Follow logs
dlogs
```

### Memory Management

```bash
# Check memory usage
mem

# Check if system is under memory pressure
memp
```

### Project Management

```bash
# Create new project
mkproject my-awesome-app
# Creates ~/projects/my-awesome-app with git init

# Quick navigation
projects    # cd ~/projects
cd my-awesome-app
```

### Tmux Sessions

```bash
# Start/attach to tmux session
dev              # Default session name
dev myproject    # Custom session name
```

## 📦 Installed Languages & Tools

### Languages

| Language | Version Management | Install Path |
|----------|-------------------|--------------|
| **Node.js** | nvm | `~/.nvm` |
| **Go** | System package | `/usr/bin/go` |
| **Rust** | rustup | `~/.cargo` |
| **Python** | System package | `/usr/bin/python` |
| **C/C++** | gcc/clang | `/usr/bin` |

### Node.js

```bash
# Check version
node --version
npm --version

# Use nvm to manage versions
nvm list
nvm install 20    # Install Node 20
nvm use 20        # Switch to Node 20
```

### Go

```bash
# Check version
go version

# Your workspace
echo $GOPATH      # ~/go

# Create a new module
go mod init myproject
```

### Rust

```bash
# Check version
rustc --version
cargo --version

# Update Rust
rustup update

# Create new project
cargo new myproject
```

### Python

```bash
# Check version
python --version

# Create virtual environment
python -m venv venv
source venv/bin/activate
```

## 🐳 Docker Development

### Using Docker Compose

Example project setup:

```bash
# Copy the template
cp ~/docker-compose-template.yml ~/projects/myapp/docker-compose.yml

# Edit as needed
nvim ~/projects/myapp/docker-compose.yml

# Start services
cd ~/projects/myapp
dstart frontend
```

### Database Connections

When containers are running:

- **PostgreSQL**: `localhost:5432`
  - User: `devuser`
  - Password: `devpassword`
  - Database: `devdb`

- **Redis**: `localhost:6379`

- **MongoDB**: `localhost:27017`
  - User: `devuser`
  - Password: `devpassword`

## 📝 Neovim Tips

```bash
# Open neovim
nvim

# Quick commands
:help          # Built-in help
:e filename    # Edit file
:w             # Save
:q             # Quit
:wq            # Save and quit
```

## 🔧 System Maintenance

### Update System

```bash
# Update all packages
update

# Or manually
sudo pacman -Syu
```

### Clean Up

```bash
# Remove unused packages
cleanup

# Or manually
sudo pacman -Rns $(pacman -Qtdq)
```

### Check Logs

```bash
# Installation log
cat /var/log/arch-arm-setup.log

# System journal
journalctl -xe
```

## 💡 Tips & Tricks

### 1. Multiple Terminals

Press `Super+Enter` to open as many terminals as you need. Use workspaces to organize:
- Workspace 1: Code editor
- Workspace 2: Running app
- Workspace 3: Database console
- Workspace 4: Documentation/browser

### 2. Memory-Conscious Development

```bash
# Check before starting heavy tasks
memp

# If memory is low:
dstop           # Stop databases
pkill chromium  # Close browser if open
```

### 3. Efficient Git Workflow

```bash
# Quick status and add
gs              # git status
ga .            # git add all
gc -m "message" # commit
gp              # push

# View history
gl              # Pretty graph of last 10 commits
```

### 4. Project Organization

Keep projects organized:
```bash
~/projects/
  ├── frontend-app/
  ├── backend-api/
  ├── mobile-app/
  └── experiments/
```

### 5. Clipboard Sharing (UTM only)

Copy/paste between host Mac and VM:
- **Mac → VM**: Cmd+C on Mac, Ctrl+Shift+V in terminal
- **VM → Mac**: Ctrl+Shift+C in terminal, Cmd+V on Mac

### 6. Shared Folder (UTM only)

Access files from your Mac:
```bash
ls /mnt/shared
```

## 🐛 Troubleshooting

### Sway won't start

```bash
# Check configuration
sway -C ~/.config/sway/config

# View errors
journalctl -xe | grep sway
```

### Docker requires sudo

```bash
# Check if you're in docker group
groups

# If not, re-login or:
newgrp docker
```

### Out of memory

```bash
# Check pressure
memp

# Free up memory
dstop
pkill -f "node|code"

# Check what's using memory
mem
```

### Clipboard not working (UTM)

```bash
sudo systemctl restart spice-vdagentd.service
```

## 📚 Learn More

- **Sway Documentation**: https://swaywm.org/
- **Arch Wiki**: https://wiki.archlinux.org/
- **Docker Compose**: https://docs.docker.com/compose/

## 🎉 Happy Coding!

Remember:
- Type `help` anytime to see available commands
- All your tools are ready to use
- The environment is optimized for 4GB RAM
- Enjoy your lean, fast development setup!

---

**Questions or issues?**
Check the logs: `/var/log/arch-arm-setup.log`
EOF
    
    # Set ownership
    chown "$username:$username" "$user_home/QUICKSTART.md"
    
    # Create a projects directory
    mkdir -p "$user_home/projects"
    chown "$username:$username" "$user_home/projects"
    
    # Ensure all permissions are correct
    chown -R "$username:$username" "$user_home"
    
    echo "[Phase 12] Installation finalized successfully"
    echo ""
    echo "✓ QUICKSTART.md created at $user_home/QUICKSTART.md"
    echo "✓ Projects directory created at $user_home/projects"
    echo "✓ All configurations applied"
}
