#!/bin/bash

# Source test frameworks
source "$(dirname "$0")/../framework/test_framework.sh"
source "$(dirname "$0")/framework/meta_test_utils.sh"

# Test suite for dependency management validation
describe "Dependency Management Meta-Level Tests"

# Test environment variables
TEST_WORKSPACE=""
TEMPLATES_DIR=""

# Setup function for each test
setup() {
    TEST_WORKSPACE="${TEMP_DIR}/dependency-management"
    mkdir -p "$TEST_WORKSPACE"
    TEMPLATES_DIR="${TEST_DIR}/../../templates"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
}

# Helper function to create test package.json with mixed dependencies
create_test_package_json() {
    local dir="$1"
    cat > "${dir}/package.json" << EOF
{
    "name": "test-project",
    "version": "1.0.0",
    "dependencies": {
        "express": "4.17.1",
        "lodash": "^4.17.21",
        "axios": "~0.21.1"
    },
    "devDependencies": {
        "jest": "^27.0.0",
        "eslint": "7.32.0",
        "nodemon": "^2.0.12"
    }
}
EOF
}

# Helper function to create test pyproject.toml with mixed dependencies
create_test_pyproject_toml() {
    local dir="$1"
    cat > "${dir}/pyproject.toml" << EOF
[project]
name = "test-project"
version = "1.0.0"
dependencies = [
    "flask==2.0.1",
    "requests>=2.26.0",
    "SQLAlchemy~=1.4.0"
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black==22.3.0",
    "mypy>=0.900"
]
EOF
}

# Test production vs development dependency strategy
it "should enforce correct dependency strategies" {
    local node_dir="${TEST_WORKSPACE}/node-project"
    local python_dir="${TEST_WORKSPACE}/python-project"
    mkdir -p "$node_dir" "$python_dir"
    
    # Create test files
    create_test_package_json "$node_dir"
    create_test_pyproject_toml "$python_dir"
    
    # Test Node.js dependencies
    echo "Validating Node.js dependencies..."
    
    # Production dependencies
    assert_dependency_strategy "express" "4.17.1" "locked"
    assert_dependency_strategy "lodash" "^4.17.21" "flexible"
    assert_dependency_strategy "axios" "~0.21.1" "flexible"
    
    # Development dependencies
    assert_dependency_strategy "eslint" "7.32.0" "locked"
    assert_dependency_strategy "jest" "^27.0.0" "flexible"
    
    # Test Python dependencies
    echo "Validating Python dependencies..."
    
    # Extract and test production dependencies
    local python_deps
    python_deps=$(grep "^    \".*\"" "${python_dir}/pyproject.toml" | grep -v "dev = \[")
    
    echo "$python_deps" | while read -r dep; do
        if [[ "$dep" =~ ([^=~>]+)(==|>=|~=)([0-9.]+) ]]; then
            local name="${BASH_REMATCH[1]}"
            local operator="${BASH_REMATCH[2]}"
            local version="${BASH_REMATCH[3]}"
            
            case "$operator" in
                "==")
                    assert_dependency_strategy "$name" "$version" "locked"
                    ;;
                ">="|"~=")
                    assert_dependency_strategy "$name" "$version" "flexible"
                    ;;
            esac
        fi
    done
}

# Test dependency update impact
it "should handle dependency updates safely" {
    local test_dir="${TEST_WORKSPACE}/update-test"
    mkdir -p "$test_dir"
    
    # Create initial package files
    create_test_package_json "$test_dir"
    create_test_pyproject_toml "$test_dir"
    
    # Simulate dependency updates
    echo "Testing Node.js dependency updates..."
    local node_deps=("express" "lodash" "axios")
    for dep in "${node_deps[@]}"; do
        # Get current version
        local current_version
        current_version=$(node -pe "require('${test_dir}/package.json').dependencies['${dep}']")
        
        # Simulate major version bump
        local new_version
        if [[ "$current_version" =~ ^[~^]?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
            new_version="$((BASH_REMATCH[1] + 1)).0.0"
        else
            continue
        fi
        
        # Update package.json
        sed -i.bak "s/\"${dep}\": \"[^\"]*\"/\"${dep}\": \"${new_version}\"/" "${test_dir}/package.json"
        
        # Verify package still validates
        local validation_output
        validation_output=$(validate_dependencies "${test_dir}/package.json" "production")
        assert_equals "0" "$?" "Dependency update should maintain valid package.json"
    done
    
    echo "Testing Python dependency updates..."
    local python_deps=("flask" "requests" "SQLAlchemy")
    for dep in "${python_deps[@]}"; do
        # Get current version constraint
        local current_constraint
        current_constraint=$(grep "$dep" "${test_dir}/pyproject.toml")
        
        # Simulate version bump while maintaining constraint style
        if [[ "$current_constraint" =~ ($dep)(==|>=|~=)([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
            local operator="${BASH_REMATCH[2]}"
            local new_version="$((BASH_REMATCH[3] + 1)).0.0"
            sed -i.bak "s/$dep$operator[0-9.]*/$dep$operator$new_version/" "${test_dir}/pyproject.toml"
        fi
        
        # Verify toml still validates
        local validation_output
        validation_output=$(validate_dependencies "${test_dir}/pyproject.toml" "production")
        assert_equals "0" "$?" "Dependency update should maintain valid pyproject.toml"
    done
}

# Test automated dependency checks
it "should automate dependency checks" {
    local test_dir="${TEST_WORKSPACE}/dependency-check"
    mkdir -p "$test_dir"
    
    # Create test files with outdated versions
    cat > "${test_dir}/package.json" << EOF
{
    "name": "test-project",
    "version": "1.0.0",
    "dependencies": {
        "lodash": "4.17.0",
        "express": "4.16.0"
    }
}
EOF
    
    cat > "${test_dir}/pyproject.toml" << EOF
[project]
name = "test-project"
version = "1.0.0"
dependencies = [
    "requests==2.25.0",
    "flask==2.0.0"
]
EOF
    
    # Check for outdated dependencies
    echo "Checking Node.js dependencies..."
    if command -v npm &> /dev/null; then
        cd "$test_dir" && npm outdated --json > outdated.json
        local outdated_count
        outdated_count=$(jq 'length' outdated.json)
        assert_not_equals "0" "$outdated_count" "Should detect outdated Node.js dependencies"
    fi
    
    echo "Checking Python dependencies..."
    if command -v pip &> /dev/null; then
        pip list --outdated --format=json > pip_outdated.json
        local pip_outdated_count
        pip_outdated_count=$(jq 'length' pip_outdated.json)
        assert_not_equals "0" "$pip_outdated_count" "Should detect outdated Python dependencies"
    fi
}

# Test dependency conflict detection
it "should detect dependency conflicts" {
    local test_dir="${TEST_WORKSPACE}/conflict-test"
    mkdir -p "$test_dir"
    
    # Create package with conflicting peer dependencies
    cat > "${test_dir}/package.json" << EOF
{
    "name": "test-project",
    "dependencies": {
        "react": "17.0.0",
        "some-component": "1.0.0"
    },
    "peerDependencies": {
        "react": "^16.0.0"
    }
}
EOF
    
    # Verify conflict detection
    local npm_output
    if command -v npm &> /dev/null; then
        npm_output=$(cd "$test_dir" && npm install 2>&1 || true)
        assert_contains "$npm_output" "peer dep" "Should detect peer dependency conflict"
    fi
    
    # Create Python requirements with conflicting dependencies
    cat > "${test_dir}/requirements.txt" << EOF
django==3.2
django-cms==4.0.0
EOF
    
    # Verify Python dependency conflicts
    local pip_output
    if command -v pip &> /dev/null; then
        pip_output=$(cd "$test_dir" && pip install -r requirements.txt 2>&1 || true)
        assert_contains "$pip_output" "Conflict" "Should detect Python package conflicts"
    fi
}

# Test dependency security validation
it "should validate dependency security" {
    local test_dir="${TEST_WORKSPACE}/security-test"
    mkdir -p "$test_dir"
    
    # Create package with known vulnerable dependency
    cat > "${test_dir}/package.json" << EOF
{
    "name": "test-project",
    "dependencies": {
        "lodash": "4.17.0"
    }
}
EOF
    
    # Check for security vulnerabilities
    if command -v npm &> /dev/null; then
        local audit_output
        audit_output=$(cd "$test_dir" && npm audit --json 2>/dev/null || true)
        assert_contains "$audit_output" "vulnerability" "Should detect security vulnerabilities"
    fi
    
    # Create Python requirements with known vulnerable package
    cat > "${test_dir}/requirements.txt" << EOF
requests==2.3.0
EOF
    
    # Check for Python package security issues
    if command -v safety &> /dev/null; then
        local safety_output
        safety_output=$(cd "$test_dir" && safety check -r requirements.txt 2>&1 || true)
        assert_contains "$safety_output" "vulnerability" "Should detect Python package vulnerabilities"
    fi
}

# Run the tests
run_tests "$(basename "$0")"
