#!/bin/bash

# Clean up first
echo "🧹 Cleaning up existing containers..."
docker-compose down -v
docker rm -f n8n-app n8n-ngrok 2>/dev/null

# Remove old volumes if any
docker volume prune -f

# Start fresh
echo "🚀 Starting n8n with ngrok..."
docker-compose up -d

echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

# Check status
echo "📊 Checking container status..."
docker ps -a

# Check n8n logs
echo "📝 n8n logs (last 15 lines):"
docker logs n8n-app --tail 15

# Check ngrok logs
echo "📝 ngrok logs (last 15 lines):"
docker logs n8n-ngrok --tail 15

# Try to get ngrok URL
echo "🌐 Attempting to get ngrok URL..."
NGROK_URL=$(docker exec n8n-ngrok curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*' | grep 'https' | sed 's/"public_url":"//' | head -1)

if [ -n "$NGROK_URL" ]; then
    echo "✅ SUCCESS! n8n is accessible at: $NGROK_URL"
    echo "✅ Webhook URL: $NGROK_URL/webhook/"
else
    echo "❌ Failed to get ngrok URL"
    echo "🔍 Debugging info:"
    
    # Check if containers are running
    echo "Container status:"
    docker inspect n8n-app --format '{{.State.Status}}'
    docker inspect n8n-ngrok --format '{{.State.Status}}'
    
    # Check exit codes
    echo "n8n exit code: $(docker inspect n8n-app --format '{{.State.ExitCode}}')"
    echo "ngrok exit code: $(docker inspect n8n-ngrok --format '{{.State.ExitCode}}')"
fi