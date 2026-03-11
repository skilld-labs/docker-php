# PHP Release Runbook

This file is the straight guide for the next PHP patch release cycle in this repo.

It covers:
- how to decide which version tag is valid
- how to test locally against Alpine packages
- how to trigger GitHub Actions
- how to verify Docker Hub publication
- what failed on March 11, 2026 and what must not regress

## Short Rule

For versioned Docker tags, use this rule:

1. The release number must exist as a stable `php/php-src` tag.
2. The installed Alpine `phpXX` package inside the image must report the same version.
3. Local tests must pass.
4. GitHub Actions `workflow_dispatch` release run must pass.
5. Docker Hub must show the exact published tags.

If any of those do not match, do not publish a versioned tag.

## Important Facts

- PHP release workflows in this repo are manual by design. They use `workflow_dispatch`.
- The host-side test entrypoint is `tests/run-test.sh`.
- The inner scripts `tests/test-base.sh`, `tests/test-fpm.sh`, and `tests/test-unit.sh` run inside a started container and must not be called directly from the host.
- `make tag` is not the release path for normal PHP patch releases. Use GitHub Actions after tests pass.

## Monthly Release Checklist

Use `84` or `85` below depending on the PHP series you are releasing.

### 1. Sync the Repo

```bash
git pull --ff-only
git status --short
```

Ignore only known local-only files such as `.claude/settings.local.json`.

### 2. Resolve the Real Release Version

Use the helper:

```bash
./release-php.sh latest 85
./release-php.sh check 85
```

What this does:
- reads the latest stable version from `https://github.com/php/php-src/tags`
- reads the installed `PHP_VERSION` from the local image
- reads the installed Alpine package version from `/lib/apk/db/installed`
- fails if the versions do not match exactly

Expected example output:

```text
Series: 8.5
Image: skilldlabs/php:85
php-src tag: 8.5.4
Installed PHP: 8.5.4
Installed apk: 8.5.4-r0
8.5.4
```

### 3. If the Local Image Is Stale, Rebuild and Test Locally

```bash
make test-local TAGS="85 85-fpm 85-unit"
```

Direct host-side smoke tests:

```bash
./tests/run-test.sh skilldlabs/php:85 8.5 base
./tests/run-test.sh skilldlabs/php:85-fpm 8.5 fpm
./tests/run-test.sh skilldlabs/php:85-unit 8.5 unit
```

If local tests fail, stop and fix the repo before dispatching GitHub Actions.

### 4. Publish Through GitHub Actions

Use the helper:

```bash
./release-php.sh publish 85
```

This dispatches the manual workflow:

```bash
gh workflow run "Build PHP 8.5" -f version=8.5.4
```

Do the same for `84` when needed:

```bash
./release-php.sh publish 84
```

### 5. Watch the Run

```bash
./gh-debug.sh list
GH_TOKEN= gh run watch <RUN_ID> -R skilld-labs/docker-php --interval 10
```

Success means all of these jobs pass:
- `build-base`
- `build-fpm`
- `build-unit`
- `build-unit-dev`

### 6. Verify Docker Hub

Check exact version tags:

```bash
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/8.5.4'
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/8.4.19'
```

Check versioned variant tags:

```bash
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/85-fpm-8.5.4'
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/85-unit-8.5.4'
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/84-fpm-8.4.19'
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/84-unit-8.4.19'
```

Check floating tags:

```bash
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/85'
curl -L -s 'https://hub.docker.com/v2/repositories/skilldlabs/php/tags/84'
```

What to confirm:
- tag exists
- `tag_status` is `active`
- `last_updated` is current
- `amd64` and `arm64` images are both present

## If Versions Do Not Match

Examples:
- `php-src` latest stable is `8.5.5` but local image still reports `8.5.4`
- Alpine package reports `8.5.5-r0` but `php-src` stable is still `8.5.4`

Then:

1. Do not publish a versioned tag.
2. Rebuild locally and check again if Alpine has updated.
3. If Alpine is ahead of upstream stable, wait for stable upstream confirmation before versioned release tagging.
4. If Alpine is behind upstream stable, wait for Alpine package availability or update the packaging source first.

Floating tags without a version input are a separate decision. Do not use them as a shortcut for versioned patch releases.

## Known Good Release on March 11, 2026

Validated and published on March 11, 2026:

- `8.5.4`
- `85-fpm-8.5.4`
- `85-unit-8.5.4`
- `8.4.19`
- `84-fpm-8.4.19`
- `84-unit-8.4.19`

Successful GitHub Actions runs:

- `Build PHP 8.5` run `22957765320`
- `Build PHP 8.4` run `22957781084`

Commit containing the CI fix and release helper:

- `7531dc0`

## Postmortem: March 11, 2026 CI Failure

### Symptom

Local testing looked good, but GitHub Actions failed almost immediately in:

- `Build PHP 8.5`
- failed run `22954509499`
- failed step `Test base image`

### Root Cause

The workflow and `make test-local` were calling:

- `tests/test-base.sh`
- `tests/test-fpm.sh`
- `tests/test-unit.sh`

directly from the host.

Those scripts had been refactored to run inside a container that was already started. The correct host-side entrypoint was `tests/run-test.sh`.

So CI built the image successfully, then ran host-side commands like `php`, `composer`, and `drush` on the GitHub runner instead of inside the built container.

### Fix

The fix was:

1. route GitHub Actions through `tests/run-test.sh`
2. route `make test-local` through `tests/run-test.sh`
3. update docs so they no longer teach the wrong entrypoint
4. add `release-php.sh` so version selection is explicit and reproducible

### Guard Rails

Before dispatching a release:

1. run `./release-php.sh check <series>`
2. if needed, run `make test-local TAGS="..."` and `./tests/run-test.sh ...`
3. trigger release with `./release-php.sh publish <series>`
4. verify Docker Hub explicitly

### Still Open

GitHub Actions prints Node.js 20 deprecation warnings for several actions.

This did not block the March 11, 2026 releases, but the action versions should be reviewed before GitHub forces Node.js 24 by default on June 2, 2026.
