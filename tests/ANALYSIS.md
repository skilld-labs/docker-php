# Test Container Optimization Analysis

## Current State

| Script | Container Starts | Pattern |
|--------|------------------|---------|
| test-base.sh | ~15 starts | New container per test (`docker run --rm`) |
| test-fpm.sh | ~3 starts | 1 daemon + exec for most tests + 1 final |
| test-unit.sh | ~2 starts | 1 daemon + exec for remaining tests |

## Issues with Current Approach

1. **High overhead**: Each `docker run` creates a new container, extracts layers, starts processes
2. **Slow tests**: ~15 seconds for base image due to repeated container starts
3. **Docker-specific**: Uses `docker inspect` with Go templates, `docker ps --format`

## Optimization Strategy

### Key Insight: Start Once, Test Many Times

For **base images** (no daemon):
- Start container with `sleep infinity` or `tail -f /dev/null`
- Run all tests via `exec` (no container restart overhead)
- Single container start instead of ~15

For **fpm/unit images** (already optimized):
- Already use daemon container + exec pattern
- Minor improvements possible

### Runtime Compatibility Matrix

| Feature | Docker | Podman | Nerdctl | Buildah |
|---------|--------|--------|---------|---------|
| `run --rm` | ✓ | ✓ | ✓ | ✗ (use `run`) |
| `exec` | ✓ | ✓ | ✓ | ✗ |
| `inspect --format` | ✓ | ✓ | partial | ✗ |
| `ps --format` | ✓ | ✓ | ✗ | ✗ |
| `run -d` | ✓ | ✓ | ✓ | ✗ |

### Runtime Detection

```bash
# Auto-detect available runtime
RUNTIME=$(command -v podman || command -v nerdctl || command -v docker || echo "docker")
```

### Optimized Pattern

```bash
# 1. Detect runtime
RUNTIME="${CONTAINER_RUNTIME:-${RUNTIME:-$(command -v podman || command -v nerdctl || command -v docker || true)}}"

# 2. Start one long-running container
CID=$($RUNTIME run -d --name test-${NAME} ${IMAGE} sleep infinity)

# 3. Run all tests via exec
$RUNTIME exec ${CID} php -v
$RUNTIME exec ${CID} composer --version
$RUNTIME exec ${CID} drush version
...

# 4. Cleanup
$RUNTIME rm -f ${CID}
```

## Expected Results

| Script | Before | After | Improvement |
|--------|--------|-------|-------------|
| test-base.sh | ~15 starts | 1 start | 93% reduction |
| test-fpm.sh | ~3 starts | 2 starts | 33% reduction |
| test-unit.sh | ~2 starts | 2 starts | No change (already optimal) |

## Implementation Requirements

1. Runtime detection (docker/podman/nerdctl)
2. POSIX-compatible helpers (avoid bashisms where possible)
3. Graceful degradation when features unavailable
4. Support `CONTAINER_RUNTIME` env var override
