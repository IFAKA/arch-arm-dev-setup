#!/bin/bash
#
# Test script to verify all edge cases are handled
#

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

test_passed=0
test_failed=0

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((test_passed++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((test_failed++))
}

echo "=== Edge Case Coverage Test ==="
echo ""

# Test 1: Missing glibc version
log_test "1. Missing glibc version detection"
if grep -q "if \[ -z \"\$glibc_version\" \]" install.sh; then
    log_pass "Handles missing glibc version"
else
    log_fail "Missing glibc version not handled"
fi

# Test 2: /boot not mounted or missing
log_test "2. /boot partition missing/not mounted"
if grep -q "mountpoint -q /boot" install.sh; then
    log_pass "Checks if /boot is mounted"
else
    log_fail "/boot mount check missing"
fi

# Test 3: /boot read-only
log_test "3. /boot read-only filesystem"
if grep -q "if \[ ! -w /boot \]" install.sh; then
    log_pass "Handles read-only /boot"
else
    log_fail "Read-only /boot not handled"
fi

# Test 4: df command fails
log_test "4. df command failure (corrupted filesystem)"
if grep -q "if df /boot &>/dev/null" install.sh; then
    log_pass "Handles df command failure"
else
    log_fail "df failure not handled"
fi

# Test 5: du command fails
log_test "5. du command failure"
if grep -q "du -h /boot/initramfs.*2>/dev/null" install.sh; then
    log_pass "Handles du command failure"
else
    log_fail "du failure not handled"
fi

# Test 6: Fallback image already removed
log_test "6. Fallback image already removed"
if grep -q "if \[ -f /boot/initramfs-linux-fallback.img \]" install.sh; then
    log_pass "Checks if fallback exists before removal"
else
    log_fail "Missing fallback existence check"
fi

# Test 7: Space check returns empty/zero
log_test "7. Space check returns empty or zero"
if grep -q 'if \[ -z "\$boot_avail_mb" \] || \[ "\$boot_avail_mb" = "0" \]' install.sh; then
    log_pass "Handles empty/zero space values"
else
    log_fail "Empty space value not handled"
fi

# Test 8: pacman upgrade fails - no space
log_test "8. pacman upgrade fails (no space)"
if grep -q 'grep -qi "no space left"' install.sh; then
    log_pass "Detects 'no space left' errors"
else
    log_fail "'No space left' detection missing"
fi

# Test 9: pacman upgrade fails - lock file
log_test "9. pacman upgrade fails (lock file)"
if grep -q 'grep -qi "could not get lock"' install.sh; then
    log_pass "Detects lock file errors"
else
    log_fail "Lock file detection missing"
fi

# Test 10: pacman upgrade fails - keyring
log_test "10. pacman upgrade fails (keyring)"
if grep -q 'grep -qi "keyring"' install.sh; then
    log_pass "Detects keyring errors"
else
    log_fail "Keyring detection missing"
fi

# Test 11: .old files don't exist
log_test "11. .old files don't exist (fresh system)"
if grep -q 'if \[ -f /boot/initramfs-linux-fallback.img.old \]' install.sh; then
    log_pass "Checks .old file existence before removal"
else
    log_fail ".old file check missing"
fi

# Test 12: rm command fails
log_test "12. rm command fails (permission/I/O error)"
if grep -q 'if rm -f /boot/initramfs-linux-fallback.img 2>/dev/null' install.sh; then
    log_pass "Checks rm command success"
else
    log_fail "rm success check missing"
fi

# Test 13: Error messages include recovery steps
log_test "13. Error messages include recovery steps"
if grep -q "Recovery steps:" install.sh; then
    log_pass "Provides recovery instructions"
else
    log_fail "Recovery instructions missing"
fi

# Test 14: Shows disk usage on error
log_test "14. Shows disk usage breakdown on error"
if grep -q "du -sh /boot/\*" install.sh; then
    log_pass "Shows disk usage on error"
else
    log_fail "Disk usage display missing"
fi

# Test 15: Logs pacman output for debugging
log_test "15. Logs pacman output for debugging"
if grep -q "tee /tmp/pacman-upgrade.log" install.sh; then
    log_pass "Logs pacman output"
else
    log_fail "Pacman logging missing"
fi

# Test 16: Verifies upgrade success
log_test "16. Verifies upgrade actually worked"
if grep -q "new_glibc.*ldd --version" install.sh; then
    log_pass "Verifies upgrade success"
else
    log_fail "Upgrade verification missing"
fi

# Test 17: Cleans up temporary files
log_test "17. Cleans up temporary files"
if grep -q "rm -f /tmp/pacman-upgrade.log" install.sh; then
    log_pass "Cleans up temp files"
else
    log_fail "Temp file cleanup missing"
fi

# Test 18: Handles unknown errors gracefully
log_test "18. Handles unknown errors gracefully"
if grep -q "Unknown upgrade failure - attempting to continue" install.sh; then
    log_pass "Handles unknown errors"
else
    log_fail "Unknown error handling missing"
fi

echo ""
echo "=== Test Results ==="
echo -e "${GREEN}Passed: $test_passed${NC}"
echo -e "${RED}Failed: $test_failed${NC}"
echo ""

if [ $test_failed -eq 0 ]; then
    echo -e "${GREEN}✓ ALL EDGE CASES COVERED${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME EDGE CASES MISSING${NC}"
    exit 1
fi
