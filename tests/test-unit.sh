#!/bin/bash
# Test script for PHP Unit images (php{VER}-unit)
# Usage: tests/test-unit.sh <IMAGE_TAG> [PHP_VERSION]
# Example: tests/test-unit.sh skilldlabs/php:85-unit 8.5

set -e

# Source test library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/test-lib.sh"

IMAGE="${1:-skilldlabs/php:85-unit}"
EXPECTED_PHP="${2:-8.5}"
PHPV="${EXPECTED_PHP//./}"  # Convert 8.5 to 85
CONTAINER_NAME="test-php-unit-${PHPV}"

echo "=========================================="
echo "Testing PHP Unit image: ${IMAGE}"
echo "Expected PHP version: ${EXPECTED_PHP}"
echo "Runtime: ${RUNTIME}"
echo "=========================================="

# Ensure image is available
ensure_image "${IMAGE}" || exit 1

# Start the Unit container (it runs unitd as daemon)
echo ""
echo "Starting Unit test container..."
# Remove any existing container first
remove_container "${CONTAINER_NAME}"

${RUNTIME} run -d --name "${CONTAINER_NAME}" -p 127.0.0.1:8080:80 "${IMAGE}" || {
  echo "Failed to start container"
  exit 1
}
sleep 3

# Verify container is running
if ! ${RUNTIME} ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" 2>/dev/null | grep -q "${CONTAINER_NAME}"; then
  echo "Container failed to start"
  ${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true
  remove_container "${CONTAINER_NAME}"
  exit 1
fi

# Set CONTAINER_NAME for run_test to use
export CONTAINER_NAME

# Run tests in the container
run_test "Unit version check" \
  "unitd --version | head -1"

run_test "Unit main process running" \
  "ps aux | grep -q 'unit: main'"

run_test "Unit controller process running" \
  "ps aux | grep -q 'unit: controller'"

run_test "Unit router process running" \
  "ps aux | grep -q 'unit: router'"

run_test "PHP CLI available in container" \
  "php -v | grep -qE 'PHP ${EXPECTED_PHP}'"

run_test "Unit PHP module loaded" \
  "ls /usr/lib/unit/modules/ | grep -q 'php'"

run_test "Unit configuration file exists" \
  "test -f /var/lib/unit/conf.json"

run_test "Work directory /var/www/html exists" \
  "test -d /var/www/html"

run_test "web-user exists with UID 1000" \
  "id web-user | grep -q 'uid=1000'"

run_test "web-group exists with GID 1000" \
  "getent group web-group | grep -q ':1000:'"

# Check if Unit processes are running as web-user
echo ""
echo "Test $((TESTS_RUN + 1)): Unit processes running as web-user"
if exec_container "${CONTAINER_NAME}" sh -c "ps aux | grep 'web-user' | grep -qE 'controller|router'"; then
  echo "${GREEN}✓ PASSED${NC} - Unit processes running as web-user"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "${RED}✗ FAILED${NC} - Unit processes not running as web-user"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Cleanup
remove_container "${CONTAINER_NAME}"
unset CONTAINER_NAME

# Print summary and exit
print_summary
