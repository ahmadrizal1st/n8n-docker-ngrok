#!/bin/bash

# TUNN8N - Docker Tunnel Manager
# Simplified version

# Define TUNN8N color palette
T8N_DARK_BLUE='\033[0;38;5;18m'
T8N_BLUE='\033[0;38;5;27m'
T8N_LIGHT_BLUE='\033[0;38;5;39m'
T8N_CYAN='\033[0;38;5;51m'
T8N_PURPLE='\033[0;38;5;129m'
T8N_PINK='\033[0;38;5;205m'
T8N_GREEN='\033[0;38;5;46m'
T8N_YELLOW='\033[0;38;5;226m'
T8N_ORANGE='\033[0;38;5;208m'
T8N_RED='\033[0;38;5;196m'
T8N_WHITE='\033[1;38;5;255m'
T8N_GRAY='\033[0;38;5;245m'
NC='\033[0m'

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
    load_env
    
    if deploy_services; then
        print_info "Waiting for services to start..."
        sleep 10
        
        print_info "Service status:"
        docker ps --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        get_ngrok_url
        
        echo
        print_success "Deployment completed!"
        echo -e "${CYAN}Local:  http://localhost:5678${NC}"
        echo -e "${CYAN}Tunnel: $(cat ngrok_url.txt 2>/dev/null || echo 'Check logs')${NC}"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

main "$@"