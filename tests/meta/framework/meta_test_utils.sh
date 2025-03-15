#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dependency Management Utilities

# Compare semantic versions
# Returns:
#   0 if $1 equals $2
#   1 if $1 is greater than $2
#   2 if $1 is less than $2
compare_versions() {
    local version1=$1
    local version2=$2
    
    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi
    
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    # Fill empty positions with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do
        ver2[i]=0
    done
    
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ ${ver1[i]} -gt ${ver2[i]} ]]; then
            return 1
        elif [[ ${ver1[i]} -lt ${ver2[i]} ]]; then
            return 2
        fi
    done
    
    return 0
}

# Validate dependency versions in package.json or pyproject.toml
validate_dependencies() {
    local file="$1"
    local dep_type="$2" # "production" or "development"
    
    case "$(basename "$file")" in
        package.json)
            if [ "$dep_type" = "production" ]; then
                jq -r '.dependencies | to_entries[] | "\(.key):\(.value)"' "$file"
            else
                jq -r '.devDependencies | to_entries[] | "\(.key):\(.value)"' "$file"
            fi
            ;;
        pyproject.toml)
            if [ "$dep_type" = "production" ]; then
                grep -A 100 '^\[project.dependencies\]' "$file" | grep -B 100 '^\['
            else
                grep -A 100 '^\[project.optional-dependencies\]' "$file" | grep -B 100 '^\['
            fi
            ;;
        *)
            echo "Unsupported dependency file: $file"
            return 1
            ;;
    esac
}

# Container Health Check Utilities

# Check if Docker container is healthy
check_container_health() {
    local container_name="$1"
    local max_wait="${2:-30}" # Default wait time: 30 seconds
    local wait_interval="${3:-5}" # Default check interval: 5 seconds
    
    local elapsed=0
    while [ $elapsed -lt $max_wait ]; do
        local status
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
        
        case "$status" in
            healthy)
                return 0
                ;;
            unhealthy)
                echo "Container $container_name is unhealthy"
                return 1
                ;;
        esac
        
        sleep "$wait_interval"
        elapsed=$((elapsed + wait_interval))
    done
    
    echo "Container health check timed out after ${max_wait} seconds"
    return 1
}

# Verify container isolation
verify_container_isolation() {
    local container_name="$1"
    local test_file="$2"
    
    # Try to access a file that should only exist in the container
    if docker exec "$container_name" test -f "$test_file"; then
        local container_content
        container_content=$(docker exec "$container_name" cat "$test_file")
        
        # Verify the file doesn't exist on host
        if [ -f "$test_file" ]; then
            local host_content
            host_content=$(cat "$test_file")
            if [ "$container_content" = "$host_content" ]; then
                echo "Container isolation breach: Same content found in host"
                return 1
            fi
        fi
        return 0
    fi
    
    echo "Container isolation test failed: Could not access test file"
    return 1
}

# Documentation Validation Utilities

# Verify that all required sections exist in a markdown file
validate_markdown_sections() {
    local file="$1"
    shift
    local sections=("$@")
    
    local missing_sections=()
    for section in "${sections[@]}"; do
        if ! grep -q "^#.*${section}" "$file"; then
            missing_sections+=("$section")
        fi
    done
    
    if [ ${#missing_sections[@]} -ne 0 ]; then
        echo "Missing required sections in $file:"
        printf '%s\n' "${missing_sections[@]}"
        return 1
    fi
    
    return 0
}

# Verify markdown links are valid
validate_markdown_links() {
    local file="$1"
    local base_dir="$2"
    
    local invalid_links=()
    
    # Extract markdown links and verify they exist
    while IFS= read -r link; do
        # Skip empty lines
        [ -z "$link" ] && continue
        
        # Remove markdown formatting to get just the path
        local path
        path=$(echo "$link" | sed -n 's/.*(\([^)]*\))/\1/p')
        
        # Skip external links
        [[ "$path" =~ ^https?:// ]] && continue
        
        # Resolve relative path
        local full_path="$base_dir/$path"
        
        if [ ! -e "$full_path" ]; then
            invalid_links+=("$path")
        fi
    done < <(grep -o '\[.*\](.*\))' "$file")
    
    if [ ${#invalid_links[@]} -ne 0 ]; then
        echo "Invalid links found in $file:"
        printf '%s\n' "${invalid_links[@]}"
        return 1
    fi
    
    return 0
}

# CI/CD Pipeline Simulation Utilities

# Simulate a CI pipeline stage
simulate_ci_stage() {
    local stage_name="$1"
    local command="$2"
    local expected_status="$3"
    
    echo -e "${BLUE}Running CI stage: ${stage_name}${NC}"
    
    local start_time
    start_time=$(date +%s)
    
    if eval "$command"; then
        local status=0
    else
        local status=1
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✓ Stage ${stage_name} completed as expected (${duration}s)${NC}"
        return 0
    else
        echo -e "${RED}✗ Stage ${stage_name} failed unexpectedly (${duration}s)${NC}"
        return 1
    fi
}

# Meta-Level Test Assertions

# Assert dependency is properly locked/flexible
assert_dependency_strategy() {
    local name="$1"
    local version="$2"
    local strategy="$3" # "locked" or "flexible"
    
    case "$strategy" in
        locked)
            if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo -e "${GREEN}✓ Dependency ${name} is properly locked to version ${version}${NC}"
                return 0
            else
                echo -e "${RED}✗ Dependency ${name} should be locked but has flexible version: ${version}${NC}"
                return 1
            fi
            ;;
        flexible)
            if [[ "$version" =~ [\^\~\*] ]]; then
                echo -e "${GREEN}✓ Dependency ${name} is properly flexible: ${version}${NC}"
                return 0
            else
                echo -e "${RED}✗ Dependency ${name} should be flexible but is locked: ${version}${NC}"
                return 1
            fi
            ;;
        *)
            echo "Invalid dependency strategy: $strategy"
            return 1
            ;;
    esac
}

# Assert a template can be generated reproducibly
assert_template_reproducible() {
    local template="$1"
    local params="$2"
    
    # Generate template twice with same parameters
    local temp_dir1
    temp_dir1=$(mktemp -d)
    local temp_dir2
    temp_dir2=$(mktemp -d)
    
    if ! eval "generate_template \"$template\" \"$params\" \"$temp_dir1\"" || \
       ! eval "generate_template \"$template\" \"$params\" \"$temp_dir2\""; then
        echo "Failed to generate template"
        rm -rf "$temp_dir1" "$temp_dir2"
        return 1
    fi
    
    # Compare the generated templates
    if diff -r "$temp_dir1" "$temp_dir2" > /dev/null; then
        echo -e "${GREEN}✓ Template generation is reproducible${NC}"
        rm -rf "$temp_dir1" "$temp_dir2"
        return 0
    else
        echo -e "${RED}✗ Template generation is not reproducible${NC}"
        echo "Differences found between:"
        echo "  $temp_dir1"
        echo "  $temp_dir2"
        rm -rf "$temp_dir1" "$temp_dir2"
        return 1
    fi
}
