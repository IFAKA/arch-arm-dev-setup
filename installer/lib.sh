#!/bin/bash
#
# Shared Library Functions
# Used by both bootstrap (install.sh) and main installer
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Wrapper for pacman that handles Landlock/sandbox errors automatically
# This is needed because pacman 7.1.0+ requires kernel 5.13+ for Landlock LSM
# but we may be running on older kernel (pre-reboot after upgrade)
safe_pacman() {
    local output_file="/tmp/pacman-safe-$$.log"
    local exit_code=0
    
    # Try normal pacman first
    "$@" 2>&1 | tee "$output_file"
    exit_code=${PIPESTATUS[0]}
    
    # If successful, clean up and return
    if [ $exit_code -eq 0 ]; then
        rm -f "$output_file"
        return 0
    fi
    
    # Check if it was a Landlock/sandbox error
    if grep -qi "landlock.*not supported\|sandbox.*failed" "$output_file" 2>/dev/null; then
        log_warning "Pacman sandbox not supported on this kernel, retrying with --disable-sandbox"
        
        # Build new command with --disable-sandbox flag
        local cmd_array=("$@")
        local new_cmd=()
        local found_pacman=false
        
        for arg in "${cmd_array[@]}"; do
            new_cmd+=("$arg")
            # Add --disable-sandbox right after pacman command
            if [[ "$arg" == *"pacman"* ]] && [ "$found_pacman" = false ]; then
                new_cmd+=("--disable-sandbox")
                found_pacman=true
            fi
        done
        
        # Try with --disable-sandbox
        if "${new_cmd[@]}" 2>&1; then
            rm -f "$output_file"
            return 0
        fi
    fi
    
    # Command failed for other reasons - preserve exit code
    rm -f "$output_file"
    return $exit_code
}

# Export functions so they're available in subshells
export -f log_info
export -f log_success
export -f log_error
export -f log_warning
export -f safe_pacman
