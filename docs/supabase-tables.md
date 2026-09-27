---
tags: [travel, supabase, tables, schema, realtime]
category: travel
last_updated: 2026-09-13
---

# Travel Supabase Tables

Database tables in Supabase for trip planning collaboration.

**Database:** Supabase PostgreSQL  
**Project:** `trips`  
**Access:** Anonymous (via publishable key + Row Level Security)  
**Realtime:** Enabled on all tables for live collaboration

---

## Table Naming Convention

Each trip gets its own set of tables with a prefix:

```
{trip-name}_activities
{trip-name}_day_headers
{trip-name}_glance
{trip-name}_inspiration
```

**Current trips:**
- `japan_*` (November 2026)

**Future trips:**
- `italy_*`, `hawaii_*`, etc.

---

## {trip}_activities

Collaborative activity planning for each day.

**Grain:** One row per activity

**Purpose:** Family members add, edit, and vote on activities for each day

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key, auto-generated |
| `day_date` | date | Which day this activity is for |
| `time` | text | Time of activity (e.g. "09:00", "afternoon", "evening") |
| `description` | text | What the activity is |
| `votes` | jsonb | Vote tallies by user: `{"Ana": 1, "Fernando": 1, "Ramon": 0}` |
| `created_by` | text | Name of person who added it |
| `created_at` | timestamptz | When activity was added |

**Vote structure:**
```json
{
  "Ana": 1,
  "Fernando": 1,
  "Ramon": 0,
  "Maria": 1
}
```

**Vote meanings:**
- `1` = interested/yes
- `0` = neutral/maybe
- `-1` = not interested (if implemented)

**Realtime enabled:** Changes sync to all browsers within ~1 second

**Row Level Security:**
- Anonymous users can: SELECT, INSERT, UPDATE, DELETE
- Policy enforces: Anyone can read/write (family collaboration)

**Example rows:**
```
| id | day_date | time | description | votes | created_by | created_at |
|----|----------|------|-------------|-------|------------|------------|
| uuid-1 | 2026-11-15 | 09:00 | Meiji Shrine visit | {"Ana": 1, "Fernando": 1} | Fernando | 2026-09-01 10:30:00 |
| uuid-2 | 2026-11-15 | 12:00 | Lunch in Harajuku | {"Ana": 1} | Ana | 2026-09-01 11:15:00 |
| uuid-3 | 2026-11-15 | 15:00 | Shibuya Crossing | {"Fernando": 1, "Ramon": 1} | Ramon | 2026-09-01 12:00:00 |
```

---

## {trip}_day_headers

Custom section titles for each day.

**Grain:** One row per day (unique on day_date)

**Purpose:** Add descriptive headers like "Arrival Day", "Tokyo Exploration", "Kyoto Day Trip"

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key, auto-generated |
| `day_date` | date | Which day (unique constraint) |
| `header_text` | text | Custom header for this day |
| `created_at` | timestamptz | When header was added |

**Realtime enabled:** Changes sync live

**Row Level Security:**
- Anonymous users can: SELECT, INSERT, UPDATE, DELETE

**Example rows:**
```
| id | day_date | header_text | created_at |
|----|----------|-------------|------------|
| uuid-1 | 2026-11-15 | Arrival Day - Tokyo | 2026-09-01 10:00:00 |
| uuid-2 | 2026-11-16 | Exploring Shibuya & Harajuku | 2026-09-01 10:05:00 |
| uuid-3 | 2026-11-17 | Day Trip to Mount Fuji | 2026-09-01 10:10:00 |
```

---

## {trip}_glance

Quick trip summary facts (dates, travelers, budget, etc.).

**Grain:** One row per field (unique on field name)

**Purpose:** High-level trip information displayed at top of planning site

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key, auto-generated |
| `field` | text | Field name (unique): "dates", "travelers", "budget", "accommodation", "flights" |
| `value` | text | Field value (free text) |
| `updated_at` | timestamptz | Last update timestamp |

**Standard fields:**
- `dates` - Trip dates (e.g. "November 15-25, 2026")
- `travelers` - Who's going (e.g. "Fernando, Ana, Ramon")
- `budget` - Estimated budget (e.g. "$5,000 per person")
- `accommodation` - Where staying (e.g. "Shibuya hotel, Kyoto ryokan")
- `flights` - Flight details (e.g. "JFK → NRT, November 15")

**Realtime enabled:** Changes sync live

**Row Level Security:**
- Anonymous users can: SELECT, INSERT, UPDATE, DELETE

**Example rows:**
```
| id | field | value | updated_at |
|----|-------|-------|------------|
| uuid-1 | dates | November 15-25, 2026 | 2026-09-01 10:00:00 |
| uuid-2 | travelers | Fernando, Ana, Ramon | 2026-09-01 10:01:00 |
| uuid-3 | budget | $5,000 per person | 2026-09-01 10:02:00 |
| uuid-4 | accommodation | Shibuya Grand Hotel | 2026-09-01 10:03:00 |
```

---

## {trip}_inspiration

Photo gallery of trip inspiration.

**Grain:** One row per photo

**Purpose:** Share photos, links, and inspiration for the trip

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key, auto-generated |
| `image_url` | text | URL to image (Supabase Storage or external) |
| `caption` | text | Photo caption or description |
| `uploaded_by` | text | Name of person who added it |
| `created_at` | timestamptz | When photo was added |

**Storage:**
- Photos uploaded to Supabase Storage bucket: `{trip-name}-images`
- External URLs also supported (e.g. Google Photos links)

**Realtime enabled:** New photos appear live for all users

**Row Level Security:**
- Anonymous users can: SELECT, INSERT, DELETE
- Cannot UPDATE (delete and re-add instead)

**Example rows:**
```
| id | image_url | caption | uploaded_by | created_at |
|----|-----------|---------|-------------|------------|
| uuid-1 | https://supabase.co/storage/v1/object/public/japan-images/tokyo-tower.jpg | Tokyo Tower at sunset | Fernando | 2026-09-01 11:00:00 |
| uuid-2 | https://supabase.co/storage/v1/object/public/japan-images/sushi.jpg | Omakase sushi inspiration | Ana | 2026-09-01 11:30:00 |
```

---

## Supabase Storage

**Bucket naming:** `{trip-name}-images`

**Example:**
- `japan-images` (for Japan trip)
- `italy-images` (for Italy trip)

**Bucket configuration:**
- Public read access
- Anonymous write access (via RLS policies)
- Max file size: 5 MB per image

**Uploaded images:**
- Stored permanently in Supabase Storage
- URLs inserted into `{trip}_inspiration` table
- Automatic CDN delivery

---

## Realtime Configuration

All tables have Realtime enabled for live collaboration.

**Subscription setup (in trip HTML):**
```javascript
const channel = supabase
  .channel('trip-changes')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'japan_activities' },
    (payload) => {
      // Handle activity changes
      updateActivitiesUI(payload);
    }
  )
  .subscribe();
```

**Events published:**
- `INSERT` - New activity/photo/header added
- `UPDATE` - Activity edited, votes changed
- `DELETE` - Activity/photo removed

**Latency:** Typically < 1 second from change to all clients

---

## Row Level Security Policies

**Philosophy:** Family collaboration, no authentication required

**All tables use same policy:**

```sql
-- Allow anonymous read
CREATE POLICY "Allow anonymous read"
ON {trip}_activities FOR SELECT
USING (true);

-- Allow anonymous insert
CREATE POLICY "Allow anonymous insert"
ON {trip}_activities FOR INSERT
WITH CHECK (true);

-- Allow anonymous update
CREATE POLICY "Allow anonymous update"
ON {trip}_activities FOR UPDATE
USING (true);

-- Allow anonymous delete
CREATE POLICY "Allow anonymous delete"
ON {trip}_activities FOR DELETE
USING (true);
```

**Security model:**
- Publishable key is public (embedded in HTML)
- RLS policies allow full CRUD for everyone
- No sensitive data stored (trip planning only)
- Trust-based family collaboration

---

## Schema Management

**Creating a new trip:**

1. Duplicate `japan/schema.sql`
2. Replace `japan_` prefix with `{trip-name}_` throughout
3. Update storage bucket name
4. Run in Supabase SQL Editor

**Schema is idempotent:**
- Safe to re-run
- Uses `CREATE TABLE IF NOT EXISTS`
- Uses `CREATE POLICY IF NOT EXISTS`

**No migrations:**
- Each trip is isolated
- Old trips can have old schema
- No need to migrate completed trips

---

## Data Retention

**Active trips:** Full data retained

**Completed trips:**
- Tables preserved indefinitely (memories!)
- Storage bucket preserved
- No automated cleanup

**Storage estimates:**
- Activities: ~50-100 rows per trip
- Day headers: ~10-15 rows per trip
- Glance: ~5-10 rows per trip
- Inspiration: ~20-50 photos per trip

**Total storage per trip:** < 50 MB

---

## Access Control

**No authentication:**
- Anyone with the URL can access
- Family-only distribution via private messages

**Publishable key embedded in HTML:**
- Public by design
- Security via RLS policies, not key secrecy

**Project-level security:**
- Only these specific tables accessible
- No access to other Supabase data
- Publishable key scoped to `trips` project

---

## Backup

**Supabase automatic backups** (verify plan tier)

**Manual backup:**
- Trip HTML is self-contained (can be saved offline)
- Photos in Supabase Storage (download bucket as zip)
- Consider: Annual export to `G:\My Drive\Personal\Travel\{trip-name}\`

---

## Related Files

**Workflow documentation:** [[travel/travel-automation]]

**Schema definitions:**
- `travel/japan/schema.sql`

**Trip sites:**
- `travel/japan/index.html`

**Live sites:**
- `https://fernandomartinez-de.github.io/trips/japan/`
