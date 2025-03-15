# System Patterns

## Directory Structure

### Memory Bank Organization

```text
memory-bank/
├── projectbrief.md
├── productContext.md
├── systemPatterns.md
├── techContext.md
├── activeContext.md
└── progress.md
```

### Template Organization

```text
python-template/
├── src/                    # Source code
│   ├── __init__.py
│   └── main.py            # FastAPI application
├── tests/                  # Unit tests
│   ├── __init__.py
│   └── test_main.py
├── Dockerfile             # Container configuration
├── environment.yml        # Conda dependencies
├── .pre-commit-config.yaml # Code quality hooks
├── README.md             # Documentation
└── .gitignore           # Version control rules
```

## Template Patterns

### Container-First Architecture

* All execution in containers
* Conda environment management
* No local dependencies
* Consistent environments

### Application Structure

* FastAPI for APIs
* CRUD operations
* Type annotations
* Automated testing

### Development Patterns

* Code quality automation
* Container-based testing
* Documentation standards
* Dependency isolation

### File Structure

* Source in src/
* Tests in tests/
* Configuration at root
* Clear documentation

## Template Management

### Update Patterns

* Container rebuilds
* Dependency updates
* Version control
* Documentation sync

### State Management

* Container state
* Environment isolation
* Configuration tracking
* Version control

## Container Integration

### Structure

* Base Conda image
* Environment setup
* Application layer
* Entry points

### Development Flow

* Local containers
* Automated testing
* Code quality checks
* Documentation

## Quality Assurance

### Code Quality

* Black formatting
* Isort imports
* Flake8 linting
* Pre-commit hooks

### Testing Strategy

* Pytest framework
* API testing
* Container validation
* Documentation verification
