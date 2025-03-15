# Meta-Level Validation Tests

This directory contains test suites specifically designed to validate the Template
Nursery at a meta-level, ensuring the robustness and resilience of the template
factory system.

## Test Categories

### Template Creation Tests (`test_template_creation.sh`)

* Template generation script validation
* CLI tool validation
* Automated initialization testing

### Dependency Management Tests (`test_dependency_management.sh`)

* Production vs Development dependency validation
* Update impact testing
* Automated dependency checks

### Environment Tests (`test_environment.sh`)

* Container build validation
* Environment isolation verification
* Build reproducibility testing

### Lifecycle Tests (`test_lifecycle.sh`)

* Project bootstrapping validation
* Integration testing
* Automated test suite validation

### Error Handling Tests (`test_error_handling.sh`)

* Error feedback validation
* Dependency failure testing
* Rollback mechanism verification

### CI/CD Tests (`test_cicd.sh`)

* Pipeline execution validation
* Template integrity checks
* Update trigger verification

### Documentation Tests (`test_documentation.sh`)

* README validation
* Documentation accuracy checks
* Usability verification

## Running Tests

### Full Meta-Level Validation

```bash
./run_meta_tests.sh
```

### Individual Categories

```bash
# Template creation validation
./test_template_creation.sh

# Dependency management validation
./test_dependency_management.sh

# Environment validation
./test_environment.sh

# Lifecycle validation
./test_lifecycle.sh

# Error handling validation
./test_error_handling.sh

# CI/CD validation
./test_cicd.sh

# Documentation validation
./test_documentation.sh
```

## Test Framework Features

The meta-level test framework extends the base test framework with additional
capabilities:

* Dependency version comparison utilities
* Container health check functions
* Documentation validation tools
* CI/CD pipeline simulation

## Writing Meta-Level Tests

### Example Test Structure

```bash
#!/bin/bash
source "$(dirname "$0")/../framework/test_framework.sh"

describe "Meta-Level Test Suite"

setup() {
    # Setup meta-level test environment
}

cleanup() {
    # Cleanup meta-level test artifacts
}

it "should validate meta-level requirement" {
    # Test implementation
}

# Run the tests
run_tests "$(basename "$0")"
```

## Best Practices

1. Focus on system-level validation
2. Test template factory behavior
3. Validate cross-cutting concerns
4. Ensure comprehensive error handling
5. Verify documentation accuracy
6. Test update mechanisms
7. Validate build reproducibility

## Adding New Tests

When adding new meta-level tests:

1. Choose the appropriate category
2. Follow the established patterns
3. Include comprehensive validation
4. Test error conditions
5. Verify rollback mechanisms
6. Document test purposes
7. Update this README as needed
