# n8n with Ngrok Docker - Makefile
# This file provides convenient commands for managing the n8n with ngrok setup

.PHONY: help build up down logs clean backup restore status dev prod

# Default target
help:
	@echo "n8n with Ngrok Docker - Management Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build     Build the Docker image"
	@echo "  up        Start services in detached mode"
	@echo "  down      Stop and remove services"
	@echo "  logs      View service logs"
	@echo "  clean     Remove all containers, volumes, and networks"
	@echo "  backup    Backup n8n data"
	@echo "  restore   Restore n8n data from backup"
	@echo "  status    Show service status"
	@echo "  dev       Start development environment"
	@echo "  prod      Start production environment"
	@echo "  shell     Open shell in running container"
	@echo "  update    Update to latest n8n version"

# Build the Docker image
build:
	@echo "Building n8n with ngrok Docker image..."
	docker-compose build

# Start services in detached mode
up:
	@echo "Starting n8n with ngrok services..."
	docker-compose up -d

# Stop services
down:
	@echo "Stopping n8n with ngrok services..."
	docker-compose down

# View service logs
logs:
	@echo "Showing service logs (follow mode)..."
	docker-compose logs -f

# Clean up everything (containers, volumes, networks)
clean:
	@echo "Cleaning up all Docker resources..."
	docker-compose down -v --rmi local --remove-orphans

# Backup n8n data
backup:
	@echo "Backing up n8n data..."
	chmod +x backup.sh
	./backup.sh

# Restore n8n data from backup
restore:
	@echo "Restoring n8n data..."
	@if [ -z "$(file)" ]; then \
		echo "Usage: make restore file=path/to/backup.tar.gz"; \
		exit 1; \
	fi
	chmod +x restore.sh
	./restore.sh $(file)

# Show service status
status:
	@echo "Service status:"
	docker-compose ps

# Start development environment
dev:
	@echo "Starting development environment..."
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up

# Start production environment
prod:
	@echo "Starting production environment..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Open shell in running container
shell:
	@echo "Opening shell in n8n container..."
	docker-compose exec n8n-ngrok /bin/bash

# Update to latest n8n version
update:
	@echo "Updating to latest n8n version..."
	docker-compose build --no-cache
	docker-compose down
	docker-compose up -d
	@echo "Update complete. Don't forget to backup before updating!"

# Check for updates
check-update:
	@echo "Checking for n8n updates..."
	@docker run --rm n8nio/n8n:latest n8n --version | head -1

# View container statistics
stats:
	@echo "Container statistics:"
	docker stats $$(docker-compose ps -q)