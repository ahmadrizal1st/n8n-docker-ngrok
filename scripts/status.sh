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
echo "║         N8N DOCKER STATUS CHECK          ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker status
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Docker is running${NC}"
fi

echo -e "\n${BLUE}CONTAINER STATUS:${NC}"
docker ps -a --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n${BLUE}N8N LOGS (last 5 lines):${NC}"
if docker ps -a | grep -q "n8n"; then
    docker logs n8n --tail 5 2>&1
else
    echo -e "${YELLOW}⚠️  n8n container not found${NC}"
fi

echo -e "\n${BLUE}STATUS SUMMARY:${NC}"
if docker ps | grep -q "n8n"; then
    echo -e "${GREEN}✅ n8n container is running${NC}"
else
    echo -e "${RED}❌ n8n container is not running${NC}"
fi