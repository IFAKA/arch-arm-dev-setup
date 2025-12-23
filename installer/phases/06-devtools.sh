#!/bin/bash
#
# Phase 6: Development Tools + Zsh + VimZap
# Installs modern shell (Zsh + Starship) and VimZap Neovim config
#

phase_dev_tools() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 6] Installing development tools, Zsh, and VimZap..."
    
    # Core development tools + Zsh + Starship
    echo "Installing packages..."
    pacman -S --noconfirm \
        curl \
        wget \
        unzip \
        zip \
        ripgrep \
        fd \
        fzf \
        jq \
        htop \
        btop \
        tmux \
        neovim \
        zsh \
        starship \
        git
    
    echo "Changing default shell to Zsh..."
    chsh -s /bin/zsh "$username"
    
    # Install Zsh plugins
    echo "Installing Zsh plugins..."
    mkdir -p "$user_home/.config/zsh/plugins"
    
    # zsh-autosuggestions
    if [ ! -d "$user_home/.config/zsh/plugins/zsh-autosuggestions" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
            "$user_home/.config/zsh/plugins/zsh-autosuggestions" 2>&1 | grep -v "Cloning into"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$user_home/.config/zsh/plugins/zsh-syntax-highlighting" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$user_home/.config/zsh/plugins/zsh-syntax-highlighting" 2>&1 | grep -v "Cloning into"
    fi
    
    # Create .zshrc (backup existing if present)
    echo "Creating .zshrc..."
    
    # Backup existing .zshrc if it exists
    if [ -f "$user_home/.zshrc" ]; then
        echo "  Backing up existing .zshrc to .zshrc.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$user_home/.zshrc" "$user_home/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create new .zshrc
    cat > "$user_home/.zshrc" <<'EOF'
# ════════════════════════════════════════════════════════════
# Zsh Configuration - Arch ARM Dev Setup
# ════════════════════════════════════════════════════════════

# Load common shell config (shared with bash)
[ -f ~/.shell_common ] && source ~/.shell_common

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Completion
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

# Better completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''

# Case-insensitive completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Plugins
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship prompt (fast, beautiful, git-aware)
eval "$(starship init zsh)"

# VimZap aliases (will be added by VimZap installer below)
EOF
    
    # Create cache directory for zsh
    mkdir -p "$user_home/.cache/zsh"
    
    # Configure Starship
    echo "Configuring Starship prompt..."
    mkdir -p "$user_home/.config"
    cat > "$user_home/.config/starship.toml" <<'EOF'
# Starship Configuration - Minimal & Fast

format = """
[┌─](bold green)$directory$git_branch$git_status$nodejs$rust$golang$python
[└─](bold green)$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold cyan"

[git_branch]
format = "[$symbol$branch]($style) "
symbol = " "
style = "bold purple"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold red"
conflicted = "🏳"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?"
stashed = "$"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[nodejs]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold green"

[rust]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold red"

[golang]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold cyan"

[python]
format = "[${symbol}${pyenv_prefix}(${version} )]($style)"
symbol = " "
style = "bold yellow"

[memory_usage]
disabled = false
threshold = 75
format = "[MEM: $ram( | $swap)]($style) "
style = "bold dimmed yellow"

[time]
disabled = false
format = '[\[$time\]]($style) '
style = "bold yellow"
time_format = "%T"
EOF
    
    # Install VimZap
    echo "Installing VimZap Neovim config..."
    
    # VimZap installer detects shell and adds aliases to .zshrc
    # It checks for existing marker and won't duplicate
    # Running as the user ensures proper detection
    su - "$username" -c 'curl -fsSL https://ifaka.github.io/vimzap/i | bash' 2>&1 | grep -E "(VimZap|Done|alias)" || true
    
    # Pre-download VimZap plugins so first nvim launch is instant
    echo "Pre-downloading Neovim plugins (this makes first launch instant)..."
    su - "$username" -c 'timeout 120 nvim --headless "+Lazy! sync" +qa' 2>&1 | grep -v "^$" || true
    
    # Note: VimZap adds its aliases to .zshrc with markers
    # Format: # VimZap aliases ... # VimZap aliases end
    # Safe to re-run - won't duplicate if markers exist
    
    # Configure tmux
    echo "Configuring tmux..."
    cat > "$user_home/.tmux.conf" <<'EOF'
# Tmux Configuration - Optimized for Development

# Better prefix (Ctrl+A instead of Ctrl+B)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Settings
set -g default-terminal "screen-256color"
set -g history-limit 5000
set -g base-index 1
setw -g pane-base-index 1

# Mouse support
set -g mouse on

# Status bar
set -g status-style bg=black,fg=white
set -g status-left '[#S] '
set -g status-left-length 20
set -g status-right 'MEM: #(free -h | awk "/^Mem:/ {print \$3}") | %H:%M '
set -g status-right-length 50

# Pane border colors
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour51

# Easy reload
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Better splits (more intuitive)
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Vim-like pane switching
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes with prefix + arrow keys
bind -r Left resize-pane -L 5
bind -r Down resize-pane -D 5
bind -r Up resize-pane -U 5
bind -r Right resize-pane -R 5

# Copy mode with vi keys
setw -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Clear screen (Ctrl+L in shell)
bind C-l send-keys 'C-l'
EOF
    
    # Set ownership
    chown -R "$username:$username" "$user_home/.config"
    chown -R "$username:$username" "$user_home/.cache"
    chown "$username:$username" "$user_home/.zshrc"
    chown "$username:$username" "$user_home/.tmux.conf"
    
    echo "[Phase 6] Development tools, Zsh, and VimZap installed successfully"
    echo "  ✓ Zsh with Starship prompt"
    echo "  ✓ Zsh plugins (autosuggestions + syntax highlighting)"
    echo "  ✓ VimZap Neovim config (12ms startup, LazyVim DX)"
    echo "  ✓ Tmux with vim keybindings"
    echo "  ✓ Modern CLI tools (ripgrep, fd, fzf, jq, btop)"
}
