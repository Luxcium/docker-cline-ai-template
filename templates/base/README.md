# {{projectName}}

{{projectDescription}}

## Features

* Memory Bank System for comprehensive project documentation
* Workspace validation and diagnostic tools
* VSCode integration with standardized settings
* Documentation standards enforcement
{{#if dockerSupport}}
* Docker containerization support
{{/if}}

## Prerequisites

Before you begin, ensure you have met the following requirements:

* Git 2.0+
* VSCode with recommended extensions
{{#if dockerSupport}}
* Docker Engine 20.10+
{{/if}}

## Installation

Follow these steps to install and set up the project:

```bash
# Clone the repository
git clone {{repositoryUrl}}

# Navigate to the project directory
cd {{projectName}}

# Install dependencies
{{installCommand}}
```

## Memory Bank Structure

This project uses a memory bank system to maintain comprehensive project documentation:

```text
memory-bank/
├── projectbrief.md    # Core requirements and goals
├── productContext.md  # Project purpose and user experience goals
├── systemPatterns.md  # Architecture and design patterns
├── techContext.md    # Technical stack and dependencies
├── activeContext.md  # Current work focus and decisions
└── progress.md       # Development status and known issues
```

### Memory Bank Usage

1. Review files in the memory bank to understand project context
2. Update documentation as the project evolves
3. Use the memory bank for onboarding new team members
4. Maintain technical decisions and architectural patterns

## Development

### Setting Up Development Environment

1. Clone the repository:

```bash
git clone {{repositoryUrl}}
cd {{projectName}}
```

2. Review VSCode settings in `.vscode/settings.json`

3. Install recommended extensions when prompted by VSCode

4. Start development:

```bash
{{devCommand}}
```

{{#if dockerSupport}}
### Using Docker

This project includes Docker support. To run using Docker:

```bash
# Build the Docker image
docker build -t {{projectName}} .

# Run the container
docker run -p {{port}}:{{port}} {{projectName}}
```
{{/if}}

## Workspace Validation

This project includes built-in workspace validation:

* Automatic format on save
* Markdown linting with customized rules
* Documentation standard enforcement
* Memory bank structure validation

### Running Validation

1. VSCode will automatically validate files on save
2. Check the Problems panel for any warnings or errors
3. Follow suggested fixes to maintain project standards

## Testing

Run the test suite to validate your changes:

```bash
{{testCommand}}
```

The test suite includes:
* Unit tests for core functionality
* Integration tests for component interaction
* End-to-end workflow tests
* Workspace validation tests

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the {{license}} License - see the [LICENSE](LICENSE) file for details.

## Author

{{authorName}}
{{authorEmail}}

## Acknowledgments

* [Acknowledgment 1]
* [Acknowledgment 2]
* [Acknowledgment 3]
