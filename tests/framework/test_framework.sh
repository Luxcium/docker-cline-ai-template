#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test suite tracking
CURRENT_SUITE=""
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test environment variables
TEST_DIR=""
TEMPLATE_DIR=""

# Temporary directory for test artifacts
TEMP_DIR=""

# Test helper functions
function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo -e "${YELLOW}  Expected: '${expected}'${NC}"
        echo -e "${YELLOW}  Actual:   '${actual}'${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$unexpected" != "$actual" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo -e "${YELLOW}  Should not be: '${unexpected}'${NC}"
        echo -e "${YELLOW}  Actual:        '${actual}'${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_file_exists() {
    local file="$1"
    local message="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo -e "${YELLOW}  File does not exist: ${file}${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_dir_exists() {
    local dir="$1"
    local message="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo -e "${YELLOW}  Directory does not exist: ${dir}${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

function assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓ PASS: ${message}${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: ${message}${NC}"
        echo -e "${YELLOW}  Expected to find: '${needle}'${NC}"
        echo -e "${YELLOW}  In:              '${haystack}'${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test lifecycle functions
function describe() {
    CURRENT_SUITE="$1"
    echo -e "\n${BLUE}Test Suite: ${CURRENT_SUITE}${NC}"
}

function it() {
    local test_name="$1"
    echo -e "\n${BLUE}  Test: ${test_name}${NC}"
}

function skip_test() {
    local message="$1"
    echo -e "${YELLOW}  SKIP: ${message}${NC}"
    ((TESTS_SKIPPED++))
}

# Test environment setup/teardown
function setup_test_environment() {
    TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEMPLATE_DIR="$(cd "${TEST_DIR}/../.." && pwd)"
    TEMP_DIR=$(mktemp -d)
    
    echo -e "${BLUE}Setting up test environment${NC}"
    echo "  Test directory: ${TEST_DIR}"
    echo "  Template directory: ${TEMPLATE_DIR}"
    echo "  Temporary directory: ${TEMP_DIR}"
}

function teardown_test_environment() {
    echo -e "\n${BLUE}Tearing down test environment${NC}"
    
    # Clean up temporary directory
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Test results reporting
function print_test_summary() {
    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    
    echo -e "\n${BLUE}Test Summary:${NC}"
    echo -e "  Total tests:  ${total}"
    echo -e "${GREEN}  Tests passed: ${TESTS_PASSED}${NC}"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}  Tests failed: ${TESTS_FAILED}${NC}"
    else
        echo -e "  Tests failed: 0"
    fi
    
    if [ $TESTS_SKIPPED -gt 0 ]; then
        echo -e "${YELLOW}  Tests skipped: ${TESTS_SKIPPED}${NC}"
    else
        echo -e "  Tests skipped: 0"
    fi
}

# Error handling
function handle_error() {
    local exit_code=$?
    local line_number=$1
    
    echo -e "${RED}Error on line ${line_number}${NC}"
    exit $exit_code
}

# Set up error handling
trap 'handle_error ${LINENO}' ERR

# Main test runner function
function run_tests() {
    setup_test_environment
    
    # Source test files
    for test_file in "$@"; do
        if [ -f "$test_file" ]; then
            echo -e "\n${BLUE}Running tests from: ${test_file}${NC}"
            source "$test_file"
        fi
    done
    
    print_test_summary
    teardown_test_environment
    
    # Exit with failure if any tests failed
    [ $TESTS_FAILED -eq 0 ] || exit 1
}
