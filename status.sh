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
NC='\033[0m' # No Color

# Header function
print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                   N8N DOCKER DIAGNOSTICS                          ║"
    echo "║                    COMPREHENSIVE STATUS                           ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Section separator
print_section() {
    echo -e "\n${MAGENTA}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}"
    echo -e "${BLUE}🤖 $1 ${NC}"
    echo -e "${MAGENTA}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}"
}

# Status indicators
status_ok() {
    echo -e "${GREEN}✅ $1${NC}"
}

status_error() {
    echo -e "${RED}❌ $1${NC}"
}

status_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

status_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
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

# Main execution
clear
print_header

# System info
echo -e "${WHITE}System: $(uname -srm)${NC}"
echo -e "${WHITE}Time: $(date)${NC}"
echo -e "${WHITE}User: $(whoami)${NC}"
echo ""

# Check prerequisites
print_section "PREREQUISITE CHECKS"
check_command "docker"
check_command "docker-compose" || check_command "docker compose"

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
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.RunningFor}}"

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
# CONTAINER DETAILED INFO
# =============================================================================
print_section "CONTAINER DETAILED INFORMATION"

# N8N Container Info
echo -e "${YELLOW}📦 N8N CONTAINER:${NC}"
if docker inspect n8n-app &>/dev/null; then
    docker inspect n8n-app --format '
Status:       {{.State.Status}}
Exit Code:    {{.State.ExitCode}}
Running:      {{.State.Running}}
Started:      {{.State.StartedAt}}
Finished:     {{.State.FinishedAt}}
Restart Count: {{.RestartCount}}
IP Address:   {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
else
    status_error "n8n-app container not found"
fi

echo ""

# Ngrok Container Info
echo -e "${YELLOW}🌐 NGROK CONTAINER:${NC}"
if docker inspect n8n-ngrok &>/dev/null; then
    docker inspect n8n-ngrok --format '
Status:       {{.State.Status}}
Exit Code:    {{.State.ExitCode}}
Running:      {{.State.Running}}
Started:      {{.State.StartedAt}}
Finished:     {{.State.FinishedAt}}
Restart Count: {{.RestartCount}}
IP Address:   {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
else
    status_error "n8n-ngrok container not found"
fi

# =============================================================================
# LOGS INSPECTION
# =============================================================================
print_section "LOGS INSPECTION"

# N8N Logs
echo -e "${YELLOW}📋 N8N LOGS (LAST 20 LINES):${NC}"
if docker ps -a | grep -q "n8n-app"; then
    docker logs n8n-app --tail 20 2>&1 | while read line; do
        if echo "$line" | grep -q -E "(error|fail|exception|warning)"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q -E "(start|ready|listen|connected)"; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${CYAN}$line${NC}"
        fi
    done
else
    status_warning "n8n-app container not available for logs"
fi

echo ""

# Ngrok Logs
echo -e "${YELLOW}📋 NGROK LOGS (LAST 20 LINES):${NC}"
if docker ps -a | grep -q "n8n-ngrok"; then
    docker logs n8n-ngrok --tail 20 2>&1 | while read line; do
        if echo "$line" | grep -q -E "(error|fail|disconnect|timeout)"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -q -E "(start|tunnel|online|connected)"; then
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
echo -e "${YELLOW}💾 DOCKER VOLUMES:${NC}"
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

echo ""

# Network Info
echo -e "${YELLOW}🌐 NETWORK INFORMATION:${NC}"
if docker network inspect n8n-network &>/dev/null; then
    docker network inspect n8n-network --format '
Name:        {{.Name}}
ID:          {{.Id}}
Driver:      {{.Driver}}
Scope:       {{.Scope}}
Internal:    {{.Internal}}
IPv6:        {{.EnableIPv6}}
Containers:  {{range $key, $value := .Containers}}{{$key}} ({{$value.IPv4Address}}), {{end}}'
else
    status_warning "Network n8n-network not found"
fi

# =============================================================================
# SUMMARY & RECOMMENDATIONS
# =============================================================================
print_section "DIAGNOSTICS SUMMARY"

# Check if containers are running
echo -e "${WHITE}Container Status Summary:${NC}"
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
echo ""
echo -e "${YELLOW}💡 RECOMMENDATIONS:${NC}"
if ! docker ps | grep -q "n8n-app"; then
    echo -e "${CYAN}• Start n8n: docker-compose up -d n8n-app${NC}"
fi
if ! docker ps | grep -q "n8n-ngrok"; then
    echo -e "${CYAN}• Start ngrok: docker-compose up -d n8n-ngrok${NC}"
fi
if docker ps | grep -q "n8n-app" && docker ps | grep -q "n8n-ngrok"; then
    echo -e "${GREEN}• All services are running properly!${NC}"
fi

echo -e "\n${GREEN}🚀 Diagnostics completed at: $(date)${NC}"