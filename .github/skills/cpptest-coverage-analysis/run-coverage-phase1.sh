#!/bin/bash
# Phase 1 Wrapper: Coverage analysis with structured output
# Wraps run-coverage.sh and adds JSON metadata

set -euo pipefail

EXEC_ID=$(date +%s)-$$
PROJECT_ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run original script and capture output
echo "[$(date '+%H:%M:%S')] Starting coverage analysis (Exec: $EXEC_ID)" >&2

if cd "$PROJECT_ROOT" && "$SCRIPT_DIR/run-coverage.sh"; then
  STATUS="success"
  EXIT_CODE=0
else
  STATUS="error"
  EXIT_CODE=$?
fi

# Extract coverage result
BUILD_DIR="$PROJECT_ROOT/build"
COVERAGE_PCT="0"
if [[ -f "$BUILD_DIR/coverage_report.txt" ]]; then
  COVERAGE_PCT=$(grep "^> TOTAL" "$BUILD_DIR/coverage_report.txt" | awk '{print $NF}' | sed 's/%//' || echo "0")
fi

# Output Phase 1 JSON metadata
cat <<EOF
{
  "status": "$STATUS",
  "operation": "run-coverage-analysis",
  "timestamp": "$(date -Iseconds)",
  "execution_id": "$EXEC_ID",
  "inputs": {
    "project_root": "$PROJECT_ROOT"
  },
  "outputs": {
    "primary_artifact": "$BUILD_DIR/coverage_report.txt",
    "coverage_percentage": $COVERAGE_PCT,
    "files": {
      "coverage_database": "$BUILD_DIR/.coverage/",
      "test_results": "$BUILD_DIR/test_results.txt",
      "coverage_report": "$BUILD_DIR/coverage_report.txt"
    }
  },
  "audit_trail": {
    "user": "$USER",
    "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
    "execution_id": "$EXEC_ID"
  },
  "next_steps": [
    "View coverage report: $BUILD_DIR/coverage_report.txt",
    "Check test results: $BUILD_DIR/test_results.txt"
  ]
}
EOF

exit $EXIT_CODE
