# Rootless Docker for Local Testing

Guide for running container tests with rootless Docker (more secure, no root required).

## Current State

Your system currently uses **rootful Docker**:
- `dockerd` runs as root (PID 3799010)
- Socket: `/var/run/docker.sock`
- User has access via docker group

## Rootless vs Rootful Docker

| Aspect | Rootful Docker | Rootless Docker |
|--------|---------------|-----------------|
| Daemon runs as | root | your user |
| Socket location | `/var/run/docker.sock` | `$XDG_RUNTIME_DIR/docker.sock` |
| Security | daemon has full root access | daemon runs in user namespace |
| Port binding | can bind any port | can only bind >1024 |
| Images | `/var/lib/docker` | `~/.local/share/docker` |
| Setup needs | systemd + docker group | user namespaces + newuidmap |

## Setting Up Rootless Docker

### Quick Install (Ubuntu/Debian)

```bash
# 1. Install dependencies
sudo apt-get update
sudo apt-get install -y uidmap slirp4netns fuse-overlayfs

# 2. Install rootless docker script
curl -fsSL https://get.docker.com/rootless | sh

# 3. Add to PATH and enable systemd service
export PATH=$HOME/bin:$PATH
systemctl --user start docker
systemctl --user enable docker

# 4. Add DOCKER_HOST to your shell profile
echo 'export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock' >> ~/.bashrc
source ~/.bashrc

# 5. Verify
docker info
```

### Manual Setup (from source)

```bash
# 1. Install dockerd binaries (if not already installed)
# dockerd and docker should be in /usr/bin or similar

# 2. Install rootless dependencies
sudo apt-get install -y uidmap slirp4netns fuse-overlayfs

# 3. Create systemd user service
mkdir -p ~/.config/systemd/user/

cat > ~/.config/systemd/user/docker.service <<'EOF'
[Unit]
Description=Docker Application Container Engine (Rootless)
Documentation=https://docs.docker.com/go/rootless/
After=network-online.target docker.socket.socket
Wants=network-online.target
Requires=docker.socket.socket

[Service]
Environment=PATH=/usr/bin:/bin
ExecStart=/usr/bin/dockerd-rootless.sh
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
Type=notify
NotifyAccess=all

[Install]
WantedBy=default.target
EOF

cat > ~/.config/systemd/user/docker.socket <<'EOF'
[Unit]
Description=Docker Socket for the Rootless Docker
Documentation=https://docs.docker.com/go/rootless/

[Socket]
ListenStream=%t/docker.sock
SocketMode=0660

[Install]
WantedBy=default.target
EOF

# 4. Enable and start
systemctl --user daemon-reload
systemctl --user start docker.service
systemctl --user enable docker.service

# 5. Set DOCKER_HOST
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

### Check User Namespace Support

```bash
# Verify your kernel supports user namespaces
grep "user_namespace" /proc/modules

# Check current limits
cat /etc/subuid
cat /etc/subgid

# You should see entries like:
# andypost:100000:65536
```

If `/etc/subuid` and `/etc/subgid` are empty, add them:
```bash
echo "$(whoami):100000:65536" | sudo tee -a /etc/subuid /etc/subgid
```

## Using Rootless Docker

### Switch Between Rootful and Rootless

```bash
# Use rootless Docker (your user)
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
docker ps

# Use rootful Docker (system)
unset DOCKER_HOST
# or
export DOCKER_HOST=unix:///var/run/docker.sock
docker ps
```

### Run Tests with Rootless Docker

```bash
# Set environment for rootless
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Run tests
./tests/test-base.sh skilldlabs/php:85 8.5
./tests/test-fpm.sh skilldlabs/php:85-fpm 8.5
./tests/test-unit.sh skilldlabs/php:85-unit 8.5

# Or use the runtime override
CONTAINER_RUNTIME=docker DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock \
  ./tests/test-base.sh skilldlabs/php:85 8.5
```

### Create Aliases for Easy Switching

Add to `~/.bashrc`:

```bash
# Rootless Docker alias
alias docker-rootless='DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock docker'
alias docker-rootful='DOCKER_HOST=unix:///var/run/docker.sock docker'

# Functions to switch context
rootless-on() {
  export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
  export CONTAINER_RUNTIME=docker
  echo "Rootless Docker enabled (socket: $DOCKER_HOST)"
}

rootless-off() {
  unset DOCKER_HOST
  export CONTAINER_RUNTIME=docker
  echo "Rootful Docker enabled (socket: /var/run/docker.sock)"
}
```

Usage:
```bash
rootless-on
./tests/test-base.sh skilldlabs/php:85 8.5

rootless-off
./tests/test-base.sh skilldlabs/php:85 8.5
```

## Podman Alternative (Often Easier)

Podman is daemonless and rootless by default - often simpler than rootless Docker:

```bash
# Install podman
sudo apt-get install -y podman

# No daemon needed, just use it
podman info

# Run tests with podman
CONTAINER_RUNTIME=podman ./tests/test-base.sh skilldlabs/php:85 8.5
```

## Troubleshooting

### "Cannot connect to Docker daemon"

```bash
# Check if rootless daemon is running
systemctl --user status docker.service

# Check socket location
ls -la $XDG_RUNTIME_DIR/docker.sock

# Set DOCKER_HOST correctly
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
```

### "Port already in use" (binding to ports < 1024)

Rootless containers cannot bind to privileged ports. Either:
1. Use ports > 1024
2. Use `sysctl net.ipv4.ip_unprivileged_port_start=0` (not recommended)
3. Use rootful Docker for port testing

### Buildx with Rootless Docker

```bash
# Create rootless buildx builder
docker buildx create --use --name rootless-builder --driver-opt network=host

# Build images
docker buildx build --platform linux/amd64 --load -t test .
```

## CI Considerations

Rootless Docker in CI (GitHub Actions, GitLab CI):

```yaml
# GitHub Actions with rootless
- name: Setup rootless Docker
  run: |
    curl -fsSL https://get.docker.com/rootless | sh
    echo "DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> $GITHUB_ENV

- name: Run tests
  run: make test-local TAGS="85 85-fpm 85-unit"
```

## Comparison for This Project

| Test | Rootful | Rootless | Podman |
|------|---------|----------|--------|
| test-base.sh | ✓ | ✓ | ✓ |
| test-fpm.sh | ✓ | ✓ | ✓ |
| test-unit.sh (port 80) | ✓ | needs >1024 | needs >1024 |

**Recommendation**: Use rootless Docker for base/fpm tests, use Podman or rootful Docker for unit tests (port 80).
