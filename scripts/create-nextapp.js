#!/usr/bin/env node

/**
 * Next.js Project Generator Script
 * 
 * This script automates the creation of a Next.js application using create-next-app
 * with configurable default settings.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Default configuration for Next.js app
const defaultConfig = {
  appName: 'my-nextjs-app',
  typescript: true,
  eslint: true,
  tailwind: true,
  src: true,
  app: true,
  importAlias: '@/*',
};

// Create interface for command line input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

/**
 * Prompts the user for configuration values with defaults
 * @param {string} question - The prompt to display
 * @param {any} defaultValue - The default value to use
 * @returns {Promise<string>} - The user's answer or default value
 */
const prompt = (question, defaultValue) => {
  return new Promise((resolve) => {
    const defaultStr = defaultValue !== undefined ? ` (default: ${defaultValue})` : '';
    rl.question(`${question}${defaultStr}: `, (answer) => {
      resolve(answer || defaultValue);
    });
  });
};

/**
 * Prompts the user for yes/no configuration values
 * @param {string} question - The prompt to display
 * @param {boolean} defaultValue - The default value to use
 * @returns {Promise<boolean>} - The user's answer as boolean
 */
const promptBoolean = async (question, defaultValue) => {
  const answer = await prompt(`${question} (y/n)`, defaultValue ? 'y' : 'n');
  return answer.toLowerCase() === 'y';
};

/**
 * Main function to run the script
 */
async function main() {
  console.log('\n🚀 Next.js Project Generator\n');
  
  // Get user configuration or use defaults
  const config = { ...defaultConfig };
  
  config.appName = await prompt('Project name', config.appName);
  config.typescript = await promptBoolean('Use TypeScript', config.typescript);
  config.eslint = await promptBoolean('Use ESLint', config.eslint);
  config.tailwind = await promptBoolean('Use Tailwind CSS', config.tailwind);
  config.src = await promptBoolean('Use src/ directory', config.src);
  config.app = await promptBoolean('Use App Router', config.app);
  config.importAlias = await prompt('Import alias', config.importAlias);
  
  rl.close();
  
  console.log('\n📋 Creating Next.js app with the following configuration:');
  console.log(JSON.stringify(config, null, 2));
  console.log('\n⏳ This may take a few minutes...\n');
  
  try {
    // Build the create-next-app command with appropriate flags
    let command = `npx create-next-app@latest ${config.appName}`;
    command += ` --typescript=${config.typescript}`;
    command += ` --eslint=${config.eslint}`;
    command += ` --tailwind=${config.tailwind}`;
    command += ` --src-dir=${config.src}`;
    command += ` --app=${config.app}`;
    command += ` --import-alias="${config.importAlias}"`;
    command += ` --use-npm`;
    
    // Execute the command
    execSync(command, { stdio: 'inherit' });
    
    console.log(`\n✅ Success! Created ${config.appName} at ${path.resolve(config.appName)}`);
    console.log('\nNext steps:');
    console.log(`  cd ${config.appName}`);
    console.log('  npm run dev\n');
    
    // Save the used configuration for reference
    const configPath = path.join(process.cwd(), config.appName, 'nextjs-config.json');
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log(`Configuration saved to ${configPath}`);
    
  } catch (error) {
    console.error('\n❌ Error creating Next.js app:');
    console.error(error.message);
    process.exit(1);
  }
}

// Run the script
main().catch(error => {
  console.error('\n❌ Unexpected error:');
  console.error(error);
  process.exit(1);
});
