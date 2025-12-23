#!/bin/bash
#
# UI Library - Whiptail wrapper functions for beautiful TUI
#

# Colors for terminal output (when not in TUI)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get terminal dimensions
TERM_HEIGHT=$(tput lines)
TERM_WIDTH=$(tput cols)

# Calculate dialog dimensions (80% of terminal)
DIALOG_HEIGHT=$((TERM_HEIGHT * 80 / 100))
DIALOG_WIDTH=$((TERM_WIDTH * 80 / 100))

# Ensure minimum dimensions
[ "$DIALOG_HEIGHT" -lt 20 ] && DIALOG_HEIGHT=20
[ "$DIALOG_WIDTH" -lt 60 ] && DIALOG_WIDTH=60

# Show welcome screen with continue button
ui_welcome() {
    local title="$1"
    local message="$2"
    
    whiptail --title "$title" --msgbox "$message" "$DIALOG_HEIGHT" "$DIALOG_WIDTH"
}

# Show info message
ui_msgbox() {
    local title="$1"
    local message="$2"
    
    whiptail --title "$title" --msgbox "$message" 20 70
}

# Ask yes/no question
ui_yesno() {
    local title="$1"
    local message="$2"
    
    whiptail --title "$title" --yesno "$message" 15 70
}

# Get text input
ui_input() {
    local title="$1"
    local prompt="$2"
    local default="$3"
    
    whiptail --title "$title" --inputbox "$prompt" 12 70 "$default" 3>&1 1>&2 2>&3
}

# Get password input
ui_password() {
    local title="$1"
    local prompt="$2"
    
    whiptail --title "$title" --passwordbox "$prompt" 12 70 3>&1 1>&2 2>&3
}

# Show menu selection
ui_menu() {
    local title="$1"
    local prompt="$2"
    shift 2
    
    whiptail --title "$title" --menu "$prompt" 20 70 10 "$@" 3>&1 1>&2 2>&3
}

# Show checklist (multiple selection)
ui_checklist() {
    local title="$1"
    local prompt="$2"
    shift 2
    
    whiptail --title "$title" --checklist "$prompt" 20 70 10 "$@" 3>&1 1>&2 2>&3
}

# Show radio list (single selection)
ui_radiolist() {
    local title="$1"
    local prompt="$2"
    shift 2
    
    whiptail --title "$title" --radiolist "$prompt" 20 70 10 "$@" 3>&1 1>&2 2>&3
}

# Show progress gauge
# Usage: { commands with echo "percent"; } | ui_progress "Title" "Initial message"
ui_progress() {
    local title="$1"
    local initial_message="$2"
    
    whiptail --title "$title" --gauge "$initial_message" 10 70 0
}

# Show info box (non-blocking, auto-closes)
ui_infobox() {
    local title="$1"
    local message="$2"
    
    whiptail --title "$title" --infobox "$message" 10 70
}

# Terminal logging functions (for phases that run outside TUI)
log_phase() {
    echo -e "${BLUE}[PHASE]${NC} $1"
}

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

# Progress tracking for gauge
# Usage: start with current=0, increment as you go
declare -g UI_PROGRESS_CURRENT=0
declare -g UI_PROGRESS_TOTAL=100

ui_progress_init() {
    UI_PROGRESS_CURRENT=0
    UI_PROGRESS_TOTAL="${1:-100}"
}

ui_progress_step() {
    local message="$1"
    local increment="${2:-10}"
    
    UI_PROGRESS_CURRENT=$((UI_PROGRESS_CURRENT + increment))
    
    # Ensure we don't exceed 100%
    [ "$UI_PROGRESS_CURRENT" -gt 100 ] && UI_PROGRESS_CURRENT=100
    
    echo "$UI_PROGRESS_CURRENT"
    echo "XXX"
    echo "$message"
    echo "XXX"
}

# Show final completion screen with countdown
ui_complete_with_countdown() {
    local title="$1"
    local message="$2"
    local countdown="${3:-10}"
    
    for ((i=countdown; i>0; i--)); do
        local msg="$message\n\nRebooting in $i seconds...\n\nPress Ctrl+C to cancel"
        whiptail --title "$title" --msgbox "$msg" 18 70 2>&1 >/dev/tty || {
            # User pressed cancel
            return 1
        }
        sleep 1
    done
    
    return 0
}

# Validation helpers
validate_username() {
    local username="$1"
    
    # Check if empty
    [ -z "$username" ] && return 1
    
    # Check if valid (lowercase, numbers, underscore, dash, starts with letter)
    [[ "$username" =~ ^[a-z][a-z0-9_-]*$ ]] || return 1
    
    # Check if user already exists
    id "$username" &>/dev/null && return 1
    
    return 0
}

validate_hostname() {
    local hostname="$1"
    
    # Check if empty
    [ -z "$hostname" ] && return 1
    
    # Check if valid (lowercase, numbers, dash, no spaces)
    [[ "$hostname" =~ ^[a-z0-9-]+$ ]] || return 1
    
    return 0
}

validate_timezone() {
    local timezone="$1"
    
    # Check if timezone file exists
    [ -f "/usr/share/zoneinfo/$timezone" ] || return 1
    
    return 0
}

# Error handling
ui_error_and_exit() {
    local title="$1"
    local message="$2"
    local log_file="${3:-/var/log/arch-arm-setup.log}"
    
    local full_message="$message\n\nInstallation failed. Please check the log:\n$log_file\n\nYou can re-run the installer after fixing the issue."
    
    whiptail --title "$title" --msgbox "$full_message" 18 70
    
    exit 1
}

# Export functions
export -f ui_welcome
export -f ui_msgbox
export -f ui_yesno
export -f ui_input
export -f ui_password
export -f ui_menu
export -f ui_checklist
export -f ui_radiolist
export -f ui_progress
export -f ui_infobox
export -f log_phase
export -f log_info
export -f log_success
export -f log_error
export -f log_warning
export -f ui_progress_init
export -f ui_progress_step
export -f ui_complete_with_countdown
export -f validate_username
export -f validate_hostname
export -f validate_timezone
export -f ui_error_and_exit
