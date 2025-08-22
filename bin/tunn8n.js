#!/usr/bin/env node

const { program } = require("commander");
const { execSync } = require("child_process");
const chalk = require("chalk");
const fs = require("fs");
const path = require("path");

// Get package installation path
const PACKAGE_ROOT = path.join(__dirname, "..");
const TEMPLATES_DIR = path.join(PACKAGE_ROOT, "templates");
const SCRIPTS_DIR = path.join(PACKAGE_ROOT, "scripts");

// Function to get package version from package.json
function getPackageVersion() {
  try {
    const packageJsonPath = path.join(PACKAGE_ROOT, "package.json");
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    return packageJson.version;
  } catch (error) {
    return "1.1.2";
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
      fs.copyFileSync(sourcePath, targetPath);
      console.log(chalk.green(`✓ Created ${file}`));
    }
  });
}

// Function to copy and set permissions on script files
function copyScriptFiles(projectName) {
  const targetDir = path.join(process.cwd(), projectName);

  if (!fs.existsSync(SCRIPTS_DIR)) {
    throw new Error("Scripts directory not found in package!");
  }

  const scriptFiles = fs.readdirSync(SCRIPTS_DIR);

  scriptFiles.forEach((file) => {
    const sourcePath = path.join(SCRIPTS_DIR, file);
    const targetPath = path.join(targetDir, file);

    if (fs.existsSync(sourcePath)) {
      fs.copyFileSync(sourcePath, targetPath);

      // Set execute permissions
      try {
        fs.chmodSync(targetPath, "755");
        console.log(chalk.green(`✓ Created and set permissions on ${file}`));
      } catch (error) {
        console.log(chalk.green(`✓ Created ${file}`));
        console.log(
          chalk.yellow(`Note: Could not set execute permissions on ${file}`)
        );
      }
    }
  });
}

// Function to execute script from current directory
function executeScript(scriptName) {
  const scriptPath = path.join(process.cwd(), scriptName);

  if (!fs.existsSync(scriptPath)) {
    throw new Error(`${scriptName} not found in current directory!`);
  }

  // Ensure script has execute permissions
  try {
    fs.chmodSync(scriptPath, "755");
  } catch (error) {
    console.log(
      chalk.yellow(`Warning: Could not set permissions on ${scriptName}`)
    );
  }

  execSync(`./${scriptName}`, { stdio: "inherit" });
}

program
  .version(getPackageVersion())
  .description("Tunn8n - Local n8n with Docker and ngrok integration");

program
  .command("create <project-name>")
  .description("Create a new tunn8n project from template")
  .action((projectName) => {
    console.log(chalk.blue(`Creating new tunn8n project: ${projectName}`));

    try {
      // Check if directory already exists
      if (fs.existsSync(projectName)) {
        console.log(
          chalk.red(`Error: Directory '${projectName}' already exists!`)
        );
        console.log(
          chalk.yellow(
            "Please choose a different project name or remove the existing directory."
          )
        );
        process.exit(1);
      }

      // Create project directory
      fs.mkdirSync(projectName, { recursive: true });
      console.log(chalk.green(`✓ Created project directory: ${projectName}`));

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
        console.log(chalk.green("✓ Created .env file from template"));
      }

      console.log(chalk.green("\n🎉 Project created successfully!"));
      console.log(chalk.yellow("\nNext steps:"));
      console.log(chalk.cyan(`  cd ${projectName}`));
      console.log(chalk.cyan("  # Edit .env file with your configuration"));
      console.log(chalk.cyan("  tunn8n start   # Start services"));
      console.log(chalk.cyan("  tunn8n status  # Check service status"));
    } catch (error) {
      console.log(chalk.red("Error creating project:"), error.message);
      process.exit(1);
    }
  });

program
  .command("start")
  .description("Start n8n with ngrok tunnel")
  .action(() => {
    console.log(chalk.blue("Starting tunn8n services..."));
    try {
      // Check if .env exists
      if (!fs.existsSync(".env")) {
        console.log(chalk.yellow("Warning: .env file not found!"));
        console.log(
          chalk.yellow("Please create .env file from .env.example first")
        );
      }

      executeScript("start.sh");
      console.log(chalk.green("✓ Services started successfully!"));
    } catch (error) {
      console.log(chalk.red("Error starting tunn8n:"), error.message);
      console.log(
        chalk.yellow(
          "Make sure Docker is running and you have proper permissions"
        )
      );
    }
  });

program
  .command("stop")
  .description("Stop all Docker containers for tunn8n project")
  .action(() => {
    console.log(chalk.blue("Stopping tunn8n services..."));
    try {
      executeScript("stop.sh");
      console.log(chalk.green("✓ Services stopped successfully!"));
    } catch (error) {
      console.log(chalk.red("Error stopping tunn8n:"), error.message);

      // Fallback to direct docker command
      try {
        console.log(
          chalk.yellow("Trying fallback method with docker-compose...")
        );
        execSync("docker-compose down", { stdio: "inherit" });
        console.log(chalk.green("✓ Services stopped using fallback method!"));
      } catch (fallbackError) {
        console.log(
          chalk.red("Fallback method also failed:"),
          fallbackError.message
        );
      }
    }
  });

program
  .command("debug")
  .description("Run debug utilities and show logs")
  .action(() => {
    console.log(chalk.blue("Running debug utilities..."));
    try {
      executeScript("debug.sh");
    } catch (error) {
      console.log(chalk.red("Error running debug:"), error.message);
    }
  });

program
  .command("status")
  .description("Check Docker service status and ngrok tunnel information")
  .action(() => {
    console.log(chalk.blue("Checking service status..."));
    try {
      executeScript("status.sh");
    } catch (error) {
      console.log(chalk.red("Error checking status:"), error.message);
    }
  });

program
  .command("init")
  .description("Initialize environment configuration file from template")
  .action(() => {
    if (!fs.existsSync(".env")) {
      if (fs.existsSync(".env.example")) {
        fs.copyFileSync(".env.example", ".env");
        console.log(chalk.green("✓ .env file created from template"));
        console.log(
          chalk.yellow("Please edit .env file with your configuration:")
        );
        console.log(chalk.cyan("  - NGROK_AUTH_TOKEN"));
        console.log(chalk.cyan("  - N8N_PORT"));
        console.log(chalk.cyan("  - Other environment variables"));
      } else {
        console.log(chalk.red("Error: .env.example template not found!"));
      }
    } else {
      console.log(chalk.yellow(".env file already exists"));
      console.log(chalk.gray("Skipping initialization..."));
    }
  });

program
  .command("update")
  .description("Update tunn8n to the latest version")
  .action(() => {
    console.log(chalk.blue("Updating tunn8n to latest version..."));
    try {
      execSync("npm install -g tunn8n@latest", { stdio: "inherit" });
      console.log(chalk.green("✓ tunn8n updated successfully!"));
    } catch (error) {
      console.log(chalk.red("Error updating tunn8n:"), error.message);
    }
  });

program
  .command("version")
  .description("Show tunn8n version information")
  .action(() => {
    console.log(chalk.blue(`tunn8n CLI Version: ${getPackageVersion()}`));
    console.log(chalk.gray("Template: n8n with Docker + Ngrok integration"));
  });

// Show help if no arguments provided
if (process.argv.length === 2) {
  program.outputHelp();
  console.log(chalk.yellow("\nExample usage:"));
  console.log(
    chalk.cyan("  tunn8n create my-project     # Create new project")
  );
  console.log(chalk.cyan("  tunn8n start                # Start services"));
  console.log(chalk.cyan("  tunn8n stop                 # Stop services"));
  console.log(chalk.cyan("  tunn8n status               # Check status"));
}

program.parse(process.argv);
