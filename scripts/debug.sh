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
echo "║           N8N DOCKER DIAGNOSTICS         ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Docker is running${NC}"
fi

# Container status
echo -e "\n${BLUE}CONTAINER STATUS:${NC}"
docker ps -a --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# N8N container details
echo -e "\n${BLUE}N8N CONTAINER INFO:${NC}"
if docker inspect n8n-app &>/dev/null; then
    docker inspect n8n-app --format '
Status: {{.State.Status}}
Running: {{.State.Running}}
Restart Count: {{.RestartCount}}
Image: {{.Config.Image}}'
else
    echo -e "${YELLOW}⚠️  n8n-app container not found${NC}"
fi

# Logs
echo -e "\n${BLUE}N8N LOGS (last 10 lines):${NC}"
if docker ps -a | grep -q "n8n-app"; then
    docker logs n8n-app --tail 10 2>&1
else
    echo -e "${YELLOW}⚠️  n8n-app container not available${NC}"
fi

# Summary
echo -e "\n${BLUE}SUMMARY:${NC}"
if docker ps | grep -q "n8n-app"; then
    echo -e "${GREEN}✅ n8n-app is running${NC}"
else
    echo -e "${RED}❌ n8n-app is NOT running${NC}"
    echo -e "${BLUE}💡 Try: docker-compose up -d n8n-app${NC}"
fi

if docker inspect n8n-app --format='{{.RestartCount}}' | grep -q "[1-9]"; then
    echo -e "${YELLOW}⚠️  n8n-app has restarted recently${NC}"
fi

echo -e "\n${GREEN}Diagnostics completed at: $(date)${NC}"