#!/usr/bin/env node

/**
 * Next.js Project Generator
 * 
 * This script creates a new Next.js application with configurable options
 * and runs directly from the current directory.
 */

const { execSync, exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Define configuration defaults
const defaultConfig = {
  appName: 'my-next-app',
  typescript: true,
  eslint: true,
  tailwind: true,
  srcDir: true,
  appRouter: true,
  importAlias: '@/*',
};

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

/**
 * Prompts the user for a configuration value with a default option
 */
function promptValue(question, defaultValue) {
  return new Promise(resolve => {
    const defaultText = defaultValue !== undefined ? ` (default: ${defaultValue})` : '';
    rl.question(`${question}${defaultText}: `, (answer) => {
      resolve(answer.trim() || defaultValue);
    });
  });
}

/**
 * Prompts the user for a yes/no question
 */
async function promptBoolean(question, defaultValue) {
  const defaultText = defaultValue ? 'Y/n' : 'y/N';
  const response = await promptValue(`${question} [${defaultText}]`, defaultValue ? 'Y' : 'N');
  return response.toLowerCase() === 'y';
}

/**
 * Validates the application name
 */
function validateAppName(name) {
  // Check if name contains only valid characters
  if (!/^[a-zA-Z0-9-_]+$/.test(name)) {
    return 'App name can only contain letters, numbers, hyphens and underscores';
  }
  
  // Check if a directory with this name already exists
  if (fs.existsSync(path.resolve(process.cwd(), name))) {
    return `A directory with the name "${name}" already exists`;
  }
  
  return null;
}

/**
 * Creates the Next.js application with the specified configuration
 */
async function createNextApp(config) {
  // Build the command string
  let command = `npx create-next-app@latest ${config.appName}`;
  command += ` --typescript=${config.typescript}`;
  command += ` --eslint=${config.eslint}`;
  command += ` --tailwind=${config.tailwind}`;
  command += ` --src-dir=${config.srcDir}`;
  command += ` --app=${config.appRouter}`;
  command += ` --import-alias="${config.importAlias}"`;
  
  // Log the command for transparency
  console.log('\n🧪 Executing command:');
  console.log(command);
  console.log('\n⏳ This may take a few minutes...\n');
  
  try {
    // Execute the create-next-app command
    execSync(command, { stdio: 'inherit' });
    return true;
  } catch (error) {
    console.error('\n❌ Failed to create Next.js application:');
    console.error(error.message);
    return false;
  }
}

/**
 * Saves the configuration used to create the app
 */
function saveConfig(config) {
  const configPath = path.join(process.cwd(), config.appName, '.next-app-config.json');
  try {
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log(`\n📝 Configuration saved to ${configPath}`);
  } catch (error) {
    console.error(`\n⚠️ Could not save configuration: ${error.message}`);
  }
}

/**
 * Main function to run the application
 */
async function main() {
  console.log('\n🚀 Next.js Application Creator\n');
  console.log('This utility will walk you through creating a new Next.js application.');
  console.log('Press ^C at any time to quit.\n');
  
  // Get user configuration
  const config = {...defaultConfig};
  
  // Application name with validation
  let nameError;
  do {
    config.appName = await promptValue('Application name', config.appName);
    nameError = validateAppName(config.appName);
    if (nameError) console.log(`❌ ${nameError}`);
  } while (nameError);
  
  // Get other configuration values
  config.typescript = await promptBoolean('Use TypeScript', config.typescript);
  config.eslint = await promptBoolean('Use ESLint', config.eslint);
  config.tailwind = await promptBoolean('Use Tailwind CSS', config.tailwind);
  config.srcDir = await promptBoolean('Use src/ directory', config.srcDir);
  config.appRouter = await promptBoolean('Use App Router (instead of Pages Router)', config.appRouter);
  config.importAlias = await promptValue('Import alias', config.importAlias);
  
  // Confirm the configuration
  console.log('\n📋 Configuration Summary:');
  console.table(config);
  
  const confirmed = await promptBoolean('Create application with these settings', true);
  if (!confirmed) {
    console.log('\n🛑 Operation cancelled by user.');
    rl.close();
    return;
  }
  
  // Create the Next.js application
  const success = await createNextApp(config);
  
  if (success) {
    // Save the configuration
    saveConfig(config);
    
    console.log('\n✅ Next.js application created successfully!');
    console.log('\nNext steps:');
    console.log(`  cd ${config.appName}`);
    console.log('  npm run dev\n');
  }
  
  rl.close();
}

// Handle errors
process.on('uncaughtException', (error) => {
  console.error('\n❌ Unexpected error:');
  console.error(error);
  rl.close();
  process.exit(1);
});

// Run the script
main().catch(error => {
  console.error('\n❌ Error running the script:');
  console.error(error.message);
  rl.close();
  process.exit(1);
});
