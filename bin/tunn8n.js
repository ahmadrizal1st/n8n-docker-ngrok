#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Get package installation path
const PACKAGE_ROOT = path.join(__dirname, "..");
const TEMPLATES_DIR = path.join(PACKAGE_ROOT, "templates");
const SCRIPTS_DIR = path.join(PACKAGE_ROOT, "scripts");

// Simple color functions replacement for chalk
const colors = {
  green: (text) => `\x1b[32m${text}\x1b[0m`,
  red: (text) => `\x1b[31m${text}\x1b[0m`,
  blue: (text) => `\x1b[34m${text}\x1b[0m`,
  yellow: (text) => `\x1b[33m${text}\x1b[0m`,
  cyan: (text) => `\x1b[36m${text}\x1b[0m`,
  gray: (text) => `\x1b[90m${text}\x1b[0m`,
  bold: (text) => `\x1b[1m${text}\x1b[0m`,
};

// Function to get package version from package.json
function getPackageVersion() {
  try {
    const packageJsonPath = path.join(PACKAGE_ROOT, "package.json");
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    return packageJson.version;
  } catch (error) {
    return "1.1.14";
  }
}

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

// Function to copy script files from package to project
function copyScriptFiles(projectName) {
  const targetDir = path.join(process.cwd(), projectName);
  const scriptsTargetDir = path.join(targetDir, "scripts");

  if (!fs.existsSync(SCRIPTS_DIR)) {
    throw new Error("Scripts directory not found in package!");
  }

  // Create scripts directory if it doesn't exist
  if (!fs.existsSync(scriptsTargetDir)) {
    fs.mkdirSync(scriptsTargetDir, { recursive: true });
  }

  const scriptFiles = fs.readdirSync(SCRIPTS_DIR);

  scriptFiles.forEach((file) => {
    const sourcePath = path.join(SCRIPTS_DIR, file);
    const targetPath = path.join(scriptsTargetDir, file);

    if (fs.existsSync(sourcePath)) {
      fs.copyFileSync(sourcePath, targetPath);
      // Set execute permissions on script files
      fs.chmodSync(targetPath, "755");
      console.log(colors.green(`✓ Created scripts/${file}`));
    }
  });
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

// Function to execute script with dynamic path detection
function executeScript(scriptName) {
  let scriptPath;
  let scriptCommand;

  // Check in scripts directory first
  const scriptsDirPath = path.join(process.cwd(), "scripts", scriptName);
  const rootPath = path.join(process.cwd(), scriptName);

  if (fs.existsSync(scriptsDirPath)) {
    scriptPath = scriptsDirPath;
    scriptCommand = `./scripts/${scriptName}`;
  } else if (fs.existsSync(rootPath)) {
    scriptPath = rootPath;
    scriptCommand = `./${scriptName}`;
    console.log(
      colors.yellow(
        `Warning: Running ${scriptName} from root directory (scripts/ preferred)`
      )
    );
  } else {
    throw new Error(`${scriptName} not found in scripts/ or root directory!`);
  }

  // Ensure script has execute permissions
  try {
    fs.chmodSync(scriptPath, "755");
  } catch (error) {
    console.log(
      colors.yellow(`Warning: Could not set permissions on ${scriptPath}`)
    );
  }

  execSync(scriptCommand, { stdio: "inherit", cwd: process.cwd() });
}

// Function to validate environment variables
function validateEnvVars() {
  const envPath = path.join(process.cwd(), ".env");

  if (!fs.existsSync(envPath)) {
    console.log(colors.yellow("Warning: .env file not found!"));
    return false;
  }

  const envContent = fs.readFileSync(envPath, "utf8");
  const lines = envContent.split("\n");
  let hasErrors = false;

  lines.forEach((line) => {
    if (line.trim() && !line.startsWith("#")) {
      const [key, value] = line.split("=");
      if (key && key.trim() && (!value || value.trim() === "")) {
        console.log(
          colors.yellow(`Warning: ${key} is defined but has no value`)
        );
        hasErrors = true;
      }
    }
  });

  return !hasErrors;
}

function showHelp() {
  console.log(`
${colors.bold("🚀 Tunn8n CLI - n8n with Docker & Ngrok")}

${colors.bold("Usage:")}
  tunn8n create <project-name>  Create new n8n project
  tunn8n start                 Start docker services
  tunn8n stop                  Stop docker services  
  tunn8n status                Check service status
  tunn8n debug                 Debug mode
  tunn8n init                  Initialize .env file
  tunn8n update                Update tunn8n to latest version
  tunn8n --version             Show version
  tunn8n --help                Show this help message

${colors.bold("Project Structure:")}
  📁 scripts/    - Shell scripts for service management
  📄 .env        - Environment configuration
  📄 docker-compose.yml - Docker service definitions
  📄 README.md   - Documentation
  📄 .gitignore  - Git ignore rules
  📄 .env.example - Example environment configuration

${colors.bold("Examples:")}
  tunn8n create my-automation
  cd my-automation
  tunn8n start
  tunn8n status
  `);
}

function createProject(projectName) {
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

    // Copy script files from package scripts directory
    copyScriptFiles(projectName);

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

function startService() {
  console.log(colors.blue("Starting tunn8n services..."));

  try {
    // Check if Docker is available
    if (!checkDocker()) {
      throw new Error("Docker is not installed or not running!");
    }

    // Check if .env exists
    if (!fs.existsSync(".env")) {
      console.log(colors.yellow("Warning: .env file not found!"));
      console.log(
        colors.yellow("Please create .env file from .env.example first")
      );
    } else {
      // Validate environment variables
      validateEnvVars();
    }

    executeScript("start.sh");
    console.log(colors.green("✓ Services started successfully!"));
  } catch (error) {
    console.log(colors.red("Error starting tunn8n:"), error.message);
    console.log(
      colors.yellow(
        "Make sure Docker is running and you have proper permissions"
      )
    );
  }
}

function stopService() {
  console.log(colors.blue("Stopping tunn8n services..."));
  try {
    executeScript("stop.sh");
    console.log(colors.green("✓ Services stopped successfully!"));
  } catch (error) {
    console.log(colors.red("Error stopping tunn8n:"), error.message);

    // Fallback to direct docker command
    try {
      console.log(
        colors.yellow("Trying fallback method with docker-compose...")
      );

      if (checkDockerCompose()) {
        execSync("docker-compose down", { stdio: "inherit" });
      } else {
        execSync("docker compose down", { stdio: "inherit" });
      }

      console.log(colors.green("✓ Services stopped using fallback method!"));
    } catch (fallbackError) {
      console.log(
        colors.red("Fallback method also failed:"),
        fallbackError.message
      );
    }
  }
}

function debugService() {
  console.log(colors.blue("Running debug utilities..."));
  try {
    executeScript("debug.sh");
  } catch (error) {
    console.log(colors.red("Error running debug:"), error.message);
  }
}

function statusService() {
  console.log(colors.blue("Checking service status..."));
  try {
    executeScript("status.sh");
  } catch (error) {
    console.log(colors.red("Error checking status:"), error.message);
  }
}

function initProject() {
  if (!fs.existsSync(".env")) {
    if (fs.existsSync(".env.example")) {
      fs.copyFileSync(".env.example", ".env");
      console.log(colors.green("✓ .env file created from template"));
      console.log(
        colors.yellow("Please edit .env file with your configuration:")
      );
      console.log(
        colors.cyan(
          "  - NGROK_AUTH_TOKEN (get from https://dashboard.ngrok.com/get-started/your-authtoken)"
        )
      );
      console.log(colors.cyan("  - N8N_PORT (default: 5678)"));
      console.log(colors.cyan("  - N8N_PROTOCOL (http or https)"));
      console.log(colors.cyan("  - Other environment variables as needed"));
    } else {
      console.log(colors.red("Error: .env.example template not found!"));
    }
  } else {
    console.log(colors.yellow(".env file already exists"));
    console.log(colors.gray("Skipping initialization..."));
  }
}

function updateTunn8n() {
  console.log(colors.blue("Updating tunn8n to latest version..."));
  try {
    execSync("npm install -g tunn8n@latest", { stdio: "inherit" });
    console.log(colors.green("✓ tunn8n updated successfully!"));
  } catch (error) {
    console.log(colors.red("Error updating tunn8n:"), error.message);
  }
}

function showVersion() {
  console.log(colors.blue(`tunn8n CLI Version: ${getPackageVersion()}`));
  console.log(colors.gray("Template: n8n with Docker + Ngrok integration"));
}

// Main command parsing
const command = process.argv[2];
const args = process.argv.slice(3);

// Handle help command
if (command === "--help" || command === "-h") {
  showHelp();
  process.exit(0);
}

switch (command) {
  case "create":
    if (args[0]) {
      createProject(args[0]);
    } else {
      console.log(colors.red("Error: Project name required!"));
      console.log(colors.cyan("Usage: tunn8n create <project-name>"));
      process.exit(1);
    }
    break;

  case "start":
    startService();
    break;

  case "stop":
    stopService();
    break;

  case "debug":
    debugService();
    break;

  case "status":
    statusService();
    break;

  case "init":
    initProject();
    break;

  case "update":
    updateTunn8n();
    break;

  case "--version":
  case "-v":
    showVersion();
    break;

  default:
    showHelp();
    break;
}
