# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image collection for PHP (7.4 through 8.5) optimized for Drupal, published as `skilldlabs/php` on Docker Hub. All images are multi-platform (linux/amd64, linux/arm64) and Alpine-based (except FrankenPHP which uses Ubuntu).

## Build Commands

```bash
# Build and push all default images (requires buildx)
make build

# Build specific tags only
make build TAGS="84 84-fpm 84-unit"

# Build Unit dev variants (adds nodejs, yarn, bash)
make unit

# Build and test locally (amd64 only, tests before push)
make test-local TAGS="85 85-fpm 85-unit"

# Setup QEMU + buildx for multi-platform builds
make prepare

# Tag a release version
make tag VER=1.2.3 TAGS="84 84-fpm"
```

Build args `COMPOSER_HASH` and `DRUSH_VERSION` are defined in the root Makefile and passed to base image builds.

## Testing

### Local Testing

```bash
# Test all PHP 8.5 variants locally
make test-local TAGS="85 85-fpm 85-unit"

# Test individual images
./tests/test-base.sh skilldlabs/php:85 8.5
./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5
./tests/test-unit.sh skilldlabs/php:85-unit 8.5

# Test with specific runtime (docker/podman/nerdctl)
CONTAINER_RUNTIME=podman ./tests/test-base.sh skilldlabs/php:85 8.5
```

### CI Testing

Images are tested in CI **before** being pushed. The workflow:
1. Builds image for `linux/amd64` only (fast, with `--load`)
2. Runs appropriate test script
3. If tests pass, pushes to all platforms
4. Uses build cache for faster rebuilds

See `.github/workflows/build-php.yml` for CI implementation.

## Debug Tools

### GitHub Actions Debug Helper

```bash
# List recent workflow runs
./gh-debug.sh list

# Watch latest run live
./gh-debug.sh watch

# Show failed runs with details
./gh-debug.sh failed

# Get logs from failed steps only
./gh-debug.sh failed-logs

# Trigger a new workflow
./gh-debug.sh trigger

# Show all jobs in a run
./gh-debug.sh jobs
```

### Runtime Options

| Runtime | Use Case | Command |
|---------|----------|---------|
| Docker | Default, CI standard | `docker run ...` |
| Podman | Rootless, daemonless | `CONTAINER_RUNTIME=podman` |
| Nerdctl | Containerd compatible | `CONTAINER_RUNTIME=nerdctl` |

## Image Hierarchy

```
Base CLI (php{VER}/)          → alpine:edge, built-in PHP server on :80
├── FPM (php{VER}-fpm/)       → FROM skilldlabs/php:{VER}, php-fpm on :9000
├── Unit (php{VER}-unit/)     → FROM skilldlabs/php:{VER}, unitd on :80
└── Unit Builder (unit-php-builder/) → compiles Nginx Unit from source
    └── Dev (unit-php-builder/dev/)  → adds nodejs, yarn, bash

Moodle variants (standalone, not based on skilldlabs/php):
├── php{VER}-moodle/          → FPM + PostgreSQL + moosh
└── php{VER}-moodle-unit/     → Unit + PostgreSQL + moosh + s6-overlay + cron

FrankenPHP (php83-frankenphp/, php84-frankenphp/, php85-frankenphp/)
    → Ubuntu noble, multi-stage build, Caddy webserver
```

Base images include: Composer 2, Drush 8, git, curl, make, mariadb-client, openssh-client, patch, rsync, sqlite, and standard PHP extensions (apcu, igbinary, xdebug, brotli, uploadprogress, gd, opcache, etc.).

## Directory Structure

```
docker-php/
├── php{VER}/                    # Base image
├── php{VER}-fpm/                # FPM variant
├── php{VER}-unit/               # Unit variant
├── php{VER}-moodle/             # Moodle + FPM
├── php{VER}-moodle-unit/        # Moodle + Unit
├── php{VER}-frankenphp/         # FrankenPHP variant
├── unit-php-builder/dev/        # Unit dev images
├── tests/                       # Test scripts
│   ├── test-lib.sh             # Shared test library
│   ├── test-base.sh            # Base image tests
│   ├── test-fpm.sh             # FPM image tests
│   ├── test-unit.sh            # Unit image tests
│   ├── install-rootless.sh     # Rootless container setup
│   ├── README.md               # Test documentation
│   ├── ROOTLESS.md             # Rootless Docker guide
│   └── QUICKREF.md             # Quick reference
├── .github/workflows/           # CI workflows
│   ├── build-php.yml          # Reusable PHP build workflow
│   ├── build-{VER}.yml         # Version-specific workflows
│   └── build-frankenphp.yml   # FrankenPHP workflows
├── gh-debug.sh                  # GitHub Actions debug helper
└── Makefile                     # Build automation
```

## Directory Naming Convention

`php{VERSION}[-VARIANT]/` where VERSION is two digits (82, 83, 84, 85) and VARIANT is one of: `fpm`, `unit`, `moodle`, `moodle-unit`, `frankenphp`.

## Key Files Per Variant

| Variant | Key files |
|---------|-----------|
| Base | `Dockerfile`, `php.ini`, `drush.phar` |
| FPM | `Dockerfile`, `php-fpm.conf` |
| Unit | `Dockerfile`, `conf.json` |
| Moodle | `Dockerfile`, `php.ini`, `xx-moodle.ini`, optional `cron.sh`, s6 service dirs |
| FrankenPHP | `Dockerfile`, `conf/Caddyfile`, `conf/php.ini`, `docker-php-ext-enable` |

## Adding a New PHP Version

1. Copy the most recent base directory (e.g. `cp -r php85 php86`)
2. Replace all version-specific references in Dockerfile (`php85` → `php86`)
3. Create corresponding `-fpm` and `-unit` directories following the same pattern
4. Add the new tags to `TAGS` in the root `Makefile`
5. For Unit images, update `unit-php-builder/dev/Makefile` TAGS
6. Create a new workflow file `.github/workflows/build-php86.yml` (or update existing reusable workflow)

## Patterns to Preserve

- PHP 8.3+ Dockerfiles include `apk add '!usr-merge-nag'` to suppress Alpine warnings
- XDebug is installed but disabled by default; enable via `-d zend_extension=xdebug.so`
- Composer is installed from source with SHA384 hash verification (hash in root Makefile)
- Drush is copied as a pre-downloaded `drush.phar` binary (PHP 8.2+)
- FPM/Unit variants create `web-user:web-group` (UID/GID 1000)
- Config files are named `xx-drupal.ini` (base) or `xx-moodle.ini` (moodle) in `/etc/php{VER}/conf.d/`
- Test scripts use runtime detection (docker/podman/nerdctl) via `CONTAINER_RUNTIME` env var

## CI/CD Workflow

### Build Process (optimized)

1. **Build Test Image** (amd64 only, with cache)
   - Uses GitHub Actions cache for Docker layers
   - Loads image for testing with `--load`

2. **Run Tests**
   - Executes appropriate test script (`test-base.sh`, `test-fpm.sh`, `test-unit.sh`)
   - Tests use single container with multiple `exec` calls (optimized)

3. **Push All Platforms** (if tests pass)
   - Builds for all platforms using cache
   - Pushes to Docker Hub with version tags

### Cache Strategy

- Uses `type=local` cache with GitHub Actions cache
- Writes to temporary directory then moves (prevents corruption)
- Shared across rebuilds for faster builds

### Triggering Workflows

```bash
# Using gh CLI
gh workflow run "Build PHP 8.5"

# Using debug script
./gh-debug.sh trigger

# With version tag
gh workflow run "Build PHP 8.5" -f version=8.5.3
```

## Test Coverage

### Base Image Tests (15 tests)
- PHP version match
- Composer installed and working
- Drush installed and working
- PHP extensions: opcache, apcu, gd, igbinary, xdebug
- Required binaries: git, curl, patch, rsync, mysql
- Built-in PHP server functionality

### FPM Image Tests (9 tests)
- PHP-FPM version and process running
- PHP CLI availability
- Log directory ownership
- Work directory exists
- web-user/web-group (UID/GID 1000)
- Configuration file present
- Port 9000 listening

### Unit Image Tests (11 tests)
- Unit version and processes (main, controller, router)
- PHP CLI availability
- Unit PHP module loaded
- Configuration file exists
- Work directory exists
- web-user/web-group (UID/GID 1000)
- Process ownership (running as web-user)

## Optimization Notes

### Container Starts
- **Old pattern**: One container per test (~15 starts for base image)
- **New pattern**: One long-running container, all tests via `exec` (1 start)
- **Improvement**: 93% reduction in container starts

### Parallel Execution
- FPM and Unit jobs run in parallel (both depend on base)
- Unit-dev runs after Unit completes
- Tests run immediately after each build completes

### Build Cache
- Uses GitHub Actions cache for Docker layers
- Cache persists between runs for faster rebuilds
- Shared across similar builds (same PHP version)

## Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/build-php.yml` | Reusable workflow for all PHP versions |
| `.github/workflows/build-{VER}.yml` | Version-specific caller workflows |
| `.github/workflows/build-frankenphp.yml` | FrankenPHP builds |
| `gh-debug.sh` | Debug helper for GitHub Actions |
