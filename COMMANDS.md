# 📋 Command Reference

Quick reference for all commands available after installation.

---

## 🚀 Initial Setup Commands

### One-Line Installer (After creating user)

```bash
git clone https://github.com/IFAKA/arch-arm-dev-setup.git && cd arch-arm-dev-setup && ./arch-arm-post-install.sh
```

---

## 💾 Memory Management

### Check Memory Status

```bash
mem                    # Full memory status with top consumers
check-mem              # Same as 'mem' (full command)
free -h                # System memory only
memp                   # Memory pressure detection & warnings
mem-pressure           # Same as 'memp' (full command)
```

### Memory Tools

```bash
htop                   # Interactive process viewer
btop                   # Modern resource monitor (recommended)
zramctl                # Check zram status
```

---

## 🐳 Docker Management

### Start/Stop Containers

```bash
dstart frontend        # Start PostgreSQL + Redis (~110MB)
dstart backend         # Start PostgreSQL + Redis + MongoDB (~210MB)
dstart fullstack       # Start all database containers (~300MB)
dstart db-only         # Same as 'frontend'
dstop                  # Stop all containers
```

### Monitor Docker

```bash
docker ps              # List running containers
docker ps -a           # List all containers (including stopped)
dmem                   # Container memory usage
docker-mem             # Same as 'dmem' (full command)
docker stats           # Live container stats
docker logs <name>     # View container logs
```

### Docker Compose

```bash
docker-compose up -d                    # Start all services
docker-compose up -d postgres redis     # Start specific services
docker-compose down                     # Stop and remove containers
docker-compose logs -f                  # Follow logs
docker-compose restart <service>        # Restart service
```

---

## 🎨 Sway Window Manager

### Launch

```bash
sway                   # Start Sway from TTY
```

### Keybindings

```bash
Super+Enter            # Open terminal
Super+d                # Application launcher (wofi)
Super+Shift+Q          # Close current window
Super+Shift+C          # Reload Sway configuration
Super+Shift+E          # Exit Sway

# Workspaces
Super+1                # Switch to workspace 1
Super+2                # Switch to workspace 2
Super+Shift+1          # Move window to workspace 1
Super+Shift+2          # Move window to workspace 2
```

### Sway Commands (from terminal)

```bash
swaymsg 'workspace 1'                    # Switch workspace
swaymsg 'output * resolution 1920x1080'  # Change resolution
swaymsg -t get_outputs                   # List outputs
swaymsg -t get_workspaces                # List workspaces
swaymsg reload                           # Reload config
```

---

## 🛠️ Development Workflows

### Start Workflows

```bash
wf                     # Frontend workflow (DBs + workspace 1)
work-frontend          # Same as 'wf' (full command)

wfs                    # Fullstack workflow (all DBs + workspace 1)
work-fullstack         # Same as 'wfs' (full command)

wc                     # Prepare for compilation (closes browser, checks memory)
work-compile           # Same as 'wc' (full command)
```

---

## 📝 Editor & Terminal

### Neovim

```bash
nvim <file>            # Open file in Neovim
nv <file>              # Alias for nvim
nvim .                 # Open current directory
nvim +PlugInstall      # Install plugins (if using vim-plug)
```

### tmux

```bash
tmux                   # Start new session
tmux new -s <name>     # Start named session
tmux ls                # List sessions
tmux attach            # Attach to last session
tmux attach -t <name>  # Attach to named session
tmux kill-session -t <name>  # Kill session

# Inside tmux (prefix: Ctrl+a)
Ctrl+a c               # Create new window
Ctrl+a n               # Next window
Ctrl+a p               # Previous window
Ctrl+a d               # Detach from session
Ctrl+a ,               # Rename window
```

---

## 🔍 Search & Find

### File Search

```bash
fd <pattern>           # Find files by name
fd -e js               # Find by extension (.js)
fd -t f <pattern>      # Files only
fd -t d <pattern>      # Directories only
fd . /path             # Search in specific path
```

### Content Search

```bash
rg <pattern>           # Search content in files
rg -i <pattern>        # Case-insensitive search
rg -l <pattern>        # List files with matches
rg -t js <pattern>     # Search in JS files only
rg --files-with-matches <pattern>  # Same as -l
```

### Fuzzy Finder

```bash
fzf                    # Interactive fuzzy finder
nvim $(fzf)            # Open file with fuzzy search
cd $(fd -t d | fzf)    # cd to directory with fuzzy search
```

---

## 🌐 Language-Specific Commands

### Node.js / npm

```bash
node --version         # Check Node version
npm --version          # Check npm version
pnpm --version         # Check pnpm version

# nvm (Node Version Manager)
nvm ls                 # List installed versions
nvm install --lts      # Install latest LTS
nvm use <version>      # Switch version
nvm current            # Show current version

# Package management
npm install            # Install dependencies
npm run dev            # Run dev script
pnpm install           # Install with pnpm
pnpm run build         # Build with pnpm
```

### Go

```bash
go version             # Check Go version
go mod init <name>     # Initialize module
go mod tidy            # Clean dependencies
go run .               # Run current package
go build               # Build binary
go test                # Run tests
go get <package>       # Get package
```

### Rust

```bash
rustc --version        # Check Rust version
cargo --version        # Check Cargo version

# Project management
cargo new <name>       # Create new project
cargo init             # Initialize in current dir
cargo build            # Build (debug)
cargo build --release  # Build (optimized)
cargo run              # Run project
cargo test             # Run tests
cargo check            # Quick compilation check
cargo clean            # Clean build artifacts

# Update Rust
rustup update          # Update Rust toolchain
```

### Python

```bash
python --version       # Check Python version
pip --version          # Check pip version

# Virtual environments
python -m venv venv    # Create venv
source venv/bin/activate  # Activate venv
deactivate             # Deactivate venv

# Package management
pip install <package>  # Install package
pip install -r requirements.txt  # Install from file
pip freeze > requirements.txt    # Export packages
```

---

## 🗄️ Database Clients

### PostgreSQL

```bash
# Connect to local dev database
psql -U devuser -d devdb -h localhost

# Common psql commands (inside psql)
\l                     # List databases
\c <database>          # Connect to database
\dt                    # List tables
\d <table>             # Describe table
\q                     # Quit
```

### Redis

```bash
# Connect to local Redis
redis-cli

# Common redis commands
PING                   # Test connection
KEYS *                 # List all keys
GET <key>              # Get value
SET <key> <value>      # Set value
DEL <key>              # Delete key
FLUSHALL               # Delete all keys
```

### MongoDB

```bash
# Connect to local MongoDB
mongosh --username devuser --password devpassword

# Common mongosh commands
show dbs               # List databases
use <database>         # Switch database
show collections       # List collections
db.<collection>.find() # Query collection
exit                   # Quit
```

---

## 🔄 Git Shortcuts

```bash
gs                     # git status
ga <file>              # git add
ga .                   # git add all
gc -m "message"        # git commit
gp                     # git push

# Full git commands
git status             # Show working tree status
git add <file>         # Stage file
git commit -m "msg"    # Commit with message
git push               # Push to remote
git pull               # Pull from remote
git log --oneline      # Compact log
git diff               # Show changes
```

---

## 🌐 Network & System

### Network

```bash
ip a                   # Show IP addresses
ping <host>            # Ping host
curl <url>             # Fetch URL
wget <url>             # Download file
```

### System Info

```bash
uname -a               # System info
hostnamectl            # Hostname and OS info
timedatectl            # Time and date info
df -h                  # Disk usage
du -sh <dir>           # Directory size
uptime                 # System uptime
```

### Processes

```bash
ps aux                 # List all processes
pgrep <name>           # Find process by name
pkill <name>           # Kill process by name
killall <name>         # Kill all matching processes
top                    # Process monitor (basic)
htop                   # Process monitor (better)
btop                   # Process monitor (best)
```

---

## 📦 Package Management

### pacman (System Packages)

```bash
sudo pacman -S <pkg>   # Install package
sudo pacman -R <pkg>   # Remove package
sudo pacman -Syu       # Update system
sudo pacman -Ss <pkg>  # Search packages
sudo pacman -Qi <pkg>  # Package info (installed)
sudo pacman -Qe        # List explicitly installed
```

### yay (AUR Helper)

```bash
yay <pkg>              # Search and install from AUR
yay -S <pkg>           # Install package
yay -Syu               # Update system + AUR
yay -Ss <pkg>          # Search AUR
yay -R <pkg>           # Remove package
```

---

## 🔧 UTM-Specific (Virtual Machine)

### Shared Folder

```bash
ls /mnt/shared         # Access shared folder
cd /mnt/shared         # Change to shared folder
sudo mount -a          # Mount all filesystems (including shared)
df -h | grep shared    # Check if shared folder is mounted

# Create symlink to home
ln -s /mnt/shared ~/shared
cd ~/shared
```

### Services

```bash
# Clipboard sharing
sudo systemctl status spice-vdagentd
sudo systemctl restart spice-vdagentd

# QEMU guest agent
sudo systemctl status qemu-guest-agent
sudo systemctl restart qemu-guest-agent
```

---

## 🔐 System Management

### Services

```bash
sudo systemctl start <service>    # Start service
sudo systemctl stop <service>     # Stop service
sudo systemctl restart <service>  # Restart service
sudo systemctl enable <service>   # Enable on boot
sudo systemctl disable <service>  # Disable on boot
sudo systemctl status <service>   # Service status
journalctl -u <service> -f        # Follow service logs
```

### Common Services

```bash
docker.service         # Docker daemon
spice-vdagentd         # Clipboard (UTM)
qemu-guest-agent       # QEMU agent (UTM)
systemd-zram-setup@zram0  # zram swap
```

---

## 📊 Monitoring Commands

### Quick Checks

```bash
mem                    # Memory overview
memp                   # Memory pressure check
dmem                   # Docker container memory
htop                   # Interactive process monitor
btop                   # Better process monitor
free -h                # Memory usage
df -h                  # Disk usage
uptime                 # Load average
```

### Detailed Monitoring

```bash
# CPU
mpstat 1               # CPU stats every 1 second
top                    # Basic top

# Memory
vmstat 1               # Virtual memory stats
cat /proc/meminfo      # Detailed memory info

# Disk I/O
iostat 1               # I/O stats

# Network
iftop                  # Network bandwidth (if installed)
nethogs                # Network usage by process (if installed)
```

---

## 🆘 Troubleshooting Commands

### Check Logs

```bash
journalctl -xe         # Recent system logs
journalctl -f          # Follow system logs
journalctl -u docker -f  # Follow Docker logs
dmesg                  # Kernel messages
dmesg | tail -50       # Last 50 kernel messages
```

### Service Issues

```bash
systemctl --failed     # List failed services
systemctl status <service>  # Check service status
journalctl -u <service> -n 50  # Last 50 log lines
```

### Network Issues

```bash
ping -c 4 8.8.8.8      # Test connectivity
ping -c 4 google.com   # Test DNS
ip route               # Show routing table
resolvectl status      # DNS status
```

---

## 💡 Pro Tips

### Command Combinations

```bash
# Find and edit file
nvim $(fd <pattern> | fzf)

# Search content and open in editor
rg -l <pattern> | fzf | xargs nvim

# Find large files
du -ah / | sort -rh | head -20

# Monitor specific process
watch -n 1 'ps aux | grep <name>'

# Quick backup
tar -czf backup-$(date +%Y%m%d).tar.gz <directory>

# Clean Docker
docker system prune -a  # Remove all unused containers/images
```

### Aliases for Even More Speed

Add to `~/.bashrc`:

```bash
alias p='sudo pacman'
alias y='yay'
alias d='docker'
alias dc='docker-compose'
alias k='kubectl'  # If you install k8s tools
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
```

---

## 📚 Help Commands

```bash
<command> --help       # Most commands have --help
man <command>          # Manual page
tldr <command>         # Simplified examples (if installed)

# Specific help
docker --help
cargo --help
npm help <command>
```

---

**Print this page or bookmark it for quick reference!** 📖
