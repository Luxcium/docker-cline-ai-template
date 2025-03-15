#!/bin/bash

# Source the test framework
source "$(dirname "$0")/../framework/test_framework.sh"

# Test suite for end-to-end user workflow
describe "End-to-End User Workflow Tests"

# Common variables
TEST_WORKSPACE=""

# Setup function for each test
setup() {
    TEST_WORKSPACE="${TEMP_DIR}/e2e-workspace"
    mkdir -p "$TEST_WORKSPACE"
}

# Cleanup function after each test
cleanup() {
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
}

# Helper function to simulate user input
simulate_user_input() {
    local template="$1"
    export PROJECT_NAME="e2e-test-project"
    export PROJECT_DESCRIPTION="End-to-end test project"
    export AUTHOR_NAME="E2E Test User"
    export AUTHOR_EMAIL="e2e@test.com"
    export REPOSITORY_URL="https://github.com/e2e-test/test-project"
    export LICENSE="MIT"
    export DOCKER_SUPPORT="true"
    export PORT="3000"
}

# Helper function to verify project can be built and run
verify_project_functionality() {
    local project_dir="$1"
    local template="$2"
    
    echo "Verifying project functionality for template: $template"
    
    case "$template" in
        "node")
            # Verify Node.js project
            (cd "$project_dir" && {
                # Install dependencies
                if ! npm install; then
                    fail "Failed to install Node.js dependencies"
                    return 1
                fi
                
                # Run tests
                if ! npm test; then
                    fail "Node.js project tests failed"
                    return 1
                fi
                
                # Start the application briefly
                npm start & local pid=$!
                sleep 5
                kill $pid
            })
            ;;
            
        "python")
            # Verify Python project
            (cd "$project_dir" && {
                # Create and activate conda environment
                if [ -f "environment.yml" ]; then
                    if ! conda env create -f environment.yml; then
                        fail "Failed to create conda environment"
                        return 1
                    fi
                    
                    # Run tests
                    if ! python -m pytest; then
                        fail "Python project tests failed"
                        return 1
                    fi
                fi
            })
            ;;
            
        "base")
            # Verify base project structure
            for file in README.md .gitignore; do
                if [ ! -f "${project_dir}/${file}" ]; then
                    fail "Missing required file: $file"
                    return 1
                fi
            done
            ;;
    esac
    
    # Verify Docker build if enabled
    if [ "$DOCKER_SUPPORT" = "true" ] && [ -f "${project_dir}/Dockerfile" ]; then
        (cd "$project_dir" && {
            if ! docker build -t "e2e-test-${template}" .; then
                fail "Docker build failed"
                return 1
            fi
        })
    fi
    
    return 0
}

# Test complete workflow for each template type
for template in "base" "node" "python"; do
    it "should complete full workflow for ${template} template" {
        setup
        simulate_user_input "$template"
        
        # Create project directory
        local project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}"
        mkdir -p "$project_dir"
        
        echo "Testing ${template} template workflow..."
        
        # 1. Copy template files
        cp -r "${TEMPLATE_DIR}/templates/${template}/." "$project_dir/"
        assert_dir_exists "$project_dir" "Project directory should be created"
        
        # 2. Make scripts executable
        if [ -f "${project_dir}/bootstrap.sh" ]; then
            chmod +x "${project_dir}/bootstrap.sh"
        fi
        if [ -f "${project_dir}/setup.sh" ]; then
            chmod +x "${project_dir}/setup.sh"
        fi
        
        # 3. Initialize the project
        (cd "$project_dir" && {
            # Run appropriate initialization script
            if [ -f "setup.sh" ]; then
                ./setup.sh
            elif [ -f "bootstrap.sh" ]; then
                ./bootstrap.sh
            fi
        })
        
        # 4. Verify project structure
        assert_dir_exists "${project_dir}/.git" "Git repository should be initialized"
        assert_file_exists "${project_dir}/README.md" "README.md should exist"
        
        # 5. Verify template-specific files
        case "$template" in
            "node")
                assert_file_exists "${project_dir}/package.json" "package.json should exist"
                assert_dir_exists "${project_dir}/src" "src directory should exist"
                ;;
            "python")
                assert_file_exists "${project_dir}/pyproject.toml" "pyproject.toml should exist"
                assert_file_exists "${project_dir}/environment.yml" "environment.yml should exist"
                ;;
        esac
        
        # 6. Verify Docker setup if enabled
        if [ "$DOCKER_SUPPORT" = "true" ]; then
            assert_file_exists "${project_dir}/Dockerfile" "Dockerfile should exist"
            assert_file_exists "${project_dir}/docker-compose.yml" "docker-compose.yml should exist"
        fi
        
        # 7. Verify project can be built and run
        if ! verify_project_functionality "$project_dir" "$template"; then
            fail "Project functionality verification failed for ${template} template"
        fi
        
        # 8. Verify Git state
        (cd "$project_dir" && {
            local git_status
            git_status=$(git status --porcelain)
            assert_equals "" "$git_status" "Git working directory should be clean"
            
            local commit_msg
            commit_msg=$(git log -1 --pretty=%B)
            assert_contains "$commit_msg" "Initial commit" "Should have initial commit"
        })
        
        echo "✅ ${template} template workflow completed successfully"
        
        cleanup
    }
done

# Test error handling in workflow
it "should handle errors gracefully during workflow" {
    setup
    simulate_user_input "node"
    
    # Test with invalid project name
    export PROJECT_NAME="invalid/name"
    local project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}"
    mkdir -p "$project_dir"
    
    # Attempt to initialize with invalid name
    cp -r "${TEMPLATE_DIR}/templates/node/." "$project_dir/"
    local output
    output=$(cd "$project_dir" && ./setup.sh 2>&1 || true)
    assert_contains "$output" "error" "Should show error for invalid project name"
    
    # Test with missing dependencies
    export PROJECT_NAME="missing-deps"
    project_dir="${TEST_WORKSPACE}/${PROJECT_NAME}"
    mkdir -p "$project_dir"
    
    # Create minimal package.json with invalid dependency
    cp -r "${TEMPLATE_DIR}/templates/node/." "$project_dir/"
    echo '{"dependencies":{"nonexistent-package":"1.0.0"}}' > "${project_dir}/package.json"
    
    output=$(cd "$project_dir" && npm install 2>&1 || true)
    assert_contains "$output" "404" "Should show error for missing dependency"
    
    cleanup
}

# Run all tests
run_tests "$(basename "$0")"
