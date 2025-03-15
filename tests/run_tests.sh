#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory containing this script
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🧪 Running template system tests...${NC}\n"

# Array to store failed test files
failed_tests=()
total_tests=0
passed_tests=0

# Function to run a test file
run_test_file() {
    local test_file="$1"
    echo -e "${BLUE}Running test suite: ${test_file}${NC}"
    
    # Run the test file
    if $test_file; then
        ((passed_tests++))
        echo -e "${GREEN}✓ Test suite passed: ${test_file}${NC}"
    else
        failed_tests+=("$test_file")
        echo -e "${RED}✗ Test suite failed: ${test_file}${NC}"
    fi
    
    ((total_tests++))
    echo
}

# Run unit tests
echo -e "${BLUE}Running unit tests...${NC}"
for test_file in "$TEST_DIR"/unit/test_*.sh; do
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        run_test_file "$test_file"
    fi
done

# Run integration tests
echo -e "${BLUE}Running integration tests...${NC}"
for test_file in "$TEST_DIR"/integration/test_*.sh; do
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        run_test_file "$test_file"
    fi
done

# Run end-to-end tests
echo -e "${BLUE}Running end-to-end tests...${NC}"
for test_file in "$TEST_DIR"/e2e/test_*.sh; do
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        run_test_file "$test_file"
    fi
done

# Run meta-level tests
echo -e "${BLUE}Running meta-level tests...${NC}"
for test_file in "$TEST_DIR"/meta/test_*.sh; do
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        run_test_file "$test_file"
    fi
done

# Print summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo -e "Total test suites:  $total_tests"
echo -e "Passed test suites: ${GREEN}$passed_tests${NC}"
failed_count=${#failed_tests[@]}
if [ $failed_count -gt 0 ]; then
    echo -e "Failed test suites: ${RED}$failed_count${NC}"
    echo -e "\n${RED}Failed test suites:${NC}"
    for failed_test in "${failed_tests[@]}"; do
        echo -e "${RED}- ${failed_test}${NC}"
    done
    exit 1
else
    echo -e "\n${GREEN}✨ All test suites passed!${NC}"
    exit 0
fi
