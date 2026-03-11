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

# Setup QEMU + buildx for multi-platform builds
make prepare

# Tag a release version
make tag VER=1.2.3 TAGS="84 84-fpm"
```

Build args `COMPOSER_HASH` and `DRUSH_VERSION` are defined in the root Makefile and passed to base image builds.

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

FrankenPHP (php83-frankenphp/) → Ubuntu noble, multi-stage build, Caddy webserver
```

Base images include: Composer 2, Drush 8, git, curl, make, mariadb-client, openssh-client, patch, rsync, sqlite, and standard PHP extensions (apcu, igbinary, xdebug, brotli, uploadprogress, gd, opcache, etc.).

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

## Patterns to Preserve

- PHP 8.3+ Dockerfiles include `apk add '!usr-merge-nag'` to suppress Alpine warnings
- XDebug is installed but disabled by default; enable via `-d zend_extension=xdebug.so`
- Composer is installed from source with SHA384 hash verification (hash in root Makefile)
- Drush is copied as a pre-downloaded `drush.phar` binary (PHP 8.2+)
- FPM/Unit variants create `web-user:web-group` (UID/GID 1000)
- Config files are named `xx-drupal.ini` (base) or `xx-moodle.ini` (moodle) in `/etc/php{VER}/conf.d/`
