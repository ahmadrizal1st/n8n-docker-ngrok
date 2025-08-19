# n8n with Ngrok Docker Setup

A complete Docker-based setup for running n8n (workflow automation) with Ngrok integration for secure public access.

## 📋 Features

- **n8n Workflow Automation**: Full n8n installation with persistent storage
- **Ngrok Integration**: Automatic tunnel creation with public URL
- **Production Ready**: Secure configuration with environment variables
- **Backup & Restore**: Automated data backup and restore scripts
- **Development Support**: Hot-reload and debugging capabilities
- **Health Monitoring**: Built-in health checks and monitoring

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Ngrok account ([sign up here](https://dashboard.ngrok.com/signup))
- Ngrok auth token from [dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)

### Installation

1. **Clone or download this project**

   ```bash
   git clone <your-repo>
   cd n8n-ngrok-docker
   ```
2. **Configure environment variables**

   ```bash
   cp .env.example .env
   nano .env  # Edit with your configuration
   ```
3. **Build and start services**

   ```bash
   make build
   make up
   ```
4. **Access your n8n instance**

   - Local: http://localhost:5678
   - Public URL: Check docker logs (`make logs`)
   - Ngrok Dashboard: http://localhost:4040

## 🛠️ Complete Implementation Guide

### Step 1: Project Setup

```bash
# Create project directory
mkdir n8n-ngrok-docker
cd n8n-ngrok-docker

# Create all necessary files from the documentation
# Copy each file content to corresponding files
```

### Step 2: Environment Configuration

```bash
# Create environment file from template
cp .env.example .env

# Generate secure encryption keys (REQUIRED for production)
openssl rand -base64 24 >> .env
echo "N8N_ENCRYPTION_KEY=$(openssl rand -base64 24)" >> .env
echo "N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 24)" >> .env

# Edit .env file with your Ngrok token
nano .env
```

### Step 3: Set File Permissions

```bash
# Make scripts executable
chmod +x start-n8n.sh backup.sh restore.sh

# Convert line endings if needed (for Windows users)
sed -i 's/\r$//' start-n8n.sh
sed -i 's/\r$//' backup.sh
sed -i 's/\r$//' restore.sh
```

### Step 4: Build and Deploy

```bash
# Build Docker image
docker-compose build

# Start services in detached mode
docker-compose up -d

# Or use make commands
make build
make up
```

### Step 5: Verify Installation

```bash
# Check service status
docker-compose ps

# View logs to get Ngrok public URL
docker-compose logs -f | grep "Public URL"

# Test n8n health
curl http://localhost:5678/healthz
```

### Step 6: Initial Setup

1. Open http://localhost:5678 in your browser
2. Create admin user account
3. Configure your first workflows
4. Note the public Ngrok URL from logs for webhooks

## ⚙️ Configuration

### Environment Variables (.env)

**Required Configuration:**

```env
# Ngrok Configuration (Get from https://dashboard.ngrok.com/)
NGROK_AUTH_TOKEN=your_ngrok_authtoken_here

# Security Configuration (Generate with openssl rand -base64 24)
N8N_ENCRYPTION_KEY=secure_random_32_char_string
N8N_USER_MANAGEMENT_JWT_SECRET=another_secure_random_32_char_string
```

**Optional Configuration:**

```env
# Ngrok Custom Domain (Paid feature)
NGROK_DOMAIN=your-custom-domain.ngrok.io
NGROK_REGION=us

# n8n Basic Configuration
N8N_PORT=5678
NODE_ENV=production
GENERIC_TIMEZONE=Asia/Jakarta

# Database (Optional - for external database)
# N8N_DATABASE_TYPE=postgresdb
# N8N_DB_POSTGRESDB_DATABASE=n8n
# N8N_DB_POSTGRESDB_HOST=postgres
# N8N_DB_POSTGRESDB_PORT=5432
# N8N_DB_POSTGRESDB_USER=username
# N8N_DB_POSTGRESDB_PASSWORD=password
```

### Generating Secure Keys

```bash
# Generate encryption key (REQUIRED)
openssl rand -base64 24
# Output: Kk5pzX8vj2QwE9rT1uY7xAbCdEfGhIj3lM

# Generate JWT secret (REQUIRED)
openssl rand -base64 24
# Output: LmN8oP7qR5sT3uV1wX9yZ2aB4cD6eF8gH

# Add to .env file
echo "N8N_ENCRYPTION_KEY=Kk5pzX8vj2QwE9rT1uY7xAbCdEfGhIj3lM" >> .env
echo "N8N_USER_MANAGEMENT_JWT_SECRET=LmN8oP7qR5sT3uV1wX9yZ2aB4cD6eF8gH" >> .env
```

## 📁 Project Structure

```
n8n-ngrok-docker/
├── docker-compose.yml          # Main service configuration
├── docker-compose.override.yml # Development overrides
├── docker-compose.prod.yml     # Production configuration
├── Dockerfile                 # Custom n8n image with ngrok
├── start-n8n.sh              # Automated startup script
├── .env                      # Environment variables (gitignored)
├── .env.example              # Environment template
├── .gitignore               # Git ignore rules
├── Makefile                 # Management commands
├── backup.sh               # Data backup script
├── restore.sh              # Data restore script
└── README.md              # This documentation
```

## 🛠️ Usage

### Management Commands

```bash
# Start all services
make up

# Stop all services
make down

# View logs in real-time
make logs

# Backup n8n data
make backup

# Restore from backup
make restore file=backups/n8n_backup_20231201_120000.tar.gz

# Development mode with hot-reload
make dev

# Production mode
make prod

# Check service status
make status

# Open shell in container
make shell
```

### Manual Docker Commands

```bash
# Build the image
docker-compose build

# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Check running containers
docker-compose ps

# Backup data manually
./backup.sh

# Restore data manually
./restore.sh backups/n8n_backup_20231201_120000.tar.gz
```

## 🔧 Development

For development with hot-reload and debugging:

```bash
# Start development environment
make dev

# Or manually with override
docker-compose -f docker-compose.yml -f docker-compose.override.yml up
```

**Development Features:**

- Source code mounting for live changes
- Node.js debugger on port 9229
- Enhanced logging with DEBUG mode
- Interactive terminal support

## 🚀 Production Deployment

For production deployment:

```bash
# Start production environment
make prod

# Or manually with production config
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Production Features:**

- Security hardening with encryption
- Resource limits and monitoring
- Log rotation (10MB max, keep 3 files)
- Health checks with longer timeouts
- Always-restart policy

## 💾 Backup and Restore

### Automated Backups

```bash
# Create backup (keeps last 7 backups)
make backup

# Backups are stored in: ./backups/
# Format: n8n_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Restore from Backup

```bash
# Restore specific backup
make restore file=backups/n8n_backup_20231201_120000.tar.gz

# List available backups
ls -la backups/
```

### Manual Backup Commands

```bash
# Manual backup
./backup.sh

# Manual restore
./restore.sh path/to/backup.tar.gz

# Verify backup contents
tar -tzf backups/n8n_backup_20231201_120000.tar.gz
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**1. Ngrok Auth Token Invalid**

```bash
# Verify token from dashboard
# Check .env file formatting (no quotes, no spaces)
NGROK_AUTH_TOKEN=31VQcyP8zVhR1NPtgORaBtt4TZq_5jb1XosKGFMiiRszcYsSY
```

**2. Port Already in Use**

```bash
# Check port usage
sudo lsof -i :5678

# Kill process or change port in .env
N8N_PORT=5679
```

**3. Permission Errors**

```bash
# Make scripts executable
chmod +x *.sh

# Check file line endings (for Windows)
sed -i 's/\r$//' *.sh
```

**4. Docker Out of Memory**

- Increase Docker memory allocation in settings
- Add resource limits in production compose file

### Logs and Debugging

```bash
# View service logs
make logs

# Check specific service logs
docker-compose logs n8n-ngrok

# Check container status
make status

# View resource usage
make stats

# Ngrok inspection dashboard
http://localhost:4040
```

### Health Checks

```bash
# Manual health check
curl http://localhost:5678/healthz

# Check Docker health status
docker inspect --format='{{.State.Health.Status}}' n8n-with-ngrok
```

## 📝 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 🆘 Support

If you encounter issues:

1. **First, check the logs**: `make logs`
2. **Verify Ngrok status**: http://localhost:4040
3. **Check environment variables**: `grep -v "^#" .env`
4. **Test basic connectivity**: `curl http://localhost:5678/healthz`

Common solutions:

- Regenerate and replace encryption keys
- Restart Docker services
- Check Ngrok auth token validity
- Verify file permissions on scripts

## 🔄 Updates and Maintenance

### Update to Latest n8n Version

```bash
# Backup first!
make backup

# Update and rebuild
make update

# Or manually
docker-compose build --no-cache
docker-compose down
docker-compose up -d
```

### Regular Maintenance Tasks

```bash
# Clean up old backups (keep last 7)
./backup.sh  # Automatic cleanup built-in

# Check disk usage
docker system df

# Clean unused Docker resources
docker system prune

# Update Docker images
docker-compose pull
```

### Monitoring and Alerts

```bash
# Set up monitoring (example)
docker stats n8n-with-ngrok

# Check logs for errors
docker-compose logs --tail=100 n8n-ngrok | grep -i error

# Monitor Ngrok tunnel status
curl -s http://localhost:4040/api/tunnels | jq
```

---

**Note**: This setup is designed for development and small-scale production use. For large-scale production deployments, consider using a reverse proxy (nginx, traefik) with proper SSL certificates instead of Ngrok.

**Security Note**: Always keep your `.env` file secure and never commit it to version control. Regularly rotate your encryption keys and Ngrok auth tokens for enhanced security.
