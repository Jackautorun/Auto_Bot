#!/usr/bin/env bash
set -euo pipefail

: "${AUTH:?Environment variable AUTH must be set to the Authorization header (e.g. 'Authorization: Bearer <token>')}"
: "${ACCEPT:?Environment variable ACCEPT must be set to the Accept header for the GitHub API (e.g. 'Accept: application/vnd.github+json')}"
: "${BASE:?Environment variable BASE must be set to the GitHub API base URL (e.g. 'https://api.github.com')}"
: "${OWNER:?Environment variable OWNER must be set to the repository owner}"
: "${REPO:?Environment variable REPO must be set to the repository name}"

PER_PAGE=${1:-10}

curl -sS -H "$AUTH" -H "$ACCEPT" \
  "$BASE/repos/$OWNER/$REPO/actions/runs?per_page=${PER_PAGE}" \
  | jq '.workflow_runs[] | {name,status,conclusion,html_url}'
