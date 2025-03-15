#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for end-to-end user workflow tests
describe "End-to-End User Workflow Tests"

# Setup test environment for each test
setup() {
    setup_test_environment
    if [ -z "$TEMP_DIR" ]; then
        TEMP_DIR="${TEMPLATE_DIR}/tmp/test-$(date +%s)"
        mkdir -p "$TEMP_DIR"
    fi
    WORKSPACE_DIR="${TEMP_DIR}/workspace"
    mkdir -p "$WORKSPACE_DIR"
    
    # Save original working directory
    ORIG_DIR="$(pwd)"
}

# Cleanup test environment after each test
cleanup() {
    # Return to original directory
    cd "$ORIG_DIR" || true
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Helper function to create test input file
create_test_input() {
    local input_file="$1"
    cat > "$input_file" << EOF
1
test-project
Test project description
Test Author
test@example.com
https://github.com/test/test-project
MIT
y
3000
$WORKSPACE_DIR/test-project
y
EOF
}

# Test project creation workflow function
test_project_creation() {
    local input_file="${TEMP_DIR}/input.txt"
    create_test_input "$input_file"
    
    # Run template factory with input
    cd "$TEMPLATE_DIR" || fail "Could not change to template directory"
    ./template_factory.sh < "$input_file"
    
    # Test project creation
    local project_dir="$WORKSPACE_DIR/test-project"
    
    test_project_files "$project_dir"
    return 0
}

# Test project files function
test_project_files() {
    local project_dir="$1"
    assert_dir_exists "$project_dir" "Project directory should be created"
    
    # Test memory bank
    assert_dir_exists "${project_dir}/memory-bank" "Memory bank directory should exist"
    for file in "projectbrief.md" "productContext.md" "systemPatterns.md" \
        "techContext.md" "activeContext.md" "progress.md"; do
        assert_file_exists "${project_dir}/memory-bank/${file}" "Memory bank file ${file} should exist"
    done
    
    # Test development environment
    assert_dir_exists "${project_dir}/.vscode" "VS Code directory should exist"
    assert_file_exists "${project_dir}/.vscode/settings.json" "VS Code settings should exist"
    
    # Test configuration files
    assert_file_exists "${project_dir}/.clinerules" ".clinerules file should exist"
    assert_file_exists "${project_dir}/docker-compose.yml" "docker-compose.yml should exist"
    assert_file_exists "${project_dir}/Dockerfile" "Dockerfile should exist"
    
    # Test Git initialization
    assert_dir_exists "${project_dir}/.git" "Git repository should be initialized"
    
    # Test content customization
    local readme_content
    readme_content=$(cat "${project_dir}/README.md")
    assert_contains "$readme_content" "test-project" "README.md should contain project name"
    assert_contains "$readme_content" "Test project description" "README.md should contain project description"
    
    cleanup
}

# Test error handling function
test_error_handling() {
    # Test invalid template selection
    echo "4" | ./template_factory.sh 2>&1 | assert_contains_output \
        "Invalid selection" "Should reject invalid template number"
    
    # Test empty project name
    printf "1\n\n" | ./template_factory.sh 2>&1 | assert_contains_output \
        "Project name cannot be empty" "Should reject empty project name"
    
    # Test invalid project name
    printf "1\ntest project\n" | ./template_factory.sh 2>&1 | assert_contains_output \
        "Project name can only contain" "Should reject invalid project name"
}

# Test validation function
test_project_validation() {
    local input_file="${TEMP_DIR}/input.txt"
    create_test_input "$input_file"
    
    # Run template factory
    cd "$TEMPLATE_DIR" || fail "Could not change to template directory"
    ./template_factory.sh < "$input_file"
    
    # Test required files existence
    local project_dir="$WORKSPACE_DIR/test-project"
    assert_file_exists "${project_dir}/README.md" "README.md should exist"
    assert_file_exists "${project_dir}/.gitignore" ".gitignore should exist"
    assert_file_exists "${project_dir}/Dockerfile" "Dockerfile should exist"
    
    # Test memory bank content
    local brief_content
    brief_content=$(cat "${project_dir}/memory-bank/projectbrief.md")
    assert_contains "$brief_content" "Test project description" "Project brief should contain description"
    
    # Test Docker configuration
    local compose_content
    compose_content=$(cat "${project_dir}/docker-compose.yml")
    assert_contains "$compose_content" "3000:3000" "docker-compose.yml should contain port mapping"
}

# Test error handling in project creation
it "should handle invalid input appropriately" {
    setup
    test_error_handling
    cleanup
}

# Test project validation
it "should validate generated project structure" {
    setup
    test_project_validation
    cleanup
}

# Run all tests
run_tests "$0"
