#!/bin/bash
# n8n Data Restore Script
# This script restores n8n data from a backup file

set -e  # Exit on error

# Configuration
CONTAINER_NAME="n8n-with-ngrok"
VOLUME_NAME="n8n_data_volume"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if backup file was provided
if [ -z "$1" ]; then
    log "Usage: $0 <backup_file.tar.gz>"
    log "Example: $0 backups/n8n_backup_20231201_120000.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"

# Validate backup file
if [ ! -f "$BACKUP_FILE" ]; then
    log "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check if file is a valid tar.gz archive
if ! tar tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    log "Error: Invalid backup file format. Must be a valid tar.gz archive."
    exit 1
fi

log "Starting n8n data restore process..."
log "Backup file: $BACKUP_FILE"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    log "Stopping n8n container..."
    docker stop "$CONTAINER_NAME"
    CONTAINER_STOPPED=true
else
    log "n8n container is not running, continuing with restore..."
    CONTAINER_STOPPED=false
fi

# Restore data using temporary container
log "Restoring data from backup..."
docker run --rm \
  -v "$VOLUME_NAME:/target" \
  -v "$(pwd):/backup" \
  alpine \
  sh -c "rm -rf /target/* && tar xzf \"/backup/$BACKUP_FILE\" -C /target --strip-components=1"

# Verify restore was successful
log "Verifying restore..."
if docker run --rm -v "$VOLUME_NAME:/verify" alpine ls -la /verify | grep -q "n8n"; then
    log "Restore verification successful!"
else
    log "Warning: Restore verification failed. The volume may be empty."
fi

# Restart container if it was stopped
if [ "$CONTAINER_STOPPED" = true ]; then
    log "Restarting n8n container..."
    docker start "$CONTAINER_NAME"
fi

log "Restore process completed successfully!"
log "Note: You may need to restart n8n for all changes to take effect."