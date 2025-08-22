#!/bin/bash

# TUNN8N - Docker Tunnel Manager
# Simplified version

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
INFO="ℹ"

print_success() {
    echo -e "${GREEN}${CHECK} ${1}${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} ${1}${NC}"
}

print_info() {
    echo -e "${CYAN}${INFO} ${1}${NC}"
}

load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
        print_success "Environment variables loaded"
    else
        print_info "Creating default .env file"
        cat > .env << EOF
NGROK_AUTH_TOKEN=your_ngrok_auth_token_here
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
EOF
        print_info "Please update .env with your values"
    fi
}

check_containers() {
    local count=$(docker ps -a --filter "name=n8n" --format "{{.Names}}" | wc -l)
    [ "$count" -gt 0 ] && return 0 || return 1
}

deploy_services() {
    if check_containers; then
        print_info "Starting existing containers"
        docker-compose up -d
    else
        print_info "Building new containers"
        docker-compose up -d --build
    fi
}

get_ngrok_url() {
    local url=$(docker logs n8n-ngrok 2>&1 | grep -oE "url=https://[a-zA-Z0-9.-]+\.ngrok-free\.app" | head -1 | sed 's/url=//')
    
    if [ -z "$url" ]; then
        url=$(docker logs n8n-ngrok 2>&1 | grep -oE 'https://[a-zA-Z0-9.-]+\.ngrok\.io' | head -1)
    fi
    
    if [ -n "$url" ]; then
        echo "$url" > ngrok_url.txt
        print_success "Tunnel URL: $url"
    else
        print_error "Could not retrieve tunnel URL"
    fi
}

main() {
    # Header
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║           TUNN8N DEPLOYMENT              ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"

    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Docker is running${NC}"
    fi

    load_env
    
    if deploy_services; then
        print_info "Waiting for services to start..."
        sleep 10
        
        # Container status
        echo -e "\n${BLUE}CONTAINER STATUS:${NC}"
        docker ps --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        get_ngrok_url
        
        # Summary
        echo -e "\n${BLUE}SUMMARY:${NC}"
        if docker ps | grep -q "n8n-app"; then
            echo -e "${GREEN}✅ n8n-app is running${NC}"
        else
            echo -e "${RED}❌ n8n-app is NOT running${NC}"
        fi
        
        echo
        print_success "Deployment completed!"
        echo -e "${CYAN}Local:  http://localhost:5678${NC}"
        echo -e "${CYAN}Tunnel: $(cat ngrok_url.txt 2>/dev/null || echo 'Check logs')${NC}"
        
        echo -e "\n${GREEN}Deployment completed at: $(date)${NC}"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

main "$@"