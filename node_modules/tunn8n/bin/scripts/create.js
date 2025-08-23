#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Colors for output
const colors = {
  green: (text) => `\x1b[32m${text}\x1b[0m`,
  red: (text) => `\x1b[31m${text}\x1b[0m`,
  blue: (text) => `\x1b[34m${text}\x1b[0m`,
  yellow: (text) => `\x1b[33m${text}\x1b[0m`,
  cyan: (text) => `\x1b[36m${text}\x1b[0m`,
  gray: (text) => `\x1b[90m${text}\x1b[0m`,
  bold: (text) => `\x1b[1m${text}\x1b[0m`,
};

// Function to print the header
function printHeader() {
  const COLORS = {
    BLUE: "\x1b[34m",
    WHITE: "\x1b[37m",
    CYAN: "\x1b[36m",
    PINK: "\x1b[35m",
    LIGHT_BLUE: "\x1b[94m",
    NC: "\x1b[0m",
  };

  console.clear();

  // TUNN8N ASCII Art
  console.log(
    `${COLORS.BLUE}  ████████╗${COLORS.WHITE}██╗   ██║${COLORS.BLUE}███╗   ██╗${COLORS.CYAN}███╗   ██╗${COLORS.PINK}  █████╗  ${COLORS.CYAN}███╗   ██╗${COLORS.NC}`
  );
  console.log(
    `${COLORS.BLUE}  ╚══██╔══╝${COLORS.WHITE}██║   ██║${COLORS.BLUE}████╗  ██║${COLORS.CYAN}████╗  ██║${COLORS.PINK} ██╔══██╗ ${COLORS.CYAN}████╗  ██║${COLORS.NC}`
  );
  console.log(
    `${COLORS.BLUE}     ██║   ${COLORS.WHITE}██║   ██║${COLORS.BLUE}██╔██╗ ██║${COLORS.CYAN}██╔██╗ ██║${COLORS.PINK}  █████║  ${COLORS.CYAN}██╔██╗ ██║${COLORS.NC}`
  );
  console.log(
    `${COLORS.BLUE}     ██║   ${COLORS.WHITE}██║   ██║${COLORS.BLUE}██║╚██╗██║${COLORS.CYAN}██║╚██╗██║${COLORS.PINK} ██║  ██║ ${COLORS.CYAN}██║╚██╗██║${COLORS.NC}`
  );
  console.log(
    `${COLORS.BLUE}     ██║   ${COLORS.WHITE}╚██████╔╝${COLORS.BLUE}██║ ╚████║${COLORS.CYAN}██║ ╚████║${COLORS.PINK} ╚█████╔╝ ${COLORS.CYAN}██║ ╚████║${COLORS.NC}`
  );
  console.log(
    `${COLORS.BLUE}     ╚═╝    ${COLORS.WHITE}╚═════╝ ${COLORS.BLUE}╚═╝  ╚═══╝${COLORS.CYAN}╚═╝  ╚═══╝${COLORS.PINK}  ╚════╝  ${COLORS.CYAN}╚═╝  ╚═══╝${COLORS.NC}`
  );

  // Header box
  const CORNER_TL = "╔";
  const CORNER_TR = "╗";
  const CORNER_BL = "╚";
  const CORNER_BR = "╝";
  const LINE_H = "═";
  const LINE_V = "║";

  console.log(`${COLORS.NC}`);
  console.log(
    `${COLORS.LIGHT_BLUE}${CORNER_TL}${LINE_H.repeat(34)}${CORNER_TR}`
  );
  console.log(`${LINE_V}    Docker Tunnel Management System    ${LINE_V}`);
  console.log(`${CORNER_BL}${LINE_H.repeat(34)}${CORNER_BR}`);
  console.log(`${COLORS.NC}`);
}

// Get package installation path
const PACKAGE_ROOT = path.join(__dirname, "..", "..");
const TEMPLATES_DIR = path.join(PACKAGE_ROOT, "templates");

// Check if Docker is available
function checkDocker() {
  try {
    execSync("docker --version", { stdio: "ignore" });
    return true;
  } catch (error) {
    return false;
  }
}

// Check if docker-compose is available
function checkDockerCompose() {
  try {
    execSync("docker-compose --version", { stdio: "ignore" });
    return true;
  } catch (error) {
    try {
      execSync("docker compose version", { stdio: "ignore" });
      return true;
    } catch (error) {
      return false;
    }
  }
}

// Function to copy template files from package to project
function copyTemplateFiles(projectName) {
  const targetDir = path.join(process.cwd(), projectName);

  if (!fs.existsSync(TEMPLATES_DIR)) {
    throw new Error("Templates directory not found in package!");
  }

  const templateFiles = fs.readdirSync(TEMPLATES_DIR);

  templateFiles.forEach((file) => {
    const sourcePath = path.join(TEMPLATES_DIR, file);
    const targetPath = path.join(targetDir, file);

    if (fs.existsSync(sourcePath)) {
      // If it's a directory, copy recursively
      if (fs.statSync(sourcePath).isDirectory()) {
        copyRecursiveSync(sourcePath, targetPath);
      } else {
        fs.copyFileSync(sourcePath, targetPath);
      }
      console.log(colors.green(`✓ Created ${file}`));
    }
  });

  // Create .gitignore if it doesn't exist in templates
  createGitignore(projectName);
}

// Recursive copy function for directories
function copyRecursiveSync(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  const items = fs.readdirSync(src);

  items.forEach((item) => {
    const srcPath = path.join(src, item);
    const destPath = path.join(dest, item);

    if (fs.statSync(srcPath).isDirectory()) {
      copyRecursiveSync(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  });
}

// Function to copy root files (package.json and README.md) to project
function copyRootFiles(projectName) {
  const targetDir = path.join(process.cwd(), projectName);

  // Copy package.json
  const packageJsonPath = path.join(PACKAGE_ROOT, "package.json");
  const targetPackageJsonPath = path.join(targetDir, "package.json");

  if (fs.existsSync(packageJsonPath)) {
    try {
      fs.copyFileSync(packageJsonPath, targetPackageJsonPath);
      console.log(colors.green("✓ Created package.json"));
    } catch (error) {
      console.log(colors.yellow("Could not copy package.json:"), error.message);
    }
  }

  // Copy README.md
  const readmePath = path.join(PACKAGE_ROOT, "README.md");
  const targetReadmePath = path.join(targetDir, "README.md");

  if (fs.existsSync(readmePath)) {
    try {
      fs.copyFileSync(readmePath, targetReadmePath);
      console.log(colors.green("✓ Created README.md"));
    } catch (error) {
      console.log(colors.yellow("Could not copy README.md:"), error.message);
    }
  }
}

// Function to create .gitignore file
function createGitignore(projectName) {
  const targetDir = path.join(process.cwd(), projectName);
  const gitignorePath = path.join(targetDir, ".gitignore");

  // Check if .gitignore already exists
  if (fs.existsSync(gitignorePath)) {
    console.log(colors.gray(".gitignore already exists"));
    return;
  }

  // Default .gitignore content for n8n Docker project
  const gitignoreContent = `# Dependencies
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
`;

  try {
    fs.writeFileSync(gitignorePath, gitignoreContent);
    console.log(colors.green("✓ Created .gitignore with default content"));
  } catch (error) {
    console.log(colors.yellow("Could not create .gitignore:"), error.message);
  }
}

// Main create project function
function createProject(projectName) {
  printHeader();
  console.log(colors.blue(`Creating new tunn8n project: ${projectName}`));

  try {
    // Check if directory already exists
    if (fs.existsSync(projectName)) {
      console.log(
        colors.red(`Error: Directory '${projectName}' already exists!`)
      );
      console.log(
        colors.yellow(
          "Please choose a different project name or remove the existing directory."
        )
      );
      process.exit(1);
    }

    // Check if Docker is available
    if (!checkDocker()) {
      console.log(colors.red("Error: Docker is not installed or not running!"));
      console.log(
        colors.yellow(
          "Please install Docker first: https://docs.docker.com/get-docker/"
        )
      );
      process.exit(1);
    }

    if (!checkDockerCompose()) {
      console.log(colors.red("Error: Docker Compose is not installed!"));
      console.log(
        colors.yellow(
          "Please install Docker Compose: https://docs.docker.com/compose/install/"
        )
      );
      process.exit(1);
    }

    // Create project directory
    fs.mkdirSync(projectName, { recursive: true });
    console.log(colors.green(`✓ Created project directory: ${projectName}`));

    // Copy template files from package templates directory
    copyTemplateFiles(projectName);

    // Copy root files (package.json and README.md)
    copyRootFiles(projectName);

    // Create .env from .env.example
    const envExamplePath = path.join(
      process.cwd(),
      projectName,
      ".env.example"
    );
    const envFilePath = path.join(process.cwd(), projectName, ".env");

    if (fs.existsSync(envExamplePath)) {
      fs.copyFileSync(envExamplePath, envFilePath);
      console.log(colors.green("✓ Created .env file from template"));

      // Show important environment variables to configure
      console.log(
        colors.yellow(
          "\nImportant: Please configure these environment variables:"
        )
      );
      console.log(
        colors.cyan(
          "  - NGROK_AUTH_TOKEN (get from https://dashboard.ngrok.com/get-started/your-authtoken)"
        )
      );
      console.log(colors.cyan("  - N8N_PORT (default: 5678)"));
      console.log(colors.cyan("  - N8N_PROTOCOL (http or https)"));
    }

    console.log(colors.green("\n🎉 Project created successfully!"));
    console.log(colors.yellow("\nNext steps:"));
    console.log(colors.cyan(`  cd ${projectName}`));
    console.log(colors.cyan("  # Edit .env file with your configuration"));
    console.log(colors.cyan("  tunn8n start   # Start services"));
    console.log(colors.cyan("  tunn8n status  # Check service status"));
  } catch (error) {
    console.log(colors.red("Error creating project:"), error.message);
    process.exit(1);
  }
}

// Export for use in main CLI
module.exports = createProject;

// If called directly
if (require.main === module) {
  const projectName = process.argv[2];
  if (!projectName) {
    console.log(colors.red("Error: Project name required!"));
    console.log(colors.cyan("Usage: node create.js <project-name>"));
    process.exit(1);
  }
  createProject(projectName);
}
