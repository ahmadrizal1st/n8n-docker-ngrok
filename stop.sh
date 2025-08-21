#!/bin/bash

# stop.sh - Script to stop tunn8n Docker containers

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
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║                  🛑 TUNN8N SERVICE STOPPER                           ║"
    echo "║                    Graceful Shutdown Utility                         ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to print colored output
print_status() {
    echo -e "${CYAN}🔄 [STATUS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

# Progress indicator
progress() {
    echo -e "${CYAN}⏳ $1...${NC}"
}

# Divider
print_divider() {
    echo -e "${MAGENTA}────────────────────────────────────────────────────────────────────────────${NC}"
}

# Check if docker is running
check_docker() {
    progress "Checking Docker status"
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    print_success "Docker is running"
}

# Main stopping function
stop_containers() {
    print_divider
    progress "Stopping tunn8n services"
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found!"
        print_warning "Are you in the correct project directory?"
        exit 1
    fi

    # Stop containers using docker-compose
    progress "Stopping Docker containers"
    if docker-compose down; then
        print_success "Containers stopped successfully"
    else
        print_error "Failed to stop containers with docker-compose"
        print_warning "Trying alternative methods..."
        
        # Alternative method: stop containers by name pattern
        stop_containers_by_name
    fi
}

# Alternative method to stop containers by name pattern
stop_containers_by_name() {
    progress "Looking for tunn8n-related containers"
    
    # Find containers with tunn8n or n8n in the name
    local containers=$(docker ps -a --filter "name=tunn8n" --filter "name=n8n" --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        print_warning "No tunn8n containers found"
        return 0
    fi
    
    print_status "Found containers: $(echo $containers | tr '\n' ' ')"
    
    # Stop each container
    for container in $containers; do
        progress "Stopping container: $container"
        docker stop "$container" 2>/dev/null || true
        
        progress "Removing container: $container"
        docker rm -f "$container" 2>/dev/null || true
    done
    
    print_success "All tunn8n containers stopped and removed"
}

# Clean up network if needed
cleanup_network() {
    progress "Checking for unused networks"
    
    # Remove networks created by docker-compose (usually prefixed with directory name)
    local current_dir=$(basename "$PWD")
    local network_name="${current_dir}_default"
    
    if docker network inspect "$network_name" > /dev/null 2>&1; then
        progress "Removing network: $network_name"
        docker network rm "$network_name" 2>/dev/null || \
        print_warning "Could not remove network $network_name (may still be in use)"
    else
        print_status "No unused networks found"
    fi
}

# Check for any orphaned processes
check_orphaned_processes() {
    progress "Checking for orphaned processes"
    
    # Look for ngrok processes that might still be running
    local ngrok_pids=$(ps aux | grep -i ngrok | grep -v grep | awk '{print $2}')
    
    if [ -n "$ngrok_pids" ]; then
        print_warning "Found orphaned ngrok processes"
        echo -e "${YELLOW}Process IDs: $ngrok_pids${NC}"
        read -p "$(echo -e ${YELLOW}"Do you want to kill these processes? (y/N): "${NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$ngrok_pids" | xargs kill -9 2>/dev/null || true
            print_success "Orphaned processes terminated"
        else
            print_status "Leaving processes running"
        fi
    else
        print_success "No orphaned processes found"
    fi
}

# Final summary
print_summary() {
    print_divider
    echo -e "${GREEN}📋 SHUTDOWN SUMMARY:${NC}"
    echo -e "${CYAN}• Docker containers stopped and removed${NC}"
    echo -e "${CYAN}• Networks cleaned up${NC}"
    echo -e "${CYAN}• Orphaned processes checked${NC}"
    print_divider
    print_success "All services stopped successfully!"
    echo -e "${GREEN}🕒 Shutdown completed at: $(date)${NC}"
    print_divider
}

# Main execution
main() {
    print_header
    print_divider
    
    check_docker
    stop_containers
    cleanup_network
    check_orphaned_processes
    
    print_summary
}

# Run main function
main "$@"