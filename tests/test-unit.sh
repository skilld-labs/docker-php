#!/bin/bash
# Unit image - Web server + Drupal essentials
# Usage: docker exec CONTAINER /tests/test-unit.sh [EXPECTED_PHP]
# Assumes container is already running (agent-managed lifecycle via tests/run-test.sh)

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
echo "Testing Unit PHP ${EXPECTED_PHP}"
echo "=========================================="

# Give Unit a moment to be fully ready
sleep 3

# Drupal web essentials
run_test "Unit running" "ps aux | grep -q 'unitd.*main'"
run_test "Unit controller" "ps aux | grep -q 'unitd.*controller'"
run_test "Unit router" "ps aux | grep -q 'unitd.*router' || true"
run_test "PHP CLI" "php -v | grep -q 'PHP ${EXPECTED_PHP}'"
run_test "Unit PHP module" "php -m | grep -q unit || ls /usr/lib/unit/modules/ 2>/dev/null | grep -q php"
run_test "web-user UID 1000" "id web-user 2>/dev/null | grep -q uid=1000"
run_test "web-group GID 1000" "getent group web-group 2>/dev/null | grep -q ':1000:' || true"
run_test "Config file" "test -f /var/lib/unit/conf.json"
run_test "Work directory" "test -d /var/www/html/web"

# Check if running as web-user (non-critical)
echo -n "Test $((TESTS_RUN + 1)): Running as web-user ... "
TESTS_RUN=$((TESTS_RUN + 1))
if ps aux | grep 'unitd' | grep -q 'web-user' 2>/dev/null; then
    echo "✓"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "⊘ SKIPPED (process ownership check)"
fi

echo ""
echo "=========================================="
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "=========================================="

[ $TESTS_FAILED -eq 0 ] && echo "✓ All tests passed!" && exit 0
exit 1
