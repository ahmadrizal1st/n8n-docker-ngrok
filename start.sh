#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Symbols
CHECK="✅"
CROSS="❌"
WARNING="⚠️ "
INFO="ℹ️ "
ROCKET="🚀"
WRENCH="🔧"
MAGNIFYING_GLASS="🔍"
CLIPBOARD="📋"
GLOBE="🌐"
HOURGLASS="⏳"
NOTE="📝"
BAR="▬"
BAR_LENGTH=50

# Print TUNN8N header
print_header() {
    echo -e "${MAGENTA}"
    echo "  ████████╗██╗   ██╗███╗   ██╗███╗   ██╗██████╗ "
    echo "  ╚══██╔══╝██║   ██║████╗  ██║████╗  ██║██╔══██╗"
    echo "     ██║   ██║   ██║██╔██╗ ██║██╔██╗ ██║██╔══██╗"
    echo "     ██║   ██║   ██║██║╚██╗██║██║╚██╗██║██║  ██║"
    echo "     ██║   ╚██████╔╝██║ ╚████║██║ ╚████║██████╔╝"
    echo "     ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚═════╝ "
    echo -e "${NC}"
    echo -e "${CYAN}         Docker Tunnel Manager${NC}"
    echo -e "${MAGENTA}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${NC}"
    echo ""
}

# Print section header
print_section() {
    echo -e "\n${BLUE}${1}${NC}"
    echo -e "${CYAN}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}${CHECK} ${1}${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}${CROSS} ${1}${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}${WARNING} ${1}${NC}"
}

# Print info message
print_info() {
    echo -e "${CYAN}${INFO} ${1}${NC}"
}

# Print TUNN8N progress with spinner
print_progress() {
    local pid=$1
    local text=$2
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    echo -e "${CYAN}${spin:0:1} ${text}...${NC}"
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %8 ))
        printf "\r${CYAN}${spin:$i:1} ${text}...${NC}"
        sleep 0.1
    done
    printf "\r${GREEN}${CHECK} ${text} completed${NC}\n"
}

# Load environment variables
load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
        print_success "Environment variables loaded from .env"
    else
        print_warning "No .env file found"
    fi
}

# Clean up containers
cleanup() {
    print_section "TUNN8N CLEANUP"
    echo -e "${CYAN}Removing existing containers and volumes...${NC}"
    
    docker-compose down -v 2>/dev/null &
    print_progress $! "Stopping TUNN8N services"
    
    docker rm -f n8n-app n8n-ngrok 2>/dev/null &
    print_progress $! "Removing containers"
    
    docker volume prune -f 2>/dev/null &
    print_progress $! "Pruning volumes"
}

# Start TUNN8N services
start_services() {
    local action=$1
    
    print_section "TUNN8N DEPLOYMENT"
    echo -e "${CYAN}Deployment strategy: ${action}${NC}"
    
    if [ "$action" = "build" ] || [ "$action" = "up --build" ]; then
        echo -e "${CYAN}Building TUNN8N images...${NC}"
        if docker-compose build; then
            print_success "TUNN8N images built successfully"
        else
            print_error "TUNN8N build failed"
            return 1
        fi
    fi
    
    echo -e "${CYAN}Launching TUNN8N services...${NC}"
    if docker-compose up -d; then
        print_success "TUNN8N services deployed successfully"
        return 0
    else
        print_error "TUNN8N deployment failed"
        return 1
    fi
}

# Wait for TUNN8N services
wait_for_services() {
    print_section "TUNN8N INITIALIZATION"
    echo -e "${CYAN}Initializing TUNN8N tunnel and services...${NC}"
    
    for i in $(seq 1 30); do
        printf "\r${HOURGLASS} TUNN8N initializing... [%2d/30 seconds]" $i
        sleep 1
    done
    echo -e "\r${CHECK} TUNN8N services should be operational now"
}

# Check TUNN8N container status - HANYA tampilkan container yang running
check_status() {
    print_section "TUNN8N STATUS REPORT"
    
    echo -e "${CYAN}Active Containers:${NC}"
    # Hanya tampilkan container yang sedang running
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | \
    while read line; do
        if [[ $line == *"n8n"* ]]; then
            if [[ $line == *"Up"* ]]; then
                echo -e "${GREEN}🚀 ${line}${NC}"
            else
                echo -e "${YELLOW}⚡ ${line}${NC}"
            fi
        else
            if [[ $line == *"Up"* ]]; then
                echo -e "${GREEN}${line}${NC}"
            else
                echo -e "${YELLOW}${line}${NC}"
            fi
        fi
    done
    
    # Cek jika ada container yang exited (hanya untuk info, tidak ditampilkan detail)
    local exited_count=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | grep -c "n8n")
    if [ "$exited_count" -gt 0 ]; then
        echo -e "${YELLOW}${WARNING} There are $exited_count exited containers (not shown)${NC}"
    fi
}

# Check TUNN8N logs
check_logs() {
    print_section "TUNN8N LOGS ANALYSIS"
    
    echo -e "${NOTE} ${CYAN}n8n core logs:${NC}"
    docker logs n8n-app --tail 8 2>&1 | while read line; do
        if [[ $line == *"error"* ]] || [[ $line == *"Error"* ]]; then
            echo -e "${RED}🔴 ${line}${NC}"
        elif [[ $line == *"warning"* ]] || [[ $line == *"Warning"* ]]; then
            echo -e "${YELLOW}🟡 ${line}${NC}"
        elif [[ $line == *"started"* ]] || [[ $line == *"ready"* ]]; then
            echo -e "${GREEN}🟢 ${line}${NC}"
        else
            echo -e "${WHITE}⚪ ${line}${NC}"
        fi
    done
    
    echo -e "\n${NOTE} ${CYAN}TUNN8N tunnel logs:${NC}"
    docker logs n8n-ngrok --tail 15 2>&1 | grep -E "(url=|Hostname|endpoint|https://|tunnel session|online at|started)" | while read line; do
        if [[ $line == *"https://"* ]]; then
            echo -e "${GREEN}🌐 ${line}${NC}"
        elif [[ $line == *"error"* ]]; then
            echo -e "${RED}🔴 ${line}${NC}"
        elif [[ $line == *"online"* ]] || [[ $line == *"started"* ]]; then
            echo -e "${GREEN}🟢 ${line}${NC}"
        else
            echo -e "${CYAN}🔵 ${line}${NC}"
        fi
    done
}

# Get TUNN8N tunnel URL
get_ngrok_url() {
    print_section "TUNN8N TUNNEL DISCOVERY"
    
    local NGROK_URL=""
    
    echo -e "${CYAN}Scanning for TUNN8N tunnel endpoints...${NC}"
    
    # Try multiple methods to get the URL
    NGROK_URL=$(docker logs n8n-ngrok 2>&1 | grep -oE "url=https://[a-zA-Z0-9.-]+\.ngrok-free\.app" | head -1 | sed 's/url=//')
    
    if [ -z "$NGROK_URL" ]; then
        NGROK_URL=$(docker logs n8n-ngrok 2>&1 | grep -oE 'https://[a-zA-Z0-9.-]+\.ngrok\.io' | head -1)
    fi
    
    if [ -z "$NGROK_URL" ]; then
        print_warning "Performing deep tunnel scan..."
        NGROK_URL=$(docker exec n8n-ngrok sh -c "if command -v curl >/dev/null 2>&1; then curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '\"public_url\":\"[^\"]*' | grep 'https' | sed 's/\"public_url\":\"//' | head -1; fi" 2>/dev/null)
    fi
    
    if [ -n "$NGROK_URL" ]; then
        echo -e "${GREEN}${CHECK} TUNN8N Tunnel Established:${NC}"
        echo -e "${MAGENTA}   ┌─────────────────────────────────────┐"
        echo -e "   │          ${WHITE}🌐 TUNN8N URL${MAGENTA}           │"
        echo -e "   │                                         │"
        echo -e "   │   ${CYAN}${NGROK_URL}${MAGENTA}   │"
        echo -e "   │                                         │"
        echo -e "   │   ${YELLOW}Webhook: ${NGROK_URL}/webhook/${MAGENTA}  │"
        echo -e "   └─────────────────────────────────────┘${NC}"
        
        echo "$NGROK_URL" > ngrok_url.txt
        echo -e "${CLIPBOARD} ${CYAN}Tunnel URL archived to ngrok_url.txt${NC}"
        
        return 0
    else
        print_warning "TUNN8N tunnel detection incomplete"
        echo -e "${MAGNIFYING_GLASS} ${CYAN}Manual inspection required:${NC}"
        echo -e "  ${WHITE}docker logs n8n-ngrok${NC}"
        echo -e "  ${WHITE}curl http://localhost:4040/api/tunnels${NC}"
        return 1
    fi
}

# Print TUNN8N footer with commands
print_footer() {
    print_section "TUNN8N COMMAND CENTER"
    
    echo -e "${CYAN}🔍 Monitor TUNN8N:${NC}"
    echo -e "  ${WHITE}docker logs n8n-app -f${NC}"
    echo -e "  ${WHITE}docker logs n8n-ngrok -f${NC}"
    
    echo -e "${CYAN}⚡ Control TUNN8N:${NC}"
    echo -e "  ${WHITE}docker-compose down          ${RED}Shutdown TUNN8N${NC}"
    echo -e "  ${WHITE}docker restart n8n-app       ${YELLOW}Restart core${NC}"
    echo -e "  ${WHITE}docker-compose restart       ${GREEN}Full restart${NC}"
    
    echo -e "${CYAN}🌐 Access Points:${NC}"
    echo -e "  ${WHITE}Local: http://localhost:5678 ${BLUE}(Direct)${NC}"
    echo -e "  ${WHITE}Tunnel: $(cat ngrok_url.txt 2>/dev/null || echo 'Check ngrok_url.txt') ${MAGENTA}(Remote)${NC}"
    
    echo -e "\n${MAGENTA}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${NC}"
    echo -e "${GREEN}${ROCKET} TUNN8N deployment sequence complete!${NC}"
    echo -e "${CYAN}   Your automation tunnel is now active${NC}"
    echo -e "${MAGENTA}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${NC}"
}

# Main TUNN8N execution
main() {
    print_header
    
    # Load environment variables
    load_env
    
    # Default to up -d if no argument provided
    ACTION="${1:-up -d}"
    
    # Clean up first
    cleanup
    
    # Start TUNN8N services
    if start_services "$ACTION"; then
        # Wait for services
        wait_for_services
        
        # Check status
        check_status
        
        # Check logs
        check_logs
        
        # Get tunnel URL
        get_ngrok_url
        
        # Print footer
        print_footer
    else
        print_error "TUNN8N deployment failed. System halted."
        echo -e "${RED}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${BAR}${NC}"
        exit 1
    fi
}

# Run TUNN8N
main "$@"