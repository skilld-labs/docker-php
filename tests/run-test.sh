#!/bin/bash
# Test runner script - public entrypoint that manages container lifecycle
# Usage: tests/run-test.sh <IMAGE> <PHP_VERSION> [TEST_TYPE]
#   IMAGE: Docker image name (e.g., skilldlabs/php:85)
#   PHP_VERSION: PHP version (e.g., 8.5)
#   TEST_TYPE: base|fpm|unit (auto-detected from image name if omitted)

set -e

IMAGE="${1}"
EXPECTED_PHP="${2}"
TEST_TYPE="${3:-}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect test type from image name if not provided
if [ -z "$TEST_TYPE" ]; then
  case "$IMAGE" in
    *-fpm) TEST_TYPE="fpm" ;;
    *-unit) TEST_TYPE="unit" ;;
    *) TEST_TYPE="base" ;;
  esac
fi

# Container name (unique per image)
PHPV="${EXPECTED_PHP//./}"
CONTAINER_NAME="test-${TEST_TYPE}-${PHPV}"

echo "=========================================="
echo "Testing: $IMAGE (PHP $EXPECTED_PHP, $TEST_TYPE)"
echo "Container: $CONTAINER_NAME"
echo "=========================================="

# Runtime detection
RUNTIME="${CONTAINER_RUNTIME:-docker}"
if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  RUNTIME="docker"
fi

# Clean up any existing container
${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true

# Start container based on type
# Mount tests directory as /tests inside container
case "$TEST_TYPE" in
  base)
    # Base image: keep alive with long sleep for testing
    ${RUNTIME} run -d --name "${CONTAINER_NAME}" \
      -v "${SCRIPT_DIR}:/tests:ro" \
      "${IMAGE}" sleep 86400 >/dev/null
    echo "Started base image container..."
    ;;
  fpm)
    # FPM image: runs php-fpm in foreground
    ${RUNTIME} run -d --name "${CONTAINER_NAME}" \
      -v "${SCRIPT_DIR}:/tests:ro" \
      "${IMAGE}" >/dev/null
    echo "Started FPM container, waiting for ready..."
    sleep 3
    ;;
  unit)
    # Unit image: runs unitd, needs proper working directory
    ${RUNTIME} run -d --name "${CONTAINER_NAME}" \
      -v "${SCRIPT_DIR}:/tests:ro" \
      "${IMAGE}" >/dev/null
    echo "Started Unit container, waiting for ready..."
    sleep 4

    # Check if Unit started successfully by examining logs
    if ! ${RUNTIME} ps -q --filter "name=${CONTAINER_NAME}" >/dev/null 2>&1; then
      echo "✗ Container failed to start"
      ${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true
      exit 1
    fi

    # Check for errors in logs (but Unit may complain about missing index.php - that's OK)
    LOGS=$(${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true)
    if echo "$LOGS" | grep -qi "fatal\|error\|failed"; then
      # Unit might complain about missing files, but process should be running
      if ! ${RUNTIME} exec "${CONTAINER_NAME}" ps aux | grep -q unitd; then
        echo "✗ Unit process not running"
        echo "Logs:"
        echo "$LOGS"
        ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
        exit 1
      fi
    fi
    echo "Unit process confirmed running..."
    ;;
esac

# Verify container is running
if ! ${RUNTIME} ps -q --filter "name=${CONTAINER_NAME}" >/dev/null 2>&1; then
  echo "✗ Container failed to start or died immediately"
  ${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true
  exit 1
fi

# Run the appropriate test
echo "Running tests..."
case "$TEST_TYPE" in
  base)
    ${RUNTIME} exec "${CONTAINER_NAME}" sh /tests/test-base.sh "${EXPECTED_PHP}"
    ;;
  fpm)
    ${RUNTIME} exec "${CONTAINER_NAME}" sh /tests/test-fpm.sh "${EXPECTED_PHP}"
    ;;
  unit)
    ${RUNTIME} exec "${CONTAINER_NAME}" sh /tests/test-unit.sh "${EXPECTED_PHP}"
    ;;
esac

TEST_EXIT=$?

# Cleanup
echo ""
echo "Cleaning up..."
${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true

if [ $TEST_EXIT -eq 0 ]; then
  echo "✓ All tests passed!"
else
  echo "✗ Tests failed!"
fi

exit $TEST_EXIT
