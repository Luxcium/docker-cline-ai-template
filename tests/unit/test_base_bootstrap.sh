#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for base template bootstrap script
describe "Base Template Bootstrap"

# Setup function for each test
setup() {
    # Create temporary project directory
    PROJECT_DIR="${TEMP_DIR}/test-project"
    mkdir -p "$PROJECT_DIR"
    
    # Copy base template files to test directory
    cp -r "${TEMPLATE_DIR}/templates/base/." "$PROJECT_DIR/"
    
    # Set test variables
    export PROJECT_NAME="test-project"
    export PROJECT_DESCRIPTION="A test project"
    export AUTHOR_NAME="Test Author"
    export AUTHOR_EMAIL="test@example.com"
    export REPOSITORY_URL="https://github.com/test/test-project"
    export LICENSE="MIT"
    export DOCKER_SUPPORT="true"
    export PORT="3000"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR"
    fi
    
    # Unset test variables
    unset PROJECT_NAME
    unset PROJECT_DESCRIPTION
    unset AUTHOR_NAME
    unset AUTHOR_EMAIL
    unset REPOSITORY_URL
    unset LICENSE
    unset DOCKER_SUPPORT
    unset PORT
}

# Test bootstrap.sh file exists
it "should have bootstrap.sh file" {
    setup
    
    assert_file_exists "${PROJECT_DIR}/bootstrap.sh" "Bootstrap script should exist"
    
    cleanup
}

# Test bootstrap.sh permissions
it "should have executable bootstrap.sh" {
    setup
    
    chmod +x "${PROJECT_DIR}/bootstrap.sh"
    local perms=$(stat -c %a "${PROJECT_DIR}/bootstrap.sh")
    assert_contains "$perms" "755" "Bootstrap script should be executable"
    
    cleanup
}

# Test environment variable validation
it "should validate required environment variables" {
    setup
    
    # Unset required variable
    unset PROJECT_NAME
    
    # Run bootstrap script and capture output
    local output
    output=$(cd "$PROJECT_DIR" && ./bootstrap.sh 2>&1 || true)
    
    assert_contains "$output" "Error: PROJECT_NAME" "Should error on missing PROJECT_NAME"
    
    cleanup
}

# Test template file processing
it "should process template placeholders" {
    setup
    
    # Create a test file with placeholders
    echo "Project: {{projectName}}" > "${PROJECT_DIR}/test.md"
    echo "Author: {{authorName}}" >> "${PROJECT_DIR}/test.md"
    
    # Run bootstrap script
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    # Check if placeholders were replaced
    local content
    content=$(cat "${PROJECT_DIR}/test.md")
    assert_contains "$content" "Project: test-project" "Should replace projectName placeholder"
    assert_contains "$content" "Author: Test Author" "Should replace authorName placeholder"
    
    cleanup
}

# Test Docker support conditional sections
it "should handle Docker support conditionals" {
    setup
    
    # Create test file with Docker conditional
    cat > "${PROJECT_DIR}/test.txt" << 'EOF'
{{#if dockerSupport}}
docker:
  image: test
{{/if}}
EOF
    
    # Test with Docker support enabled
    export DOCKER_SUPPORT="true"
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    local content
    content=$(cat "${PROJECT_DIR}/test.txt")
    assert_contains "$content" "docker:" "Should include Docker section when enabled"
    
    # Test with Docker support disabled
    export DOCKER_SUPPORT="false"
    echo "{{#if dockerSupport}}docker: image: test{{/if}}" > "${PROJECT_DIR}/test.txt"
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    content=$(cat "${PROJECT_DIR}/test.txt")
    assert_not_equals "$content" "docker: image: test" "Should exclude Docker section when disabled"
    
    cleanup
}

# Test Git initialization
it "should initialize Git repository" {
    setup
    
    # Run bootstrap script
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    # Check if Git repository was initialized
    assert_dir_exists "${PROJECT_DIR}/.git" "Git repository should be initialized"
    
    # Check if initial commit was made
    local has_commits
    has_commits=$(cd "$PROJECT_DIR" && git log --oneline 2>/dev/null || echo "")
    assert_contains "$has_commits" "Initial commit" "Should have initial commit"
    
    cleanup
}

# Test development environment setup
it "should setup development environment" {
    setup
    
    # Run bootstrap script
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    # Check if VS Code directory was created
    assert_dir_exists "${PROJECT_DIR}/.vscode" "VS Code directory should be created"
    
    # If Docker is enabled, check Docker files
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        assert_file_exists "${PROJECT_DIR}/Dockerfile" "Dockerfile should exist when Docker is enabled"
    fi
    
    cleanup
}

# Run all tests
run_tests "$(basename "$0")"
