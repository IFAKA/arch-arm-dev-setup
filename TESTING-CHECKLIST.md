# 🧪 Testing Checklist - Zsh Auto-Start Fix

This document helps you verify the critical Zsh auto-start fix works correctly.

## 🎯 What Was Fixed

### **Problem**
- Default shell was set to **Zsh** but only `.bash_profile` was created
- Zsh uses `.zprofile` instead of `.bash_profile`
- **Result**: Sway wouldn't auto-start on login ❌

### **Solution Applied**
1. ✅ Created `.zprofile` for Zsh auto-start (primary fix)
2. ✅ Kept `.bash_profile` for Bash fallback compatibility
3. ✅ Changed terminal exec from `bash` to `zsh` in Sway config
4. ✅ Updated file ownership to include `.zprofile`

---

## 📋 Pre-Installation Testing

**Before running a fresh install, verify files are correct:**

### ✅ **Check 1: Verify installer/phases/05-sway.sh changes**

```bash
# Check that terminal auto-start uses Zsh (not Bash)
grep "exec foot" installer/phases/05-sway.sh

# Expected output (line 100):
# exec foot -e zsh -c 'if [ -f ~/.first-login ]; then ... fi; exec zsh'
```

**✅ PASS if**: Contains `zsh` (not `bash`)

---

### ✅ **Check 2: Verify .zprofile creation**

```bash
# Check that .zprofile is created
grep -A 7 "\.zprofile" installer/phases/05-sway.sh

# Expected output should include:
# cat > "$user_home/.zprofile" <<'EOF'
# # Auto-start Sway on tty1
# if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#     echo "Starting Sway..."
#     exec sway
# fi
# EOF
```

**✅ PASS if**: `.zprofile` is created with Sway auto-start logic

---

### ✅ **Check 3: Verify .zprofile ownership**

```bash
# Check that ownership is set for .zprofile
grep "chown.*\.zprofile" installer/phases/05-sway.sh

# Expected output (around line 281):
# chown "$username:$username" "$user_home/.zprofile"
```

**✅ PASS if**: `.zprofile` ownership line exists

---

## 🚀 Post-Installation Testing

**After running a fresh installation, verify the system works:**

### ✅ **Test 1: Verify default shell is Zsh**

**Login to the VM and run:**

```bash
echo $SHELL
```

**✅ PASS if**: Output is `/bin/zsh`

---

### ✅ **Test 2: Verify .zprofile exists**

```bash
ls -la ~/.zprofile
cat ~/.zprofile
```

**✅ PASS if**: 
- File exists
- Contains Sway auto-start code
- Owned by your user (not root)

---

### ✅ **Test 3: Verify .bash_profile exists (fallback)**

```bash
ls -la ~/.bash_profile
cat ~/.bash_profile
```

**✅ PASS if**: 
- File exists
- Contains identical Sway auto-start code
- Provides Bash compatibility

---

### ✅ **Test 4: Verify Sway auto-starts on login**

**Logout and login again:**

```bash
exit
```

**Then login as your user**

**✅ PASS if**: 
- Sway starts automatically without manual intervention
- You see "Starting Sway..." message
- GUI appears immediately after login

---

### ✅ **Test 5: Verify terminal auto-opens with Zsh**

**After Sway starts:**

**✅ PASS if**: 
- Terminal opens automatically
- Prompt shows Starship theme
- Running `echo $SHELL` shows `/bin/zsh`
- Welcome message displays (on first login)

---

### ✅ **Test 6: Verify welcome message displays**

**On first login only:**

**✅ PASS if**: 
- Welcome message box appears in terminal
- Shows "Welcome to Your Development Environment!"
- Lists quick commands
- Prompt to press Enter to continue
- File `~/.first-login` is deleted after display

---

### ✅ **Test 7: Verify Zsh features work**

```bash
# Test auto-suggestions (type a command you used before)
# Should show gray suggestion text

# Test syntax highlighting (type a valid command)
# Should show colored syntax

# Test Starship prompt
cd ~/projects
git init
# Prompt should show git branch icon

# Test completion
cd ~/pro<TAB>
# Should autocomplete to ~/projects/
```

**✅ PASS if**: All Zsh features work correctly

---

### ✅ **Test 8: Verify VimZap aliases work**

```bash
# Test all Neovim aliases
v
# Should open Neovim

vi
# Should open Neovim

vim
# Should open Neovim
```

**✅ PASS if**: All aliases open Neovim with VimZap config

---

### ✅ **Test 9: Verify shared shell config loads**

```bash
# Check that .shell_common is loaded
type mem
type wf
type help

# All should show they are functions/aliases
```

**✅ PASS if**: Common aliases and functions are available

---

## 🔄 Regression Testing

**Verify nothing broke:**

### ✅ **Test 10: Verify Bash still works (fallback)**

```bash
# Switch to Bash temporarily
bash

# Check if .bash_profile would work
cat ~/.bash_profile

# Test that bash has access to common config
type mem
type wf
```

**✅ PASS if**: 
- Bash works
- `.bash_profile` contains auto-start code
- Common aliases load in Bash too

---

### ✅ **Test 11: Verify auto-start only on tty1**

**SSH into the VM (if possible) or switch to tty2:**

```bash
# Press Ctrl+Alt+F2 to switch to tty2
# Login

# Sway should NOT auto-start here
```

**✅ PASS if**: Sway only auto-starts on tty1, not other ttys

---

## 📊 Test Results Summary

**Fill in your test results:**

| Test # | Test Name | Status | Notes |
|--------|-----------|--------|-------|
| 1 | Default shell is Zsh | ⬜ | |
| 2 | .zprofile exists | ⬜ | |
| 3 | .bash_profile exists | ⬜ | |
| 4 | Sway auto-starts | ⬜ | |
| 5 | Terminal opens with Zsh | ⬜ | |
| 6 | Welcome message displays | ⬜ | |
| 7 | Zsh features work | ⬜ | |
| 8 | VimZap aliases work | ⬜ | |
| 9 | Shared config loads | ⬜ | |
| 10 | Bash fallback works | ⬜ | |
| 11 | Auto-start only on tty1 | ⬜ | |

**Legend**: ✅ Pass | ❌ Fail | ⬜ Not tested

---

## 🐛 If Tests Fail

### **Sway doesn't auto-start**

1. Check if `.zprofile` exists: `ls -la ~/.zprofile`
2. Check default shell: `echo $SHELL`
3. Manually run: `cat ~/.zprofile`
4. Try manual start: `sway`

### **Terminal opens with Bash instead of Zsh**

1. Check Sway config: `grep "exec foot" ~/.config/sway/config`
2. Should contain `zsh`, not `bash`
3. Reload Sway: `Super+Shift+C`

### **Welcome message doesn't appear**

1. Check if marker exists: `ls -la ~/.first-login`
2. Check message file: `cat ~/.welcome-message.txt`
3. Logout and login again to trigger first-login

---

## ✅ Sign-Off

**After completing all tests:**

- [ ] All critical tests pass (1-6)
- [ ] No regressions detected (7-11)
- [ ] Ready for production use
- [ ] Documentation matches actual behavior

**Tested by**: ________________  
**Date**: ________________  
**VM/Device**: ________________  
**Notes**: 

---

## 🚀 Quick Manual Test (5 minutes)

**Don't have time for full testing? Do this quick smoke test:**

1. ✅ Fresh install on clean Arch ARM
2. ✅ Reboot after install completes
3. ✅ Login with new user
4. ✅ Verify Sway starts automatically
5. ✅ Verify terminal opens automatically
6. ✅ Run `echo $SHELL` → should be `/bin/zsh`
7. ✅ Type `help` → should show command reference
8. ✅ Type `v` → should open Neovim with VimZap

**If all 8 pass: You're good to go!** 🎉

---

**Questions or issues? Open an issue on GitHub!**
