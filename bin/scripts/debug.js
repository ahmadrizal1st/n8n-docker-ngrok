#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");

// Colors for output
const COLORS = {
  RED: "\x1b[31m",
  GREEN: "\x1b[32m",
  YELLOW: "\x1b[33m",
  BLUE: "\x1b[34m",
  NC: "\x1b[0m", // No Color
};

// Symbols
const CHECK = "✅";
const CROSS = "❌";
const WARNING = "⚠️";
const INFO = "💡";

function printSuccess(message) {
  console.log(`${COLORS.GREEN}${CHECK} ${message}${COLORS.NC}`);
}

function printError(message) {
  console.log(`${COLORS.RED}${CROSS} ${message}${COLORS.NC}`);
}

function printWarning(message) {
  console.log(`${COLORS.YELLOW}${WARNING} ${message}${COLORS.NC}`);
}

function printInfo(message) {
  console.log(`${COLORS.BLUE}${INFO} ${message}${COLORS.NC}`);
}

function checkDocker() {
  try {
    execSync("docker info", { stdio: "ignore" });
    return true;
  } catch (error) {
    return false;
  }
}

function getContainerStatus() {
  try {
    console.log(`\n${COLORS.BLUE}CONTAINER STATUS:${COLORS.NC}`);
    execSync(
      'docker ps -a --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"',
      {
        stdio: "inherit",
      }
    );
  } catch (error) {
    printError("Could not get container status");
  }
}

function getN8nContainerInfo() {
  try {
    console.log(`\n${COLORS.BLUE}N8N CONTAINER INFO:${COLORS.NC}`);

    // Check if n8n-app container exists
    try {
      execSync("docker inspect n8n-app", { stdio: "ignore" });

      // Get detailed info
      const info = execSync(
        'docker inspect n8n-app --format "\nStatus: {{.State.Status}}\nRunning: {{.State.Running}}\nRestart Count: {{.RestartCount}}\nImage: {{.Config.Image}}"',
        {
          encoding: "utf8",
        }
      );

      console.log(info);
    } catch (inspectError) {
      printWarning("n8n-app container not found");
    }
  } catch (error) {
    printError("Error getting n8n container info");
  }
}

function getN8nLogs() {
  try {
    console.log(`\n${COLORS.BLUE}N8N LOGS (last 10 lines):${COLORS.NC}`);

    // Check if n8n-app container exists
    const containers = execSync(
      'docker ps -a --filter "name=n8n-app" --format "{{.Names}}"',
      {
        encoding: "utf8",
      }
    );

    if (containers.trim().includes("n8n-app")) {
      try {
        execSync("docker logs n8n-app --tail 10", { stdio: "inherit" });
      } catch (logError) {
        console.log("Could not retrieve logs - container may not be running");
      }
    } else {
      printWarning("n8n-app container not available");
    }
  } catch (error) {
    printError("Error getting n8n logs");
  }
}

function checkN8nRunning() {
  try {
    const output = execSync(
      'docker ps --filter "name=n8n-app" --format "{{.Names}}"',
      {
        encoding: "utf8",
      }
    );
    return output.trim().includes("n8n-app");
  } catch (error) {
    return false;
  }
}

function checkRestartCount() {
  try {
    const restartCount = execSync(
      'docker inspect n8n-app --format "{{.RestartCount}}"',
      {
        encoding: "utf8",
      }
    ).trim();

    return parseInt(restartCount) > 0;
  } catch (error) {
    return false;
  }
}

function getNetworkInfo() {
  try {
    console.log(`\n${COLORS.BLUE}NETWORK INFO:${COLORS.NC}`);

    // Get network information
    execSync('docker network ls --filter "name=n8n"', { stdio: "inherit" });

    console.log(`\n${COLORS.BLUE}CONTAINER IP ADDRESSES:${COLORS.NC}`);
    execSync(
      'docker inspect n8n-app --format "IP: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"',
      {
        stdio: "inherit",
      }
    );
  } catch (error) {
    // Ignore network errors
  }
}

function getResourceUsage() {
  try {
    console.log(`\n${COLORS.BLUE}RESOURCE USAGE:${COLORS.NC}`);

    execSync(
      'docker stats n8n-app --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"',
      {
        stdio: "inherit",
      }
    );
  } catch (error) {
    printWarning("Could not get resource usage");
  }
}

function main() {
  // Header
  console.log(`${COLORS.BLUE}`);
  console.log("╔══════════════════════════════════════════╗");
  console.log("║           N8N DOCKER DIAGNOSTICS         ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`${COLORS.NC}`);

  // Check Docker
  if (!checkDocker()) {
    console.log(`${COLORS.RED}❌ Docker is not running${COLORS.NC}`);
    process.exit(1);
  } else {
    console.log(`${COLORS.GREEN}✅ Docker is running${COLORS.NC}`);
  }

  // Container status
  getContainerStatus();

  // N8N container details
  getN8nContainerInfo();

  // Logs
  getN8nLogs();

  // Network info
  getNetworkInfo();

  // Resource usage
  getResourceUsage();

  // Summary
  console.log(`\n${COLORS.BLUE}SUMMARY:${COLORS.NC}`);

  const isN8nRunning = checkN8nRunning();
  if (isN8nRunning) {
    printSuccess("n8n-app is running");
  } else {
    printError("n8n-app is NOT running");
    printInfo("Try: docker-compose up -d n8n-app");
  }

  const hasRestarted = checkRestartCount();
  if (hasRestarted) {
    printWarning("n8n-app has restarted recently");
  }

  console.log(
    `\n${COLORS.GREEN}Diagnostics completed at: ${new Date().toLocaleString()}${
      COLORS.NC
    }`
  );
}

// Export for use in main CLI
module.exports = main;

// If called directly
if (require.main === module) {
  main().catch((error) => {
    console.error(`${COLORS.RED}Fatal error: ${error.message}${COLORS.NC}`);
    process.exit(1);
  });
}
