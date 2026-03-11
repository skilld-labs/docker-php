#!/bin/bash
# FrankenPHP image - Drupal essentials
# Usage: docker exec CONTAINER /tests/test-frankenphp.sh [EXPECTED_PHP]
# TODO: Implement full test suite for FrankenPHP

set -e

EXPECTED_PHP="${1:-8.5}"

echo "=========================================="
echo "Testing FrankenPHP PHP ${EXPECTED_PHP}"
echo "=========================================="
echo ""
echo "FrankenPHP tests: TODO - Not yet implemented"
echo ""
echo "Future tests should include:"
echo "  - PHP CLI version check"
echo "  - FrankenPHP process running"
echo "  - Caddy webserver running"
echo "  - Composer available"
echo "  - HTTP response on port 80"
echo "=========================================="

# For now, just exit successfully
exit 0
