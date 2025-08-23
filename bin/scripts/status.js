#!/usr/bin/env node

const { execSync } = require("child_process");

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

function printSuccess(message) {
  console.log(`${COLORS.GREEN}${CHECK} ${message}${COLORS.NC}`);
}

function printError(message) {
  console.log(`${COLORS.RED}${CROSS} ${message}${COLORS.NC}`);
}

function printWarning(message) {
  console.log(`${COLORS.YELLOW}${WARNING} ${message}${COLORS.NC}`);
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

function getN8nLogs() {
  try {
    console.log(`\n${COLORS.BLUE}N8N LOGS (last 5 lines):${COLORS.NC}`);

    // Check if any n8n container exists
    const containers = execSync(
      'docker ps -a --filter "name=n8n" --format "{{.Names}}"',
      {
        encoding: "utf8",
      }
    );

    if (containers.trim().length > 0) {
      // Get the first n8n container found
      const containerName = containers.trim().split("\n")[0];
      try {
        execSync(`docker logs ${containerName} --tail 5`, { stdio: "inherit" });
      } catch (logError) {
        console.log("Could not retrieve logs - container may not be running");
      }
    } else {
      printWarning("n8n container not found");
    }
  } catch (error) {
    printError("Error getting n8n logs");
  }
}

function checkN8nRunning() {
  try {
    const output = execSync(
      'docker ps --filter "name=n8n" --format "{{.Names}}"',
      {
        encoding: "utf8",
      }
    );
    return output.trim().length > 0;
  } catch (error) {
    return false;
  }
}

function getServiceHealth() {
  try {
    console.log(`\n${COLORS.BLUE}SERVICE HEALTH:${COLORS.NC}`);

    // Try to check if n8n web interface is accessible
    const runningContainers = execSync(
      'docker ps --filter "name=n8n" --format "{{.Names}}:{{.Ports}}"',
      {
        encoding: "utf8",
      }
    );

    if (runningContainers.trim()) {
      const containers = runningContainers.trim().split("\n");

      containers.forEach((containerInfo) => {
        const [containerName, ports] = containerInfo.split(":");
        const httpPortMatch = ports.match(/([0-9]+)->5678/);

        if (httpPortMatch) {
          const hostPort = httpPortMatch[1];
          try {
            // Try to curl the health endpoint
            execSync(
              `curl -s -o /dev/null -w "%{http_code}" http://localhost:${hostPort}/health`,
              {
                stdio: "ignore",
              }
            );
            printSuccess(
              `${containerName} health check passed (port ${hostPort})`
            );
          } catch (error) {
            printWarning(
              `${containerName} health check failed (port ${hostPort})`
            );
          }
        }
      });
    }
  } catch (error) {
    // Ignore health check errors
  }
}

function main() {
  // Header
  console.log(`${COLORS.BLUE}`);
  console.log("╔══════════════════════════════════════════╗");
  console.log("║         N8N DOCKER STATUS CHECK          ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`${COLORS.NC}`);

  // Check Docker status
  if (!checkDocker()) {
    console.log(`${COLORS.RED}❌ Docker is not running${COLORS.NC}`);
    process.exit(1);
  } else {
    console.log(`${COLORS.GREEN}✅ Docker is running${COLORS.NC}`);
  }

  // Container status
  getContainerStatus();

  // N8N logs
  getN8nLogs();

  // Service health check
  getServiceHealth();

  // Status summary
  console.log(`\n${COLORS.BLUE}STATUS SUMMARY:${COLORS.NC}`);

  const isN8nRunning = checkN8nRunning();
  if (isN8nRunning) {
    printSuccess("n8n container is running");
  } else {
    printError("n8n container is not running");
  }

  console.log(
    `\n${
      COLORS.GREEN
    }Status check completed at: ${new Date().toLocaleString()}${COLORS.NC}`
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
