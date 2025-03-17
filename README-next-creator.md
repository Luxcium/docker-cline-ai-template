# Next.js Application Creator

A utility script for quickly creating Next.js applications with custom configurations.

## Features

* Interactive prompts with smart defaults
* TypeScript support configuration
* ESLint integration options
* Tailwind CSS setup
* App Router / Pages Router selection
* Source directory structure options
* Custom import alias configuration

## Usage

### Quick Start

Run the quick start script:

```bash
./create-next.sh
```

### Manual Execution

Make the script executable:

```bash
chmod +x ./next-app-creator.js
```

Run the script:

```bash
./next-app-creator.js
```

Follow the interactive prompts to configure and create your Next.js application.

## Configuration Options

* **App Name:** The name of your Next.js application
* **TypeScript:** Enable/disable TypeScript support
* **ESLint:** Enable/disable ESLint configuration
* **Tailwind CSS:** Enable/disable Tailwind CSS setup
* **Source Directory:** Use src/ directory structure
* **App Router:** Use the App Router (vs Pages Router)
* **Import Alias:** Configure import aliases (default: @/*)

## After Creation

After your Next.js application is created:

1. Change to your application directory:
   ```bash
   cd your-app-name
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Open your browser and navigate to `http://localhost:3000`

## Requirements

* Node.js 14.6.0 or later
* npm 6.0.0 or later
```

The configuration used to create your application is saved to `.next-app-config.json`
in your project root for future reference.
