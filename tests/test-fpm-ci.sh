#!/bin/bash
# Simplified FPM test for CI compatibility
# Minimal, robust, works with sh/bash

set -e

IMAGE="${1:-skilldlabs/php:85-fpm}"
EXPECTED_PHP="${2:-8.5}"
PHPV="${EXPECTED_PHP//./}"
CONTAINER_NAME="test-php-fpm-${PHPV}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

RUNTIME="${CONTAINER_RUNTIME:-docker}"

echo "Testing PHP-FPM image: ${IMAGE}"
echo "Expected PHP: ${EXPECTED_PHP}"
echo "Runtime: ${RUNTIME}"

# Remove any existing container
${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true

# Start container
echo "Starting container..."
${RUNTIME} run -d --name "${CONTAINER_NAME}" "${IMAGE}" > /dev/null

# Wait for container to be ready
sleep 5

# Verify container is running
if ! ${RUNTIME} ps -q --filter "name=${CONTAINER_NAME}" > /dev/null 2>&1; then
    echo "Container failed to start"
    ${RUNTIME} logs "${CONTAINER_NAME}" 2>&1 || true
    ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
    exit 1
fi

# Test PHP-FPM version
echo "Testing PHP-FPM version..."
if ${RUNTIME} exec "${CONTAINER_NAME}" php-fpm${PHPV} -v 2>&1 | grep -q "PHP ${EXPECTED_PHP}"; then
    echo "${GREEN}✓ PHP-FPM version OK${NC}"
else
    echo "${RED}✗ PHP-FPM version failed${NC}"
    ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
    exit 1
fi

# Test PHP CLI
echo "Testing PHP CLI..."
if ${RUNTIME} exec "${CONTAINER_NAME}" php -r "echo PHP_VERSION;" 2>/dev/null | grep -q "${EXPECTED_PHP:0:3}${EXPECTED_PHP:2:3}"; then
    echo "${GREEN}✓ PHP CLI OK${NC}"
else
    echo "${RED}✗ PHP CLI failed${NC}"
    ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
    exit 1
fi

# Test web-user
echo "Testing web-user..."
if ${RUNTIME} exec "${CONTAINER_NAME}" id web-user 2>/dev/null | grep -q "uid=1000"; then
    echo "${GREEN}✓ web-user OK${NC}"
else
    echo "${RED}✗ web-user failed${NC}"
    ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
    exit 1
fi

# Test config file
echo "Testing config..."
if ${RUNTIME} exec "${CONTAINER_NAME}" test -f "/etc/php${PHPV}/php-fpm.conf"; then
    echo "${GREEN}✓ Config OK${NC}"
else
    echo "${RED}✗ Config failed${NC}"
    ${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true
    exit 1
fi

# Cleanup
${RUNTIME} rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo ""
echo "${GREEN}All tests passed!${NC}"
exit 0
