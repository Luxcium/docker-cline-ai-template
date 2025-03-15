#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for template initialization
describe "Template Initialization Integration Tests"

# Common variables
TEST_WORKSPACE=""
CURRENT_TEMPLATE=""

# Setup function for each test
setup() {
    TEST_WORKSPACE="${TEMP_DIR}/workspace"
    mkdir -p "$TEST_WORKSPACE"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
    
    # Unset any environment variables that might have been set
    unset PROJECT_NAME
    unset PROJECT_DESCRIPTION
    unset AUTHOR_NAME
    unset AUTHOR_EMAIL
    unset REPOSITORY_URL
    unset LICENSE
    unset DOCKER_SUPPORT
    unset PORT
}

# Helper function to set common environment variables
set_common_env_vars() {
    export PROJECT_NAME="test-project"
    export PROJECT_DESCRIPTION="Test project description"
    export AUTHOR_NAME="Test Author"
    export AUTHOR_EMAIL="test@example.com"
    export REPOSITORY_URL="https://github.com/test/test-project"
    export LICENSE="MIT"
    export DOCKER_SUPPORT="true"
    export PORT="3000"
}

# Helper function to verify common project structure
verify_common_structure() {
    local project_dir="$1"
    
    # Check basic project structure
    assert_dir_exists "$project_dir" "Project directory should exist"
    assert_dir_exists "${project_dir}/.git" "Git repository should be initialized"
    assert_dir_exists "${project_dir}/.vscode" "VS Code directory should exist"
    
    # Check common files
    assert_file_exists "${project_dir}/README.md" "README.md should exist"
    assert_file_exists "${project_dir}/.gitignore" ".gitignore should exist"
    
    # If Docker support is enabled, check Docker files
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        assert_file_exists "${project_dir}/Dockerfile" "Dockerfile should exist"
        assert_file_exists "${project_dir}/docker-compose.yml" "docker-compose.yml should exist"
    fi
    
    # Verify Git initialization
    local has_commits
    has_commits=$(cd "$project_dir" && git log --oneline 2>/dev/null || echo "")
    assert_contains "$has_commits" "Initial commit" "Should have initial commit"
}

# Test base template initialization
it "should initialize base template correctly" {
    setup
    set_common_env_vars
    CURRENT_TEMPLATE="base"
    
    # Create project directory
    local project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}-${CURRENT_TEMPLATE}"
    mkdir -p "$project_dir"
    
    # Copy template files
    cp -r "${TEMPLATE_DIR}/templates/${CURRENT_TEMPLATE}/." "$project_dir/"
    
    # Run bootstrap script
    (cd "$project_dir" && ./bootstrap.sh)
    
    # Verify common structure
    verify_common_structure "$project_dir"
    
    cleanup
}

# Test Node.js template initialization
it "should initialize Node.js template correctly" {
    setup
    set_common_env_vars
    CURRENT_TEMPLATE="node"
    
    # Create project directory
    local project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}-${CURRENT_TEMPLATE}"
    mkdir -p "$project_dir"
    
    # Copy template files
    cp -r "${TEMPLATE_DIR}/templates/${CURRENT_TEMPLATE}/." "$project_dir/"
    
    # Run setup script
    (cd "$project_dir" && ./setup.sh)
    
    # Verify common structure
    verify_common_structure "$project_dir"
    
    # Verify Node.js specific structure
    assert_file_exists "${project_dir}/package.json" "package.json should exist"
    assert_dir_exists "${project_dir}/src" "src directory should exist"
    assert_file_exists "${project_dir}/src/index.js" "index.js should exist"
    assert_dir_exists "${project_dir}/src/tests" "tests directory should exist"
    
    # Verify package.json content
    local package_json
    package_json=$(cat "${project_dir}/package.json")
    assert_contains "$package_json" "\"name\": \"${PROJECT_NAME}\"" "package.json should have correct project name"
    assert_contains "$package_json" "\"description\": \"${PROJECT_DESCRIPTION}\"" "package.json should have correct description"
    
    cleanup
}

# Test Python template initialization
it "should initialize Python template correctly" {
    setup
    set_common_env_vars
    CURRENT_TEMPLATE="python"
    
    # Create project directory
    local project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}-${CURRENT_TEMPLATE}"
    mkdir -p "$project_dir"
    
    # Copy template files
    cp -r "${TEMPLATE_DIR}/templates/${CURRENT_TEMPLATE}/." "$project_dir/"
    
    # Run bootstrap script (if exists, otherwise might need to handle differently)
    if [ -f "${project_dir}/bootstrap.sh" ]; then
        (cd "$project_dir" && ./bootstrap.sh)
    fi
    
    # Verify common structure
    verify_common_structure "$project_dir"
    
    # Verify Python specific structure
    assert_file_exists "${project_dir}/pyproject.toml" "pyproject.toml should exist"
    assert_file_exists "${project_dir}/environment.yml" "environment.yml should exist"
    assert_dir_exists "${project_dir}/src" "src directory should exist"
    assert_dir_exists "${project_dir}/tests" "tests directory should exist"
    assert_file_exists "${project_dir}/src/__init__.py" "__init__.py should exist"
    assert_file_exists "${project_dir}/src/main.py" "main.py should exist"
    
    # Verify environment.yml content
    local env_yml
    env_yml=$(cat "${project_dir}/environment.yml")
    assert_contains "$env_yml" "name: ${PROJECT_NAME}" "environment.yml should have correct project name"
    
    cleanup
}

# Test template error handling
it "should handle template initialization errors gracefully" {
    setup
    set_common_env_vars
    
    # Test with missing template directory
    local project_dir="${TEST_WORKSPACE}/missing-template"
    mkdir -p "$project_dir"
    
    # Try to copy non-existent template
    if cp -r "${TEMPLATE_DIR}/templates/nonexistent/." "$project_dir/" 2>/dev/null; then
        fail "Should not be able to copy non-existent template"
    fi
    
    # Test with invalid project name
    export PROJECT_NAME="invalid/name"
    project_dir="${TEST_WORKSPACE}/invalid-name"
    mkdir -p "$project_dir"
    cp -r "${TEMPLATE_DIR}/templates/base/." "$project_dir/"
    
    local output
    output=$(cd "$project_dir" && ./bootstrap.sh 2>&1 || true)
    assert_contains "$output" "error" "Should show error for invalid project name"
    
    cleanup
}

# Run the tests
run_tests "$(basename "$0")"
