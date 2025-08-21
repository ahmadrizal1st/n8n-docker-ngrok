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
ORANGE='\033[38;5;208m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Header function
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║                  🐳 N8N DOCKER STATUS CHECK                          ║"
    echo "║                    Quick Health Assessment                           ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Section separator
print_section() {
    echo -e "\n${BLUE}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}$1${NC} ${BLUE}│${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────────────────┘${NC}"
}

# Success message
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Error message
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Info message
info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Progress indicator
progress() {
    echo -e "${CYAN}⏳ $1...${NC}"
}

# Divider
print_divider() {
    echo -e "${MAGENTA}────────────────────────────────────────────────────────────────────────────${NC}"
}

# Main execution
print_header

# System info
echo -e "${YELLOW}🖥️  System:${NC} $(uname -srm)"
echo -e "${YELLOW}🕐 Time:${NC} $(date)"
echo -e "${YELLOW}👤 User:${NC} $(whoami)"
print_divider

# Check if Docker is running
progress "Checking Docker status"
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker first."
    exit 1
else
    success "Docker is running"
fi

# =============================================================================
# DOCKER CONTAINER STATUS
# =============================================================================
print_section "DOCKER CONTAINER STATUS"
progress "Fetching container information"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}"

# =============================================================================
# DOCKER COMPOSE STATUS
# =============================================================================
print_section "DOCKER COMPOSE STATUS"
progress "Checking compose services"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

# =============================================================================
# N8N LOGS
# =============================================================================
print_section "N8N APPLICATION LOGS"
progress "Checking application logs"
if docker ps -a | grep -q "n8n-app"; then
    echo -e "${YELLOW}📋 Last 20 lines:${NC}"
    docker logs n8n-app --tail 20 2>&1 | while read line; do
        if echo "$line" | grep -q -E "(error|fail|exception|warning|Error|Failed|Exception|Warning)"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q -E "(start|ready|listen|connected|Started|Ready|Listening|Connected)"; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${WHITE}$line${NC}"
        fi
    done
else
    warning "n8n-app container not found"
fi

# =============================================================================
# NGROK LOGS
# =============================================================================
print_section "NGROK LOGS"
progress "Checking ngrok logs"
if docker ps -a | grep -q "n8n-ngrok"; then
    echo -e "${YELLOW}📋 Last 20 lines:${NC}"
    docker logs n8n-ngrok --tail 20 2>&1 | while read line; do
        if echo "$line" | grep -q -E "(error|fail|disconnect|timeout|Error|Failed|Disconnect|Timeout)"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q -E "(start|tunnel|online|connected|Start|Tunnel|Online|Connected)"; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${CYAN}$line${NC}"
        fi
    done
else
    warning "n8n-ngrok container not found"
fi

# =============================================================================
# SYSTEM INFORMATION
# =============================================================================
print_section "SYSTEM INFORMATION"
echo -e "${YELLOW}📅 Timestamp:${NC} $(date)"
echo -e "${YELLOW}🏷️  Hostname:${NC} $(hostname)"
echo -e "${YELLOW}⏱️  Uptime:${NC} $(uptime -p | sed 's/up //')"

# Resource usage
progress "Checking resource usage"
echo -e "${YELLOW}💾 Memory:${NC} $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo -e "${YELLOW}📊 Disk:${NC} $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"

# =============================================================================
# FINAL STATUS CHECK
# =============================================================================
print_section "SERVICE STATUS SUMMARY"

# Check if n8n-app is running
if docker ps | grep -q "n8n-app"; then
    success "n8n-app container is running"
else
    error "n8n-app container is not running"
fi

# Check if n8n-ngrok is running
if docker ps | grep -q "n8n-ngrok"; then
    success "n8n-ngrok container is running"
else
    error "n8n-ngrok container is not running"
fi

# Check container health
print_divider
progress "Performing health checks"

if docker ps | grep -q "n8n-app" && docker ps | grep -q "n8n-ngrok"; then
    success "All essential services are operational"
    echo -e "${GREEN}🚀 N8N should be accessible and functioning properly${NC}"
elif docker ps | grep -q "n8n-app"; then
    warning "N8N is running but ngrok tunnel may not be available"
    echo -e "${YELLOW}⚠️  Check ngrok configuration if external access is needed${NC}"
else
    error "Critical services are not running"
    echo -e "${RED}❌ N8N is not available. Check your deployment.${NC}"
fi

print_divider
echo -e "${GREEN}✅ Status check completed at: $(date)${NC}"