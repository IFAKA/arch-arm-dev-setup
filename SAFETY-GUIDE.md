# Safety Guide: Script Compatibility & Existing Configurations

## ⚠️ Important: Will This Break Existing Scripts?

### **Short Answer: No, with caveats**

The installer is designed to be **safe for fresh installations** but has some considerations for existing systems.

---

## 🔍 What Gets Modified

### **1. `.zshrc` File**

**Location:** `~/.zshrc`

**Behavior:**
```bash
# Phase 6 (line 51-58 in 06-devtools.sh)
if [ -f "$user_home/.zshrc" ]; then
    # BACKS UP existing file with timestamp
    cp .zshrc .zshrc.backup-20250101-120000
fi

# Then CREATES fresh .zshrc
cat > .zshrc << 'EOF'
...
EOF
```

**Impact:**
- ✅ **Existing `.zshrc` is BACKED UP** (timestamped)
- ⚠️ **New `.zshrc` REPLACES old one**
- ✅ **VimZap adds aliases after** (won't be overwritten)

**Risk Level:** 🟡 **MEDIUM**
- Fresh install: ✅ No risk
- Existing system with custom `.zshrc`: ⚠️ Custom config will be replaced (but backed up)

---

### **2. `.bashrc` File**

**Location:** `~/.bashrc`

**Behavior:**
```bash
# Phase 11 (line 181 in 11-shell.sh)
if [ -f "$user_home/.bashrc" ]; then
    cp .bashrc .bashrc.backup
fi

# Then APPENDS (not overwrites!)
cat >> .bashrc << 'EOF'
...
EOF
```

**Impact:**
- ✅ **Existing `.bashrc` is BACKED UP**
- ✅ **APPENDS to existing** (doesn't overwrite)
- ✅ **Safe for existing bash configs**

**Risk Level:** 🟢 **LOW**
- Existing configs are preserved
- Our additions are appended

---

### **3. VimZap Installation**

**Behavior:**
```bash
# VimZap installer checks for marker
if grep -q "# VimZap aliases" ~/.zshrc; then
    # Already exists, skip
else
    # Add aliases
    echo "# VimZap aliases" >> ~/.zshrc
    echo "alias v='nvim'" >> ~/.zshrc
    echo "alias vi='nvim'" >> ~/.zshrc
    echo "alias vim='nvim'" >> ~/.zshrc
    echo "# VimZap aliases end" >> ~/.zshrc
fi
```

**Impact:**
- ✅ **Won't duplicate** if already installed
- ✅ **Safe to re-run**
- ✅ **Uses markers** to detect existing installation

**Risk Level:** 🟢 **LOW**

---

## 🛡️ Safety Mechanisms

### **Built-in Protections:**

1. **Backups Before Modification:**
   - `.zshrc` → `.zshrc.backup-TIMESTAMP`
   - `.bashrc` → `.bashrc.backup`

2. **Append-Only Where Possible:**
   - `.bashrc` uses `>>` (append)
   - Only `.zshrc` uses `>` (overwrite with backup)

3. **Marker-Based Detection:**
   - VimZap uses markers to prevent duplicates
   - Scripts check for existing installations

4. **Shared Configuration:**
   - `.shell_common` holds most config
   - Easy to customize without touching `.zshrc`/`.bashrc`

---

## 🔧 Existing System Scenarios

### **Scenario 1: Fresh Arch ARM Install**
```
User: alarm (default)
.zshrc: doesn't exist
.bashrc: minimal default

Result: ✅ SAFE - Everything works perfectly
```

### **Scenario 2: Existing User with Custom .zshrc**
```
User: youruser
.zshrc: exists with custom config
.bashrc: exists with custom config

What Happens:
1. .zshrc → backed up to .zshrc.backup-TIMESTAMP
2. New .zshrc created (custom config replaced)
3. .bashrc → backed up and appended (custom config preserved)
4. VimZap adds aliases to new .zshrc

Result: ⚠️ MEDIUM RISK
- Custom .zshrc content is LOST (but backed up)
- User needs to manually merge old config
- Bash config is safe
```

### **Scenario 3: VimZap Already Installed**
```
User: youruser
.zshrc: exists with VimZap aliases
Neovim: has VimZap config

What Happens:
1. .zshrc → backed up and replaced
2. VimZap installer runs
3. VimZap detects markers and re-adds aliases
4. Neovim config gets updated

Result: ✅ SAFE - VimZap won't duplicate
```

### **Scenario 4: Scripts Sourcing .zshrc**
```bash
# User has script:
#!/bin/zsh
source ~/.zshrc
echo "Do something"
```

**Impact:**
- After installation, script sources NEW .zshrc
- If old .zshrc had custom functions/variables, they're gone
- Script might break if it depended on old .zshrc content

**Solution:**
- User should restore needed parts from backup
- Or modify script to source .shell_common instead

---

## 🚨 Breaking Changes & Mitigations

### **Potential Breaking Scenarios:**

#### **1. Custom Functions in Old .zshrc**
```bash
# Old .zshrc had:
my_custom_function() {
    echo "Custom!"
}

# After install: LOST (but in backup)
```

**Mitigation:**
```bash
# Restore from backup:
cp ~/.zshrc.backup-20250101-120000 ~/old.zshrc
# Extract needed functions and add to .shell_common
```

#### **2. Environment Variables in Old .zshrc**
```bash
# Old .zshrc had:
export MY_VAR="important"

# After install: LOST (but in backup)
```

**Mitigation:**
```bash
# Add to .shell_common or .zshrc:
echo 'export MY_VAR="important"' >> ~/.shell_common
```

#### **3. Plugins/Frameworks (oh-my-zsh, etc.)**
```bash
# Old .zshrc had oh-my-zsh:
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# After install: LOST
```

**Mitigation:**
```bash
# Our install uses Starship instead
# If user wants oh-my-zsh, they need to:
# 1. Restore old .zshrc from backup
# 2. Manually merge our config
# OR
# 3. Add oh-my-zsh to our .zshrc
```

---

## ✅ Safe Re-Run Behavior

**Is the installer idempotent?**

### **YES, mostly:**

```bash
# Run 1: Creates everything
curl ... | bash

# Run 2: Safe to re-run
curl ... | bash

# What happens:
- New .zshrc backup created (overwrites anyway)
- .bashrc appends again (duplicates possible)
- VimZap won't duplicate (has markers)
- Zsh plugins won't re-clone (checks existence)
```

**⚠️ Note:** `.bashrc` will have duplicate entries if re-run multiple times.

---

## 🔒 Best Practices for Users

### **Before Running Installer:**

1. **Backup your dotfiles:**
   ```bash
   cp ~/.zshrc ~/backup/.zshrc.manual-backup
   cp ~/.bashrc ~/backup/.bashrc.manual-backup
   ```

2. **Check what you have:**
   ```bash
   cat ~/.zshrc   # See your current config
   cat ~/.bashrc  # See your current config
   ```

3. **Extract custom parts:**
   - Save any custom functions, aliases, variables
   - Plan to add them to `.shell_common` later

### **After Running Installer:**

1. **Review backups:**
   ```bash
   ls -la ~/*.backup*
   diff ~/.zshrc.backup-* ~/.zshrc
   ```

2. **Restore needed config:**
   ```bash
   # Extract custom parts from backup
   vim ~/.zshrc.backup-20250101-120000
   
   # Add to .shell_common (shared) or .zshrc (zsh-only)
   vim ~/.shell_common
   ```

3. **Test your scripts:**
   ```bash
   # Run your scripts that depend on .zshrc
   ./my-script.sh
   ```

---

## 📋 Migration Checklist

If you have existing `.zshrc` with custom config:

- [ ] Backup dotfiles before installation
- [ ] Note custom functions/aliases/variables
- [ ] Run installer
- [ ] Check backup location
- [ ] Extract needed custom config
- [ ] Add to `.shell_common` (recommended) or `.zshrc`
- [ ] Test affected scripts
- [ ] Remove backup if everything works

---

## 🆘 Recovery

### **If Something Breaks:**

1. **Restore from backup:**
   ```bash
   cp ~/.zshrc.backup-20250101-120000 ~/.zshrc
   source ~/.zshrc
   ```

2. **Hybrid approach:**
   ```bash
   # Start fresh and add custom parts
   cp ~/.zshrc.backup-20250101-120000 ~/old.zshrc
   
   # Extract custom functions
   vim ~/old.zshrc  # Copy custom parts
   vim ~/.shell_common  # Paste here
   
   source ~/.zshrc
   ```

3. **Complete rollback:**
   ```bash
   # Restore original configs
   cp ~/.zshrc.backup-20250101-120000 ~/.zshrc
   cp ~/.bashrc.backup ~/.bashrc
   
   # Remove VimZap
   curl -fsSL ifaka.github.io/vimzap/i | bash -s uninstall
   
   # Change shell back to bash
   chsh -s /bin/bash
   ```

---

## 🎯 Recommendations

### **For Fresh Installations:**
✅ **Go ahead!** Everything is designed for fresh installs.

### **For Existing Systems:**
⚠️ **Caution recommended:**
1. Backup your dotfiles first
2. Review what you have in `.zshrc`
3. Plan to migrate custom config
4. Run installer
5. Restore/merge custom parts

### **For Production Systems:**
🔴 **Test first:**
1. Test in a VM or container
2. Document your custom config
3. Plan migration strategy
4. Schedule maintenance window
5. Have rollback plan ready

---

## 🔍 Summary Table

| File | Action | Risk | Backup? | Recovery |
|------|--------|------|---------|----------|
| `.zshrc` | Overwrite | 🟡 Medium | ✅ Yes (timestamped) | Restore from backup |
| `.bashrc` | Append | 🟢 Low | ✅ Yes | Restore from backup |
| `.shell_common` | Create | 🟢 Low | N/A (new file) | Just delete |
| VimZap config | Create/Update | 🟢 Low | ✅ Yes (via VimZap) | Uninstall VimZap |
| Zsh plugins | Clone | 🟢 Low | N/A | Just delete |

**Overall Risk Level:** 🟡 **MEDIUM for existing systems, 🟢 LOW for fresh installs**

---

## 💡 Pro Tips

1. **Use `.shell_common` for portability:**
   - Add custom config here instead of `.zshrc`
   - Works in both bash and zsh
   - Survives re-installs

2. **Keep `.zshrc` minimal:**
   - Just zsh-specific settings
   - Everything else in `.shell_common`

3. **Document your custom config:**
   - Keep a README of what you added
   - Easy to recreate if needed

4. **Version control your dotfiles:**
   ```bash
   cd ~
   git init
   git add .zshrc .bashrc .shell_common
   git commit -m "My dotfiles"
   ```

---

**Questions? Check the backup files first, they have all your old config!**
