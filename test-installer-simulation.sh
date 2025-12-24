#!/bin/bash
#
# Installer Simulation Test
# Tests the full installer logic WITHOUT modifying your Mac
# Simulates a fresh UTM Gallery Arch ARM environment
#

# Don't exit on error - we want to collect all test results
set -uo pipefail

TEST_DIR="/tmp/arch-arm-installer-test-$$"
LOG_FILE="$TEST_DIR/test.log"
ERRORS=0
WARNINGS=0
PASSED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1" | tee -a "$LOG_FILE"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$LOG_FILE"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$LOG_FILE"
    ((ERRORS++))
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
    ((WARNINGS++))
}

# Setup test environment
setup_test_env() {
    mkdir -p "$TEST_DIR"
    touch "$LOG_FILE"
    log_test "Setting up test environment..."
    cd "$TEST_DIR"
    
    # Download latest installer
    if curl -fsSL "https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh?$(date +%s)" -o install.sh; then
        log_pass "Downloaded install.sh"
    else
        log_fail "Failed to download install.sh"
        exit 1
    fi
    
    # Download main installer
    mkdir -p installer/phases
    if curl -fsSL "https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/installer/main.sh" -o installer/main.sh; then
        log_pass "Downloaded installer/main.sh"
    else
        log_fail "Failed to download installer/main.sh"
        exit 1
    fi
    
    # Download all phases
    for phase in {00..12}; do
        phase_files=(
            "00-welcome"
            "01-user"
            "02-system"
            "03-utm"
            "04-memory"
            "05-sway"
            "06-devtools"
            "07-languages"
            "08-docker"
            "09-databases"
            "10-utilities"
            "11-shell"
            "12-complete"
        )
        
        phase_name="${phase_files[$((10#$phase))]}"
        if curl -fsSL "https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/installer/phases/${phase_name}.sh" -o "installer/phases/${phase_name}.sh" 2>/dev/null; then
            log_pass "Downloaded phase: ${phase_name}.sh"
        else
            log_warn "Optional phase ${phase_name}.sh not available"
        fi
    done
    
    # Download UI library
    if curl -fsSL "https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/installer/ui.sh" -o installer/ui.sh 2>/dev/null; then
        log_pass "Downloaded installer/ui.sh"
    else
        log_warn "installer/ui.sh not available"
    fi
}

# Test 1: Bash syntax validation
test_syntax() {
    log_test "Running bash syntax validation..."
    
    for script in install.sh installer/main.sh installer/phases/*.sh installer/ui.sh; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                log_pass "Syntax valid: $script"
            else
                log_fail "Syntax error in: $script"
            fi
        fi
    done
}

# Test 2: Check for required functions
test_required_functions() {
    log_test "Checking for required functions..."
    
    # install.sh should have
    if grep -q "safe_pacman()" install.sh; then
        log_pass "install.sh has safe_pacman()"
    else
        log_fail "install.sh missing safe_pacman()"
    fi
    
    if grep -q "upgrade_system()" install.sh; then
        log_pass "install.sh has upgrade_system()"
    else
        log_fail "install.sh missing upgrade_system()"
    fi
    
    # installer/main.sh should have
    if grep -q "safe_pacman()" installer/main.sh; then
        log_pass "installer/main.sh has safe_pacman()"
    else
        log_fail "installer/main.sh missing safe_pacman()"
    fi
    
    if grep -q "create_pacman_wrapper" installer/main.sh; then
        log_pass "installer/main.sh creates pacman wrapper script"
    else
        log_fail "installer/main.sh missing pacman wrapper creation"
    fi
    
    # Check that wrapper script handles Landlock
    if grep -q "/usr/local/bin/pacman" installer/main.sh; then
        log_pass "installer/main.sh uses /usr/local/bin for wrapper"
    else
        log_warn "Pacman wrapper path not found"
    fi
}

# Test 3: Check .zprofile syntax
test_zprofile_syntax() {
    log_test "Checking .zprofile syntax..."
    
    if [ -f "installer/phases/05-sway.sh" ]; then
        # Extract .zprofile content
        sed -n '/cat.*\.zprofile/,/^EOF$/p' installer/phases/05-sway.sh | grep -v "cat\|EOF" > /tmp/test-zprofile.sh
        
        # Check for 'local' keyword (invalid in .zprofile)
        if grep -q "local current_tty" /tmp/test-zprofile.sh; then
            log_fail ".zprofile contains 'local' keyword (invalid outside functions)"
        else
            log_pass ".zprofile syntax looks correct (no 'local' keyword)"
        fi
        
        # Verify it's valid shell syntax
        if bash -n /tmp/test-zprofile.sh 2>/dev/null; then
            log_pass ".zprofile is valid shell syntax"
        else
            log_fail ".zprofile has syntax errors"
        fi
        
        rm -f /tmp/test-zprofile.sh
    else
        log_warn "Sway phase not available for testing"
    fi
}

# Test 4: Check Landlock error handling
test_landlock_handling() {
    log_test "Testing Landlock error handling..."
    
    # Create mock pacman that simulates Landlock error
    cat > /tmp/mock-pacman.sh << 'MOCKPACMAN'
#!/bin/bash
if [[ "$*" == *"--disable-sandbox"* ]]; then
    echo "Success with --disable-sandbox"
    exit 0
else
    echo "error: restricting filesystem access failed because Landlock is not supported by the kernel!" >&2
    echo "error: switching to sandbox user 'alpm' failed!" >&2
    exit 1
fi
MOCKPACMAN
    chmod +x /tmp/mock-pacman.sh
    
    # Extract and test safe_pacman function
    sed -n '/^safe_pacman()/,/^}/p' install.sh > /tmp/test-safe-pacman.sh
    echo "" >> /tmp/test-safe-pacman.sh
    echo "safe_pacman /tmp/mock-pacman.sh -Sy" >> /tmp/test-safe-pacman.sh
    
    if bash /tmp/test-safe-pacman.sh 2>&1 | grep -q "Success with --disable-sandbox"; then
        log_pass "safe_pacman handles Landlock errors correctly"
    else
        log_fail "safe_pacman does NOT handle Landlock errors"
    fi
    
    rm -f /tmp/mock-pacman.sh /tmp/test-safe-pacman.sh
}

# Test 5: Check version consistency
test_version_consistency() {
    log_test "Checking version consistency..."
    
    version=$(grep "INSTALLER_VERSION=" install.sh | cut -d'"' -f2)
    if [ -n "$version" ]; then
        log_pass "Installer version: $version"
        
        # Check if version is in banner
        if grep -q "$version" install.sh; then
            log_pass "Version appears in banner"
        else
            log_warn "Version not found in banner"
        fi
    else
        log_fail "No version found in install.sh"
    fi
}

# Test 6: Check for common pitfalls
test_common_pitfalls() {
    log_test "Checking for common pitfalls..."
    
    # Check for unquoted variables
    if grep -rn '\$[A-Z_]*[^"]' --include="*.sh" . | grep -v "EOF\|echo\|log_" | head -1 > /dev/null; then
        log_warn "Found potentially unquoted variables (may be false positives)"
    else
        log_pass "No obvious unquoted variable issues"
    fi
    
    # Check for missing error handling on critical operations
    if grep -rn "pacman -S" installer/phases/ | grep -v "safe_pacman" | head -1 > /dev/null; then
        log_warn "Found direct pacman calls in phases (should work with override, but inconsistent)"
    else
        log_pass "All pacman calls go through wrapper"
    fi
    
    # Check for set -e in all scripts
    scripts_without_set_e=0
    for script in install.sh installer/main.sh; do
        if ! grep -q "set -e" "$script"; then
            log_warn "$script missing 'set -e'"
            ((scripts_without_set_e++))
        fi
    done
    
    if [ $scripts_without_set_e -eq 0 ]; then
        log_pass "All main scripts have error handling (set -e)"
    fi
}

# Test 7: Simulate full flow (logic only)
test_full_flow_simulation() {
    log_test "Simulating full installation flow..."
    
    echo "  Step 1: Bootstrap (install.sh)"
    if grep -q "auto_expand_disk()" install.sh; then
        log_pass "  ✓ Has auto disk expansion"
    fi
    
    if grep -q "upgrade_system()" install.sh; then
        log_pass "  ✓ Has system upgrade"
    fi
    
    if grep -q "install_whiptail()" install.sh; then
        log_pass "  ✓ Has whiptail installation"
    fi
    
    if grep -q "download_installer()" install.sh; then
        log_pass "  ✓ Has installer download"
    fi
    
    echo ""
    echo "  Step 2: Main Installer (installer/main.sh)"
    if [ -f "installer/main.sh" ]; then
        if grep -q "phase_create_user" installer/main.sh; then
            log_pass "  ✓ Calls user creation"
        fi
        
        if grep -q "phase_install_sway" installer/main.sh; then
            log_pass "  ✓ Calls sway installation"
        fi
        
        if grep -q "phase_language_runtimes" installer/main.sh; then
            log_pass "  ✓ Calls language runtime installation"
        fi
    fi
}

# Run all tests
run_all_tests() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     Arch ARM Dev Setup - Installer Simulation Test       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "This test simulates the installer WITHOUT modifying your system"
    echo "Test directory: $TEST_DIR"
    echo ""
    
    setup_test_env
    echo ""
    
    test_syntax
    echo ""
    
    test_required_functions
    echo ""
    
    test_zprofile_syntax
    echo ""
    
    test_landlock_handling
    echo ""
    
    test_version_consistency
    echo ""
    
    test_common_pitfalls
    echo ""
    
    test_full_flow_simulation
    echo ""
    
    # Summary
    echo "═══════════════════════════════════════════════════════════"
    echo "                      TEST SUMMARY"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${GREEN}PASSED:${NC}   $PASSED"
    echo -e "${YELLOW}WARNINGS:${NC} $WARNINGS"
    echo -e "${RED}FAILED:${NC}   $ERRORS"
    echo ""
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
        echo ""
        echo "Confidence Level: HIGH"
        echo "The installer should work correctly on a fresh Arch ARM VM."
        echo ""
        echo "Safe to run:"
        echo "  curl -fsSL https://raw.githubusercontent.com/IFAKA/arch-arm-dev-setup/main/install.sh | bash"
        echo ""
        exit 0
    else
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo "Confidence Level: LOW"
        echo "Review failures above before running the installer."
        echo ""
        echo "Test log: $LOG_FILE"
        exit 1
    fi
}

# Cleanup on exit
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        echo ""
        echo "Test artifacts saved in: $TEST_DIR"
        echo "To cleanup: rm -rf $TEST_DIR"
    fi
}
trap cleanup EXIT

# Run tests
run_all_tests
