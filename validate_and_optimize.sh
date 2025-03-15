#!/bin/bash

# 1️⃣ Validate Test System Execution
./tests/run_tests.sh

# If tests fail, analyze error logs and categorize issues:
if [[ $? -ne 0 ]]; then
    echo "🔍 Test Execution Failed - Initiating Deep Analysis..."
    
    # Inspect which test categories failed
    failed_tests=$(grep 'FAIL' tests/test_results.log)
    echo "🚨 Failing Tests: $failed_tests"
    
    # Identify specific reasons for failure
    for test in $failed_tests; do
        echo "🔎 Analyzing failure in: $test"
        cat "tests/logs/$test.log"
    done

    # Validate Template Factory readiness
    if [ ! -d "template-factory" ]; then
        echo "⚠️ Template factory directory missing. Implement required components."
    fi
    
    if [ ! -f "template-factory/generate.sh" ]; then
        echo "⚠️ Template generation script missing. Implement 'generate.sh'."
    fi

    if grep -q 'MISSING_IMPLEMENTATION' tests/logs/*; then
        echo "⚠️ Some tests reference unimplemented features. Proceed to implementation."
    fi
fi

# 3️⃣ Ensure Comprehensive Testing Coverage
if ! grep -q 'ALL TESTS PASSED' tests/test_results.log; then
    echo "⚠️ Not all features are tested. Implement missing test cases."
fi

# 4️⃣ Optimize Implementation for Full Coverage
echo "🔄 Re-running tests after optimizations..."
./tests/run_tests.sh

# Final validation of Template Factory
if grep -q 'ALL TESTS PASSED' tests/test_results.log; then
    echo "✅ Template Factory is fully functional and aligned with expected implementations."
else
    echo "🚨 Template Factory or Tests are incomplete. Further analysis required."
fi
