#!/bin/bash
# Setup script for rootless container testing
# Supports both Docker Rootless and Podman

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Rootless Container Setup"
echo "=========================================="

# Check current user
if [ "$(id -u)" -eq 0 ]; then
  echo "${RED}ERROR: Don't run this script as root${NC}"
  echo "Run as your regular user"
  exit 1
fi

USER=$(whoami)
echo "Running as: ${USER}"

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=${ID}
  echo "OS: ${PRETTY_NAME}"
fi

# Check prerequisites
echo ""
echo "Checking prerequisites..."

MISSING=0

# Check subuid/subgid
if ! grep -q "^${USER}:" /etc/subuid 2>/dev/null; then
  echo "${YELLOW}⚠ No subuid entry for ${USER}${NC}"
  echo "  Run: sudo usermod --add-subuids ${USER}=100000-65536 ${USER}"
  MISSING=1
else
  echo "✓ subuid configured"
fi

if ! grep -q "^${USER}:" /etc/subgid 2>/dev/null; then
  echo "${YELLOW}⚠ No subgid entry for ${USER}${NC}"
  echo "  Run: sudo usermod --add-subgids ${USER}=100000-65536 ${USER}"
  MISSING=1
else
  echo "✓ subgid configured"
fi

# Check for newuidmap/newgidmap
if ! command -v newuidmap >/dev/null 2>&1; then
  echo "${YELLOW}⚠ uidmap package not found${NC}"
  MISSING=1
else
  echo "✓ uidmap available"
fi

# Check for slirp4netns
if ! command -v slirp4netns >/dev/null 2>&1; then
  echo "${YELLOW}⚠ slirp4netns not found${NC}"
  MISSING=1
else
  echo "✓ slirp4netns available"
fi

if [ $MISSING -eq 1 ]; then
  echo ""
  echo "${YELLOW}Some prerequisites are missing.${NC}"
  echo "Install them with:"
  case "$OS" in
    ubuntu|debian)
      echo "  sudo apt-get install -y uidmap slirp4netns fuse-overlayfs"
      ;;
    fedora|rhel|centos)
      echo "  sudo dnf install -y shadow-utils slirp4netns fuse-overlayfs"
      ;;
    arch|manjaro)
      echo "  sudo pacman -S uidmap slirp4netns fuse-overlayfs"
      ;;
    *)
      echo "  # Install uidmap, slirp4netns, fuse-overlayfs for your distro"
      ;;
  esac
  echo ""
  read -p "Install missing packages now? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    case "$OS" in
      ubuntu|debian)
        sudo apt-get update
        sudo apt-get install -y uidmap slirp4netns fuse-overlayfs
        ;;
      fedora|rhel|centos)
        sudo dnf install -y shadow-utils slirp4netns fuse-overlayfs
        ;;
      arch|manjaro)
        sudo pacman -S --needed uidmap slirp4netns fuse-overlayfs
        ;;
      *)
        echo "Please install manually and re-run this script"
        exit 1
        ;;
    esac
  else
    echo "Please install missing packages and re-run"
    exit 1
  fi
fi

echo ""
echo "=========================================="
echo "Choose your rootless container engine:"
echo "=========================================="
echo "1) Podman (recommended - daemonless, rootless by default)"
echo "2) Docker Rootless (compatible with Docker commands)"
echo "3) Both (side-by-side installation)"
echo ""
read -p "Choice [1/2/3]: " -n 1 -r CHOICE
echo

case "$CHOICE" in
  1)
    INSTALL_PODMAN=1
    INSTALL_DOCKERLESS=0
    ;;
  2)
    INSTALL_PODMAN=0
    INSTALL_DOCKERLESS=1
    ;;
  3)
    INSTALL_PODMAN=1
    INSTALL_DOCKERLESS=1
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Install Podman
if [ $INSTALL_PODMAN -eq 1 ]; then
  echo ""
  echo "=========================================="
  echo "Installing Podman"
  echo "=========================================="

  if command -v podman >/dev/null 2>&1; then
    echo "Podman already installed: $(podman --version)"
  else
    case "$OS" in
      ubuntu|debian)
        echo "Installing Podman for Ubuntu/Debian..."
        # Add Podman PPA
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key \
          | sudo gpg --dearmor -o /etc/apt/keyrings/libcontainers-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" \
          | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list
        sudo apt-get update
        sudo apt-get install -y podman
        ;;
      fedora|rhel|centos)
        sudo dnf install -y podman
        ;;
      arch|manjaro)
        sudo pacman -S podman
        ;;
    esac

    if command -v podman >/dev/null 2>&1; then
      echo "${GREEN}✓ Podman installed: $(podman --version)${NC}"
    else
      echo "${RED}✗ Podman installation failed${NC}"
    fi
  fi

  # Configure Podman registries
  mkdir -p ~/.config/containers
  echo "Podman configured. Test with: podman info"
fi

# Install Docker Rootless
if [ $INSTALL_DOCKERLESS -eq 1 ]; then
  echo ""
  echo "=========================================="
  echo "Installing Docker Rootless"
  echo "=========================================="

  if systemctl --user is-active docker.service >/dev/null 2>&1; then
    echo "Docker Rootless already running"
    docker-rootless info 2>/dev/null && echo "✓ Working" || echo "⚠ May need configuration"
  else
    echo "Downloading Docker Rootless install script..."
    curl -fsSL https://get.docker.com/rootless -o /tmp/docker-rootless-install.sh
    sh /tmp/docker-rootless-install.sh

    # Create systemd service files
    mkdir -p ~/.config/systemd/user

    cat > ~/.config/systemd/user/docker.service <<'EOF'
[Unit]
Description=Docker Application Container Engine (Rootless)
Documentation=https://docs.docker.com/go/rootless/
After=network-online.target docker.socket.socket
Wants=network-online.target
Requires=docker.socket.socket

[Service]
Environment=PATH=/usr/bin:/bin:/usr/local/bin:$HOME/bin
ExecStart=$HOME/bin/dockerd-rootless.sh
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

    # Enable and start
    systemctl --user daemon-reload
    systemctl --user start docker.service
    systemctl --user enable docker.service

    echo ""
    echo "Waiting for Docker Rootless to start..."
    sleep 3

    if systemctl --user is-active docker.service >/dev/null 2>&1; then
      echo "${GREEN}✓ Docker Rootless installed and running${NC}"
    else
      echo "${YELLOW}⚠ Docker Rootless service not active. Check: journalctl --user -u docker.service${NC}"
    fi
  fi
fi

# Setup shell configuration
echo ""
echo "=========================================="
echo "Setting up shell configuration"
echo "=========================================="

# Detect shell
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
  echo "Adding aliases to $SHELL_CONFIG"

  # Remove old aliases if they exist
  sed -i '/# Rootless container aliases/,/^$/d' "$SHELL_CONFIG" 2>/dev/null || true

  cat >> "$SHELL_CONFIG" <<'EOF'

# Rootless container aliases
alias podman-podman='CONTAINER_RUNTIME=podman'
alias podman-test='CONTAINER_RUNTIME=podman ./tests/run-test.sh'

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
EOF

  echo "Added aliases to $SHELL_CONFIG"
  echo "Source it with: source $SHELL_CONFIG"
fi

# Create wrapper scripts
mkdir -p ~/.local/bin
cat > ~/.local/bin/docker-rootless <<'EOF'
#!/bin/bash
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
exec docker "$@"
EOF
chmod +x ~/.local/bin/docker-rootless

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="

# Show status
echo ""
echo "Status:"
echo ""

if [ $INSTALL_PODMAN -eq 1 ] && command -v podman >/dev/null 2>&1; then
  echo "📦 Podman: $(podman --version)"
  echo "   Test: CONTAINER_RUNTIME=podman ./tests/run-test.sh skilldlabs/php:85 8.5 base"
fi

if [ $INSTALL_DOCKERLESS -eq 1 ]; then
  if systemctl --user is-active docker.service >/dev/null 2>&1; then
    echo "🐳 Docker Rootless: Running"
    echo "   Test: DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock ./tests/run-test.sh skilldlabs/php:85 8.5 base"
    echo "   Or: rootless-on && ./tests/run-test.sh skilldlabs/php:85 8.5 base"
  else
    echo "🐳 Docker Rootless: Not running (check: journalctl --user -u docker.service)"
  fi
fi

echo ""
echo "For more info, see: tests/ROOTLESS.md"
