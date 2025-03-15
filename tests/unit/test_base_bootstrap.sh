#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for base template bootstrap script
describe "Base Template Bootstrap"

# Setup function for each test
setup() {
    setup_test_environment
    if [ -z "$TEMP_DIR" ]; then
        TEMP_DIR="${TEMPLATE_DIR}/tmp/test-$(date +%s)"
        mkdir -p "$TEMP_DIR"
    fi
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
    local perms
    perms=$(stat -c %a "${PROJECT_DIR}/bootstrap.sh")
    assert_contains "$perms" "755" "Bootstrap script should be executable"
    cleanup
}

# Test environment variable validation
it "should validate required environment variables" {
    setup
    unset PROJECT_NAME
    local output
    output=$(cd "$PROJECT_DIR" && ./bootstrap.sh 2>&1 || true)
    assert_contains "$output" "Error: PROJECT_NAME" "Should error on missing PROJECT_NAME"
    cleanup
}

# Test template file processing
it "should process template placeholders" {
    setup
    echo "Project: {{projectName}}" > "${PROJECT_DIR}/test.md"
    echo "Author: {{authorName}}" >> "${PROJECT_DIR}/test.md"
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    local content
    content=$(cat "${PROJECT_DIR}/test.md")
    assert_contains "$content" "Project: test-project" "Should replace projectName placeholder"
    assert_contains "$content" "Author: Test Author" "Should replace authorName placeholder"
    cleanup
}

# Test Docker support conditional sections
it "should handle Docker support conditionals" {
    setup
    cat > "${PROJECT_DIR}/test.txt" << 'EOF'
{{#if dockerSupport}}
docker:
  image: test
{{/if}}
EOF
    export DOCKER_SUPPORT="true"
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    local content
    content=$(cat "${PROJECT_DIR}/test.txt")
    assert_contains "$content" "docker:" "Should include Docker section when enabled"
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
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    assert_dir_exists "${PROJECT_DIR}/.git" "Git repository should be initialized"
    local has_commits
    has_commits=$(cd "$PROJECT_DIR" && git log --oneline 2>/dev/null || echo "")
    assert_contains "$has_commits" "Initial commit" "Should have initial commit"
    cleanup
}

# Test memory bank initialization
it "should initialize memory bank with required files" {
    setup
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    assert_dir_exists "${PROJECT_DIR}/memory-bank" "Memory bank directory should be created"
    
    # Check required memory bank files
    local required_files=("projectbrief.md" "productContext.md" "systemPatterns.md" 
                         "techContext.md" "activeContext.md" "progress.md")
    
    for file in "${required_files[@]}"; do
        assert_file_exists "${PROJECT_DIR}/memory-bank/${file}" "Memory bank should contain ${file}"
        local content
        content=$(cat "${PROJECT_DIR}/memory-bank/${file}")
        assert_not_empty "$content" "${file} should not be empty"
    done
    
    # Check memory bank content
    local projectbrief_content
    projectbrief_content=$(cat "${PROJECT_DIR}/memory-bank/projectbrief.md")
    assert_contains "$projectbrief_content" "$PROJECT_DESCRIPTION" "Project brief should contain project description"
    
    local techcontext_content
    techcontext_content=$(cat "${PROJECT_DIR}/memory-bank/techContext.md")
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        assert_contains "$techcontext_content" "Docker engine" "Tech context should mention Docker when enabled"
    else
        assert_not_contains "$techcontext_content" "Docker engine" "Tech context should not mention Docker when disabled"
    fi
    cleanup
}

# Test workspace validation
it "should validate workspace structure" {
    setup
    # Test with all required files
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    
    # Check .clinerules file
    assert_file_exists "${PROJECT_DIR}/.clinerules" ".clinerules file should exist"
    local clinerules_content
    clinerules_content=$(cat "${PROJECT_DIR}/.clinerules")
    assert_contains "$clinerules_content" "WORKSPACE_MONITORING: \"active\"" ".clinerules should have workspace monitoring enabled"
    
    # Check VSCode settings
    assert_file_exists "${PROJECT_DIR}/.vscode/settings.json" "VSCode settings should exist"
    local settings_content
    settings_content=$(cat "${PROJECT_DIR}/.vscode/settings.json")
    assert_contains "$settings_content" "\"markdownlint.config\"" "VSCode settings should include markdown linting configuration"
    
    # Test validation failure scenarios
    rm -rf "${PROJECT_DIR}/memory-bank"
    local output
    output=$(cd "$PROJECT_DIR" && ./bootstrap.sh 2>&1 || true)
    assert_contains "$output" "Error: Missing required directory: memory-bank" "Should detect missing memory-bank directory"
    cleanup
}

# Test development environment setup
it "should setup development environment" {
    setup
    (cd "$PROJECT_DIR" && ./bootstrap.sh)
    assert_dir_exists "${PROJECT_DIR}/.vscode" "VS Code directory should be created"
    
    # Test Docker files when enabled
    if [ "$DOCKER_SUPPORT" = "true" ]; then
        assert_file_exists "${PROJECT_DIR}/docker-compose.yml" "docker-compose.yml should exist when Docker is enabled"
        assert_file_exists "${PROJECT_DIR}/Dockerfile" "Dockerfile should exist when Docker is enabled"
        local compose_content
        compose_content=$(cat "${PROJECT_DIR}/docker-compose.yml")
        assert_contains "$compose_content" "\"${PORT}:${PORT}\"" "docker-compose.yml should use specified port"
    fi
    
    # Test VSCode settings
    local settings_content
    settings_content=$(cat "${PROJECT_DIR}/.vscode/settings.json")
    assert_contains "$settings_content" "\"editor.formatOnSave\": true" "VSCode settings should enable format on save"
    cleanup
}

# Run all tests
run_tests "$0"
