#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║           TUNN8N SERVICE STOPPER         ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ docker-compose.yml not found!${NC}"
    echo -e "${YELLOW}⚠️  Are you in the correct directory?${NC}"
    exit 1
fi

# Stop containers using docker-compose
echo -e "${BLUE}🔄 Stopping Docker containers...${NC}"
if docker-compose down; then
    echo -e "${GREEN}✅ Containers stopped successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Trying alternative stop method...${NC}"
    
    # Alternative method: stop containers by name pattern
    containers=$(docker ps -a --filter "name=tunn8n" --filter "name=n8n" --format "{{.Names}}")
    
    if [ -n "$containers" ]; then
        echo "Found containers: $(echo $containers | tr '\n' ' ')"
        for container in $containers; do
            docker stop "$container" 2>/dev/null || true
            docker rm -f "$container" 2>/dev/null || true
            echo "Stopped: $container"
        done
        echo -e "${GREEN}✅ All containers stopped${NC}"
    else
        echo -e "${YELLOW}⚠️  No TUNN8N containers found${NC}"
    fi
fi

# Summary
echo -e "${GREEN}✅ Shutdown completed at: $(date)${NC}"