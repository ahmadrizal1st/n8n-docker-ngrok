#!/bin/bash

# TUNN8N - Docker Tunnel Manager
# Enhanced version with unique style and features

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

# TUNN8N Symbols
T8N_CHECK="✅"
T8N_CROSS="❌"
T8N_WARNING="⚠️ "
T8N_INFO="ℹ️ "
T8N_ROCKET="🚀"
T8N_WRENCH="🔧"
T8N_MAGNIFYING_GLASS="🔍"
T8N_CLIPBOARD="📋"
T8N_GLOBE="🌐"
T8N_HOURGLASS="⏳"
T8N_NOTE="📝"
T8N_LINK="🔗"
T8N_SHIELD="🛡️ "
T8N_GEAR="⚙️"
T8N_ZAP="⚡"
T8N_FIRE="🔥"

# TUNN8N Patterns
T8N_BAR_H="▬"
T8N_BAR_V="│"
T8N_CORNER_TL="╭"
T8N_CORNER_TR="╮"
T8N_CORNER_BL="╰"
T8N_CORNER_BR="╯"
T8N_LINE_H="─"
T8N_LINE_V="│"
T8N_ARROW_R="➤"
T8N_DIAMOND="◆"

# Animation sequences
T8N_SPINNER=("⣷" "⣯" "⣟" "⡿" "⢿" "⣻" "⣽" "⣾")
T8N_WAVES=("≋" "~" "≈" "∽")
T8N_PULSE=("◎" "◉" "◎" "○")

print_t8n_header() {
    clear
    echo -e "${T8N_DARK_BLUE}"
    # Baris 1 - T U N N 8 N
    echo -e "${BLUE}  ████████╗${WHITE}██╗   ██╗${BLUE}███╗   ██╗${CYAN}███╗   ██╗${PINK}  █████╗  ${CYAN}███╗   ██╗${NC}"
    
    # Baris 2 - T U N N 8 N
    echo -e "${BLUE}  ╚══██╔══╝${WHITE}██║   ██║${BLUE}████╗  ██║${CYAN}████╗  ██║${PINK} ██╔══██╗ ${CYAN}████╗  ██║${NC}"
    
    # Baris 3 - T U N N 8 N
    echo -e "${BLUE}     ██║   ${WHITE}██║   ██║${BLUE}██╔██╗ ██║${CYAN}██╔██╗ ██║${PINK}  █████║  ${CYAN}██╔██╗ ██║${NC}"
    
    # Baris 4 - T U N N 8 N
    echo -e "${BLUE}     ██║   ${WHITE}██║   ██║${BLUE}██║╚██╗██║${CYAN}██║╚██╗██║${PINK} ██║  ██║ ${CYAN}██║╚██╗██║${NC}"
    
    # Baris 5 - T U N N 8 N
    echo -e "${BLUE}     ██║   ${WHITE}╚██████╔╝${BLUE}██║ ╚████║${CYAN}██║ ╚████║${PINK} ╚█████╔╝ ${CYAN}██║ ╚████║${NC}"
    
    # Baris 6 - T U N N 8 N
    echo -e "${BLUE}     ╚═╝    ${WHITE}╚═════╝ ${BLUE}╚═╝  ╚═══╝${CYAN}╚═╝  ╚═══╝${PINK}  ╚════╝  ${CYAN}╚═╝  ╚═══╝${NC}"
    echo -e "${NC}"
    echo -e "${T8N_LIGHT_BLUE}${T8N_CORNER_TL}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_CORNER_TR}"
    echo -e "${T8N_LINE_V}    Docker Tunnel Management System    ${T8N_LINE_V}"
    echo -e "${T8N_CORNER_BL}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_CORNER_BR}"
    echo -e "${NC}"
}

# Print section header with TUNN8N style
print_t8n_section() {
    echo -e "\n${T8N_LIGHT_BLUE}${T8N_DIAMOND} ${1}${NC}"
    echo -e "${T8N_BLUE}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${NC}"
}

# Print success message
print_t8n_success() {
    echo -e "${T8N_GREEN}${T8N_CHECK} ${1}${NC}"
}

# Print error message
print_t8n_error() {
    echo -e "${T8N_RED}${T8N_CROSS} ${1}${NC}"
}

# Print warning message
print_t8n_warning() {
    echo -e "${T8N_YELLOW}${T8N_WARNING} ${1}${NC}"
}

# Print info message
print_t8n_info() {
    echo -e "${T8N_CYAN}${T8N_INFO} ${1}${NC}"
}

# Print TUNN8N progress with custom spinner
print_t8n_progress() {
    local pid=$1
    local text=$2
    local i=0
    
    echo -ne "${T8N_BLUE}${T8N_SPINNER[0]} ${text}...${NC}"
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % ${#T8N_SPINNER[@]} ))
        echo -ne "\r${T8N_BLUE}${T8N_SPINNER[$i]} ${text}...${NC}"
        sleep 0.1
    done
    
    echo -e "\r${T8N_GREEN}${T8N_CHECK} ${text} completed${NC}"
}

# Load environment variables with style
load_t8n_env() {
    print_t8n_section "ENVIRONMENT CONFIGURATION"
    
    if [ -f .env ]; then
        export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
        echo -e "${T8N_CYAN}${T8N_GEAR} Loading environment variables...${NC}"
        
        # Display key environment variables
        if [ -n "$NGROK_AUTH_TOKEN" ]; then
            echo -e "${T8N_GREEN}${T8N_SHIELD} NGROK Auth: Configured${NC}"
        else
            echo -e "${T8N_YELLOW}${T8N_WARNING} NGROK Auth: Not configured${NC}"
        fi
        
        print_t8n_success "Environment variables loaded from .env"
    else
        print_t8n_warning "No .env file found"
        echo -e "${T8N_CYAN}${T8N_INFO} Creating default .env file...${NC}"
        cat > .env << EOF
# TUNN8N Configuration
NGROK_AUTH_TOKEN=your_ngrok_auth_token_here
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
EOF
        print_t8n_info "Default .env file created. Please update with your values."
    fi
}

# Check if containers already exist with TUNN8N style
check_t8n_existing_containers() {
    print_t8n_section "CONTAINER DISCOVERY"
    
    local existing_count=$(docker ps -a --filter "name=n8n" --format "{{.Names}}" | wc -l)
    
    if [ "$existing_count" -gt 0 ]; then
        echo -e "${T8N_CYAN}${T8N_MAGNIFYING_GLASS} Found ${existing_count} TUNN8N container(s)${NC}"
        
        docker ps -a --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}" | while read line; do
            if [[ $line == *"Up"* ]]; then
                echo -e "${T8N_GREEN}${T8N_CHECK} ${line}${NC}"
            elif [[ $line == *"Exited"* ]]; then
                echo -e "${T8N_YELLOW}${T8N_WARNING} ${line}${NC}"
            else
                echo -e "${T8N_ORANGE}${T8N_INFO} ${line}${NC}"
            fi
        done
        return 0
    else
        echo -e "${T8N_BLUE}${T8N_INFO} No existing TUNN8N containers found${NC}"
        return 1
    fi
}

# Determine deployment strategy based on existing containers
determine_t8n_deployment_strategy() {
    if check_t8n_existing_containers; then
        print_t8n_info "Using existing containers - no build needed"
        echo "up -d"
    else
        print_t8n_info "No containers found - building new images"
        echo "up -d --build"
    fi
}

# Start TUNN8N services with visual feedback
start_t8n_services() {
    local action=$1
    
    print_t8n_section "SERVICE DEPLOYMENT"
    echo -e "${T8N_CYAN}${T8N_ROCKET} Deployment strategy: ${action}${NC}"
    
    if [ "$action" = "up -d --build" ]; then
        echo -e "${T8N_BLUE}${T8N_GEAR} Building TUNN8N images...${NC}"
        if docker-compose build; then
            print_t8n_success "TUNN8N images built successfully"
        else
            print_t8n_error "TUNN8N build failed"
            return 1
        fi
    fi
    
    echo -e "${T8N_BLUE}${T8N_ZAP} Launching TUNN8N services...${NC}"
    if docker-compose up -d; then
        print_t8n_success "TUNN8N services deployed successfully"
        return 0
    else
        print_t8n_error "TUNN8N deployment failed"
        return 1
    fi
}

# Wait for TUNN8N services with animation
wait_for_t8n_services() {
    print_t8n_section "SERVICE INITIALIZATION"
    echo -e "${T8N_CYAN}${T8N_HOURGLASS} Initializing TUNN8N tunnel and services...${NC}"
    
    for i in $(seq 1 30); do
        wave_idx=$(( (i-1) % ${#T8N_WAVES[@]} ))
        echo -ne "\r${T8N_BLUE}${T8N_WAVES[$wave_idx]} TUNN8N initializing... [${i}/30 seconds]${NC}"
        sleep 1
    done
    echo -e "\r${T8N_GREEN}${T8N_CHECK} TUNN8N services should be operational now${NC}"
}

# Check TUNN8N container status with enhanced display
check_t8n_status() {
    print_t8n_section "STATUS REPORT"
    
    echo -e "${T8N_CYAN}${T8N_SHIELD} Active Containers:${NC}"
    
    # Get running containers with custom format
    docker ps --format "${T8N_GREEN}${T8N_CHECK} {{.Names}} | {{.Status}} | {{.Ports}}${NC}" | \
    while read line; do
        if [[ $line == *"n8n"* ]]; then
            echo -e "  ${line}"
        else
            echo -e "  ${T8N_BLUE}${T8N_INFO} ${line}${NC}"
        fi
    done
    
    # Check for exited containers
    local exited_count=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | grep -c "n8n")
    if [ "$exited_count" -gt 0 ]; then
        echo -e "${T8N_YELLOW}${T8N_WARNING} There are ${exited_count} exited containers${NC}"
        docker ps -a --filter "status=exited" --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}" | \
        while read line; do
            echo -e "  ${T8N_YELLOW}${T8N_WARNING} ${line}${NC}"
        done
    fi
}

# Check TUNN8N logs with enhanced formatting
check_t8n_logs() {
    print_t8n_section "LOG ANALYSIS"
    
    echo -e "${T8N_NOTE} ${T8N_CYAN}n8n core logs:${NC}"
    docker logs n8n-app --tail 10 2>&1 | while read line; do
        if [[ $line == *"error"* ]] || [[ $line == *"Error"* ]]; then
            echo -e "${T8N_RED}${T8N_CROSS} ${line}${NC}"
        elif [[ $line == *"warning"* ]] || [[ $line == *"Warning"* ]]; then
            echo -e "${T8N_YELLOW}${T8N_WARNING} ${line}${NC}"
        elif [[ $line == *"started"* ]] || [[ $line == *"ready"* ]]; then
            echo -e "${T8N_GREEN}${T8N_CHECK} ${line}${NC}"
        elif [[ $line == *"listen"* ]]; then
            echo -e "${T8N_BLUE}${T8N_INFO} ${line}${NC}"
        else
            echo -e "${T8N_WHITE}  ${line}${NC}"
        fi
    done
    
    echo -e "\n${T8N_NOTE} ${T8N_CYAN}TUNN8N tunnel logs:${NC}"
    docker logs n8n-ngrok --tail 15 2>&1 | grep -E "(url=|Hostname|endpoint|https://|tunnel session|online at|started)" | while read line; do
        if [[ $line == *"https://"* ]]; then
            echo -e "${T8N_GREEN}${T8N_LINK} ${line}${NC}"
        elif [[ $line == *"error"* ]]; then
            echo -e "${T8N_RED}${T8N_CROSS} ${line}${NC}"
        elif [[ $line == *"online"* ]] || [[ $line == *"started"* ]]; then
            echo -e "${T8N_GREEN}${T8N_CHECK} ${line}${NC}"
        else
            echo -e "${T8N_CYAN}${T8N_INFO} ${line}${NC}"
        fi
    done
}

# Get TUNN8N tunnel URL with enhanced display
get_t8n_ngrok_url() {
    print_t8n_section "TUNNEL DISCOVERY"
    
    local NGROK_URL=""
    
    echo -e "${T8N_CYAN}${T8N_MAGNIFYING_GLASS} Scanning for TUNN8N tunnel endpoints...${NC}"
    
    # Try multiple methods to get the URL
    NGROK_URL=$(docker logs n8n-ngrok 2>&1 | grep -oE "url=https://[a-zA-Z0-9.-]+\.ngrok-free\.app" | head -1 | sed 's/url=//')
    
    if [ -z "$NGROK_URL" ]; then
        NGROK_URL=$(docker logs n8n-ngrok 2>&1 | grep -oE 'https://[a-zA-Z0-9.-]+\.ngrok\.io' | head -1)
    fi
    
    if [ -z "$NGROK_URL" ]; then
        print_t8n_warning "Performing deep tunnel scan..."
        NGROK_URL=$(docker exec n8n-ngrok sh -c "if command -v curl >/dev/null 2>&1; then curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '\"public_url\":\"[^\"]*' | grep 'https' | sed 's/\"public_url\":\"//' | head -1; fi" 2>/dev/null)
    fi
    
    if [ -n "$NGROK_URL" ]; then
        echo -e "${T8N_GREEN}${T8N_CHECK} TUNN8N Tunnel Established:${NC}"
        echo -e "${T8N_PURPLE}   ${T8N_CORNER_TL}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_CORNER_TR}"
        echo -e "   ${T8N_LINE_V}         ${T8N_GLOBE} TUNN8N URL         ${T8N_LINE_V}"
        echo -e "   ${T8N_LINE_V}                                     ${T8N_LINE_V}"
        echo -e "   ${T8N_LINE_V}   ${T8N_CYAN}${NGROK_URL}${T8N_PURPLE}   ${T8N_LINE_V}"
        echo -e "   ${T8N_LINE_V}                                     ${T8N_LINE_V}"
        echo -e "   ${T8N_LINE_V}   ${T8N_YELLOW}Webhook: ${NGROK_URL}/webhook/${T8N_PURPLE}  ${T8N_LINE_V}"
        echo -e "   ${T8N_CORNER_BL}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_LINE_H}${T8N_CORNER_BR}${NC}"
        
        echo "$NGROK_URL" > ngrok_url.txt
        echo -e "${T8N_CLIPBOARD} ${T8N_CYAN}Tunnel URL archived to ngrok_url.txt${NC}"
        
        return 0
    else
        print_t8n_warning "TUNN8N tunnel detection incomplete"
        echo -e "${T8N_MAGNIFYING_GLASS} ${T8N_CYAN}Manual inspection required:${NC}"
        echo -e "  ${T8N_WHITE}docker logs n8n-ngrok${NC}"
        echo -e "  ${T8N_WHITE}curl http://localhost:4040/api/tunnels${NC}"
        return 1
    fi
}

# Print TUNN8N footer with commands
print_t8n_footer() {
    print_t8n_section "COMMAND CENTER"
    
    echo -e "${T8N_CYAN}${T8N_MAGNIFYING_GLASS} Monitor TUNN8N:${NC}"
    echo -e "  ${T8N_WHITE}docker logs n8n-app -f${NC}"
    echo -e "  ${T8N_WHITE}docker logs n8n-ngrok -f${NC}"
    
    echo -e "${T8N_CYAN}${T8N_ZAP} Control TUNN8N:${NC}"
    echo -e "  ${T8N_WHITE}docker-compose down          ${T8N_RED}Shutdown TUNN8N${NC}"
    echo -e "  ${T8N_WHITE}docker restart n8n-app       ${T8N_YELLOW}Restart core${NC}"
    echo -e "  ${T8N_WHITE}docker-compose restart       ${T8N_GREEN}Full restart${NC}"
    
    echo -e "${T8N_CYAN}${T8N_GLOBE} Access Points:${NC}"
    echo -e "  ${T8N_WHITE}Local: http://localhost:5678 ${T8N_BLUE}(Direct)${NC}"
    echo -e "  ${T8N_WHITE}Tunnel: $(cat ngrok_url.txt 2>/dev/null || echo 'Check ngrok_url.txt') ${T8N_PURPLE}(Remote)${NC}"
    
    echo -e "\n${T8N_PURPLE}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${NC}"
    echo -e "${T8N_GREEN}${T8N_ROCKET} TUNN8N deployment sequence complete!${NC}"
    echo -e "${T8N_CYAN}   Your automation tunnel is now active${NC}"
    echo -e "${T8N_PURPLE}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${NC}"
}

# Main TUNN8N execution
t8n_main() {
    print_t8n_header
    
    # Load environment variables
    load_t8n_env
    
    # Determine deployment strategy based on existing containers
    DEPLOYMENT_STRATEGY=$(determine_t8n_deployment_strategy)
    
    # Start TUNN8N services
    if start_t8n_services "$DEPLOYMENT_STRATEGY"; then
        # Wait for services
        wait_for_t8n_services
        
        # Check status
        check_t8n_status
        
        # Check logs
        check_t8n_logs
        
        # Get tunnel URL
        get_t8n_ngrok_url
        
        # Print footer
        print_t8n_footer
    else
        print_t8n_error "TUNN8N deployment failed. System halted."
        echo -e "${T8N_RED}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${T8N_BAR_H}${NC}"
        exit 1
    fi
}

# Run TUNN8N
t8n_main "$@"
