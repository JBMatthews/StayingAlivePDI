![ServiceNow PDI Stayin' Alive](./staying_alive_banner.png)

Tiny Bash script to keep your ServiceNow **Personal Developer Instance (PDI)** "Staying Alive" like John Travolta.  

This project combines:  
1. A **ServiceNow Scoped App** → provides a REST API + table to log pings.  
2. A **Local Script + Cron Job** → runs daily to hit your PDI and record activity.  

Together, they ensure your PDI doesn’t expire from inactivity — and give you proof that the keep-alive is working.

---

## Quick Start

### 1. Fork This Repo
Click **Fork** at the top of this page to copy it into your GitHub account.  
Clone it locally:
```bash
git clone https://github.com/YOUR-USERNAME/StayinAlivePDI.git
cd StayinAlivePDI
```

---

### 2. Create a GitHub PAT (Personal Access Token)

If you haven’t done this before:  

1. Go to [GitHub → Settings → Developer Settings → Personal Access Tokens](https://github.com/settings/tokens).  
2. Click **Generate new token (classic)**.  
3. Give it a name like `ServiceNowSourceControl`.  
4. Expiration: choose a reasonable timeframe (e.g., 90 days).  
5. Scopes: check only **repo** (full control of private repositories) if your fork is private. For public forks, minimal scopes are fine.  
6. Generate and copy the token.  

    > Save this token — you’ll need it in the next step.  

---

### 3. Install the App in Your PDI

1. Log into [developer.servicenow.com](https://developer.servicenow.com) and open your PDI.  
2. In the left nav, go to **Connections & Credentials → Credentials** (table: `discovery_credentials`).  
3. Click **New** → select **Basic Auth Credentials**.  
   - **Name**: `GitHubAccessControl`  
   - **Username**: your GitHub username you use to log into GitHub.  
   - **Password**: the GitHub PAT you created in Step 2  
   - Save the record.  
4. Now go to **System Applications → Studio**.  
5. Click **Import From Source Control**.  
   - **URL**: your fork’s GitHub repo URL  
   - **Credential**: select the `GitHub` Basic Auth credential you just created  
6. Import the **Stayin’ Alive PDI** app.  

This gives you:  
- **Table**: `Keepalive Log` (`x_yourcompany_alive_log`)  
- **Scripted REST API**: `/api/x_yourcompany_alive/stayin_alive/ping`  

---

### 4. Set Up Local Credentials

Copy the template:
```bash
cp credentials.sh.example credentials.sh
```

Edit `credentials.sh`:
```bash
#!/bin/bash
SNow_URL="https://devXXXXX.service-now.com"  # no trailing slash
SNow_USER="admin"
SNow_PASS='your_password'
```

Protect it:
```bash
chmod 600 credentials.sh
```

---

### 5. Test the Script

Make it executable:
```bash
chmod +x keep_pdi_alive.sh
```

Run manually:
```bash
./keep_pdi_alive.sh
```

Expected:
```
2025-09-26 09:15:01 - Keep-alive POST returned HTTP 201
```

Then, check your PDI:  
- Navigate: **Stayin’ Alive → Keepalive Logs**  
- You should see a new row with the current time.

---

### 6. Automate with Cron

Edit your crontab:
```bash
crontab -e
```

Add:
```cron
0 9 * * * cd /Users/YOURNAME/Path/StayinAlivePDI && ./keep_pdi_alive.sh >> pdi_keepalive.log 2>&1
```
    
    > If you are unsure of what the absolute path to "StayinAlivePDI" is and you are using Terminal, you can use the command 'pwd'

- Runs every day at 9am.  
- Appends results to `pdi_keepalive.log` in your repo folder.  

Check logs:
```bash
tail -f pdi_keepalive.log
```

---

## Verification

- **Local**: check `pdi_keepalive.log` for daily entries.  
- **PDI**: open the **Keepalive Log** table — every script run inserts a new record.  
- **System Logs → Transactions** also shows `/stayin_alive/ping`.

---

## Security

- Don’t commit your `credentials.sh`. (It’s already in `.gitignore`.)  
- Use single quotes `'...'` around your password if it contains `$` or `!`.  
- If you regenerate your PDI, just update `SNow_URL` in `credentials.sh`.

---

## Example Output

**Local log:**
```
2025-09-26 09:00:00 - Keep-alive POST returned HTTP 201
```

**Keepalive Log in ServiceNow:**

| Run Time             | Status | Message    | Source   |
|----------------------|--------|------------|----------|
| 2025-09-26 09:00:00  | 200    | cron ping  | MyMac    |

---

## Summary

- Fork → Create a PAT → Create a Basic Auth Credential in your PDI → Import app.  
- Configure `credentials.sh`.  
- Run `keep_pdi_alive.sh` daily via cron.  
- Confirm logs locally and in your PDI.  

Stayin’ Alive — your PDI heartbeat that never skips a beat. 


---

## Personal Note
- **Don't be that guy**. After a tough breakup, I lost my PDI. That shouldn't happen. But, please, don't misuse this. 
- **Dear ServiceNow**, I'm not only single but currently unemployed... please consider sending application along with cease and desist letter. 

---
