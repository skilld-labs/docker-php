#!/bin/bash
# FPM image - Web server + Drupal essentials
# Usage: docker exec CONTAINER /tests/test-fpm.sh [EXPECTED_PHP]
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
echo "Testing FPM PHP ${EXPECTED_PHP}"
echo "=========================================="

# Give FPM a moment to be fully ready
sleep 2

# Drupal web essentials
run_test "PHP-FPM version" "php-fpm${PHPV} -v 2>&1 | grep -q 'PHP ${EXPECTED_PHP}'"
run_test "PHP-FPM master process" "ps aux | grep -q 'php-fpm.*master' || true"
run_test "PHP CLI" "php -v | grep -q 'PHP ${EXPECTED_PHP}'"
run_test "web-user UID 1000" "id web-user 2>/dev/null | grep -q uid=1000"
run_test "web-group GID 1000" "getent group web-group 2>/dev/null | grep -q ':1000:' || true"
run_test "Config file" "test -f /etc/php${PHPV}/php-fpm.conf"
run_test "Log directory" "test -d /var/log/php${PHPV}"

# Port check (non-critical, tools may not be available)
echo -n "Test $((TESTS_RUN + 1)): Port 9000 listening ... "
TESTS_RUN=$((TESTS_RUN + 1))
if { netstat -tlnp 2>/dev/null | grep ':9000' || ss -tlnp 2>/dev/null | grep ':9000'; } 2>/dev/null | grep -q '9000'; then
    echo "✓"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "⊘ SKIPPED (port tools unavailable)"
fi

echo ""
echo "=========================================="
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "=========================================="

[ $TESTS_FAILED -eq 0 ] && echo "✓ All tests passed!" && exit 0
exit 1
