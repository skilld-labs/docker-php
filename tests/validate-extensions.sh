#!/bin/sh
# PHP Extensions Validator (POSIX-compliant)
# Usage: tests/validate-extensions.sh <PHP_VERSION>
#   PHP_VERSION: e.g., 8.5, 8.4, etc.

set -e

PHP_VERSION="${1:-8.5}"

echo "=========================================="
echo "Validating PHP ${PHP_VERSION} Extensions"
echo "=========================================="

# Get actual loaded modules from PHP
ACTUAL_MODULES=$(php -m 2>/dev/null || true)

if [ -z "$ACTUAL_MODULES" ]; then
  echo "Error: Cannot get PHP modules. Are you running inside a PHP container?"
  exit 1
fi

# Count actual modules (exclude header lines)
ACTUAL_COUNT=$(echo "$ACTUAL_MODULES" | grep -vE '^\[.*\]$|^$' | wc -l)

echo "Found ${ACTUAL_COUNT} loaded modules"
echo ""

# Critical extensions for Drupal (must be present)
# Using grep instead of arrays for POSIX compatibility
echo "Checking required Drupal extensions:"

REQUIRED_PRESENT=0
REQUIRED_TOTAL=0

check_required() {
  if echo "$ACTUAL_MODULES" | grep -qx "$1"; then
    printf "  - %-20s ... ✓\n" "$1"
    REQUIRED_PRESENT=$((REQUIRED_PRESENT + 1))
  else
    printf "  - %-20s ... ✗ MISSING\n" "$1"
  fi
  REQUIRED_TOTAL=$((REQUIRED_TOTAL + 1))
}

check_required "Zend OPcache"
check_required "apcu"
check_required "gd"
check_required "json"
check_required "mbstring"
check_required "pdo_mysql"
check_required "pdo_sqlite"
check_required "curl"
check_required "openssl"
check_required "zip"

echo ""
echo "Required: $REQUIRED_PRESENT/$REQUIRED_TOTAL present"
echo ""

# Check for version-specific extensions
echo "Checking PHP ${PHP_VERSION} specific extensions:"
case "$PHP_VERSION" in
  8.5|85)
    for ext in lexbor uri readline; do
      if echo "$ACTUAL_MODULES" | grep -qx "$ext"; then
        printf "  - %-20s ... ✓\n" "$ext"
      else
        printf "  - %-20s ... ⊘ NOT FOUND (may be optional)\n" "$ext"
      fi
    done
    ;;
  *)
    echo "  (no version-specific extensions defined)"
    ;;
esac

echo ""

# Check PECL extensions
echo "Checking PECL extensions:"
PECL_PRESENT=0
PECL_TOTAL=0

check_pecl() {
  if echo "$ACTUAL_MODULES" | grep -qx "$1"; then
    printf "  - %-20s ... ✓\n" "$1"
    PECL_PRESENT=$((PECL_PRESENT + 1))
  else
    printf "  - %-20s ... ⊘ NOT LOADED\n" "$1"
  fi
  PECL_TOTAL=$((PECL_TOTAL + 1))
}

check_pecl "apcu"
check_pecl "igbinary"
check_pecl "brotli"
check_pecl "uploadprogress"

# Xdebug is special - installed but not loaded by default (requires zend_extension)
echo "  - xdebug               ... (available but not loaded by default)"
PECL_TOTAL=$((PECL_TOTAL + 1))

echo ""
echo "PECL (loaded): $PECL_PRESENT/$PECL_TOTAL present"
echo ""

# Show all loaded modules for reference
echo "All loaded modules:"
echo "$ACTUAL_MODULES" | grep -vE '^\[.*\]$|^$' | sort | while read -r mod; do
  printf "  - %s\n" "$mod"
done
echo ""

# Summary
echo "=========================================="
echo "Summary:"
echo "  Total modules: $ACTUAL_COUNT"
echo "  Required: $REQUIRED_PRESENT/$REQUIRED_TOTAL"
echo "  PECL: $PECL_PRESENT/$PECL_TOTAL"
echo ""

if [ $REQUIRED_PRESENT -lt $REQUIRED_TOTAL ]; then
  echo "✗ VALIDATION FAILED: Missing required extensions"
  exit 1
else
  echo "✓ VALIDATION PASSED"
  exit 0
fi
