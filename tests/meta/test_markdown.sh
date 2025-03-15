#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for markdown validation
describe "Markdown Standards"

# Function to check markdown file
validate_markdown() {
    local file="$1"
    local output
    
    # Run markdownlint on the file
    output=$(markdownlint "$file" 2>&1)
    if [ $? -eq 0 ]; then
        return 0
    else
        echo "$output"
        return 1
    fi
}

# Setup function
setup() {
    setup_test_environment
    # Ensure markdownlint configuration exists
    assert_file_exists "${TEMPLATE_DIR}/.markdownlint.json" "Markdown linting configuration should exist"
}

# Test main README.md
it "should validate main README.md" {
    setup
    local output
    output=$(validate_markdown "${TEMPLATE_DIR}/README.md")
    assert_success "$?" "Main README.md should pass markdown validation: $output"
    cleanup
}

# Test base template README.md
it "should validate base template README.md" {
    setup
    local output
    output=$(validate_markdown "${TEMPLATE_DIR}/templates/base/README.md")
    assert_success "$?" "Base template README.md should pass markdown validation: $output"
    cleanup
}

# Test node template README.md
it "should validate node template README.md" {
    setup
    local output
    output=$(validate_markdown "${TEMPLATE_DIR}/templates/node/README.md")
    assert_success "$?" "Node template README.md should pass markdown validation: $output"
    cleanup
}

# Test python template README.md
it "should validate python template README.md" {
    setup
    local output
    output=$(validate_markdown "${TEMPLATE_DIR}/templates/python/README.md")
    assert_success "$?" "Python template README.md should pass markdown validation: $output"
    cleanup
}

# Test memory bank markdowns
it "should validate memory bank markdown files" {
    setup
    local success=0
    local files=(
        "projectbrief.md"
        "productContext.md"
        "systemPatterns.md"
        "techContext.md"
        "activeContext.md"
        "progress.md"
    )
    
    for file in "${files[@]}"; do
        local output
        output=$(validate_markdown "${TEMPLATE_DIR}/memory-bank/${file}")
        if [ $? -ne 0 ]; then
            echo "Error in ${file}: $output"
            success=1
        fi
    done
    
    assert_equals $success 0 "Memory bank markdown files should pass validation"
    cleanup
}

# Test markdown consistency across all files
it "should maintain consistent markdown style" {
    setup
    local success=0
    local total_errors=0
    
    # Find all markdown files
    while IFS= read -r file; do
        local output
        output=$(validate_markdown "$file")
        if [ $? -ne 0 ]; then
            echo "Errors in $file:"
            echo "$output"
            total_errors=$((total_errors + 1))
        fi
    done < <(find "${TEMPLATE_DIR}" -type f -name "*.md")
    
    assert_equals $total_errors 0 "All markdown files should follow consistent style"
    cleanup
}

# Run all tests
run_tests "$0"
