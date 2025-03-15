# Docker-Cline AI Template Factory

Generate production-ready project templates with built-in memory bank and test framework integration.

## Features

* Memory Bank System for project documentation and context
* Docker integration with customizable configurations
* Workspace validation and diagnostic tools
* Comprehensive test framework
* Multiple template support (Base, Node.js, Python)
* Automated project initialization
* VSCode integration with standardized settings

## Requirements

* Bash 4.0+
* Git 2.0+
* Docker Engine (optional, for Docker support)
* Node.js (for Node.js templates)
* Python & Conda (for Python templates)

## Usage

1. Run the template factory:

```bash
./template_factory.sh
```

2. Select a template:
    * `base`: Basic project structure with Docker support
    * `node`: Node.js project with Jest for testing
    * `python`: Python project with pytest and conda environment

3. Provide project details:
    * Project name
    * Description
    * Author information
    * Repository URL
    * License
    * Docker configuration

4. The factory will:
    * Create project structure
    * Initialize memory bank
    * Setup development environment
    * Configure Docker (if enabled)
    * Run validation tests
    * Initialize Git repository

## Memory Bank Structure

Each generated project includes a memory bank with:

* `projectbrief.md`: Core requirements and goals
* `productContext.md`: Project purpose and user experience goals
* `systemPatterns.md`: Architecture and design patterns
* `techContext.md`: Technical stack and dependencies
* `activeContext.md`: Current work focus and decisions
* `progress.md`: Development status and known issues

## Directory Structure

```text
generated-project/
├── memory-bank/          # Project documentation and context
├── .vscode/             # VSCode configuration
├── .clinerules          # Cline AI configuration
├── src/                 # Source code directory
├── tests/              # Test directory
├── docker-compose.yml  # Docker composition (if enabled)
├── Dockerfile         # Docker configuration (if enabled)
└── README.md         # Project documentation
```

## Development Workflow

1. Review the memory bank documentation
2. Configure development environment
3. Implement core features
4. Run tests using the integrated test framework
5. Update memory bank as project evolves
6. Use Docker for containerized development (if enabled)

## Testing

All generated projects come with:

* Unit tests for core functionality
* Integration tests for component interaction
* End-to-end tests for complete workflows
* Workspace validation tests

To run tests on a generated project:

```bash
cd your-project
./tests/run_tests.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Submit a pull request

## License

MIT License
