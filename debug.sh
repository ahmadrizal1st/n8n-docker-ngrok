#!/bin/bash

# Debug script
echo "=== Docker Container Status ==="
docker ps -a

echo "=== Docker Compose Status ==="
docker-compose ps

echo "=== n8n Logs (last 20 lines) ==="
docker logs n8n-app --tail 20 2>&1

echo "=== ngrok Logs (last 20 lines) ==="
docker logs n8n-ngrok --tail 20 2>&1

echo "=== Checking ngrok API ==="
docker exec n8n-ngrok curl -s localhost:4040/api/tunnels || echo "Ngrok API not available"

echo "=== Checking n8n Health ==="
curl -s http://localhost:5678/healthz || echo "n8n health check failed"