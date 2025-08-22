# Tunn8n - N8N + Ngrok Docker Starter

A complete CLI tool to create and manage n8n (workflow automation) with Docker and expose it to the internet using Ngrok with custom domain support.

## 🚀 Features

- ✅ **Easy CLI Setup** - Create new projects with one command
- ✅ **n8n latest version** with Docker Compose
- ✅ **Ngrok integration** with custom domain support
- ✅ **Secure environment variables** handling
- ✅ **Health checks** and auto-restart
- ✅ **Persistent data storage**
- ✅ **Multi-platform support** (macOS, Windows, Linux)
- ✅ **Complete CLI interface** for easy management
- ✅ **Automatic script management** with proper permissions
- ✅ **Environment validation** and error checking
- ✅ **Fallback mechanisms** for robust operation

## 📦 Installation

### Method 1: Install via npm (Recommended)

```bash
# Install globally
npm install -g tunn8n@latest

# Verify installation
tunn8n --version
tunn8n -v
```

### Method 2: Manual Setup (if preferred)

```bash
# Clone the repository
git clone <your-repo-url>
cd tunn8n

# Install dependencies(optional)
npm install

# Link for local development
npm link
```

## 🚀 Quick Start

### 1. Create a New Project

```bash
# Create new n8n project
tunn8n create my-automation-project

# Navigate to project
cd my-automation-project
```

### 2. Initialize Environment

```bash
# Setup environment configuration
tunn8n init

# Edit .env file with your settings
nano .env  # or use your favorite editor
```

### 3. Configure Environment

Edit the `.env` file:

```env
# Ngrok Configuration
NGROK_AUTHTOKEN=your_ngrok_auth_token_here
NGROK_DOMAIN=your_custom_domain.ngrok-free.app  # Optional for paid plans

# n8n Configuration
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=your_ngrok_url
TZ=Asia/Jakarta

# Optional: Basic Auth (recommended)
# N8N_BASIC_AUTH_USER=admin
# N8N_BASIC_AUTH_PASSWORD=secure_password_here
```

**⚠️ IMPORTANT:** Get your Ngrok auth token from [Ngrok Dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)

### 4. Start Services

```bash
# Start n8n with Ngrok tunnel
tunn8n start
```

## 🛠️ CLI Commands

### Project Management

```bash
# Create new project
tunn8n create <project-name>

# Initialize environment (create .env from template)
tunn8n init

# Update to latest version
tunn8n update
```

### Service Control

```bash
# Start all services
tunn8n start

# Check service status
tunn8n status

# View debug information and logs
tunn8n debug

# Stop all services
tunn8n stop
```

### Information

```bash
# Show version
tunn8n --version

# Show help
tunn8n --help
```

## 📋 Prerequisites

### Required Software

- **Docker** - [Install Guide](https://docs.docker.com/get-docker/)
- **Docker Compose** - Usually included with Docker Desktop
- **Node.js** (v14+) - Only required for CLI tool

### Ngrok Setup

1. Create free account at [ngrok.com](https://ngrok.com/)
2. Get your auth token from [dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)
3. (Optional) Reserve custom domain for paid plans

## 🔧 Project Structure

```
my-automation-project/
├── scripts/               # Shell scripts for service management
│   ├── start.sh          # Start services script
│   ├── stop.sh           # Stop services script  
│   ├── status.sh         # Status monitoring script
│   └── debug.sh          # Debugging utilities
├── docker-compose.yml    # Docker compose configuration
├── .env                  # Environment variables (created by tunn8n init)
├── .env.example          # Environment template
├── .gitignore           # Git ignore rules
└── README.md            # Project documentation
```

## 🌐 Access Points

After starting services:

- **Local n8n Access**: http://localhost:5678
- **Remote Access**: Your Ngrok URL (shown in logs)
- **Ngrok Dashboard**: http://localhost:4040

## 📊 Monitoring

### Check Service Status

```bash
tunn8n status

# Or manually
docker-compose ps
docker stats
```

### View Logs

```bash
tunn8n debug

# Or follow specific logs
docker-compose logs -f n8n-app
docker-compose logs -f n8n-ngrok
```

## 🛑 Stopping Services

### Graceful Shutdown

```bash
# Using CLI
tunn8n stop

# Using Docker directly
docker-compose down
```

### Complete Cleanup

```bash
# Remove everything (including volumes)
docker-compose down -v

# Clean Docker system
docker system prune -f
```

## 🔍 Troubleshooting

### Common Issues

1. **Port 5678 already in use**
   
   ```bash
   # Change N8N_PORT in .env file
   N8N_PORT=5679
   ```
2. **Ngrok authentication errors**
   
   - Verify `NGROK_AUTHTOKEN` in `.env` file
   - Check token at [Ngrok Dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)
3. **Docker permission issues** (Linux)
   
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
4. **Script permission issues**
   
   ```bash
   # Grant execute permissions to scripts
   chmod +x scripts/*.sh
   ```

### Debug Commands

```bash
# Check Ngrok tunnel status
docker exec n8n-ngrok curl -s http://localhost:4040/api/tunnels | jq

# Test n8n health
curl http://localhost:5678/healthz

# View container logs
docker logs n8n-app --tail 50
```

## 🔒 Security Notes

1. **Never commit `.env` file** to version control
2. Use strong passwords for basic authentication
3. Regularly rotate Ngrok authentication tokens
4. Monitor access logs frequently
5. Consider VPN for production use

## 📞 Support

### Useful Links

- [n8n Documentation](https://docs.n8n.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Ngrok Documentation](https://ngrok.com/docs)
- [Docker Installation Guide](https://docs.docker.com/get-docker/)

### Getting Help

1. Check logs: `tunn8n debug`
2. Verify Ngrok token is correct
3. Ensure Docker is running
4. Check port availability
5. Validate environment variables: `tunn8n init` and check `.env` file

## 🎯 Example Usage

```bash
# Complete workflow example
tunn8n create my-n8n-project
cd my-n8n-project
tunn8n init

# Edit .env with your Ngrok token and settings
nano .env

tunn8n start
tunn8n status

# When done working
tunn8n stop
```

## 📝 License

MIT License - feel free to use this project for your automation needs!

---

**Happy Automating!** 🚀

*For issues and contributions, please check the project repository.*

## 🔄 Changelog

### Version 1.3.7

- **Enhanced CLI** with better error handling and fallback mechanisms
- **Automatic script permissions** management
- **Environment validation** with helpful warnings
- **Improved project structure** with dedicated scripts directory
- **Better Docker compatibility** checks
- **Template-based .env initialization**
- **Comprehensive .gitignore** for security

### Key Improvements

- ✅ Automatic script permission setting (chmod 755)
- ✅ Environment variable validation with warnings
- ✅ Fallback to direct docker commands if scripts fail
- ✅ Better error messages and user guidance
- ✅ Template-based project creation with proper structure
- ✅ Enhanced security with comprehensive .gitignore

---

*Note: This tool automatically handles script permissions and provides fallback mechanisms for robust operation across different environments.*

