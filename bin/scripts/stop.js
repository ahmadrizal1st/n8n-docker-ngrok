const { execSync } = require("child_process");
const fs = require("fs");

function stopService() {
  try {
    // Check if docker-compose.yml exists
    if (!fs.existsSync("docker-compose.yml")) {
      throw new Error(
        "docker-compose.yml not found! Make sure you're in the project directory."
      );
    }

    // Check which compose command to use
    let composeCommand = "docker-compose";
    try {
      execSync("docker-compose --version", { stdio: "ignore" });
    } catch (error) {
      try {
        execSync("docker compose version", { stdio: "ignore" });
        composeCommand = "docker compose";
      } catch (err) {
        throw new Error(
          "Neither docker-compose nor docker compose are available!"
        );
      }
    }

    // Stop services
    execSync(`${composeCommand} down`, { stdio: "inherit" });

    console.log("Services stopped successfully!");
  } catch (error) {
    throw new Error(`Failed to stop services: ${error.message}`);
  }
}

// Export for use in main CLI
module.exports = stopService;

// If called directly (for testing)
if (require.main === module) {
  stopService();
}
