#!/usr/bin/env bash
set -euo pipefail

# Resolve script directory so it can find .env beside it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
else
  echo "[ERROR] .env file not found in ${SCRIPT_DIR}. Copy .env.example to .env and fill it out."
  exit 1
fi

: "${SNow_URL:?Missing SNow_URL in .env}"
: "${SNow_USER:?Missing SNow_USER in .env}"
: "${SNow_PASS:?Missing SNow_PASS in .env}"
REQUEST_TIMEOUT="${REQUEST_TIMEOUT:-30}"

LOG_FILE="${SCRIPT_DIR}/pdi_keepalive.log"

# Perform a tiny GET to register activity
STATUS=0
OUTPUT=$(curl -sS -u "${SNow_USER}:${SNow_PASS}" \
  "${SNow_URL}/api/now/table/sys_properties?sysparm_limit=1" \
  -H "Accept: application/json" \
  --max-time "${REQUEST_TIMEOUT}" \
  --write-out " HTTP_STATUS:%{http_code}" \
  || STATUS=$?)

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ $STATUS -ne 0 ]]; then
  echo "${TIMESTAMP} - FAILED: curl exited with status ${STATUS}" | tee -a "${LOG_FILE}"
  exit $STATUS
fi

HTTP_CODE="${OUTPUT##*HTTP_STATUS:}"
if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "${TIMESTAMP} - FAILED: HTTP ${HTTP_CODE}" | tee -a "${LOG_FILE}"
  exit 2
fi

echo "${TIMESTAMP} - OK: Keep-alive ping sent to ${SNow_URL}" | tee -a "${LOG_FILE}"
