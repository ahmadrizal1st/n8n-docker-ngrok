#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Get package installation path
const PACKAGE_ROOT = path.join(__dirname, "..");
const SCRIPTS_DIR = path.join(PACKAGE_ROOT, "bin", "scripts");

// Import script functions
const startServiceScript = require(path.join(SCRIPTS_DIR, "start.js"));
const stopServiceScript = require(path.join(SCRIPTS_DIR, "stop.js"));
const debugServiceScript = require(path.join(SCRIPTS_DIR, "debug.js"));
const statusServiceScript = require(path.join(SCRIPTS_DIR, "status.js"));
const createProjectScript = require(path.join(SCRIPTS_DIR, "create.js"));

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
    return "1.3.8";
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
${colors.bold("🚀 tun8n CLI - n8n with Docker & Ngrok")}

${colors.bold("Usage:")}
  tun8n create <project-name>  Create new n8n project
  tun8n start                 Start docker services
  tun8n stop                  Stop docker services  
  tun8n status                Check service status
  tun8n debug                 Debug mode
  tun8n init                  Initialize .env file
  tun8n update                Update tun8n to latest version
  tun8n --version             Show version
  tun8n --help                Show this help message

${colors.bold("Project Structure:")}
  📄 docker-compose.yml - Docker service definitions
  📄 .gitignore  - Git ignore rules
  📄 .env        - Environment configuration
  📄 .env.example - Example environment configuration
  📄 README.md   - Documentation
  📄 package.json - Project metadata and dependencies

${colors.bold("Examples:")}
  tun8n create my-automation
  cd my-automation
  tun8n start
  tun8n status
  `);
}

function startService() {
  console.log(colors.blue("Starting tun8n services..."));

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

    if (typeof startServiceScript === "function") {
      startServiceScript();
    } else if (typeof startServiceScript.main === "function") {
      startServiceScript.main();
    } else {
      throw new Error("Start script does not export a function");
    }

    console.log(colors.green("✓ Services started successfully!"));
  } catch (error) {
    console.log(colors.red("Error starting tun8n:"), error.message);
    console.log(
      colors.yellow(
        "Make sure Docker is running and you have proper permissions"
      )
    );
  }
}

function stopService() {
  console.log(colors.blue("Stopping tun8n services..."));
  try {
    if (typeof stopServiceScript === "function") {
      stopServiceScript();
    } else if (typeof stopServiceScript.main === "function") {
      stopServiceScript.main();
    } else {
      throw new Error("Stop script does not export a function");
    }

    console.log(colors.green("✓ Services stopped successfully!"));
  } catch (error) {
    console.log(colors.red("Error stopping tun8n:"), error.message);

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
    if (typeof debugServiceScript === "function") {
      debugServiceScript();
    } else if (typeof debugServiceScript.main === "function") {
      debugServiceScript.main();
    } else {
      throw new Error("Debug script does not export a function");
    }
  } catch (error) {
    console.log(colors.red("Error running debug:"), error.message);
  }
}

function statusService() {
  console.log(colors.blue("Checking service status..."));
  try {
    if (typeof statusServiceScript === "function") {
      statusServiceScript();
    } else if (typeof statusServiceScript.main === "function") {
      statusServiceScript.main();
    } else {
      throw new Error("Status script does not export a function");
    }
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

function updatetun8n() {
  console.log(colors.blue("Updating tun8n to latest version..."));
  try {
    execSync("npm install -g tun8n@latest", { stdio: "inherit" });
    console.log(colors.green("✓ tun8n updated successfully!"));
  } catch (error) {
    console.log(colors.red("Error updating tun8n:"), error.message);
  }
}

function showVersion() {
  console.log(colors.blue(`tun8n CLI Version: ${getPackageVersion()}`));
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
      createProjectScript(args[0]);
    } else {
      console.log(colors.red("Error: Project name required!"));
      console.log(colors.cyan("Usage: tun8n create <project-name>"));
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
    updatetun8n();
    break;

  case "--version":
  case "-v":
    showVersion();
    break;

  default:
    showHelp();
    break;
}
