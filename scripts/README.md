# Scripts Directory

This directory contains utility scripts for project setup and management.

## Available Scripts

### create-nextapp.js

A utility script to create a new Next.js application with configurable options.

#### Usage

```bash
# Make the script executable first
chmod +x ./scripts/create-nextapp.js

# Run the script
./scripts/create-nextapp.js
```

#### Features

* Interactive prompts with sensible defaults
* Configurable TypeScript support
* Optional Tailwind CSS integration
* App Router / Pages Router selection
* ESLint configuration
* Custom import aliases
* Automated project structure setup

#### Default Configuration

The script uses the following defaults, which can be changed during execution:

* Project name: my-nextjs-app
* TypeScript: Enabled
* ESLint: Enabled
* Tailwind CSS: Enabled
* src/ directory: Enabled
* App Router: Enabled
* Import alias: @/*
