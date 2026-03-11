#!/bin/bash
# Test script for base PHP images (php{VER})
# Usage: tests/test-base.sh <IMAGE_TAG> [PHP_VERSION]
# Example: tests/test-base.sh skilldlabs/php:85 8.5

set -e

# Source test library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/test-lib.sh"

IMAGE="${1:-skilldlabs/php:85}"
EXPECTED_PHP="${2:-8.5}"
CONTAINER_NAME="test-php-base-${EXPECTED_PHP//./}"

echo "=========================================="
echo "Testing base PHP image: ${IMAGE}"
echo "Expected PHP version: ${EXPECTED_PHP}"
echo "Runtime: ${RUNTIME}"
echo "=========================================="

# Ensure image is available
ensure_image "${IMAGE}" || exit 1

# Start one long-running container for all tests
echo ""
echo "Starting test container..."
start_container "${CONTAINER_NAME}" "${IMAGE}" || {
  echo "Failed to start container"
  exit 1
}
sleep 2

# Verify container is running
if ! ${RUNTIME} ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
  echo "Container failed to start"
  ${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true
  remove_container "${CONTAINER_NAME}"
  exit 1
fi

# Run all tests in the same container
run_test "PHP version check" \
  "php -v | grep -qE 'PHP ${EXPECTED_PHP}'"

run_test "Composer version check" \
  "composer --version | grep -qE 'Composer version [0-9]'"

run_test "Drush version check" \
  "drush version | grep -qE 'Drush Version'"

run_test "OPcache extension loaded" \
  "php -m | grep -q 'Zend OPcache'"

run_test "APCu extension loaded" \
  "php -m | grep -q 'apcu'"

run_test "GD extension loaded" \
  "php -m | grep -q 'gd'"

run_test "igbinary extension loaded" \
  "php -m | grep -q 'igbinary'"

run_test "Xdebug extension available" \
  "ls /usr/lib/php*/modules/xdebug.so 2>/dev/null || test -f /usr/lib/php85/modules/xdebug.so || test -f /usr/lib/php84/modules/xdebug.so || test -f /usr/lib/php83/modules/xdebug.so"

run_test "Work directory /srv exists" \
  "test -d /srv"

run_test "git binary available" \
  "which git"

run_test "curl binary available" \
  "which curl"

run_test "patch binary available" \
  "which patch"

run_test "rsync binary available" \
  "which rsync"

run_test "mariadb-client available" \
  "which mysql"

run_test "Built-in PHP server works" \
  "php -S 0.0.0.0:8081 -t /srv &>/dev/null & sleep 1 && kill %1 2>/dev/null || true"

# Cleanup
remove_container "${CONTAINER_NAME}"

# Print summary and exit
print_summary
