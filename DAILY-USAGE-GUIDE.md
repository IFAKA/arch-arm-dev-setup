# 🚀 Daily Usage Guide - Arch ARM Dev Setup

**Your complete guide to using the system every day**

---

## ✅ **YES! NOW WE'RE 100% DONE!**

All essential features are now included:
- ✅ Firefox browser
- ✅ mpv video player
- ✅ YouTube support (watch and download)
- ✅ Window switching (Super+Tab)
- ✅ Proper Sway session management
- ✅ Complete documentation

---

## 🎯 Quick Start Every Day

### **First Login**
1. Login with your username
2. Sway starts automatically ✅
3. Terminal opens with welcome message ✅
4. Start working immediately! ✅

### **After Reboot**
1. Login with your username
2. Sway starts automatically ✅
3. **Everything is exactly as you left it!** ✅

---

## 🪟 Window Management - Your Daily Workflow

### **Opening Applications**

```bash
Super + Enter       # New terminal (most common!)
Super + w           # Firefox browser
Super + n           # Neovim in terminal
Super + d           # Application launcher (for other apps)
```

### **Switching Between Windows**

```bash
Super + Tab         # Next window (like Alt+Tab on Windows/Mac)
Super + Shift + Tab # Previous window
Super + Arrows      # Move focus with arrow keys
```

**💡 Tip**: `Super+Tab` is your best friend - use it to quickly jump between terminal, browser, and editor!

### **Workspaces (Virtual Desktops)**

Think of workspaces like different screens for different tasks:

```bash
Super + 1           # Workspace 1 (e.g., coding)
Super + 2           # Workspace 2 (e.g., browser/docs)
Super + 3           # Workspace 3 (e.g., database/docker)
Super + 4           # Workspace 4 (e.g., testing)
```

**Move windows between workspaces**:
```bash
Super + Shift + 1   # Send current window to workspace 1
Super + Shift + 2   # Send current window to workspace 2
# etc.
```

**Example workflow**:
1. Open terminal (`Super+Enter`) - stays in workspace 1
2. Open Firefox (`Super+w`) - stays in workspace 1
3. Send Firefox to workspace 2 (`Super+Shift+2`)
4. Switch to workspace 2 to browse (`Super+2`)
5. Switch back to coding (`Super+1`)

### **Window Actions**

```bash
Super + f           # Fullscreen current window
Super + r           # Resize mode
                    #   - Use arrow keys to resize
                    #   - Press Esc or Enter when done

Super + Space       # Toggle floating (window floats on top)
Super + Shift + Q   # Close current window
```

---

## 🌐 Using the Browser

### **Open Firefox**

```bash
Super + w           # Instant Firefox!
# Or from terminal:
firefox &           # Open Firefox in background
web                 # Alias for firefox
```

### **Browser Tips**
- Firefox is pre-installed and ready
- Supports all standard web features
- Can watch YouTube directly in browser
- Or use `ytplay` for mpv (uses less memory!)

---

## 🎬 Watching YouTube

### **Method 1: In mpv (Recommended - Uses Less Memory)**

```bash
# Watch a video directly
ytplay https://youtube.com/watch?v=VIDEO_ID

# Search and watch
ytsearch linux tutorial
ytsearch neovim tips
```

**Why mpv?**
- ✅ Uses ~200MB less RAM than browser
- ✅ Better for 4GB systems
- ✅ Keyboard controls (space=pause, arrows=seek)
- ✅ Automatically limited to 720p

**mpv Keyboard Controls**:
```
Space          # Pause/play
Left/Right     # Seek backward/forward 5 seconds
Up/Down        # Volume up/down
f              # Fullscreen
q              # Quit
```

### **Method 2: In Firefox Browser**

```bash
Super + w          # Open Firefox
# Navigate to youtube.com
# Watch normally
```

### **Download Videos**

```bash
# Download video
yt https://youtube.com/watch?v=VIDEO_ID

# Download audio only (music)
yta https://youtube.com/watch?v=VIDEO_ID

# Download at specific quality (720p max recommended)
ytv https://youtube.com/watch?v=VIDEO_ID
```

---

## 🔄 Sway Session Management

### **What happens if I close Sway?**

```bash
Super + Shift + E   # Exit Sway
```

**Result**:
- Sway closes
- You drop back to TTY (text console)
- You see your terminal prompt

**To restart**:
```bash
sway               # Just type 'sway' and press Enter
```

**Everything restores**:
- ✅ Your workspace layout
- ✅ Open windows (if apps support it)
- ✅ Keybindings
- ✅ All configs

### **What happens on reboot?**

```bash
sudo reboot
```

**After reboot**:
1. Login screen appears
2. Enter your username and password
3. **Sway starts automatically!** ✅
4. Terminal opens with your shell
5. Continue working!

**Do I need to setup anything?** NO! ✅
- Sway auto-starts (via .zprofile)
- All configs are preserved
- All aliases and functions ready
- Just login and go!

---

## 💻 Coding Workflow

### **Typical Day**

```bash
# 1. Login (Sway auto-starts)
# 2. Terminal opens automatically

# 3. Navigate to project
cd ~/projects/my-app

# 4. Open editor
v .                 # Open current directory in Neovim

# 5. Start dev server in another terminal
Super + Enter       # New terminal
npm run dev         # Or your dev command

# 6. Switch between editor and terminal
Super + Tab         # Quick window switch!

# 7. Need docs? Open browser
Super + w           # Firefox opens
# Navigate to docs

# 8. Switch back to code
Super + 1           # Back to workspace 1 (code)
```

### **Using Multiple Terminals**

```bash
Super + Enter       # Terminal 1 (editor)
Super + Enter       # Terminal 2 (dev server)
Super + Enter       # Terminal 3 (git/commands)

# Switch between them
Super + Tab         # Cycle through all windows
Super + Arrows      # Move focus precisely
```

### **Using Workspaces for Different Projects**

```bash
# Workspace 1: Project A
Super + 1
cd ~/projects/project-a
v .

# Workspace 2: Project B
Super + 2
cd ~/projects/project-b
v .

# Workspace 3: Documentation/Browser
Super + 3
Super + w           # Firefox

# Switch between projects
Super + 1           # Back to Project A
Super + 2           # Switch to Project B
```

---

## 🛠️ Development Commands

### **Starting Development**

```bash
# Frontend (Postgres + Redis)
wf

# Fullstack (all databases)
wfs

# Check what's running
dps

# Check memory
mem
```

### **Docker Management**

```bash
dstart frontend     # Start databases
dstop               # Stop all containers
dmem                # Check container memory
dlogs               # Follow logs
```

### **Git Workflow**

```bash
gs                  # git status
ga .                # git add all
gc -m "message"     # git commit
gp                  # git push

# Or use LazyGit (in Neovim)
v .
# Press Space + gg
```

---

## 📊 Memory Management

### **Check Memory**

```bash
mem                 # Quick memory check
memp                # Detailed memory pressure
```

### **Free Memory When Needed**

```bash
# Close browser
pkill firefox

# Stop Docker containers
dstop

# Check what's using RAM
mem
```

### **Memory Tips**
- Browser uses most RAM (~300-500MB)
- Docker containers use 50-100MB each
- Use mpv instead of browser YouTube (saves 200MB)
- Close browser when compiling large projects

---

## ⌨️ Essential Keyboard Shortcuts

### **Sway (Window Manager)**

```
Super + Enter       Open terminal
Super + w           Open Firefox
Super + n           Open Neovim
Super + d           App launcher
Super + Tab         Next window
Super + 1/2/3/4     Switch workspace
Super + f           Fullscreen
Super + r           Resize mode
Super + Shift + Q   Close window
Super + Shift + E   Exit Sway
```

### **Terminal (Foot)**

```
Ctrl + Shift + C    Copy
Ctrl + Shift + V    Paste
Ctrl + Shift + N    New window
Ctrl + D            Close terminal
```

### **Neovim (VimZap)**

```
Space               Command menu
Space + e           File explorer
Space + ff          Find files
Space + fg          Grep in files
Space + gg          LazyGit
```

---

## 🎨 Customization

### **Change Sway Config**

```bash
nvim ~/.config/sway/config
# Make changes
Super + Shift + C   # Reload config
```

### **Change Shell Aliases**

```bash
nvim ~/.shell_common
# Make changes
source ~/.zshrc     # Reload
```

### **Change mpv Settings**

```bash
nvim ~/.config/mpv/mpv.conf
# Change video quality, cache, etc.
```

---

## 🆘 Common Questions

### **Q: How do I restart Sway if it crashes?**
```bash
sway               # Just type 'sway'
```

### **Q: How do I switch between windows quickly?**
```bash
Super + Tab        # Like Alt+Tab on other systems
```

### **Q: Can I have multiple terminals side-by-side?**
Yes! Open multiple terminals (`Super+Enter` multiple times), they'll tile automatically. Use `Super+r` to resize them.

### **Q: What if I forget a keybinding?**
```bash
help               # Shows all commands and keybindings
```

### **Q: How do I watch YouTube without using much memory?**
```bash
ytsearch tutorial name   # Search and play in mpv
# Uses ~300MB less than browser
```

### **Q: Does everything survive a reboot?**
✅ YES! Just login and Sway starts automatically with all your configs.

### **Q: Can I use a mouse?**
✅ YES! All operations work with mouse too. But keyboard is faster!

---

## 📚 Quick Reference Card

**Print this and keep it handy!**

```
═══════════════════════════════════════════════
ESSENTIAL SHORTCUTS
═══════════════════════════════════════════════

OPEN APPS:
  Super+Enter  Terminal
  Super+w      Firefox
  Super+n      Neovim
  Super+d      App Launcher

SWITCH WINDOWS:
  Super+Tab    Next window
  Super+1234   Workspaces

WINDOW ACTIONS:
  Super+f      Fullscreen
  Super+r      Resize
  Super+Shift+Q  Close

CODING:
  v <file>     Open in Neovim
  Space        Neovim menu
  help         Show all commands

MEDIA:
  ytplay <url>   Watch YouTube
  ytsearch <q>   Search YouTube
  web            Firefox

DEVELOPMENT:
  wf           Frontend workflow
  wfs          Fullstack workflow
  mem          Check memory
  dps          Docker status

SYSTEM:
  sway         Start/restart Sway
  help         Show all commands
  q            Exit/quit
═══════════════════════════════════════════════
```

---

## 🎯 Your First Hour Checklist

After installation, try these in order:

- [ ] Login (Sway starts automatically)
- [ ] Press `help` to see all commands
- [ ] Open Firefox: `Super+w`
- [ ] Open new terminal: `Super+Enter`
- [ ] Switch between windows: `Super+Tab`
- [ ] Watch a YouTube video: `ytsearch neovim tutorial`
- [ ] Open Neovim: `v`
- [ ] Try workspaces: `Super+1`, `Super+2`
- [ ] Check memory: `mem`
- [ ] Create a test project: `mkproject test`

---

## 🚀 You're Ready!

**Everything you need to know**:
1. `Super+Tab` to switch windows
2. `Super+w` for browser
3. `Super+Enter` for terminal
4. `help` when you forget
5. `sway` if it crashes
6. Everything auto-restarts on reboot

**Now go build something amazing!** 💪
