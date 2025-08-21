#!/usr/bin/env node

const { program } = require("commander");
const { execSync } = require("child_process");
const chalk = require("chalk");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

program
  .version("1.0.0")
  .description("Tunn8n - Local n8n with Docker and ngrok integration");

program
  .command("create <project-name>")
  .description("Create a new tunn8n project from template")
  .option("-t, --template <template>", "Template version to use", "latest")
  .action((projectName, options) => {
    console.log(chalk.blue(`Creating new tunn8n project: ${projectName}`));
    console.log(chalk.gray(`Using template: ${options.template}`));

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

      // Copy template files
      const templateFiles = [
        "docker-compose.yml",
        ".env.example",
        "start.sh",
        "debug.sh",
        "check-status.sh",
        ".gitignore",
        "README.md",
      ];

      templateFiles.forEach((file) => {
        const sourcePath = path.join(__dirname, file);
        const targetPath = path.join(projectName, file);

        if (fs.existsSync(sourcePath)) {
          fs.copyFileSync(sourcePath, targetPath);
          console.log(chalk.green(`✓ Created ${file}`));
        }
      });

      // Create .env from .env.example
      const envExamplePath = path.join(projectName, ".env.example");
      const envFilePath = path.join(projectName, ".env");

      if (fs.existsSync(envExamplePath)) {
        fs.copyFileSync(envExamplePath, envFilePath);
        console.log(chalk.green("✓ Created .env file from template"));
      }

      console.log(chalk.green("\n🎉 Project created successfully!"));
      console.log(chalk.yellow("\nNext steps:"));
      console.log(chalk.cyan(`  cd ${projectName}`));
      console.log(chalk.cyan("  # Edit .env file with your configuration"));
      console.log(chalk.cyan("  tunn8n init    # Initialize environment"));
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
          chalk.yellow("Run 'tunn8n init' first or create .env manually")
        );
      }

      execSync("./start.sh", { stdio: "inherit" });
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
  .command("debug")
  .description("Run debug utilities and show logs")
  .action(() => {
    console.log(chalk.blue("Running debug utilities..."));
    try {
      execSync("./debug.sh", { stdio: "inherit" });
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
      execSync("./check-status.sh", { stdio: "inherit" });
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
    console.log(chalk.blue("tunn8n CLI Version: 1.0.0"));
    console.log(chalk.gray("Template: n8n with Docker + Ngrok integration"));
  });

// Show help if no arguments provided
if (process.argv.length === 2) {
  program.outputHelp();
  console.log(chalk.yellow("\nExample usage:"));
  console.log(
    chalk.cyan("  tunn8n create my-project     # Create new project")
  );
  console.log(
    chalk.cyan("  tunn8n init                 # Initialize environment")
  );
  console.log(chalk.cyan("  tunn8n start                # Start services"));
  console.log(chalk.cyan("  tunn8n status               # Check status"));
}

program.parse(process.argv);
