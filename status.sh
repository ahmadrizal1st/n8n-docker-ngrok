#!/bin/bash

# =============================================================================
# N8N DOCKER DIAGNOSTICS SCRIPT
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Header function
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                          ║"
    echo "║                  🐳 N8N DOCKER DIAGNOSTICS SUITE                         ║"
    echo "║                     Comprehensive Status Report                          ║"
    echo "║                                                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Section separator
print_section() {
    echo -e "\n${BLUE}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${CYAN}🤖 $1${NC} ${BLUE}│${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────────────────────┘${NC}"
}

# Subsection
print_subsection() {
    echo -e "\n${YELLOW}├── ${1}${NC}"
}

# Status indicators
status_ok() {
    echo -e "${GREEN}✅ [OK] $1${NC}"
}

status_error() {
    echo -e "${RED}❌ [ERROR] $1${NC}"
}

status_warning() {
    echo -e "${YELLOW}⚠️  [WARNING] $1${NC}"
}

status_info() {
    echo -e "${CYAN}ℹ️  [INFO] $1${NC}"
}

# Check command existence
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓ $1 found${NC}"
        return 0
    else
        echo -e "${RED}✗ $1 not found${NC}"
        return 1
    fi
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
echo -e "${WHITE}🖥️  System: $(uname -srm)${NC}"
echo -e "${WHITE}🕐 Time: $(date)${NC}"
echo -e "${WHITE}👤 User: $(whoami)${NC}"
print_divider

# Check prerequisites
print_section "PREREQUISITE CHECKS"
progress "Checking Docker installation"
check_command "docker"
check_command "docker-compose" || check_command "docker compose"

progress "Checking Docker daemon status"
if ! docker info >/dev/null 2>&1; then
    status_error "Docker daemon is not running. Please start Docker first."
    exit 1
else
    status_ok "Docker daemon is running"
fi

# =============================================================================
# DOCKER STATUS
# =============================================================================
print_section "DOCKER CONTAINER STATUS"
progress "Fetching container status"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}\t{{.State}}"

# =============================================================================
# DOCKER COMPOSE STATUS
# =============================================================================
print_section "DOCKER COMPOSE STATUS"
progress "Checking compose status"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

# =============================================================================
# CONTAINER DETAILED INFO
# =============================================================================
print_section "CONTAINER DETAILED INFORMATION"

# N8N Container Info
print_subsection "N8N CONTAINER DETAILS"
if docker inspect n8n-app &>/dev/null; then
    docker inspect n8n-app --format '
📦 Container: {{.Name}}
🔄 Status: {{.State.Status}}
🔢 Exit Code: {{.State.ExitCode}}
🏃 Running: {{.State.Running}}
⏰ Started: {{.State.StartedAt}}
⏹️  Finished: {{.State.FinishedAt}}
🔄 Restart Count: {{.RestartCount}}
🌐 IP Address: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}
📊 Image: {{.Config.Image}}'
else
    status_error "n8n-app container not found"
fi

echo ""

# Ngrok Container Info
print_subsection "NGROK CONTAINER DETAILS"
if docker inspect n8n-ngrok &>/dev/null; then
    docker inspect n8n-ngrok --format '
📦 Container: {{.Name}}
🔄 Status: {{.State.Status}}
🔢 Exit Code: {{.State.ExitCode}}
🏃 Running: {{.State.Running}}
⏰ Started: {{.State.StartedAt}}
⏹️  Finished: {{.State.FinishedAt}}
🔄 Restart Count: {{.RestartCount}}
🌐 IP Address: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}
📊 Image: {{.Config.Image}}'
else
    status_warning "n8n-ngrok container not found"
fi

# =============================================================================
# LOGS INSPECTION
# =============================================================================
print_section "LOGS INSPECTION"

# N8N Logs
print_subsection "N8N LOGS (LAST 20 LINES)"
if docker ps -a | grep -q "n8n-app"; then
    progress "Fetching n8n logs"
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
    status_warning "n8n-app container not available for logs"
fi

echo ""

# Ngrok Logs
print_subsection "NGROK LOGS (LAST 20 LINES)"
if docker ps -a | grep -q "n8n-ngrok"; then
    progress "Fetching ngrok logs"
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
    status_warning "n8n-ngrok container not available for logs"
fi

# =============================================================================
# STORAGE & NETWORKING
# =============================================================================
print_section "STORAGE & NETWORKING"

# Docker Volumes
print_subsection "DOCKER VOLUMES"
progress "Checking volumes"
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}\t{{.Mountpoint}}"

echo ""

# Network Info
print_subsection "NETWORK INFORMATION"
if docker network inspect n8n-network &>/dev/null; then
    progress "Inspecting network"
    docker network inspect n8n-network --format '
🌐 Name: {{.Name}}
🔖 ID: {{.Id}}
🛠️  Driver: {{.Driver}}
📋 Scope: {{.Scope}}
🔒 Internal: {{.Internal}}
IPv6: {{.EnableIPv6}}
📡 Containers: {{range $key, $value := .Containers}}
   • {{$key}} ({{$value.IPv4Address}}){{end}}'
else
    status_warning "Network n8n-network not found"
fi

# =============================================================================
# RESOURCE USAGE
# =============================================================================
print_section "RESOURCE USAGE"
progress "Checking resource consumption"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" | head -n 6

# =============================================================================
# SUMMARY & RECOMMENDATIONS
# =============================================================================
print_section "DIAGNOSTICS SUMMARY"

# Check if containers are running
print_subsection "CONTAINER STATUS SUMMARY"
if docker ps | grep -q "n8n-app"; then
    status_ok "n8n-app is running"
else
    status_error "n8n-app is NOT running"
fi

if docker ps | grep -q "n8n-ngrok"; then
    status_ok "n8n-ngrok is running"
else
    status_error "n8n-ngrok is NOT running"
fi

# Final recommendations
print_subsection "RECOMMENDATIONS"
if ! docker ps | grep -q "n8n-app"; then
    echo -e "${CYAN}• Start n8n: docker-compose up -d n8n-app${NC}"
fi
if ! docker ps | grep -q "n8n-ngrok"; then
    echo -e "${CYAN}• Start ngrok: docker-compose up -d n8n-ngrok${NC}"
fi
if docker ps | grep -q "n8n-app" && docker ps | grep -q "n8n-ngrok"; then
    echo -e "${GREEN}• All services are running properly!${NC}"
fi

# Check for recent restarts
print_subsection "HEALTH CHECKS"
if docker inspect n8n-app --format='{{.RestartCount}}' | grep -q "[1-9]"; then
    status_warning "n8n-app has been restarted recently"
fi
if docker inspect n8n-ngrok --format='{{.RestartCount}}' | grep -q "[1-9]"; then
    status_warning "n8n-ngrok has been restarted recently"
fi

print_divider
echo -e "${GREEN}🚀 Diagnostics completed at: $(date)${NC}"
echo -e "${GREEN}📊 Report generated successfully!${NC}"
print_divider