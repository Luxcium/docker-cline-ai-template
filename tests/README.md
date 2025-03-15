# Template System Testing Framework

This directory contains the testing infrastructure for the template system. The test
framework is designed to ensure reliability and correctness of template
initialization, customization, and usage.

## Test Structure

```text
tests/
├── framework/           # Core testing framework
│   └── test_framework.sh  # Base testing utilities and functions
├── unit/               # Unit tests for individual components
│   └── test_base_bootstrap.sh  # Tests for base template bootstrap
├── integration/        # Integration tests across components
│   └── test_template_initialization.sh  # Template initialization tests
├── e2e/               # End-to-end workflow tests
│   └── test_user_workflow.sh  # Complete user workflow tests
├── run_tests.sh       # Main test runner script
└── README.md          # Test documentation
```

## Running Tests

### Running All Tests

To run the complete test suite:

```bash
./tests/run_tests.sh
```

This will execute all test files in the following order:

1. Unit tests
2. Integration tests
3. End-to-end tests

### Running Specific Test Types

You can run specific test files directly:

```bash
# Run unit tests
./tests/unit/test_base_bootstrap.sh

# Run integration tests
./tests/integration/test_template_initialization.sh

# Run end-to-end tests
./tests/e2e/test_user_workflow.sh
```

## Test Types

### Unit Tests

* Focus on individual components and functions
* Test specific behaviors in isolation
* Quick to run and help locate issues
* Example: Testing placeholder replacement in bootstrap script

### Integration Tests

* Test interaction between components
* Verify template initialization process
* Ensure different parts work together
* Example: Testing complete template setup process

### End-to-End Tests

* Test complete user workflows
* Simulate real-world usage
* Verify system works as a whole
* Example: Creating a project from template and verifying it works

## Writing Tests

### Test Framework Features

The test framework provides several utilities for writing tests:

```bash
# Define a test suite
describe "Test Suite Name"

# Define individual test
it "should do something specific" {
    # Test code here
}

# Assertions
assert_equals "expected" "actual" "Message"
assert_not_equals "unexpected" "actual" "Message"
assert_file_exists "path/to/file" "Message"
assert_dir_exists "path/to/dir" "Message"
assert_contains "haystack" "needle" "Message"

# Setup and cleanup
setup() {
    # Setup code here
}

cleanup() {
    # Cleanup code here
}
```

### Example Test

```bash
#!/bin/bash
source "$(dirname "$0")/../framework/test_framework.sh"

describe "Example Test Suite"

# Define test-wide variables
TEST_DIR=""

# Setup function run before each test
setup() {
    TEST_DIR=$(mktemp -d)
}

# Cleanup function run after each test
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Individual test
it "should create required files" {
    setup
    
    # Test code
    touch "${TEST_DIR}/test.txt"
    assert_file_exists "${TEST_DIR}/test.txt" "Test file should exist"
    
    cleanup
}

# Run the tests
run_tests "$(basename "$0")"
```

## Test Environment

Tests run in a controlled environment where:

* Each test gets a clean temporary directory
* Environment variables are reset between tests
* File system changes are isolated
* Docker containers are cleaned up
* Git repositories are properly initialized/cleaned

## Adding New Tests

When adding new tests:

1. Choose the appropriate test type (unit/integration/e2e)
2. Create a new test file in the corresponding directory
3. Name the file `test_*.sh`
4. Make the file executable (`chmod +x`)
5. Follow the test template structure
6. Include setup and cleanup functions
7. Add clear test descriptions
8. Run tests to verify

## Best Practices

1. **Isolation**: Each test should be independent
2. **Cleanup**: Always clean up resources after tests
3. **Clear Names**: Use descriptive test names
4. **Focused Tests**: Each test should verify one thing
5. **Setup/Teardown**: Use setup and cleanup functions
6. **Error Handling**: Test error cases
7. **Documentation**: Comment complex test logic
8. **Deterministic**: Tests should be reproducible

## Debugging Tests

When tests fail:

1. Run specific test file directly
2. Check test output for error messages
3. Examine test environment in cleanup failure
4. Use `set -x` for shell debugging
5. Check system requirements
6. Verify test dependencies

## System Requirements

* Bash 4.0+
* Git
* Docker (for container tests)
* Node.js (for Node.js template tests)
* Python & Conda (for Python template tests)

## Contributing

When contributing new tests:

1. Follow the established pattern
2. Add documentation
3. Test error cases
4. Verify cleanup
5. Run full test suite
6. Update this README if needed
