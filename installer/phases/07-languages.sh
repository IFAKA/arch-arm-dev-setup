#!/bin/bash
#
# Phase 7: Language Runtimes
#

phase_language_runtimes() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 7] Installing language runtimes..."
    
    # Node.js via nvm (run as user, not root)
    echo "Installing Node.js via nvm..."
    if [ ! -d "$user_home/.nvm" ]; then
        su - "$username" -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
        su - "$username" -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts && nvm use --lts && npm install -g pnpm'
    fi
    
    # Go
    echo "Installing Go..."
    pacman -S --noconfirm go
    
    # Rust (run as user)
    echo "Installing Rust..."
    if [ ! -d "$user_home/.cargo" ]; then
        su - "$username" -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
        
        # Configure Rust for low memory builds
        mkdir -p "$user_home/.cargo"
        cat > "$user_home/.cargo/config.toml" <<'EOF'
[build]
jobs = 2

[profile.dev]
debug = 1

[profile.release]
lto = "thin"
EOF
        chown -R "$username:$username" "$user_home/.cargo"
    fi
    
    # Python
    echo "Installing Python..."
    pacman -S --noconfirm python python-pip python-virtualenv
    
    # C/C++ toolchain
    echo "Installing C/C++ toolchain..."
    pacman -S --noconfirm gcc clang cmake ninja
    
    echo "[Phase 7] Language runtimes installed"
}
