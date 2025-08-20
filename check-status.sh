#!/bin/bash

echo "=== DOCKER STATUS ==="
docker ps -a
echo ""

echo "=== DOCKER COMPOSE STATUS ==="
docker-compose ps
echo ""

echo "=== N8N CONTAINER INFO ==="
docker inspect n8n-app --format 'Status: {{.State.Status}}, ExitCode: {{.State.ExitCode}}, Running: {{.State.Running}}'
echo ""

echo "=== NGROK CONTAINER INFO ==="
docker inspect n8n-ngrok --format 'Status: {{.State.Status}}, ExitCode: {{.State.ExitCode}}, Running: {{.State.Running}}'
echo ""

echo "=== N8N LOGS (LAST 20 LINES) ==="
docker logs n8n-app --tail 20 2>&1
echo ""

echo "=== NGROK LOGS (LAST 20 LINES) ==="
docker logs n8n-ngrok --tail 20 2>&1
echo ""

echo "=== DOCKER VOLUMES ==="
docker volume ls
echo ""

echo "=== NETWORK INFO ==="
docker network inspect n8n-network 2>/dev/null || echo "Network n8n-network not found"