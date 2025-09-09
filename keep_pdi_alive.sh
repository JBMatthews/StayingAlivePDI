#!/bin/bash
set -euo pipefail

# Load credentials
source "$(dirname "$0")/credentials.sh"

# Send keep-alive ping
curl -sS -u "${SNow_USER}:${SNow_PASS}" \
  "${SNow_URL}/api/now/table/sys_properties?sysparm_limit=1" \
  -H "Accept: application/json" > /dev/null

echo "$(date) - Keep-alive ping sent to $SNow_URL"
