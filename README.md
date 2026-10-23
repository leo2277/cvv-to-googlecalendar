# CVV → GCal | Cloudflare Worker

Syncs homework/tests from **Classeviva (Spaggiari)** to **Google Calendar** via a scheduled Cloudflare Worker cron job. Includes a React dev dashboard to monitor logs and manage synced events.

## Stack

| Layer | Tech |
|-------|------|
| Runtime | Cloudflare Workers |
| Router | Hono |
| Database | Cloudflare D1 (SQLite) |
| KV Store | Cloudflare KV |
| Frontend | React 18 + Tailwind CSS + Vite |
| Auth | Google Service Account (JWT / RS256) |
| Schedule | Cloudflare Cron Trigger (06:00, 14:00, 20:00 UTC) |

---

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Create Cloudflare D1 database

```bash
npx wrangler d1 create cvv-calendar-db
```

Copy the `database_id` output and paste it into `wrangler.toml` → `[[d1_databases]]`.

### 3. Create KV namespace

```bash
npx wrangler kv:namespace create KV
```

Copy the `id` output and paste it into `wrangler.toml` → `[[kv_namespaces]]`.

### 4. Apply the database schema

```bash
# Local (dev)
npx wrangler d1 execute cvv-calendar-db --local --file=schema.sql

# Remote (production)
npx wrangler d1 execute cvv-calendar-db --remote --file=schema.sql
```

### 5. Set secrets

```bash
npx wrangler secret put CVV_USERNAME        # Your Classeviva student code
npx wrangler secret put CVV_PASSWORD        # Your Classeviva password
npx wrangler secret put CVV_STUDENT_ID      # Your Classeviva student ID
npx wrangler secret put GOOGLE_SERVICE_ACCOUNT_JSON  # Full JSON of service account key
npx wrangler secret put GOOGLE_CALENDAR_ID  # Calendar ID (e.g. xxx@group.calendar.google.com)
npx wrangler secret put DASHBOARD_PASSWORD  # Password for the dashboard
```

### 6. Google Calendar setup

1. Create a Google Cloud project
2. Enable the **Google Calendar API**
3. Create a **Service Account** and download the JSON key
4. Share your Google Calendar with the service account email (give it "Make changes to events" permission)
5. Set `GOOGLE_SERVICE_ACCOUNT_JSON` to the full contents of the downloaded JSON key

---

## Development

```bash
npm run dev
```

The local dev server runs at `http://localhost:8787`.

## Build & Deploy

```bash
npm run deploy
```

---

## Dashboard

Navigate to your Worker's URL. Log in with:
- **Username**: value of `DASHBOARD_USERNAME` in `wrangler.toml` (default: `admin`)
- **Password**: value of `DASHBOARD_PASSWORD` secret

### Features
- **Events tab**: View all synced events, edit overrides, re-sync, or mark as deleted
- **Logs tab**: Live log viewer with level filtering and auto-refresh
- **Force Sync**: Manually trigger a sync from the dashboard

---

## API Endpoints

All endpoints require `Authorization: Basic <base64(user:pass)>`.

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/sync/status` | Last run info + event stats |
| `POST` | `/api/sync` | Trigger a manual sync |
| `GET` | `/api/logs` | Fetch logs (filter: `level`, `run_id`, `limit`) |
| `DELETE` | `/api/logs` | Clear logs older than 30 days |
| `GET` | `/api/events` | Fetch events (filter: `status`, `from`, `limit`) |
| `DELETE` | `/api/events/:id` | Mark event as deleted |
| `PUT` | `/api/events/:id/override` | Set title/description/skip override |
| `POST` | `/api/events/:id/resync` | Trigger re-sync for a specific event |

---

## Cron Schedule

Default: `0 6,14,20 * * *` → runs at 06:00, 14:00, 20:00 UTC every day.

Edit in `wrangler.toml` → `[triggers]` → `crons`.
