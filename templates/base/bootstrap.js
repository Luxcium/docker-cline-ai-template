#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class ProjectBootstrapper {
  constructor(config) {
    this.config = {
      projectName: '',
      projectDescription: '',
      authorName: '',
      authorEmail: '',
      repositoryUrl: '',
      license: 'MIT',
      dockerSupport: false,
      port: 3000,
      ...config
    };
    
    this.templateVariables = new Map();
    for (const [key, value] of Object.entries(this.config)) {
      this.templateVariables.set(`{{${key}}}`, value);
      // Support Handlebars-style conditionals
      if (typeof value === 'boolean') {
        this.templateVariables.set(`{{#if ${key}}}`, value ? '' : '/*');
        this.templateVariables.set(`{{/if}}`, value ? '' : '*/');
      }
    }
  }

  async processFile(filePath) {
    try {
      let content = await fs.readFile(filePath, 'utf8');
      
      for (const [placeholder, value] of this.templateVariables) {
        content = content.replace(new RegExp(placeholder, 'g'), value);
      }
      
      await fs.writeFile(filePath, content);
      console.log(`✅ Processed: ${filePath}`);
    } catch (error) {
      console.error(`❌ Error processing ${filePath}:`, error);
      throw error;
    }
  }

  async processDirectory(directory) {
    try {
      const entries = await fs.readdir(directory, { withFileTypes: true });
      
      for (const entry of entries) {
        const fullPath = path.join(directory, entry.name);
        
        if (entry.isDirectory()) {
          await this.processDirectory(fullPath);
        } else {
          await this.processFile(fullPath);
        }
      }
    } catch (error) {
      console.error(`❌ Error processing directory ${directory}:`, error);
      throw error;
    }
  }

  async initGit() {
    try {
      execSync('git init', { stdio: 'inherit' });
      execSync('git add .', { stdio: 'inherit' });
      execSync('git commit -m "Initial commit"', { stdio: 'inherit' });
      console.log('✅ Git repository initialized');
    } catch (error) {
      console.error('❌ Error initializing Git:', error);
      throw error;
    }
  }

  async setupDevEnvironment() {
    try {
      if (this.config.dockerSupport) {
        console.log('🐳 Setting up Docker environment...');
        // Docker setup logic here
      }
      
      // VSCode setup
      await fs.mkdir('.vscode', { recursive: true });
      // Add VSCode settings...
      
      console.log('✅ Development environment configured');
    } catch (error) {
      console.error('❌ Error setting up dev environment:', error);
      throw error;
    }
  }

  async bootstrap() {
    try {
      console.log('🚀 Starting project bootstrap...');
      
      // Process all template files
      await this.processDirectory(process.cwd());
      
      // Initialize Git repository
      await this.initGit();
      
      // Setup development environment
      await this.setupDevEnvironment();
      
      console.log(`✨ Project ${this.config.projectName} has been bootstrapped successfully!`);
    } catch (error) {
      console.error('❌ Bootstrap failed:', error);
      process.exit(1);
    }
  }
}

// Example usage (will be replaced by CLI interaction):
const bootstrapper = new ProjectBootstrapper({
  projectName: '{{projectName}}',
  projectDescription: '{{projectDescription}}',
  authorName: '{{authorName}}',
  authorEmail: '{{authorEmail}}',
  repositoryUrl: '{{repositoryUrl}}',
  license: '{{license}}',
  dockerSupport: {{dockerSupport}},
  port: {{port}}
});

bootstrapper.bootstrap();
