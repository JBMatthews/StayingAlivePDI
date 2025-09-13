#!/bin/bash
set -euo pipefail

# ---- LOAD CREDS ----
# Use an absolute path so cron can find it
CRED_FILE="credentials.sh"   # <-- change this
if [[ ! -f "$CRED_FILE" ]]; then
  echo "Cred file not found: $CRED_FILE" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CRED_FILE"

# Validate required vars
: "${SNow_URL:?Missing SNow_URL in $CRED_FILE}"
: "${SNow_USER:?Missing SNow_USER in $CRED_FILE}"
: "${SNow_PASS:?Missing SNow_PASS in $CRED_FILE}"

# Optional knobs
VERBOSE=${VERBOSE:-false}                 # print JSON payload
VERIFY_WINDOW_MIN=${VERIFY_WINDOW_MIN:-10} # minutes to look back

# Normalize URL (avoid trailing slash)
SNow_URL="${SNow_URL%/}"

# ---- PRIMARY PING ----
TMP_JSON="$(mktemp)"
STATUS_CODE=$(
  curl -sS -u "${SNow_USER}:${SNow_PASS}" \
    -H "Accept: application/json" \
    -o "$TMP_JSON" \
    -w "%{http_code}" \
    "${SNow_URL}/api/now/table/sys_properties?sysparm_limit=1"
)

TS="$(date '+%Y-%m-%d %H:%M:%S')"
if [[ "$STATUS_CODE" == "200" ]]; then
  echo "$TS - Keep-alive OK (HTTP $STATUS_CODE) -> ${SNow_URL}"
else
  echo "$TS - Keep-alive FAILED (HTTP $STATUS_CODE) -> ${SNow_URL}"
fi

if [[ "$VERBOSE" == "true" ]]; then
  echo "---- RESPONSE BEGIN ----"
  cat "$TMP_JSON"
  echo
  echo "---- RESPONSE END ----"
fi
rm -f "$TMP_JSON"

# ---- VERIFICATION VIA TRANSACTION LOGS (#3) ----
# Look back N minutes, match the endpoint, and your user (dot-walk the user reference).
VERIFY_QUERY="sys_created_on>=javascript:gs.minutesAgoStart(${VERIFY_WINDOW_MIN})^urlLIKE/api/now/table/sys_properties^user.user_name=${SNow_USER}"
VERIFY_FIELDS="sys_created_on,url,user,response_status"

LOG_CHECK=$(
  curl -sS -u "${SNow_USER}:${SNow_PASS}" \
    -H "Accept: application/json" \
    -G "${SNow_URL}/api/now/table/syslog_transaction" \
    --data-urlencode "sysparm_query=${VERIFY_QUERY}" \
    --data "sysparm_fields=${VERIFY_FIELDS}" \
    --data "sysparm_limit=1"
)

echo "$TS - Verification (syslog_transaction search, last ${VERIFY_WINDOW_MIN}m):"
echo "$LOG_CHECK"

# Optional: a simple count (uncomment if you prefer a yes/no tally)
# COUNT_JSON=$(
#   curl -sS -u "${SNow_USER}:${SNow_PASS}" \
#     -H "Accept: application/json" \
#     -G "${SNow_URL}/api/now/stats/syslog_transaction" \
#     --data-urlencode "sysparm_query=${VERIFY_QUERY}" \
#     --data "sysparm_count=true"
# )
# echo "$TS - Verification count: $COUNT_JSON"

