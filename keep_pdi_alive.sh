#!/bin/bash
set -euo pipefail

# Load creds
CRED_FILE="$(dirname "$0")/credentials.sh"
if [[ ! -f "$CRED_FILE" ]]; then
  echo "Cred file not found: $CRED_FILE" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CRED_FILE"

# Identify the machine running this script
HOSTNAME=$(hostname)

# Send a POST request to the custom Scripted REST API
STATUS_CODE=$(
  curl -sS -u "${SNow_USER}:${SNow_PASS}" \
    -o /dev/null \
    -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -d "{\"status\":200, \"message\":\"cron ping\", \"source\":\"$HOSTNAME\"}" \
    "${SNow_URL}/api/x_1522524_stayin_0/stayinalive_api/travolta"
)

TS="$(date '+%Y-%m-%d %H:%M:%S')"
echo "$TS - Keep-alive POST returned HTTP $STATUS_CODE"

