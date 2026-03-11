#!/bin/bash
# GitHub Actions debug helper scripts
# Usage: ./gh-debug.sh [command]

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

case "${1:-help}" in
  list|ls)
    echo "=== Recent workflow runs ==="
    gh run list --limit 10
    ;;

  latest|last)
    RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
    echo "=== Latest run: $RUN_ID ==="
    gh run view "$RUN_ID"
    ;;

  watch|w)
    RUN_ID="${2:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"
    echo "=== Watching run $RUN_ID ==="
    gh run watch "$RUN_ID" --interval 5
    ;;

  status|s)
    RUN_ID="${2:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"
    echo "=== Run $RUN_ID status ==="
    gh run view "$RUN_ID" --json conclusion,status,workflowName,jobs --jq '.'
    ;;

  failed|f)
    echo "=== Recent failed runs ==="
    gh run list --limit 20 --json conclusion,databaseId,displayTitle --jq '.[] | select(.conclusion == "failure") | "\(.databaseId): \(.displayTitle)"'

    echo ""
    echo "=== Latest failed run details ==="
    FAILED_ID=$(gh run list --limit 20 --json conclusion,databaseId --jq '.[] | select(.conclusion == "failure") | .databaseId' | head -1)
    if [ -n "$FAILED_ID" ]; then
      echo "Checking failed run: $FAILED_ID"
      gh run view "$FAILED_ID" --json jobs --jq '.jobs[] | select(.conclusion == "failure") | {name, conclusion, steps: [.steps[] | select(.conclusion == "failure") | {name, conclusion}]}' 2>/dev/null || gh run view "$FAILED_ID"
    fi
    ;;

  logs|log)
    RUN_ID="${2:-$(gh run list --json databaseId,conclusion --limit 1 --jq '.[0].databaseId')}"
    JOB_ID="${3}"

    if [ -n "$JOB_ID" ]; then
      echo "=== Logs for job $JOB_ID in run $RUN_ID ==="
      gh run view "$RUN_ID" --job "$JOB_ID" --log
    else
      echo "=== Logs for run $RUN_ID ==="
      gh run view "$RUN_ID" --log
    fi
    ;;

  failed-logs|fl)
    echo "=== Getting logs from latest failed run ==="
    FAILED_ID=$(gh run list --json conclusion,databaseId --limit 1 --jq '.[] | select(.conclusion == "failure") | .databaseId')
    if [ -n "$FAILED_ID" ]; then
      echo "Failed run: $FAILED_ID"
      echo ""
      gh run view "$FAILED_ID" --log-failed 2>/dev/null || gh run view "$FAILED_ID" --log | grep -A 20 -E "(error|Error|ERROR|failed|Failed)"
    else
      echo "No recent failed runs found"
    fi
    ;;

  jobs|j)
    RUN_ID="${2:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"
    echo "=== Jobs for run $RUN_ID ==="
    gh run view "$RUN_ID" --json jobs --jq '.jobs[] | "\(.name): \(.status) - \(.conclusion // "running")"'
    ;;

  trigger|tr)
    WORKFLOW="${2:-Build PHP 8.5}"
    echo "=== Triggering $WORKFLOW ==="
    gh workflow run "$WORKFLOW"
    sleep 2
    echo ""
    gh run list --limit 3
    ;;

  workflows|wf)
    echo "=== Available workflows ==="
    gh workflow list
    ;;

  test-run|test)
    echo "=== Triggering test run with skip_tests=false ==="
    gh workflow run "Build PHP 8.5"
    echo ""
    echo "Use './gh-debug.sh watch' to monitor progress"
    ;;

  compare|cmp)
    echo "=== Comparing last 2 runs ==="
    gh run list --limit 2 --json databaseId,status,conclusion,displayTitle,startedAt --jq '.'
    ;;

  open|o)
    RUN_ID="${2:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"
    echo "=== Opening run $RUN_ID in browser ==="
    gh run view "$RUN_ID" --web
    ;;

  help|--help|-h|"")
    cat <<'EOF'
GitHub Actions Debug Helper

Usage: ./gh-debug.sh <command> [args]

Commands:
  list, ls           List recent workflow runs
  latest, last       Show latest run details
  watch, w [RUN_ID]  Watch a run live (default: latest)
  status, s [RUN_ID] Show detailed status of a run
  failed, f          Show recent failed runs with details
  logs, log [RUN] [JOB]  Get logs from a run/job
  failed-logs, fl    Get logs from failed steps only
  jobs, j [RUN_ID]   List all jobs in a run
  trigger, tr [WF]   Trigger a workflow (default: "Build PHP 8.5")
  workflows, wf      List all workflows
  test-run, test     Trigger a test run
  compare, cmp       Compare last 2 runs
  open, o [RUN_ID]   Open run in browser

Examples:
  ./gh-debug.sh ls                    # List recent runs
  ./gh-debug.sh watch                 # Watch latest run
  ./gh-debug.sh failed                # Show failed runs
  ./gh-debug.sh trigger               # Trigger PHP 8.5 build
  ./gh-debug.sh logs 22951170758      # Get logs for specific run

Shortcuts:
  Use 'gh' command directly for more options:
  - gh run list
  - gh run view <RUN_ID>
  - gh workflow list
  - gh workflow run <WORKFLOW>
EOF
    ;;
esac
