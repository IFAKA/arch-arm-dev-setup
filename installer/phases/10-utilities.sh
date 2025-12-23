#!/bin/bash
#
# Phase 10: Utility Scripts
# Create helpful scripts for development workflow
#

phase_utility_scripts() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 10] Creating utility scripts..."
    
    mkdir -p "$user_home/bin"
    
    # Memory check script
    cat > "$user_home/bin/check-mem" <<'EOF'
#!/bin/bash
echo "═══════════════════════════════════════════"
echo "Memory Usage"
echo "═══════════════════════════════════════════"
free -h
echo ""
echo "Top Memory Consumers:"
echo "───────────────────────────────────────────"
ps aux --sort=-%mem | head -11
echo ""
echo "zram Status:"
echo "───────────────────────────────────────────"
zramctl 2>/dev/null || echo "zram not available"
EOF
    chmod +x "$user_home/bin/check-mem"
    
    # Docker start script
    cat > "$user_home/bin/docker-start" <<'EOF'
#!/bin/bash
PROFILE=${1:-frontend}
PROJECT_DIR=${2:-$(pwd)}

cd "$PROJECT_DIR"

case $PROFILE in
  frontend)
    docker-compose up -d postgres redis
    echo "✅ Started: PostgreSQL, Redis (~110MB RAM)"
    ;;
  fullstack)
    docker-compose up -d postgres redis mongodb
    echo "✅ Started: PostgreSQL, Redis, MongoDB (~260MB RAM)"
    ;;
  *)
    echo "❌ Unknown profile: $PROFILE"
    echo "Available: frontend, fullstack"
    exit 1
    ;;
esac

echo ""
check-mem
EOF
    chmod +x "$user_home/bin/docker-start"
    
    # Docker stop script
    cat > "$user_home/bin/docker-stop" <<'EOF'
#!/bin/bash
PROJECT_DIR=${1:-$(pwd)}
cd "$PROJECT_DIR"
docker-compose down
echo "✅ All containers stopped"
check-mem
EOF
    chmod +x "$user_home/bin/docker-stop"
    
    # Docker memory usage
    cat > "$user_home/bin/docker-mem" <<'EOF'
#!/bin/bash
echo "═══════════════════════════════════════════"
echo "Docker Container Memory Usage"
echo "═══════════════════════════════════════════"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}"
EOF
    chmod +x "$user_home/bin/docker-mem"
    
    # Memory pressure detection
    cat > "$user_home/bin/mem-pressure" <<'EOF'
#!/bin/bash
AVAILABLE=$(free | grep Mem | awk '{print $7}')
TOTAL=$(free | grep Mem | awk '{print $2}')
PERCENT=$((AVAILABLE * 100 / TOTAL))

echo "═══════════════════════════════════════════"
echo "Memory Pressure Check"
echo "═══════════════════════════════════════════"

if [ $PERCENT -lt 20 ]; then
  echo "⚠️  MEMORY PRESSURE DETECTED!"
  echo "Available: ${PERCENT}%"
  echo ""
  echo "Quick fixes:"
  echo "  1. dstop          # Stop Docker containers"
  echo "  2. pkill chromium # Close browser"
  echo "  3. pkill -f 'node|code' # Kill heavy processes"
  echo ""
  check-mem
else
  echo "✅ Memory OK (${PERCENT}% available)"
  echo ""
  free -h
fi
EOF
    chmod +x "$user_home/bin/mem-pressure"
    
    # Frontend workflow
    cat > "$user_home/bin/work-frontend" <<'EOF'
#!/bin/bash
echo "🚀 Starting Frontend Development Workflow"
echo "═══════════════════════════════════════════"
echo ""

echo "Current memory:"
free -h | grep Mem
echo ""

echo "Starting databases..."
docker-start frontend

# Switch to workspace 1 if in Sway
swaymsg 'workspace 1' 2>/dev/null || true

echo ""
echo "✅ Frontend Environment Ready!"
echo "   • Databases: PostgreSQL, Redis"
echo "   • Memory: ~620MB expected"
echo ""
echo "Start coding! 🎨"
EOF
    chmod +x "$user_home/bin/work-frontend"
    
    # Fullstack workflow
    cat > "$user_home/bin/work-fullstack" <<'EOF'
#!/bin/bash
echo "🚀 Starting Fullstack Development Workflow"
echo "═══════════════════════════════════════════"
echo ""

echo "Current memory:"
free -h | grep Mem
echo ""

echo "Starting all services..."
docker-start fullstack

# Switch to workspace 1 if in Sway
swaymsg 'workspace 1' 2>/dev/null || true

echo ""
echo "✅ Fullstack Environment Ready!"
echo "   • Databases: PostgreSQL, Redis, MongoDB"
echo "   • Memory: ~1.2GB expected"
echo ""
echo "Start coding! 🚀"
EOF
    chmod +x "$user_home/bin/work-fullstack"
    
    # Compile preparation (free memory)
    cat > "$user_home/bin/work-compile" <<'EOF'
#!/bin/bash
echo "🔧 Preparing for compilation..."
echo "═══════════════════════════════════════════"
echo ""

echo "Before cleanup:"
free -h | grep Mem
echo ""

echo "Stopping Docker containers..."
docker-compose down 2>/dev/null

echo "Closing heavy applications..."
pkill chromium 2>/dev/null

sleep 2

echo ""
echo "After cleanup:"
free -h | grep Mem
echo ""
echo "✅ Ready for compilation!"
EOF
    chmod +x "$user_home/bin/work-compile"
    
    # Set ownership
    chown -R "$username:$username" "$user_home/bin"
    
    echo "[Phase 10] Utility scripts created in ~/bin"
}
