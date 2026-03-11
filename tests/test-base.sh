#!/bin/bash
# Base PHP image - Drupal CLI essentials
# Usage: docker exec CONTAINER /tests/test-base.sh [EXPECTED_PHP]
# Assumes container is already running (agent-managed lifecycle)

set -e

EXPECTED_PHP="${1:-8.5}"
PHPV="${EXPECTED_PHP//./}"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local name="$1"
    local cmd="$2"
    TESTS_RUN=$((TESTS_RUN + 1))
    printf "Test %d: %s ... " "$TESTS_RUN" "$name"
    if eval "$cmd" 2>/dev/null; then
        echo "✓"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "=========================================="
echo "Testing Base PHP ${EXPECTED_PHP}"
echo "=========================================="

# Drupal CLI essentials
run_test "PHP ${EXPECTED_PHP}" "php -v | grep -q 'PHP ${EXPECTED_PHP}'"
run_test "Composer" "composer --version 2>&1 | grep -q Composer"
run_test "Drush" "drush --version 2>&1 | grep -q Drush"
run_test "MySQL client" "command -v mysql || command -v mariadb"
run_test "git" "command -v git"
run_test "curl" "command -v curl"
run_test "patch" "command -v patch"
run_test "rsync" "command -v rsync"

echo ""
echo "--- Extension Validation ---"
echo ""

# Run extension validator (doesn't count toward test total, provides detailed output)
if sh /tests/validate-extensions.sh "${EXPECTED_PHP}"; then
    echo "✓ Extensions validated"
else
    echo "✗ Extension validation failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""
echo "=========================================="
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "=========================================="

[ $TESTS_FAILED -eq 0 ] && echo "✓ All tests passed!" && exit 0
exit 1
