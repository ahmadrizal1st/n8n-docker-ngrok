#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Colors for output
const COLORS = {
  RED: "\x1b[31m",
  GREEN: "\x1b[32m",
  YELLOW: "\x1b[33m",
  BLUE: "\x1b[34m",
  CYAN: "\x1b[36m",
  PURPLE: "\x1b[35m",
  NC: "\x1b[0m", // No Color
};

// Symbols
const CHECK = "✓";
const CROSS = "✗";
const INFO = "ℹ";

function printSuccess(message) {
  console.log(`${COLORS.GREEN}${CHECK} ${message}${COLORS.NC}`);
}

function printError(message) {
  console.log(`${COLORS.RED}${CROSS} ${message}${COLORS.NC}`);
}

function printInfo(message) {
  console.log(`${COLORS.CYAN}${INFO} ${message}${COLORS.NC}`);
}

function printWarning(message) {
  console.log(`${COLORS.YELLOW}${message}${COLORS.NC}`);
}

function validateEnvironment() {
  const envPath = path.join(process.cwd(), ".env");

  if (!fs.existsSync(envPath)) {
    throw new Error(".env file not found! Please run 'tunn8n init' first.");
  }

  const envContent = fs.readFileSync(envPath, "utf8");
  const lines = envContent.split("\n");
  let missingRequired = false;

  const requiredVars = ["NGROK_AUTHTOKEN", "N8N_PORT"];

  printInfo("Validating environment variables...");

  requiredVars.forEach((varName) => {
    const found = lines.some((line) => {
      const [key] = line.split("=");
      return (
        key.trim() === varName &&
        line.includes("=") &&
        line.split("=")[1].trim() !== ""
      );
    });

    if (!found) {
      printWarning(`Warning: ${varName} is required but not set or empty`);
      missingRequired = true;
    }
  });

  if (missingRequired) {
    printWarning("\nPlease configure your .env file with required values:");
    console.log(
      `${COLORS.CYAN}  - NGROK_AUTHTOKEN (from https://dashboard.ngrok.com)${COLORS.NC}`
    );
    console.log(`${COLORS.CYAN}  - N8N_PORT (e.g., 5678)${COLORS.NC}`);
    printWarning(
      "\nYou can edit .env file or run 'tunn8n init' to recreate it."
    );

    // Ask if user wants to continue anyway
    const readline = require("readline").createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    return new Promise((resolve) => {
      readline.question(
        `${COLORS.YELLOW}Continue anyway? (y/N): ${COLORS.NC}`,
        (answer) => {
          readline.close();
          resolve(
            answer.toLowerCase() === "y" || answer.toLowerCase() === "yes"
          );
        }
      );
    });
  }

  return true;
}

function cleanupExistingContainers() {
  try {
    printInfo("Checking for existing containers...");

    // Get all containers related to this project
    const containers = execSync(
      'docker ps -a --filter "name=n8n" --filter "name=postgres" --filter "name=ngrok" --format "{{.Names}}"',
      {
        encoding: "utf8",
      }
    ).trim();

    if (containers) {
      const containerList = containers
        .split("\n")
        .filter((name) => name.length > 0);

      if (containerList.length > 0) {
        printWarning(`Found existing containers: ${containerList.join(", ")}`);
        printWarning("Removing existing containers to avoid conflicts...");

        containerList.forEach((container) => {
          try {
            // Stop and remove container
            execSync(`docker rm -f ${container}`, { stdio: "inherit" });
            printSuccess(`Removed container: ${container}`);
          } catch (containerError) {
            printWarning(
              `Could not remove container ${container}: ${containerError.message}`
            );
          }
        });
      }
    }

    return true;
  } catch (error) {
    printWarning("Warning during cleanup: " + error.message);
    return false;
  }
}

function checkDockerComposeCommand() {
  try {
    execSync("docker-compose --version", { stdio: "ignore" });
    return "docker-compose";
  } catch (error) {
    try {
      execSync("docker compose version", { stdio: "ignore" });
      return "docker compose";
    } catch (err) {
      throw new Error(
        "Neither docker-compose nor docker compose are available!"
      );
    }
  }
}

function fixDockerComposeFile() {
  try {
    const composePath = path.join(process.cwd(), "docker-compose.yml");
    if (fs.existsSync(composePath)) {
      let content = fs.readFileSync(composePath, "utf8");

      // Remove obsolete version attribute if exists
      if (content.includes("version:")) {
        content = content.replace(/version:\s*["']?[0-9.]+["']?\s*\n/, "");
        fs.writeFileSync(composePath, content);
        printSuccess(
          "Removed obsolete version attribute from docker-compose.yml"
        );
      }
    }
  } catch (error) {
    printWarning("Could not fix docker-compose.yml: " + error.message);
  }
}

async function startService() {
  try {
    // Header
    console.log(`${COLORS.BLUE}`);
    console.log("╔══════════════════════════════════════════╗");
    console.log("║           TUNN8N DEPLOYMENT              ║");
    console.log("╚══════════════════════════════════════════╝");
    console.log(`${COLORS.NC}`);

    // Check if docker-compose.yml exists
    if (!fs.existsSync("docker-compose.yml")) {
      throw new Error(
        "docker-compose.yml not found! Make sure you're in the project directory."
      );
    }

    // Check Docker
    try {
      execSync("docker info", { stdio: "ignore" });
      printSuccess("Docker is running");
    } catch (error) {
      throw new Error("Docker is not running!");
    }

    // Validate environment variables
    const shouldContinue = await validateEnvironment();
    if (!shouldContinue) {
      printWarning("Aborting start process.");
      return;
    }

    // Fix docker-compose file if needed
    fixDockerComposeFile();

    // Clean up existing containers to avoid conflicts
    cleanupExistingContainers();

    // Determine which compose command to use
    const composeCommand = checkDockerComposeCommand();

    printInfo("Starting n8n, PostgreSQL, and Ngrok services...");

    // Start services in detached mode
    execSync(`${composeCommand} up -d`, { stdio: "inherit" });

    printSuccess("Services started successfully!");

    // Get the actual port from environment or use default
    let n8nPort = "5678";
    try {
      const envContent = fs.readFileSync(".env", "utf8");
      const portLine = envContent
        .split("\n")
        .find((line) => line.startsWith("N8N_PORT="));
      if (portLine) {
        n8nPort = portLine.split("=")[1].trim() || "5678";
      }
    } catch (error) {
      // Use default port if cannot read .env
    }

    console.log(
      `${COLORS.CYAN}n8n will be available at: http://localhost:${n8nPort}${COLORS.NC}`
    );
    console.log(
      `${COLORS.CYAN}Ngrok tunnel will be created automatically${COLORS.NC}`
    );

    // Show status after starting
    setTimeout(() => {
      try {
        console.log(`${COLORS.BLUE}\n=== Service Status ===${COLORS.NC}`);
        execSync(`${composeCommand} ps`, { stdio: "inherit" });

        console.log(`${COLORS.BLUE}\n=== Recent Logs ===${COLORS.NC}`);
        execSync(`${composeCommand} logs --tail=5`, { stdio: "inherit" });
      } catch (error) {
        // Ignore errors in status check
      }
    }, 3000);
  } catch (error) {
    printError(`Failed to start services: ${error.message}`);
    throw error;
  }
}

// Export for use in main CLI
module.exports = startService;

// If called directly (for testing)
if (require.main === module) {
  startService().catch((error) => {
    printError("Fatal error: " + error.message);
    process.exit(1);
  });
}
