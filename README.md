# ServiceNow Staying Alive PDI 

A simple shell script + cron setup to prevent your **ServiceNow Personal Developer Instance (PDI)** from expiring due to inactivity.  
By default, ServiceNow reclaims PDIs after ~10 days of no activity. This script uses a harmless REST API call to "ping" your instance automatically, so you never have to worry about it disappearing.

---

## How It Works
- Uses `curl` with **Basic Auth** to hit a lightweight ServiceNow API endpoint (`sys_properties`).
- The request counts as user activity.
- When scheduled with `cron`, the script runs on your Mac at regular intervals to keep the instance alive.

---

## Prerequisites
- macOS or Linux with:
  - `bash` (preinstalled)
  - `curl` (preinstalled)
- A valid ServiceNow PDI URL, username, and password  
  (tip: create a dedicated "keepalive" user in your PDI if you prefer not to use `admin`).

---

## Setup

### 1. Save the Script
Create a file called `keep_pdi_alive.sh` in your home directory:

```bash
#!/bin/bash
# ---- CONFIG ----
SNow_URL="https://devXXXXX.service-now.com"
SNow_USER="admin"
SNow_PASS="your_password"
# ---------------

curl -sS -u "${SNow_USER}:${SNow_PASS}" \
  "${SNow_URL}/api/now/table/sys_properties?sysparm_limit=1" \
  -H "Accept: application/json" > /dev/null

echo "$(date) - Keep-alive ping sent to $SNow_URL"
