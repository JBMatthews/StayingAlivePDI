![ServiceNow PDI Stayin' Alive](./staying_alive_banner.png)

Tiny Bash script to keep your ServiceNow **Personal Developer Instance (PDI)** "Stayin' Alive" like the BeeGees.  
It works by hitting a lightweight REST API endpoint on a schedule.

---

## Files
- `keep_pdi_alive.sh` → Main script
- `credentials.sh` → Stores your ServiceNow URL, username, and password
- `README.md` → Instructions


---

## Setup

1. Copy `credentials.sh.example` to `credentials.sh` and update with your real info:
   ```bash
   #!/bin/bash
   SNow_URL="https://devXXXXX.service-now.com"
   SNow_USER="admin"
   SNow_PASS="your_password"
   ```

2. Make scripts executable:
   ```bash
   chmod +x keep_pdi_alive.sh
   chmod 600 credentials.sh   # protect credentials
   ```

3. Run manually:
   ```bash
   ./keep_pdi_alive.sh
   ```

4. Automate with cron (example: run every day at 9am):
   ```bash
   crontab -e
   ```
   Add:
   ```
   0 9 * * * /bin/bash /absolute/path/to/keep_pdi_alive.sh >> /absolute/path/to/pdi_keepalive.log 2>&1
   ```

---

## Security
- **Never commit real `credentials.sh`**. Only commit the template `credentials.sh.example`.
- Add `credentials.sh` to `.gitignore`.

---

## Personal Note
- **Don't be that guy**. After a tough breakup, I lost my PDI. That shouldn't happen. But, please, don't misuse this. 
- **Dear ServiceNow**, I'm not only single but currently unemployed... please consider sending application along with cease and desist letter. 

---
