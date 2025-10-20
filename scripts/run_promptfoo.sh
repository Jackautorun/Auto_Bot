#!/usr/bin/env bash
set -euo pipefail

# Run promptfoo evaluation with a timestamped report directory.
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_DIR="reports/${STAMP}"

mkdir -p "${REPORT_DIR}"

npx promptfoo eval promptfooconfig.yaml \
  --report "${REPORT_DIR}" \
  "$@"

echo "\nEvaluation complete. Report saved to ${REPORT_DIR}".
