-- Logs table
CREATE TABLE IF NOT EXISTS logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  level TEXT NOT NULL CHECK(level IN ('INFO', 'WARN', 'ERROR', 'DEBUG')),
  message TEXT NOT NULL,
  context TEXT,
  sync_run_id TEXT
);

-- Synced events table
CREATE TABLE IF NOT EXISTS synced_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classeviva_event_id TEXT NOT NULL UNIQUE,
  google_event_id TEXT,
  calendar_id TEXT,
  title TEXT NOT NULL,
  description TEXT,
  event_date TEXT NOT NULL,
  event_type TEXT NOT NULL CHECK(event_type IN ('homework', 'test', 'other')),
  subject TEXT,
  teacher TEXT,
  last_synced_at TEXT NOT NULL DEFAULT (datetime('now')),
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'deleted', 'error')),
  sync_run_id TEXT
);

-- Manual event overrides table
CREATE TABLE IF NOT EXISTS event_overrides (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classeviva_event_id TEXT NOT NULL UNIQUE,
  override_title TEXT,
  override_description TEXT,
  override_date TEXT,
  skip_sync INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_logs_sync_run ON logs(sync_run_id);
CREATE INDEX IF NOT EXISTS idx_synced_events_date ON synced_events(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_synced_events_status ON synced_events(status);
