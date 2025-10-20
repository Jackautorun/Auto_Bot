#!/usr/bin/env bash
set -euo pipefail

: "${AUTH:?Environment variable AUTH must be set to the Authorization header (e.g. 'Authorization: Bearer <token>')}"
: "${ACCEPT:?Environment variable ACCEPT must be set to the Accept header for the GitHub API (e.g. 'Accept: application/vnd.github+json')}"
: "${BASE:?Environment variable BASE must be set to the GitHub API base URL (e.g. 'https://api.github.com')}"
: "${OWNER:?Environment variable OWNER must be set to the repository owner}"
: "${REPO:?Environment variable REPO must be set to the repository name}"

require_command() {
  local binary=$1
  shift

  if ! command -v "$binary" >/dev/null 2>&1; then
    echo "Error: $binary is required but was not found in PATH." >&2
    if [ "$#" -gt 0 ]; then
      printf '%s\n' "$@" >&2
    fi
    exit 127
  fi
}

require_command curl \
  "Install curl from https://curl.se/ or your package manager and try again."
require_command jq \
  "Install jq from https://jqlang.github.io/jq/ or your package manager and try again."

PER_PAGE=${1:-10}

curl -sS -H "$AUTH" -H "$ACCEPT" \
  "$BASE/repos/$OWNER/$REPO/actions/runs?per_page=${PER_PAGE}" \
  | jq '.workflow_runs[] | {name,status,conclusion,html_url}'
