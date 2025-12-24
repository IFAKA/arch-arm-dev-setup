# 🛡️ Edge Cases Coverage

This document lists all edge cases handled by the installer's `upgrade_system()` function.

## ✅ All 18 Edge Cases Covered

### **1. Missing glibc Version Detection**
- **Scenario:** `ldd --version` fails or returns empty
- **Handling:** Assumes upgrade needed, continues safely
- **Code:** Checks `if [ -z "$glibc_version" ]`

### **2. /boot Partition Missing/Not Mounted**
- **Scenario:** System uses /boot as directory on root partition
- **Handling:** Detects with `mountpoint -q`, continues without error
- **Code:** Warning logged, continues with root partition space

### **3. /boot Read-Only Filesystem**
- **Scenario:** /boot mounted as read-only
- **Handling:** Attempts remount as read-write
- **Code:** `mount -o remount,rw /boot`
- **Failure:** Exits with clear error if remount fails

### **4. df Command Failure**
- **Scenario:** Corrupted filesystem, df unable to read
- **Handling:** Fallback to assumed 200MB (sufficient)
- **Code:** `if df /boot &>/dev/null; then ... else`

### **5. du Command Failure**
- **Scenario:** Cannot determine file size
- **Handling:** Uses "unknown size" placeholder
- **Code:** `${fallback_size:-"unknown size"}`

### **6. Fallback Image Already Removed**
- **Scenario:** User manually removed fallback before running script
- **Handling:** Checks existence before removal
- **Code:** `if [ -f /boot/initramfs-linux-fallback.img ]; then`

### **7. Space Check Returns Empty/Zero**
- **Scenario:** df returns invalid data
- **Handling:** Assumes 200MB, allows upgrade to proceed
- **Code:** `if [ -z "$boot_avail_mb" ] || [ "$boot_avail_mb" = "0" ]`

### **8. pacman Upgrade Fails - No Space Left**
- **Scenario:** Disk full during upgrade
- **Handling:** Parses error, identifies partition, provides specific cleanup
- **Code:** `grep -qi "no space left" /tmp/pacman-upgrade.log`
- **Recovery:** Shows /boot and / space, cleanup commands

### **9. pacman Upgrade Fails - Lock File**
- **Scenario:** Another package manager running
- **Handling:** Detects lock file error, provides removal command
- **Code:** `grep -qi "could not get lock"`
- **Recovery:** `rm -f /var/lib/pacman/db.lck`

### **10. pacman Upgrade Fails - Keyring Issues**
- **Scenario:** Package signing key problems
- **Handling:** Detects keyring errors, provides reinitialization steps
- **Code:** `grep -qi "keyring"`
- **Recovery:** `pacman-key --init && pacman-key --populate`

### **11. .old Files Don't Exist**
- **Scenario:** Fresh system, no previous upgrades
- **Handling:** Checks existence before attempting removal
- **Code:** `if [ -f /boot/initramfs-linux-fallback.img.old ]`
- **Result:** No error, continues to current file cleanup

### **12. rm Command Fails**
- **Scenario:** Permission denied or I/O error
- **Handling:** Checks rm success, exits with error if fails
- **Code:** `if rm -f /boot/initramfs-linux-fallback.img 2>/dev/null; then`

### **13. Error Messages Include Recovery Steps**
- **Scenario:** Any failure condition
- **Handling:** Every error includes "Recovery steps:" section
- **Examples:** Lock file removal, keyring reinit, space cleanup

### **14. Shows Disk Usage on Error**
- **Scenario:** Space-related failure
- **Handling:** Shows `ls -lh` and `du -sh` output
- **Code:** `du -sh /boot/* | sort -rh | head -10`

### **15. Logs pacman Output**
- **Scenario:** Upgrade fails with unclear error
- **Handling:** Full pacman output saved to `/tmp/pacman-upgrade.log`
- **Code:** `pacman -Syu --noconfirm 2>&1 | tee /tmp/pacman-upgrade.log`
- **Usage:** Analyzed for error patterns, shown to user

### **16. Verifies Upgrade Success**
- **Scenario:** pacman returns success but didn't actually upgrade
- **Handling:** Checks glibc version before/after
- **Code:** Compares `$glibc_version` → `$new_glibc`
- **Output:** Shows version change in success message

### **17. Cleans Up Temporary Files**
- **Scenario:** pacman log file left behind
- **Handling:** Removes log after processing
- **Code:** `rm -f /tmp/pacman-upgrade.log`

### **18. Unknown Errors Handled Gracefully**
- **Scenario:** Unexpected pacman failure
- **Handling:** Logs last 20 lines, offers to continue or abort
- **Code:** Generic error handler, shows log tail
- **Behavior:** Warns user, allows continuation with existing packages

---

## 🔍 Additional Safeguards

### **Multi-Step /boot Cleanup**
1. Remove `.old` backup files (if exist)
2. Check space
3. If insufficient, remove current fallback
4. Re-check space
5. If still insufficient, show detailed error

### **Defensive Programming**
- All commands check exit codes
- All variables have fallback values
- All file operations check existence first
- All df/du commands handle failure
- All errors provide recovery instructions

### **Error Message Quality**
- Always include "what happened"
- Always include "why it happened"
- Always include "how to fix it"
- Always include specific commands to run
- Always show relevant system state

---

## 🧪 Testing

Run `./test-edge-cases.sh` to verify all edge cases are handled:

```bash
./test-edge-cases.sh
```

Expected output:
```
=== Test Results ===
Passed: 18
Failed: 0

✓ ALL EDGE CASES COVERED
```

---

## 📚 Related Documentation

- **TROUBLESHOOTING.md** - User-facing troubleshooting guide
- **install.sh** - Source code with inline comments
- **test-edge-cases.sh** - Automated edge case verification

---

**Last Updated:** December 24, 2025  
**Test Coverage:** 18/18 edge cases (100%)
