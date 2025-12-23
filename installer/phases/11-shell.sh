#!/bin/bash
#
# Phase 11: Shell Configuration with Amazing DX
# Creates shared config for both Bash and Zsh
#

phase_shell_config() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 11] Configuring shell environment..."
    
    # Create shared shell configuration (used by both bash and zsh)
    cat > "$user_home/.shell_common" <<'EOF'
# ════════════════════════════════════════════════════════════
# Shared Shell Configuration (Bash + Zsh)
# Arch ARM Dev Setup
# ════════════════════════════════════════════════════════════

# PATH
export PATH="$HOME/bin:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Editor
export EDITOR=nvim
export VISUAL=nvim

# ════════════════════════════════════════════════════════════
# Development Aliases
# ════════════════════════════════════════════════════════════

# Memory management
alias mem='check-mem'
alias memp='mem-pressure'

# Docker workflow
alias dstart='docker-start'
alias dstop='docker-stop'
alias dmem='docker-mem'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker-compose logs -f'

# Development workflows
alias wf='work-frontend'
alias wfs='work-fullstack'
alias wc='work-compile'

# Editor shortcuts (VimZap adds v, vi, vim)
alias nv='nvim'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -10'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Directory shortcuts
alias projects='cd ~/projects'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System shortcuts
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "Nothing to clean"'
alias installed='pacman -Qe'
alias orphans='pacman -Qdt'

# Better ls (colorized)
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias lt='ls -lth'

# Better grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias h='history'
alias c='clear'
alias q='exit'

# Media shortcuts
alias yt='yt-dlp'
alias ytv='yt-dlp -f "bestvideo[height<=720]+bestaudio/best[height<=720]"'  # 720p max (memory-friendly)
alias yta='yt-dlp -x --audio-format mp3'  # Audio only

# Browser
alias web='firefox'

# ════════════════════════════════════════════════════════════
# Helper Functions
# ════════════════════════════════════════════════════════════

# Quick project creator
mkproject() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: mkproject <project-name>"
        return 1
    fi
    
    mkdir -p ~/projects/"$name"
    cd ~/projects/"$name"
    echo "# $name" > README.md
    git init
    echo "✓ Created project: ~/projects/$name"
}

# Quick tmux session
dev() {
    local session_name="${1:-dev}"
    
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
    else
        tmux new-session -s "$session_name"
    fi
}

# Show system info
sysinfo() {
    echo "════════════════════════════════════════════════════════"
    echo "System Information"
    echo "════════════════════════════════════════════════════════"
    echo "Hostname:     $(hostname)"
    echo "Kernel:       $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime:       $(uptime -p)"
    echo "Shell:        $SHELL"
    echo ""
    echo "Memory:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h / | tail -1
    echo "════════════════════════════════════════════════════════"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$@"
}

# Quick backup
backup() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup-$(date +%Y%m%d-%H%M%S)"
        echo "✓ Backed up: ${file}.backup-$(date +%Y%m%d-%H%M%S)"
    else
        echo "File not found: $file"
    fi
}

# Watch YouTube in mpv (memory-friendly)
ytplay() {
    if [ -z "$1" ]; then
        echo "Usage: ytplay <youtube-url>"
        echo "Example: ytplay https://youtube.com/watch?v=..."
        return 1
    fi
    
    # Play at 720p max (saves RAM)
    mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best[height<=720]" "$1"
}

# Search and play YouTube (requires yt-dlp)
ytsearch() {
    if [ -z "$1" ]; then
        echo "Usage: ytsearch <search terms>"
        echo "Example: ytsearch linux tutorial"
        return 1
    fi
    
    echo "Searching YouTube for: $*"
    local url=$(yt-dlp --get-id "ytsearch1:$*" 2>/dev/null)
    
    if [ -n "$url" ]; then
        echo "Playing: https://youtube.com/watch?v=$url"
        ytplay "https://youtube.com/watch?v=$url"
    else
        echo "No results found"
    fi
}

EOF
    
    # Update .bashrc (keep existing, add sourcing of shared config)
    if [ -f "$user_home/.bashrc" ]; then
        cp "$user_home/.bashrc" "$user_home/.bashrc.backup"
    fi
    
    cat >> "$user_home/.bashrc" <<'EOF'

# ════════════════════════════════════════════════════════════
# Arch ARM Dev Setup - Bash Configuration
# ════════════════════════════════════════════════════════════

# Load shared shell config (common with zsh)
[ -f ~/.shell_common ] && source ~/.shell_common

# Bash-specific settings
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Better tab completion
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null

# Check window size after each command
shopt -s checkwinsize 2>/dev/null

# Bash prompt (if not using Starship)
# Note: Starship works in bash too! To use it, add: eval "$(starship init bash)"
# For now, keep simple bash prompt:

# Function to get git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Function to get memory available
get_mem_available() {
    free -h | awk '/^Mem:/ {print $7}'
}

# Colorful prompt with git and memory info
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(parse_git_branch)\[\033[00m\] \[\033[01;36m\][$(get_mem_available)]\[\033[00m\]\$ '

EOF
    
    # .zshrc already exists from Phase 6 and sources .shell_common
    # Just ensure the file has proper ownership
    
    # Set ownership
    chown "$username:$username" "$user_home/.shell_common"
    chown "$username:$username" "$user_home/.bashrc"
    [ -f "$user_home/.bashrc.backup" ] && chown "$username:$username" "$user_home/.bashrc.backup"
    
    # Create enhanced help command
    mkdir -p "$user_home/bin"
    
    cat > "$user_home/bin/help" <<'EOF'
#!/bin/bash
#
# Help command - Show all available commands and keybindings
#

cat << 'HELP'
╔═══════════════════════════════════════════════════════════╗
║         🚀 Arch ARM Dev Environment - Quick Reference      ║
╚═══════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ Neovim (VimZap) - 12ms startup, LazyVim DX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
v, vi, vim       Open Neovim with VimZap config

In Neovim, press Space for command menu:
  Space + e      File explorer (toggle)
  Space + ff     Find files
  Space + fg     Grep in files
  Space + fb     Find buffers
  Space + fr     Recent files
  
  Space + ca     Code action
  Space + cr     Rename symbol
  Space + cf     Format code
  
  Space + gg     LazyGit
  Space + gf     Git files
  Space + gs     Git status
  
  Space + ?      Show all keymaps

LSP Navigation:
  gd             Go to definition
  gr             Go to references
  K              Hover docs
  [d / ]d        Prev/next diagnostic

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Development Workflows
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wf              Start frontend dev (Postgres + Redis)
wfs             Start fullstack dev (all databases)
wc              Prepare for compilation (free memory)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐳 Docker Commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dstart [profile] Start Docker containers (frontend/fullstack)
dstop            Stop all Docker containers
dmem             Show Docker memory usage
dps              Show running containers
dlogs            Follow container logs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💾 Memory Management
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mem              Check memory usage and top consumers
memp             Check memory pressure and get suggestions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎬 Media & Browser
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ytplay <url>     Watch YouTube video in mpv (720p max)
ytsearch <term>  Search and play YouTube video
web              Open Firefox browser
yt <url>         Download YouTube video
yta <url>        Download YouTube audio only

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⌨️  Shell & Tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dev [name]       Start/attach tmux session
mkproject <name> Create new project in ~/projects/
mkcd <dir>       Create directory and cd into it
extract <file>   Extract any archive type
backup <file>    Create timestamped backup
sysinfo          Show system information

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 System Commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
update           Update all packages (pacman -Syu)
cleanup          Remove unused packages
installed        List explicitly installed packages
orphans          List orphaned packages

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎹 Sway Keybindings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super+Enter          Open new terminal
Super+w              Open Firefox browser
Super+n              Open Neovim
Super+d              Application launcher (wofi)
Super+Tab            Switch between windows (like Alt+Tab)
Super+1/2/3/4        Switch to workspace 1/2/3/4
Super+Shift+1/2/3/4  Move window to workspace
Super+f              Toggle fullscreen
Super+r              Resize mode (arrows to resize, Esc to exit)
Super+Space          Toggle floating mode
Super+Arrows         Move focus between windows
Super+Shift+Q        Close window
Super+Shift+C        Reload Sway config
Super+Shift+E        Exit Sway (type 'sway' to restart)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Git Shortcuts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gs               git status
ga <files>       git add
gc -m "msg"      git commit
gp               git push
gl               git log (last 10, graph)
gd               git diff
gco <branch>     git checkout
gb               git branch

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 Documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
~/QUICKSTART.md      Detailed quick reference
help                 This help message

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Shell: Zsh with Starship prompt (git-aware, beautiful, fast)
Editor: Neovim with VimZap config (LazyVim DX, 12ms startup)

For more help: cat ~/QUICKSTART.md | less

HELP
EOF
    
    chmod +x "$user_home/bin/help"
    chown -R "$username:$username" "$user_home/bin"
    
    echo "[Phase 11] Shell configuration complete"
    echo "  ✓ Shared config (.shell_common) for Bash + Zsh"
    echo "  ✓ Enhanced aliases and functions"
    echo "  ✓ Help command with comprehensive reference"
}
