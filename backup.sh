#!/bin/bash
# n8n Data Backup Script
# This script creates a backup of the n8n Docker volume data

set -e  # Exit on error

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.tar.gz"
CONTAINER_NAME="n8n-with-ngrok"
VOLUME_NAME="n8n_data_volume"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

log "Starting n8n data backup process..."
log "Backup file: $BACKUP_FILE"

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    log "Stopping n8n container temporarily..."
    docker stop "$CONTAINER_NAME"
    CONTAINER_STOPPED=true
else
    log "n8n container is not running, continuing with backup..."
    CONTAINER_STOPPED=false
fi

# Create backup using temporary container
log "Creating backup of volume data..."
docker run --rm \
  -v "$VOLUME_NAME:/source" \
  -v "$(pwd)/$BACKUP_DIR:/backup" \
  alpine \
  tar czf "/backup/n8n_backup_$TIMESTAMP.tar.gz" -C /source ./

# Restart container if it was stopped
if [ "$CONTAINER_STOPPED" = true ]; then
    log "Restarting n8n container..."
    docker start "$CONTAINER_NAME"
fi

# Verify backup was created
if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Backup completed successfully!"
    log "Backup size: $BACKUP_SIZE"
    log "Backup location: $BACKUP_FILE"
    
    # Clean up old backups (keep last 7)
    log "Cleaning up old backups (keeping last 7)..."
    ls -t "$BACKUP_DIR"/n8n_backup_*.tar.gz | tail -n +8 | xargs rm -f --
else
    log "Error: Backup file was not created successfully"
    exit 1
fi

log "Backup process completed successfully!"