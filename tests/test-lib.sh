#!/bin/bash
# Shared test library for container image testing
# Runtime-agnostic: supports docker, podman, nerdctl

# Color codes
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export NC='\033[0m' # No Color

# Test counter variables (exported for scripts to use)
export TESTS_RUN=0
export TESTS_PASSED=0
export TESTS_FAILED=0

# Detect container runtime
# Priority: CONTAINER_RUNTIME env > podman > nerdctl > docker
detect_runtime() {
  if [ -n "${CONTAINER_RUNTIME}" ]; then
    echo "${CONTAINER_RUNTIME}"
  elif command -v podman >/dev/null 2>&1; then
    echo "podman"
  elif command -v nerdctl >/dev/null 2>&1; then
    echo "nerdctl"
  elif command -v docker >/dev/null 2>&1; then
    echo "docker"
  else
    echo "docker"  # default fallback
  fi
}

export RUNTIME="${RUNTIME:-$(detect_runtime)}"

# Check if image exists locally, pull if needed
ensure_image() {
  local image="$1"

  if ! ${RUNTIME} image inspect "${image}" >/dev/null 2>&1; then
    echo "Image ${image} not found locally. Pulling..."
    ${RUNTIME} pull "${image}" || {
      echo "Failed to pull image ${image}"
      return 1
    }
  fi
}

# Start a long-running container for testing
# Usage: start_container <name> <image> [extra_args]
start_container() {
  local name="$1"
  local image="$2"
  shift 2
  local extra_args="$@"

  # Cleanup any existing container with same name
  ${RUNTIME} rm -f "${name}" >/dev/null 2>&1 || true

  # Start container with sleep infinity to keep it running
  ${RUNTIME} run -d --name "${name}" ${extra_args} "${image}" sleep infinity
}

# Execute command in container
# Usage: exec_container <name> <command...>
exec_container() {
  local name="$1"
  shift

  ${RUNTIME} exec "${name}" "$@"
}

# Remove container
# Usage: remove_container <name>
remove_container() {
  local name="$1"

  ${RUNTIME} rm -f "${name}" >/dev/null 2>&1 || true
}

# Run a test and track results
# Usage: run_test <test_name> <test_command>
# The command is executed with exec_container if CONTAINER_NAME is set
run_test() {
  local test_name="$1"
  local test_cmd="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  echo ""
  echo "Test ${TESTS_RUN}: ${test_name}"

  # If CONTAINER_NAME is set, run command in that container
  if [ -n "${CONTAINER_NAME}" ]; then
    if exec_container "${CONTAINER_NAME}" sh -c "${test_cmd}"; then
      echo "${GREEN}✓ PASSED${NC}"
      TESTS_PASSED=$((TESTS_PASSED + 1))
      return 0
    else
      echo "${RED}✗ FAILED${NC}"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  else
    # Run as a raw command (for --rm containers)
    if eval "${test_cmd}"; then
      echo "${GREEN}✓ PASSED${NC}"
      TESTS_PASSED=$((TESTS_PASSED + 1))
      return 0
    else
      echo "${RED}✗ FAILED${NC}"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  fi
}

# Run a test with a custom command (not in container)
# Usage: run_test_raw <test_name> <command>
run_test_raw() {
  local test_name="$1"
  local test_cmd="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  echo ""
  echo "Test ${TESTS_RUN}: ${test_name}"

  if eval "${test_cmd}"; then
    echo "${GREEN}✓ PASSED${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo "${RED}✗ FAILED${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Print test summary
print_summary() {
  echo ""
  echo "=========================================="
  echo "Test Summary"
  echo "=========================================="
  echo "Total tests: ${TESTS_RUN}"
  echo "${GREEN}Passed: ${TESTS_PASSED}${NC}"
  if [ ${TESTS_FAILED} -gt 0 ]; then
    echo "${RED}Failed: ${TESTS_FAILED}${NC}"
    echo ""
    echo "FAILED - Some tests did not pass"
    return 1
  else
    echo "All tests passed!"
    return 0
  fi
}

# Helper: check if a process is running in container
# Usage: check_process <container_name> <pattern>
check_process() {
  local name="$1"
  local pattern="$2"

  exec_container "${name}" ps aux 2>/dev/null | grep -q "${pattern}"
}

# Helper: check if a port is listening
# Usage: check_port <container_name> <port>
check_port() {
  local name="$1"
  local port="$2"

  # Try various methods depending on what's available
  exec_container "${name}" sh -c "
    netstat -tlnp 2>/dev/null | grep ':${port}' ||
    ss -tlnp 2>/dev/null | grep ':${port}' ||
    lsof -i :${port} 2>/dev/null ||
    (cat /proc/net/tcp 2>/dev/null | grep -q '${port}') ||
    true
  " | grep -q "${port}"
}
