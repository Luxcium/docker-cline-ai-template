#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for template initialization integration tests
describe "Template Initialization Integration Tests"

# Setup test environment for each test
setup() {
    setup_test_environment
    if [ -z "$TEMP_DIR" ]; then
        TEMP_DIR="${TEMPLATE_DIR}/tmp/test-$(date +%s)"
        mkdir -p "$TEMP_DIR"
    fi
    WORKSPACE_DIR="${TEMP_DIR}/workspace"
    mkdir -p "$WORKSPACE_DIR"
}

# Cleanup test environment after each test
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Helper function to create a test project
create_test_project() {
    local template="$1"
    local project_name="test-project-${template}"
    local project_dir="${WORKSPACE_DIR}/${project_name}"
    
    # Create project using template_factory.sh
    mkdir -p "$project_dir"
    cp -r "${TEMPLATE_DIR}/templates/${template}/." "$project_dir/"
    
    # Set environment variables
    export PROJECT_NAME="$project_name"
    export PROJECT_DESCRIPTION="Test project for ${template} template"
    export AUTHOR_NAME="Test Author"
    export AUTHOR_EMAIL="test@example.com"
    export REPOSITORY_URL="https://github.com/test/${project_name}"
    export LICENSE="MIT"
    export DOCKER_SUPPORT="true"
    export PORT="3000"
    
    # Run bootstrap script
    (cd "$project_dir" && ./bootstrap.sh)
    
    echo "$project_dir"
}

# Test base template initialization
test_base_template() {
    local project_dir
    project_dir=$(create_test_project "base")
    
    # Test project directory exists
    assert_dir_exists "$project_dir" "Project directory should exist"
    
    # Test Git repository initialization
    assert_dir_exists "${project_dir}/.git" "Git repository should be initialized"
    
    # Test VS Code configuration
    assert_dir_exists "${project_dir}/.vscode" "VS Code directory should exist"
    
    # Test essential files
    assert_file_exists "${project_dir}/README.md" "README.md should exist"
    assert_file_exists "${project_dir}/.gitignore" ".gitignore should exist"
    assert_file_exists "${project_dir}/Dockerfile" "Dockerfile should exist"
    assert_file_exists "${project_dir}/docker-compose.yml" "docker-compose.yml should exist"
    
    # Test Git commit
    local has_commits
    has_commits=$(cd "$project_dir" && git log --oneline 2>/dev/null || echo "")
    assert_contains "$has_commits" "Initial commit" "Should have initial commit"
    echo "$project_dir"
}

# Test base template initialization
it "should initialize base template correctly" {
    local _test_init() {
        setup
        local project_dir
        project_dir=$(test_base_template)
        cleanup
    }
    _test_init
}

# Run all tests
run_tests "$0"
