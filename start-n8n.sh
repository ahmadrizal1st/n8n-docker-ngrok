#!/bin/bash
# n8n with Ngrok Startup Script
# This script handles the automatic startup of n8n and ngrok
# It configures the environment, starts services, and manages graceful shutdown

set -e  # Exit on error

# Default configuration values
N8N_PORT=${N8N_PORT:-5678}
NGROK_AUTH_TOKEN=${NGROK_AUTH_TOKEN:-}
NGROK_REGION=${NGROK_REGION:-us}
NGROK_DOMAIN=${NGROK_DOMAIN:-}
N8N_HOST=${N8N_HOST:-0.0.0.0}
NODE_ENV=${NODE_ENV:-production}

# Logging function with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if port is available
check_port() {
    netstat -tuln | grep -q ":$1 "
    return $?
}

# Wait for n8n to be ready
wait_for_n8n() {
    log "Waiting for n8n to start on port $N8N_PORT..."
    local max_retries=30
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if check_port $N8N_PORT; then
            log "n8n is ready and listening on port $N8N_PORT"
            return 0
        fi
        retry_count=$((retry_count + 1))
        sleep 2
    done
    
    log "Error: n8n failed to start within timeout period"
    return 1
}

# Function to get ngrok public URL from API
get_ngrok_url() {
    local max_retries=15
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        local response=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null || true)
        local public_url=$(echo "$response" | jq -r '.tunnels[] | select(.proto=="https") | .public_url' 2>/dev/null || true)
        
        if [ ! -z "$public_url" ] && [ "$public_url" != "null" ]; then
            echo "$public_url"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        sleep 2
    done
    
    echo "null"
    return 1
}

# Update n8n configuration with correct WEBHOOK_URL
update_n8n_config() {
    local webhook_url="$1"
    local config_file="/home/node/.n8n/config"
    
    log "Updating n8n WEBHOOK_URL to: $webhook_url"
    
    # Update environment variables for current process
    export WEBHOOK_URL="$webhook_url"
    export N8N_WEBHOOK_URL="$webhook_url"
    
    # Update config file for persistence
    if [ -f "$config_file" ]; then
        # Create backup of original config
        cp "$config_file" "$config_file.backup.$(date +%s)"
        
        # Update or add webhook URL configuration
        if grep -q "webhookUrl" "$config_file"; then
            sed -i "s|webhookUrl.*|webhookUrl: \"$webhook_url\"|g" "$config_file"
        else
            echo "webhookUrl: \"$webhook_url\"" >> "$config_file"
        fi
        log "n8n configuration updated successfully"
    else
        log "Warning: n8n config file not found at $config_file"
    fi
}

# Graceful shutdown handler
cleanup() {
    log "Received shutdown signal. Performing graceful shutdown..."
    
    # Stop n8n process
    pkill -f "n8n start" 2>/dev/null || true
    
    # Stop ngrok process if running
    pkill -f "ngrok" 2>/dev/null || true
    
    log "Shutdown complete. Goodbye!"
    exit 0
}

# Set trap for graceful shutdown
trap cleanup SIGINT SIGTERM

# Main execution starts here
log "Starting n8n with Ngrok integration..."
log "Environment: $NODE_ENV"
log "n8n Port: $N8N_PORT"

# Start n8n in background
log "Starting n8n process..."
n8n start --host="$N8N_HOST" --port="$N8N_PORT" --tunnel=false &

# Wait for n8n to start
if ! wait_for_n8n; then
    log "Critical: n8n failed to start. Exiting..."
    exit 1
fi

# Ngrok setup and configuration
if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
    log "Configuring ngrok with provided auth token..."
    
    # Configure ngrok auth token
    if /usr/local/bin/ngrok config add-authtoken "$NGROK_AUTH_TOKEN" > /dev/null 2>&1; then
        log "Ngrok auth token configured successfully"
    else
        log "Error: Failed to configure ngrok auth token. Please check your token."
        log "Continuing without ngrok tunnel..."
        NGROK_AUTH_TOKEN=""
    fi
    
    if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
        # Build ngrok command with options
        NGROK_CMD="/usr/local/bin/ngrok http --region=\"$NGROK_REGION\" --log=stdout"
        
        # Add custom domain if provided (requires paid plan)
        if [ ! -z "$NGROK_DOMAIN" ]; then
            log "Using custom domain: $NGROK_DOMAIN"
            NGROK_CMD="$NGROK_CMD --domain=$NGROK_DOMAIN"
        fi
        
        NGROK_CMD="$NGROK_CMD $N8N_PORT"
        
        # Start ngrok tunnel
        log "Starting ngrok tunnel..."
        eval $NGROK_CMD &
        
        # Wait for ngrok to initialize and get public URL
        log "Waiting for ngrok tunnel to become active..."
        sleep 5
        
        PUBLIC_URL=$(get_ngrok_url)
        
        if [ "$PUBLIC_URL" != "null" ] && [ ! -z "$PUBLIC_URL" ]; then
            log "=================================================="
            log "🎉 n8n Public URL: $PUBLIC_URL"
            log "📊 Ngrok Dashboard: http://localhost:4040"
            log "🔧 Local Access: http://localhost:$N8N_PORT"
            log "=================================================="
            
            # Update n8n configuration with the public URL
            update_n8n_config "$PUBLIC_URL"
            
        else
            log "Warning: Could not obtain ngrok public URL. Please check ngrok status at http://localhost:4040"
            log "n8n is available internally at: http://localhost:$N8N_PORT"
        fi
    fi
else
    log "NGROK_AUTH_TOKEN not provided. Starting n8n without ngrok tunnel."
    log "n8n is available at: http://localhost:$N8N_PORT"
fi

# Main monitoring loop
log "All services are running. Entering monitoring mode..."
while true; do
    # Check if n8n process is still running
    if ! pgrep -f "n8n start" > /dev/null; then
        log "Error: n8n process has stopped unexpectedly"
        exit 1
    fi
    
    # Check ngrok process if token was provided
    if [ ! -z "$NGROK_AUTH_TOKEN" ]; then
        if ! pgrep -f "ngrok" > /dev/null; then
            log "Warning: ngrok process has stopped"
        fi
    fi
    
    # Sleep before next check
    sleep 10
done