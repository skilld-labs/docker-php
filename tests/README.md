# Container Image Tests

Test scripts for validating Docker images across multiple container runtimes.

## Supported Runtimes

| Runtime | Detection | Status |
|---------|-----------|--------|
| Docker | `docker` command | ✓ Full support |
| Podman | `podman` command | ✓ Full support |
| Nerdctl | `nerdctl` command | ✓ Full support |

## Runtime Detection

Tests automatically detect available runtimes in this order:
1. `CONTAINER_RUNTIME` environment variable (if set)
2. `podman`
3. `nerdctl`
4. `docker` (default)

### Override Runtime

```bash
# Use podman explicitly
CONTAINER_RUNTIME=podman tests/test-base.sh skilldlabs/php:85 8.5

# Use nerdctl explicitly
CONTAINER_RUNTIME=nerdctl tests/test-base.sh skilldlabs/php:85 8.5
```

## Test Scripts

| Script | Purpose | Container Starts |
|--------|---------|------------------|
| `test-base.sh` | Tests base PHP images (cli, composer, drush, extensions) | 1 (optimized) |
| `test-fpm.sh` | Tests PHP-FPM images (daemon, config, permissions) | 1 |
| `test-unit.sh` | Tests Unit images (unitd, config, web-user) | 1 |

## Usage

### Test a Single Image

```bash
# Base image
./tests/test-base.sh skilldlabs/php:85 8.5

# FPM image
./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5

# Unit image
./tests/test-unit.sh skilldlabs/php:85-unit 8.5
```

### Test with Makefile

```bash
# Build and test all PHP 8.5 images locally
make test-local TAGS="85 85-fpm 85-unit"

# Build and test PHP 8.4
make test-local TAGS="84 84-fpm 84-unit"
```

## What Gets Tested

### Base Images (`test-base.sh`)
- PHP version match
- Composer installed and working
- Drush installed and working
- PHP extensions: opcache, apcu, gd, igbinary, xdebug
- Required binaries: git, curl, patch, rsync, mysql
- Work directories
- Built-in PHP server

### FPM Images (`test-fpm.sh`)
- PHP-FPM version and process
- PHP CLI availability
- Log directory ownership
- Work directory
- web-user/web-group (UID/GID 1000)
- Configuration file

### Unit Images (`test-unit.sh`)
- Unit version and processes (main, controller, router)
- PHP CLI availability
- PHP module loaded
- Configuration file
- Work directory
- web-user/web-group (UID/GID 1000)
- Process ownership

## CI Integration

The tests run automatically in CI before pushing images:

1. Build image for `linux/amd64` with `--load` (for local testing)
2. Run appropriate test script
3. If tests pass, push to all configured platforms

See `.github/workflows/build-php.yml`.

## Optimization

Tests use a "start once, test many" pattern:
- One long-running container per image type
- All checks done via `exec` (no restart overhead)
- ~93% reduction in container starts for base images
- Compatible across runtimes (docker, podman, nerdctl)

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed
