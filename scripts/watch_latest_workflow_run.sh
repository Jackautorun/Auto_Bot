#!/usr/bin/env bash
set -euo pipefail

: "${AUTH:?Environment variable AUTH must be set to the Authorization header (e.g. 'Authorization: Bearer <token>')}"
: "${ACCEPT:?Environment variable ACCEPT must be set to the Accept header for the GitHub API (e.g. 'Accept: application/vnd.github+json')}"
: "${BASE:?Environment variable BASE must be set to the GitHub API base URL (e.g. 'https://api.github.com')}"
: "${OWNER:?Environment variable OWNER must be set to the repository owner}"
: "${REPO:?Environment variable REPO must be set to the repository name}"

POLL_INTERVAL=${1:-10}
RUN_ID=${2:-}

fetch_latest_run_id() {
  curl -sS -H "$AUTH" -H "$ACCEPT" \
    "$BASE/repos/$OWNER/$REPO/actions/runs?per_page=1" \
    | jq -r '.workflow_runs[0].id'
}

fetch_run() {
  local id="$1"
  curl -sS -H "$AUTH" -H "$ACCEPT" \
    "$BASE/repos/$OWNER/$REPO/actions/runs/$id"
}

if [[ -z "$RUN_ID" ]]; then
  RUN_ID="$(fetch_latest_run_id)"
  if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
    echo "Unable to determine the latest workflow run ID" >&2
    exit 1
  fi
fi

echo "Watching workflow run $RUN_ID (poll interval: ${POLL_INTERVAL}s)"

while true; do
  RESPONSE="$(fetch_run "$RUN_ID")"
  STATUS="$(jq -r '.status' <<<"$RESPONSE")"
  CONCLUSION="$(jq -r '.conclusion // ""' <<<"$RESPONSE")"
  HTML_URL="$(jq -r '.html_url' <<<"$RESPONSE")"
  echo "[$(date --iso-8601=seconds)] status=$STATUS conclusion=${CONCLUSION:-n/a} url=$HTML_URL"

  if [[ "$STATUS" == "completed" ]]; then
    if [[ "$CONCLUSION" == "success" ]]; then
      exit 0
    else
      exit 1
    fi
  fi

  sleep "$POLL_INTERVAL"
done
