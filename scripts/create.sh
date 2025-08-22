#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to copy template files
copy_template_files() {
    local project_name=$1
    local templates_dir="./templates"
    
    if [ ! -d "$templates_dir" ]; then
        print_color "$RED" "Error: Templates directory not found!"
        exit 1
    fi
    
    # Copy all files from templates directory
    cp -r "$templates_dir"/* "$project_name/"
    print_color "$GREEN" "✓ Copied template files"
    
    # Create .gitignore if it doesn't exist
    create_gitignore "$project_name"
}

# Function to create .gitignore
create_gitignore() {
    local project_name=$1
    local gitignore_path="$project_name/.gitignore"
    
    if [ -f "$gitignore_path" ]; then
        print_color "$GRAY" ".gitignore already exists"
        return
    fi
    
    cat > "$gitignore_path" << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.production

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# Docker volumes and data
data/
docker-data/
volumes/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Temporary folders
tmp/
temp/

# n8n specific
n8n/
n8n_public/

# Ngrok (if used)
ngrok.yml

# Docker compose override
docker-compose.override.yml
EOF

    print_color "$GREEN" "✓ Created .gitignore with default content"
}

# Function to copy script files
copy_script_files() {
    local project_name=$1
    local scripts_dir="./scripts"
    local target_scripts_dir="$project_name/scripts"
    
    if [ ! -d "$scripts_dir" ]; then
        print_color "$RED" "Error: Scripts directory not found!"
        exit 1
    fi
    
    # Create scripts directory
    mkdir -p "$target_scripts_dir"
    
    # Copy all script files
    cp -r "$scripts_dir"/* "$target_scripts_dir/"
    
    # Make scripts executable
    chmod +x "$target_scripts_dir"/*.sh
    
    print_color "$GREEN" "✓ Copied and made scripts executable"
}

# Main function
create_project() {
    local project_name=$1
    
    print_color "$BLUE" "Creating new tunn8n project: $project_name"
    
    # Check if directory already exists
    if [ -d "$project_name" ]; then
        print_color "$RED" "Error: Directory '$project_name' already exists!"
        print_color "$YELLOW" "Please choose a different project name or remove the existing directory."
        exit 1
    fi
    
    # Create project directory
    mkdir -p "$project_name"
    print_color "$GREEN" "✓ Created project directory: $project_name"
    
    # Copy template files
    copy_template_files "$project_name"
    
    # Copy script files
    copy_script_files "$project_name"
    
    # Create .env from .env.example if it exists
    local env_example_path="$project_name/.env.example"
    local env_file_path="$project_name/.env"
    
    if [ -f "$env_example_path" ]; then
        cp "$env_example_path" "$env_file_path"
        print_color "$GREEN" "✓ Created .env file from template"
    fi
    
    print_color "$GREEN" "\n🎉 Project created successfully!"
    print_color "$YELLOW" "\nNext steps:"
    print_color "$CYAN" "  cd $project_name"
    print_color "$CYAN" "  # Edit .env file with your configuration"
    print_color "$CYAN" "  ./scripts/start.sh   # Start services"
    print_color "$CYAN" "  ./scripts/status.sh  # Check service status"
}

# Check if project name is provided
if [ $# -eq 0 ]; then
    print_color "$RED" "Error: Project name required!"
    print_color "$CYAN" "Usage: ./create.sh <project-name>"
    exit 1
fi

# Run main function with provided project name
create_project "$1"