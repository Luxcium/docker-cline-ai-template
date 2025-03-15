#!/bin/bash

# Source test frameworks
source "$(dirname "$0")/../framework/test_framework.sh"
source "$(dirname "$0")/framework/meta_test_utils.sh"

# Test suite for .clinerules validation
describe "Clinerules Configuration Tests"

# Test environment variables
TEST_WORKSPACE=""

# Setup function for each test
setup() {
    TEST_WORKSPACE="${TEMP_DIR}/clinerules-test"
    mkdir -p "$TEST_WORKSPACE"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
}

# Test markdown rules configuration
it "should enforce markdown standards without line length limit" {
    local test_dir="${TEST_WORKSPACE}/markdown-test"
    mkdir -p "$test_dir"
    
    # Copy .clinerules to test directory
    cp "${TEST_DIR}/../../.clinerules" "$test_dir/"
    
    # Create test markdown file with long lines
    cat > "${test_dir}/test.md" << EOF
# Test Document

This is a very long line that would normally exceed the standard 80-character limit but should be allowed according to our configuration which explicitly disables line length validation in favor of content readability and flexibility.

* List item with proper asterisk
  * Nested item with correct indentation
  * Another nested item

\`\`\`javascript
// Code block with language specified
const example = "Hello World";
\`\`\`

# Another Top Level Heading
EOF
    
    # Validate markdown compliance
    local config
    config=$(cat "${test_dir}/.clinerules")
    
    # Check if line length validation is disabled
    assert_contains "$config" "\"MD013\": false" "Line length validation should be disabled"
    
    # Verify other markdown rules are enforced
    assert_contains "$config" "\"heading_rules\"" "Should have heading rules defined"
    assert_contains "$config" "\"list_rules\"" "Should have list rules defined"
    assert_contains "$config" "\"code_rules\"" "Should have code rules defined"
}

# Test learning directives
it "should have proper learning configuration" {
    local config_file="${TEST_DIR}/../../.clinerules"
    local content
    content=$(cat "$config_file")
    
    # Verify learning mode settings
    assert_contains "$content" "LEARN_MODE: \"continuous\"" "Should have continuous learning mode"
    assert_contains "$content" "MEMORY_PERSISTENCE: \"enabled\"" "Should have memory persistence enabled"
    assert_contains "$content" "CONTEXT_LAYERING: \"enabled\"" "Should have context layering enabled"
    
    # Check knowledge retention patterns
    assert_contains "$content" "\"auto_update\": true" "Should have auto-update enabled"
    assert_contains "$content" "\"versioning\": true" "Should have versioning enabled"
}

# Test self-improvement mechanisms
it "should support self-improvement capabilities" {
    local config_file="${TEST_DIR}/../../.clinerules"
    local content
    content=$(cat "$config_file")
    
    # Verify pattern tracking configuration
    assert_contains "$content" "\"user_behaviors\"" "Should track user behaviors"
    assert_contains "$content" "\"error_patterns\"" "Should track error patterns"
    assert_contains "$content" "\"optimization_opportunities\"" "Should identify optimization opportunities"
    
    # Check version control settings
    assert_contains "$content" "\"history_retention\": true" "Should retain history"
    assert_contains "$content" "\"rollback_support\": true" "Should support rollbacks"
}

# Test memory bank integration
it "should integrate with memory bank" {
    local config_file="${TEST_DIR}/../../.clinerules"
    local content
    content=$(cat "$config_file")
    
    # Verify sync configuration
    assert_contains "$content" "\"auto_sync\": true" "Should have auto-sync enabled"
    assert_contains "$content" "\"sync_on_change\": true" "Should sync on changes"
    
    # Check persistence settings
    assert_contains "$content" "\"state_preservation\": true" "Should preserve state"
    assert_contains "$content" "\"context_retention\": true" "Should retain context"
}

# Test version tracking
it "should maintain version information" {
    local config_file="${TEST_DIR}/../../.clinerules"
    local content
    content=$(cat "$config_file")
    
    # Version information should be present
    assert_contains "$content" "Version: " "Should have version information"
    assert_contains "$content" "Last Updated: " "Should have last updated timestamp"
    
    # Verify version format
    if [[ "$content" =~ Version:\ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        local version="${BASH_REMATCH[1]}"
        assert_matches "^[0-9]+\.[0-9]+\.[0-9]+$" "$version" "Version should follow semantic versioning"
    else
        fail "Version information not found or invalid"
    fi
}

# Test configuration updates
it "should handle configuration updates properly" {
    local test_dir="${TEST_WORKSPACE}/update-test"
    mkdir -p "$test_dir"
    cp "${TEST_DIR}/../../.clinerules" "${test_dir}/.clinerules"
    
    # Simulate configuration update
    local original_content
    original_content=$(cat "${test_dir}/.clinerules")
    
    # Update version
    sed -i.bak 's/Version: [0-9.]\+/Version: 1.1.0/' "${test_dir}/.clinerules"
    
    # Update timestamp
    sed -i.bak "s/Last Updated: .\+/Last Updated: $(date +%Y-%m-%d)/" "${test_dir}/.clinerules"
    
    # Verify changes were tracked
    local updated_content
    updated_content=$(cat "${test_dir}/.clinerules")
    
    assert_not_equals "$original_content" "$updated_content" "Content should be updated"
    assert_contains "$updated_content" "Version: 1.1.0" "Version should be updated"
    assert_contains "$updated_content" "Last Updated: $(date +%Y-%m-%d)" "Timestamp should be updated"
}

# Test metrics tracking
it "should configure performance metrics" {
    local config_file="${TEST_DIR}/../../.clinerules"
    local content
    content=$(cat "$config_file")
    
    # Verify metrics configuration
    assert_contains "$content" "\"pattern_recognition_rate\": true" "Should track pattern recognition"
    assert_contains "$content" "\"error_prevention_rate\": true" "Should track error prevention"
    assert_contains "$content" "\"optimization_success_rate\": true" "Should track optimization success"
    
    # Check quality assurance settings
    assert_contains "$content" "\"markdown_compliance\": true" "Should monitor markdown compliance"
    assert_contains "$content" "\"documentation_completeness\": true" "Should monitor documentation completeness"
}

# Run the tests
run_tests "$(basename "$0")"
