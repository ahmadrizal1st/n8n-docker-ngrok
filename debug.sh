#!/bin/bash

# =============================================================================
# N8N DOCKER STATUS CHECK SCRIPT
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Header function
print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     N8N DOCKER STATUS                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Section separator
print_section() {
    echo -e "\n${MAGENTA}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${MAGENTA}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
}

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Error message
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Main execution
clear
print_header

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker first."
    exit 1
fi

# =============================================================================
# DOCKER CONTAINER STATUS
# =============================================================================
print_section "DOCKER CONTAINER STATUS"
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

# =============================================================================
# DOCKER COMPOSE STATUS
# =============================================================================
print_section "DOCKER COMPOSE STATUS"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

# =============================================================================
# N8N LOGS
# =============================================================================
print_section "N8N APPLICATION LOGS (LAST 20 LINES)"
if docker ps -a | grep -q "n8n-app"; then
    docker logs n8n-app --tail 20 2>&1
else
    warning "n8n-app container not found"
fi

# =============================================================================
# NGROK LOGS
# =============================================================================
print_section "NGROK LOGS (LAST 20 LINES)"
if docker ps -a | grep -q "n8n-ngrok"; then
    docker logs n8n-ngrok --tail 20 2>&1
else
    warning "n8n-ngrok container not found"
fi

# =============================================================================
# SYSTEM INFORMATION
# =============================================================================
print_section "SYSTEM INFORMATION"
echo -e "${YELLOW}Timestamp:${NC} $(date)"
echo -e "${YELLOW}Hostname:${NC} $(hostname)"
echo -e "${YELLOW}Uptime:${NC} $(uptime -p)"

# =============================================================================
# FINAL STATUS CHECK
# =============================================================================
print_section "FINAL STATUS CHECK"

# Check if n8n-app is running
if docker ps | grep -q "n8n-app"; then
    success "n8n-app is running"
else
    error "n8n-app is not running"
fi

# Check if n8n-ngrok is running
if docker ps | grep -q "n8n-ngrok"; then
    success "n8n-ngrok is running"
else
    error "n8n-ngrok is not running"
fi

echo -e "\n${GREEN}Status check completed!${NC}"