# N8N + Ngrok Starter Kit

A complete starter kit to run n8n (workflow automation tool) with Docker and expose it to the internet using Ngrok with custom domain.

## 🚀 Features

- ✅ n8n latest version with Docker
- ✅ Ngrok integration with custom domain
- ✅ Secure environment variables handling
- ✅ Health checks and auto-restart
- ✅ Persistent data storage
- ✅ Easy-to-use setup scripts
- ✅ Multi-platform support (macOS, Windows, Linux)

## 📋 Prerequisites

- Docker installed
- Docker Compose installed
- Ngrok account (free)
- Ngrok auth token
- Custom Ngrok domain (optional)

## 🛠️ Installation

### 1. Install Docker

**macOS:**

```bash
# Using Homebrew
brew install --cask docker

# Or download from: https://docs.docker.com/desktop/install/mac-install/
```

**Windows:**

- Download Docker Desktop from: https://docs.docker.com/desktop/install/windows-install/
- Enable WSL 2 if using Windows 10/11

**Linux (Ubuntu/Debian):**

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### 2. Install Ngrok (Optional - for local development)

**macOS:**

```bash
# Using Homebrew
brew install ngrok

# Or download from: https://ngrok.com/download
```

**Windows:**

- Download ngrok from: https://ngrok.com/download
- Extract and add to PATH or run from download directory

**Linux:**

```bash
# Using curl
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update
sudo apt install ngrok

# Alternative method
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/
```

### 3. Get Ngrok Auth Token

1. Sign up at https://ngrok.com/
2. Go to https://dashboard.ngrok.com/get-started/your-authtoken
3. Copy your authtoken

### 4. Setup Project

```bash
# Clone or download the project
git clone <your-repo-url>
cd n8n-ngrok-starter

# Create .env file from template
cp .env.example .env
```

## 🔧 Configuration

### Environment Setup

Edit the `.env` file:

```env
# ================================
# Ngrok Configuration
# ================================
# Your Ngrok authentication token (get it from https://dashboard.ngrok.com/get-started/your-authtoken)
NGROK_AUTHTOKEN=

# Optional: Set custom domain from Ngrok (only for paid plans)
NGROK_DOMAIN=

# ================================
# n8n Configuration
# ================================
# Public webhook URL (your ngrok URL will be something like: https://xxxx-xx-xx-xxx-xx.ngrok-free.app)
WEBHOOK_URL=xxxx-xx-xx-xxx-xx.ngrok-free.app

# Timezone setting (default: Asia/Jakarta)
TZ=Asia/Jakarta

# Optional: Enable Basic Auth for n8n (recommended for security)
# N8N_BASIC_AUTH_USER=admin
# N8N_BASIC_AUTH_PASSWORD=your_secure_password
```

**⚠️ IMPORTANT: NEVER commit `.env` file to version control!**

```bash
echo ".env" >> .gitignore
```

### Alternative: Export Variables Directly

If you prefer not to use `.env` file:

```bash
export NGROK_AUTHTOKEN=your_actual_ngrok_token_here
export NGROK_DOMAIN=quick-ant-officially.ngrok-free.app
```

## 🚀 How to Run

### Method 1: Using Setup Script (Recommended)

```bash
# Make scripts executable
chmod +x setup.sh start.sh debug.sh check-status.sh

# Run setup
./setup.sh
```

### Method 2: Using Docker Compose Directly

```bash
# With .env file
docker-compose up -d

# Or with exported variables
NGROK_AUTHTOKEN=your_token docker-compose up -d
```

### Method 3: Manual Setup

```bash
# Clean previous containers
docker-compose down

# Build and start
docker-compose up --build -d

# Follow logs
docker-compose logs -f
```

## 📊 Status Monitoring

### Check Container Status

```bash
# View all containers status
docker-compose ps

# View Docker processes
docker ps

# View detailed information
docker stats
```

### Monitor Logs

```bash
# Real-time logs
docker-compose logs -f

# n8n logs only
docker logs n8n-app -f --tail 50

# Ngrok logs only
docker logs n8n-ngrok -f --tail 50
```

### Check Ngrok Tunnel

```bash
# Check tunnel status
docker exec n8n-ngrok curl -s http://localhost:4040/api/tunnels | jq

# Get public URL
docker exec n8n-ngrok curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep 'https' | head -1
```

## ⚡ Quick Commands

### Start Services

```bash
docker-compose up -d
```

### Stop Services

```bash
docker-compose down
```

### Restart Services

```bash
docker-compose restart
```

### Force Rebuild

```bash
docker-compose up -d --build --force-recreate
```

### Clean Everything

```bash
docker-compose down -v
docker volume prune -f
docker system prune -f
```

## 🛑 How to Stop

### Graceful Shutdown

```bash
# Stop containers but keep data
docker-compose down

# Stop and remove volumes (data will be lost)
docker-compose down -v
```

### Emergency Stop

```bash
# Force stop all containers
docker stop n8n-app n8n-ngrok

# Remove containers
docker rm n8n-app n8n-ngrok
```

### Complete Cleanup

```bash
# Remove containers, volumes, networks
docker-compose down -v --rmi all

# Clean Docker system
docker system prune -af
docker volume prune -f
```

## 🔍 Troubleshooting

### Common Issues

1. **Port Already in Use**

   ```bash
   # Check processes using port
   lsof -i :5678

   # Alternative check
   netstat -tulpn | grep :5678
   ```
2. **Ngrok Authentication Error**

   ```bash
   # Verify token
   echo $NGROK_AUTHTOKEN

   # Test ngrok token
   docker run --rm -it -e NGROK_AUTHTOKEN=$NGROK_AUTHTOKEN ngrok/ngrok:latest version
   ```
3. **n8n Not Starting**

   ```bash
   # Debug n8n container
   docker logs n8n-app --tail 100

   # Execute into container
   docker exec -it n8n-app sh
   ```
4. **Permission Issues (Linux)**

   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   newgrp docker
   ```

### Debug Scripts

```bash
# Run debug script
./debug.sh

# Check detailed status
./check-status.sh

# Health check
curl http://localhost:5678/healthz
```

## 📁 Project Structure

```
n8n-ngrok-starter/
├── docker-compose.yml      # Docker compose configuration
├── .env.example           # Environment variables template
├── start.sh               # Start services script
├── debug.sh               # Debugging utilities
├── check-status.sh        # Status monitoring script
├── .gitignore            # Git ignore rules
├── .dockerignore             # Docker ignore rules
└── README.md             # This documentation
```

## 🌐 Access Points

- **n8n Local Access**: http://localhost:5678
- **n8n Remote Access**: https://quick-ant-officially.ngrok-free.app
- **Ngrok Dashboard**: http://localhost:4040 (when running locally)

## 🔒 Security Considerations

1. **NEVER** expose `.env` file publicly
2. Use strong passwords for basic authentication
3. Regularly rotate Ngrok authentication tokens
4. Monitor access logs frequently
5. Consider using VPN or private network for production
6. Enable HTTPS only in production environments

## 📞 Support & Resources

If you encounter issues:

1. **Check Logs**: `docker-compose logs`
2. **Verify Ngrok Token**: https://dashboard.ngrok.com/get-started/your-authtoken
3. **n8n Documentation**: https://docs.n8n.io/
4. **Docker Documentation**: https://docs.docker.com/
5. **Ngrok Documentation**: https://ngrok.com/docs

### Useful Links

- [n8n Official Documentation](https://docs.n8n.io/)
- [Docker Installation Guide](https://docs.docker.com/get-docker/)
- [Ngrok Dashboard](https://dashboard.ngrok.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/reference/)

## 🐛 Common Solutions

### Docker Daemon Not Running

```bash
# Start Docker daemon (macOS/Windows)
open -a Docker  # macOS
# Or start Docker Desktop application

# Linux (systemd)
sudo systemctl start docker
sudo systemctl enable docker
```

### Port Conflicts

Change the port in `docker-compose.yml`:

```yaml
ports:
  - "8080:5678"  # host_port:container_port
```

### Memory Issues

Increase Docker memory allocation in Docker Desktop settings (Preferences → Resources).

## 📝 License

MIT License - feel free to use this project for your automation needs!

---

**Happy Automating!** 🚀

*For additional help, create an issue in the project repository or check the troubleshooting section above.*
