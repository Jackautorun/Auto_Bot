#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: list_workflow_runs.sh [options] [per_page]

List recent GitHub Actions workflow runs. Provide the `per_page` value as a
positional argument for backward compatibility, or use the `-p/--per-page`
option. Additional filters can be supplied via flags.

Options:
  -p, --per-page <n>   Number of runs to request (default: 10)
  -s, --status <value> Filter by status (queued, in_progress, completed)
  -b, --branch <name>  Filter runs by branch name
  -e, --event <type>   Filter runs by the triggering event (push, pull_request, ...)
  -h, --help           Show this message and exit
USAGE
}

: "${AUTH:?Environment variable AUTH must be set to the Authorization header (e.g. 'Authorization: Bearer <token>')}"
: "${ACCEPT:?Environment variable ACCEPT must be set to the Accept header for the GitHub API (e.g. 'Accept: application/vnd.github+json')}"
: "${BASE:?Environment variable BASE must be set to the GitHub API base URL (e.g. 'https://api.github.com')}"
: "${OWNER:?Environment variable OWNER must be set to the repository owner}"
: "${REPO:?Environment variable REPO must be set to the repository name}"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found in PATH." >&2
  exit 127
fi

PER_PAGE=10
STATUS=""
BRANCH=""
EVENT=""

POSITIONAL_PER_PAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--per-page)
      [[ $# -ge 2 ]] || { echo "Option $1 requires an argument." >&2; exit 2; }
      PER_PAGE="$2"
      shift 2
      ;;
    -s|--status)
      [[ $# -ge 2 ]] || { echo "Option $1 requires an argument." >&2; exit 2; }
      STATUS="$2"
      shift 2
      ;;
    -b|--branch)
      [[ $# -ge 2 ]] || { echo "Option $1 requires an argument." >&2; exit 2; }
      BRANCH="$2"
      shift 2
      ;;
    -e|--event)
      [[ $# -ge 2 ]] || { echo "Option $1 requires an argument." >&2; exit 2; }
      EVENT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -z "$POSITIONAL_PER_PAGE" ]]; then
        POSITIONAL_PER_PAGE="$1"
        shift
      else
        echo "Unexpected positional argument: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
done

if [[ -n "$POSITIONAL_PER_PAGE" ]]; then
  PER_PAGE="$POSITIONAL_PER_PAGE"
fi

if ! [[ "$PER_PAGE" =~ ^[0-9]+$ ]] || (( PER_PAGE <= 0 )); then
  echo "per_page must be a positive integer (received: $PER_PAGE)." >&2
  exit 2
fi

declare -a query_params
query_params+=("per_page=$PER_PAGE")

if [[ -n "$STATUS" ]]; then
  case "$STATUS" in
    queued|in_progress|completed)
      query_params+=("status=$STATUS")
      ;;
    *)
      echo "Invalid status: $STATUS. Expected queued, in_progress, or completed." >&2
      exit 2
      ;;
  esac
fi

if [[ -n "$BRANCH" ]]; then
  query_params+=("branch=$BRANCH")
fi

if [[ -n "$EVENT" ]]; then
  query_params+=("event=$EVENT")
fi

QUERY_STRING=$(IFS='&'; echo "${query_params[*]}")

curl -sS -H "$AUTH" -H "$ACCEPT" \
  "$BASE/repos/$OWNER/$REPO/actions/runs?$QUERY_STRING" \
  | jq '.workflow_runs[] | {name,status,conclusion,event,head_branch,html_url}'
