#!/bin/bash
# Reusable benchmark functions for Drupal performance testing
# Source this file in test scripts or performance workflows

# Drupal installation helpers
drupal_install_sqlite() {
    local docroot="$1"
    local db_path="$2"

    if [ ! -d "$docroot" ]; then
        echo "Error: docroot '$docroot' does not exist"
        return 1
    fi

    php "$docroot/core/scripts/drush.php" \
        --root="$docroot" \
        sql-create --db-url="sqlite://$db_path" -y
}

drupal_rebuild_cache() {
    local docroot="$1"

    if [ ! -d "$docroot" ]; then
        echo "Error: docroot '$docroot' does not exist"
        return 1
    fi

    php "$docroot/core/scripts/drush.php" --root="$docroot" cache:rebuild -y
}

# Request timing functions
time_cold_request() {
    local url="$1"
    local retries="${2:-1}"

    if [ -z "$url" ]; then
        echo "Error: URL is required"
        return 1
    fi

    for i in $(seq 1 "$retries"); do
        curl -s -o /dev/null -w '%{time_total}\n' "$url"
    done
}

time_warm_request() {
    local url="$1"
    local warmup_count="${2:-5}"

    if [ -z "$url" ]; then
        echo "Error: URL is required"
        return 1
    fi

    # Warm up the cache
    for i in $(seq 1 "$warmup_count"); do
        curl -s -o /dev/null "$url" >/dev/null 2>&1
    done

    # Measure warm request time
    curl -s -o /dev/null -w '%{time_total}\n' "$url"
}

# Profiling support (placeholder for future implementation)
enable_spx() {
    # php-spx for lightweight profiling
    # Usage: enable_spx
    if command -v docker-php-ext-enable >/dev/null 2>&1; then
        docker-php-ext-enable spx 2>/dev/null || {
            # Fallback: manually enable
            local phpv="${PHPV:-85}"
            echo "extension=spx.so" >> "/etc/php${phpv}/conf.d/99-spx.ini"
        }
    else
        echo "Warning: docker-php-ext-enable not available, SPX not enabled"
    fi
}

enable_xhprof() {
    # xhprof for detailed profiling
    # Usage: enable_xhprof
    if command -v docker-php-ext-enable >/dev/null 2>&1; then
        docker-php-ext-enable xhprof 2>/dev/null || \
            echo "Warning: xhprof extension not found"
    else
        echo "Warning: docker-php-ext-enable not available, xhprof not enabled"
    fi
}

setup_otel() {
    # OpenTelemetry placeholder
    # Future: Install OTEL extension, configure endpoint, export metrics
    echo "OTEL setup: TODO - not implemented yet"
}

# Helper to check if a URL is accessible
check_url() {
    local url="$1"
    local expected_code="${2:-200}"

    local code
    code=$(curl -s -o /dev/null -w '%{http_code}' "$url")
    if [ "$code" = "$expected_code" ]; then
        return 0
    else
        echo "URL returned $code, expected $expected_code"
        return 1
    fi
}

# Export functions for use in subshells
export -f drupal_install_sqlite drupal_rebuild_cache time_cold_request time_warm_request
export -f enable_spx enable_xhprof setup_otel check_url
