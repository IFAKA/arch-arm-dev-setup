#!/bin/bash
#
# Phase 9: Database Tools
#

phase_database_tools() {
    local username="$1"
    local user_home="/home/$username"
    
    echo "[Phase 9] Installing database clients..."
    
    # Install database client libraries
    pacman -S --noconfirm postgresql-libs redis
    
    # Create docker-compose template for databases
    cat > "$user_home/docker-compose-template.yml" <<'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: dev-postgres
    environment:
      POSTGRES_PASSWORD: devpassword
      POSTGRES_USER: devuser
      POSTGRES_DB: devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    mem_limit: 100m
    mem_reservation: 50m

  redis:
    image: redis:7-alpine
    container_name: dev-redis
    ports:
      - "6379:6379"
    mem_limit: 50m
    mem_reservation: 25m

  mongodb:
    image: mongo:7
    container_name: dev-mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: devuser
      MONGO_INITDB_ROOT_PASSWORD: devpassword
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    mem_limit: 150m
    mem_reservation: 100m

volumes:
  postgres-data:
  mongo-data:
EOF
    
    chown "$username:$username" "$user_home/docker-compose-template.yml"
    
    echo "[Phase 9] Database tools and templates created"
}
