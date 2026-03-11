# Container Runtime Quick Reference

Quick commands for testing with different container runtimes.

## Your Current System

- **Docker (rootful)**: Running as root daemon
- **Docker Rootless**: Not installed
- **Podman**: Not installed
- **subuid/subgid**: ✓ Configured for user `andy`
- **slirp4netns**: ✓ Available

## Quick Test Commands

### Using Rootful Docker (current default)

```bash
# All variants
make test-local TAGS="85 85-fpm 85-unit"

# Individual
./tests/test-base.sh skilldlabs/php:85 8.5
./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5
./tests/test-unit.sh skilldlabs/php:85-unit 8.5
```

### Using Rootless Docker (after setup)

```bash
# One-time setup
./tests/install-rootless.sh
# Choose option 2 (Docker Rootless)

# Then test
DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock ./tests/test-base.sh skilldlabs/php:85 8.5

# Or use the alias (after sourcing .bashrc)
rootless-on
./tests/test-base.sh skilldlabs/php:85 8.5
```

### Using Podman (recommended - easiest)

```bash
# One-time setup
./tests/install-rootless.sh
# Choose option 1 (Podman)

# Then test
CONTAINER_RUNTIME=podman ./tests/test-base.sh skilldlabs/php:85 8.5
CONTAINER_RUNTIME=podman ./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5
CONTAINER_RUNTIME=podman ./tests/test-unit.sh skilldlabs/php:85-unit 8.5
```

## Setup Rootless Containers

```bash
# Interactive setup (installs Podman or Docker Rootless)
./tests/install-rootless.sh

# Manual Podman install
sudo apt-get install -y podman
CONTAINER_RUNTIME=podman ./tests/test-base.sh skilldlabs/php:85 8.5

# Manual Docker Rootless install
sudo apt-get install -y uidmap slirp4netns fuse-overlayfs
curl -fsSL https://get.docker.com/rootless | sh
systemctl --user start docker
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

## Comparison

| Feature | Rootful Docker | Rootless Docker | Podman |
|---------|---------------|-----------------|--------|
| Daemon | root (systemd) | user (systemd --user) | none |
| Socket | /var/run/docker.sock | /run/user/UID/docker.sock | none |
| Port binding | any port | ports > 1024 | ports > 1024 |
| Setup complexity | easy | medium | easy |
| Images | /var/lib/docker | ~/.local/share/docker | ~/.local/share/containers |
| Test compatibility | 100% | 95% | 95% |

## Test Compatibility

| Test | Rootful | Rootless | Podman |
|------|---------|----------|--------|
| test-base.sh | ✓ | ✓ | ✓ |
| test-fpm.sh | ✓ | ✓ | ✓ |
| test-unit.sh | ✓ | ⚠ port 80 | ⚠ port 80 |

⚠ = Unit tests use port 80 which requires root or workaround

## Unit Test Port Workaround

For rootless testing of unit images:

```bash
# Use a higher port
CONTAINER_RUNTIME=podman ./tests/test-unit.sh skilldlabs/php:85-unit 8.5

# Or modify test to use port 8080
# Edit tests/test-unit.sh: change `-p 8080:80` is already there
```

## Verify Runtime

```bash
# Check which runtime is active
echo "Runtime: ${RUNTIME:-docker}"
echo "DOCKER_HOST: ${DOCKER_HOST:-not set}"

# Test connection
docker info        # rootful or rootless (via DOCKER_HOST)
podman info        # podman
nerdctl info       # nerdctl
```

## Useful Aliases (add to ~/.bashrc)

```bash
# Runtime selection
alias use-docker='export CONTAINER_RUNTIME=docker; unset DOCKER_HOST'
alias use-podman='export CONTAINER_RUNTIME=podman'
alias use-rootless='export CONTAINER_RUNTIME=docker; export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock'

# Quick test
alias test-base='./tests/test-base.sh skilldlabs/php:85 8.5'
alias test-fpm='./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5'
alias test-unit='./tests/test-unit.sh skilldlabs/php:85-unit 8.5'

# Combined
alias test-all='make test-local TAGS="85 85-fpm 85-unit"'
```

## CI Usage

In CI, you typically have Docker pre-installed. The test scripts work out of the box:

```yaml
# GitHub Actions
- name: Run tests
  run: make test-local TAGS="85 85-fpm 85-unit"

# With Podman in CI
- name: Install Podman
  run: sudo apt-get install -y podman
- name: Run tests
  run: CONTAINER_RUNTIME=podman make test-local TAGS="85 85-fpm 85-unit"
```

## Troubleshooting

### "Cannot connect to Docker daemon"
```bash
# Check daemon is running
systemctl --user status docker.service  # rootless
sudo systemctl status docker            # rootful

# Check socket
ls -la /var/run/docker.sock              # rootful
ls -la $XDG_RUNTIME_DIR/docker.sock      # rootless
```

### "Permission denied"
```bash
# Add user to docker group (rootful only)
sudo usermod -aG docker $USER
newgrp docker
```

### "Port already in use"
```bash
# Find what's using the port
sudo lsof -i :8080

# Kill the container
docker rm -f test-unit-85
podman rm -f test-unit-85
```

## File Summary

| File | Purpose |
|------|---------|
| `tests/test-lib.sh` | Shared test library with runtime detection |
| `tests/test-base.sh` | Base image tests |
| `tests/test-fpm.sh` | FPM image tests |
| `tests/test-unit.sh` | Unit image tests |
| `tests/install-rootless.sh` | Interactive setup script |
| `tests/ROOTLESS.md` | Detailed rootless guide |
| `tests/QUICKREF.md` | This file |
| `tests/ANALYSIS.md` | Optimization analysis |
| `tests/README.md` | Test documentation |
