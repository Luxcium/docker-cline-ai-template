#!/bin/bash

# Source test frameworks
source "$(dirname "$0")/../framework/test_framework.sh"
source "$(dirname "$0")/framework/meta_test_utils.sh"

# Test suite for template creation validation
describe "Template Creation Meta-Level Tests"

# Test environment variables
TEST_WORKSPACE=""
TEMPLATES_DIR=""

# Setup function for each test
setup() {
    TEST_WORKSPACE="${TEMP_DIR}/template-creation"
    mkdir -p "$TEST_WORKSPACE"
    TEMPLATES_DIR="${TEST_DIR}/../../templates"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
}

# Helper function to create test template with known issues
create_test_template() {
    local template_dir="$1"
    mkdir -p "$template_dir"
    
    # Create template files
    cat > "${template_dir}/template.json" << EOF
{
    "name": "test-template",
    "version": "1.0.0",
    "variables": {
        "projectName": "string",
        "description": "string",
        "author": "string"
    }
}
EOF
    
    cat > "${template_dir}/README.md" << EOF
# {{projectName}}

{{description}}

Created by {{author}}
EOF
    
    # Create bootstrap script with deliberate error handling issue
    cat > "${template_dir}/bootstrap.sh" << EOF
#!/bin/bash
# Missing error handling for required variables

echo "Initializing project..."
sed -i "s/{{projectName}}/$PROJECT_NAME/g" README.md
sed -i "s/{{description}}/$PROJECT_DESCRIPTION/g" README.md
sed -i "s/{{author}}/$AUTHOR_NAME/g" README.md
EOF
    
    chmod +x "${template_dir}/bootstrap.sh"
}

# Test template script error handling
it "should validate template script error handling" {
    local template_dir="${TEST_WORKSPACE}/error-handling-template"
    create_test_template "$template_dir"
    
    # Test without required variables
    local output
    output=$(cd "$template_dir" && ./bootstrap.sh 2>&1 || true)
    
    # Should fail due to missing variables
    assert_not_equals "0" "$?" "Template script should fail with missing variables"
    assert_contains "$output" "error" "Should contain error message for missing variables"
    
    # Test with variables set
    export PROJECT_NAME="test-project"
    export PROJECT_DESCRIPTION="A test project"
    export AUTHOR_NAME="Test Author"
    
    output=$(cd "$template_dir" && ./bootstrap.sh 2>&1)
    assert_equals "0" "$?" "Template script should succeed with variables set"
    
    # Verify file content
    local content
    content=$(cat "${template_dir}/README.md")
    assert_contains "$content" "test-project" "Project name should be replaced"
    assert_contains "$content" "A test project" "Description should be replaced"
    assert_contains "$content" "Test Author" "Author should be replaced"
}

# Test template generation reproducibility
it "should generate templates reproducibly" {
    local template_name="test-template"
    local template_params='{
        "projectName": "reproducible-test",
        "description": "Testing template reproducibility",
        "author": "Test Author"
    }'
    
    # Create test template
    local template_dir="${TEST_WORKSPACE}/${template_name}"
    create_test_template "$template_dir"
    
    # Test reproducibility
    assert_template_reproducible "$template_name" "$template_params"
}

# Test CLI tool parameter validation
it "should validate CLI tool parameters" {
    # Test with missing required parameter
    local output
    output=$(create_from_template 2>&1 || true)
    assert_not_equals "0" "$?" "CLI should fail without parameters"
    assert_contains "$output" "usage" "Should show usage information"
    
    # Test with invalid template name
    output=$(create_from_template "nonexistent-template" "test-project" 2>&1 || true)
    assert_not_equals "0" "$?" "CLI should fail with invalid template"
    assert_contains "$output" "template not found" "Should show template not found error"
    
    # Test with invalid project name
    output=$(create_from_template "base" "invalid/name" 2>&1 || true)
    assert_not_equals "0" "$?" "CLI should fail with invalid project name"
    assert_contains "$output" "invalid project name" "Should show invalid name error"
}

# Test template initialization requirements
it "should validate template initialization requirements" {
    for template in base node python; do
        local template_dir="${TEMPLATES_DIR}/${template}"
        
        # Check for required files
        assert_file_exists "${template_dir}/README.md" "Template should have README"
        
        # Check for initialization script
        local init_script
        if [ -f "${template_dir}/setup.sh" ]; then
            init_script="setup.sh"
        elif [ -f "${template_dir}/bootstrap.sh" ]; then
            init_script="bootstrap.sh"
        else
            fail "Template ${template} missing initialization script"
            continue
        fi
        
        # Verify script is executable
        local perms
        perms=$(stat -c %a "${template_dir}/${init_script}")
        assert_contains "$perms" "755" "Initialization script should be executable"
        
        # Check script contents for basic requirements
        local script_content
        script_content=$(cat "${template_dir}/${init_script}")
        assert_contains "$script_content" "#!/bin/bash" "Script should have shebang"
        assert_contains "$script_content" "PROJECT_NAME" "Script should use PROJECT_NAME"
    done
}

# Test template validation
it "should validate template structure" {
    for template in base node python; do
        local template_dir="${TEMPLATES_DIR}/${template}"
        
        # Check for undefined variables
        local undefined_vars
        undefined_vars=$(find "$template_dir" -type f -exec grep -l '{{.*}}' {} \;)
        assert_equals "" "$undefined_vars" "Template should not have undefined variables"
        
        # Check for required sections in README
        local sections=("Description" "Installation" "Usage")
        validate_markdown_sections "${template_dir}/README.md" "${sections[@]}"
        
        # Verify template manifest if exists
        if [ -f "${template_dir}/template.json" ]; then
            local manifest_content
            manifest_content=$(cat "${template_dir}/template.json")
            assert_contains "$manifest_content" "\"name\"" "Manifest should have name"
            assert_contains "$manifest_content" "\"version\"" "Manifest should have version"
        fi
    done
}

# Test error recovery
it "should handle error recovery gracefully" {
    local template_dir="${TEST_WORKSPACE}/recovery-template"
    create_test_template "$template_dir"
    
    # Simulate partial initialization failure
    (cd "$template_dir" && {
        export PROJECT_NAME="recovery-test"
        # Corrupt README mid-process
        ./bootstrap.sh &
        sleep 1
        echo "Corrupted content" > README.md
        wait
    })
    
    # Verify recovery leaves workspace in consistent state
    local readme_content
    readme_content=$(cat "${template_dir}/README.md")
    if [[ "$readme_content" == *"{{projectName}}"* ]] || 
       [[ "$readme_content" == *"Corrupted content"* ]]; then
        fail "Template failed to recover from corruption"
    fi
}

# Run the tests
run_tests "$(basename "$0")"
