---
tags: [travel, planning, static-site, collaboration]
category: travel
status: active
last_updated: 2026-09-13
repo: personal
---

# Travel Planning Sites

Static HTML trip planning sites with real-time family collaboration via Supabase.

## Repository

`C:\Users\fmartine\Personal\repos\personal\travel\`

GitHub: `https://github.com/fernandomartinez-de/personal` (travel/ folder)

GitHub Pages: `https://fernandomartinez-de.github.io/trips/`

## Tables

**→ [[travel/supabase-tables]]**

Complete Supabase table schemas for trip planning:
- {trip}_activities, {trip}_day_headers, {trip}_glance, {trip}_inspiration

## Scripts

**→ [[travel/scripts]]**

No Python scripts - pure HTML/JavaScript:
- Embedded Supabase client, Real-time subscriptions, localStorage caching

## Overview

```
Static HTML (single file per trip)
  ↓
Supabase Realtime (collaboration)
  ↓
GitHub Pages (automatic deployment)
```

One self-contained `index.html` per trip with embedded JavaScript. No build step, no server.

## Architecture

**Single-file HTML sites:**
- Tailwind CSS (CDN)
- Supabase JS SDK (CDN)
- Google Maps JS API (CDN, keyed)
- Images as separate files (not embedded)

**Collaboration:**
- Anonymous access (no login)
- Pick name once via "Poner nombre" button
- Supabase Realtime pushes changes (<1 second)
- localStorage caches state for offline reads
- Row Level Security policies enforce read/write permissions

**Deployment:**
- Push to main → GitHub Pages redeploys (~1 minute)
- Live at: `https://fernandomartinez-de.github.io/trips/{trip-name}/`

---

## Current Trips

### Japan · November 2026

**Folder:** `travel/japan/`  
**Live site:** `https://fernandomartinez-de.github.io/trips/japan/`

**Files:**
- `index.html` - Complete trip site
- `schema.sql` - Supabase DDL + RLS policies + Realtime + seed data
- `assets/img/` - Inspiration photos + hero portrait

**Database:**
- Project: `trips` (Supabase)
- Tables: `japan_*` prefixed
- Storage bucket: `japan-images`

---

## Workflow: Adding a New Trip

### 1. Duplicate Existing Trip

```bash
cd travel
cp -r japan/ italy/
```

### 2. Edit `index.html`

**Update:**
- `ITINERARY` array (dates, cities, coordinates, activities)
- Hero copy and page title
- Supabase table prefixes (change `japan_*` to `italy_*`)

**Or create new Supabase project:**
- Update project URL + publishable key at top of HTML

### 3. Set Up Database

**If using same Supabase project:**
- Add `italy_*` prefixed tables following `japan/schema.sql` pattern
- Each trip gets its own set of tables

**If using separate project:**
- Create new Supabase project
- Run trip's `schema.sql` in SQL Editor

### 4. Update Landing Page

**Add to root `index.html`:**
- Card for new trip

**Add to `travel/README.md`:**
- Bullet under "Trips" list

### 5. Deploy

```bash
git add .
git commit -m "Add Italy trip"
git push
```

GitHub Pages redeploys automatically in ~1 minute.

---

## Data Structure

### Itinerary Format

```javascript
const ITINERARY = [
  {
    date: '2026-11-15',
    city: 'Tokyo',
    lat: 35.6762,
    lng: 139.6503,
    activities: [
      { time: '09:00', description: 'Arrive at Narita Airport' },
      { time: '12:00', description: 'Check into hotel in Shibuya' },
      { time: '15:00', description: 'Explore Meiji Shrine' }
    ]
  }
];
```

### Supabase Tables

**{trip}_activities** (collaborative activity planning)
- `id` (uuid, PK)
- `day_date` (date)
- `time` (text)
- `description` (text)
- `votes` (jsonb, {user_id: vote_count})
- `created_by` (text)
- `created_at` (timestamptz)

**{trip}_day_headers** (day section titles)
- `id` (uuid, PK)
- `day_date` (date, unique)
- `header_text` (text)
- `created_at` (timestamptz)

**{trip}_glance** (quick trip summary)
- `id` (uuid, PK)
- `field` (text, unique) - "dates", "travelers", "budget"
- `value` (text)
- `updated_at` (timestamptz)

**{trip}_inspiration** (photo collection)
- `id` (uuid, PK)
- `image_url` (text)
- `caption` (text)
- `uploaded_by` (text)
- `created_at` (timestamptz)

**Row Level Security:**
- Anonymous publishable key can read + write all tables
- Policies defined in `schema.sql`
- No authentication required

---

## Local Development

### Run Locally

**Option 1: Double-click**
```
Open japan/index.html in browser (file:///)
```

**Caveat:**
- Google Places autocomplete won't work (API key is HTTP-referrer restricted)
- Supabase and Realtime work fine from file://

**Option 2: Local server**
```bash
cd travel/japan
python -m http.server
# Visit http://localhost:8000
```

This enables Google Places autocomplete for testing.

### No Build Step

There is no build process. Edit HTML directly and refresh browser.

---

## GitHub Pages Configuration

**Already configured:**
- Settings → Pages → Deploy from a branch
- Branch: `main`
- Root: `/ (root)`

**Live URLs:**
- Landing page: `https://fernandomartinez-de.github.io/trips/`
- Japan direct: `https://fernandomartinez-de.github.io/trips/japan/`

---

## Supabase Configuration

**Project:** `trips`

**Access:**
- Anonymous publishable key embedded in each trip's `index.html`
- Row Level Security gates access (not the key itself)

**Storage:**
- Bucket: `{trip-name}-images` (e.g. `japan-images`)
- For uploaded inspiration photos

**Schema Management:**
```sql
-- Load or refresh schema
-- Paste trip's schema.sql into Supabase SQL Editor and Run
-- Script is idempotent (safe to re-run)
```

---

## Family Collaboration

**How it works:**

1. **No login required**
   - Every family member opens same URL
   - Anonymous access via Supabase publishable key

2. **Name selection**
   - Each person picks name once via "Poner nombre" button
   - Stored in localStorage

3. **Real-time updates**
   - Activity edits, votes, day headers, trip glance, inspiration photos
   - All save to Supabase
   - Supabase Realtime pushes changes to all browsers (~1 second)

4. **Offline capability**
   - localStorage caches state
   - UI is instant
   - Works offline for reads

---

## Dependencies

**CDN (no installation):**
- Tailwind CSS
- Supabase JS SDK
- Google Maps JavaScript API (keyed, HTTP-referrer restricted)

**External Services:**
- Supabase (database + realtime + storage)
- GitHub Pages (hosting)

**No build tools:**
- No npm, no bundler, no transpilation
- Pure HTML + JavaScript

---

## Secrets

**Embedded in HTML (public):**
- Supabase project URL
- Supabase anonymous publishable key
- Google Maps API key (referrer-restricted)

**Not secrets (by design):**
- Publishable key is meant to be public
- Security enforced by Row Level Security policies, not by hiding the key

---

## Failure Modes

**Google Places autocomplete not working:**
- API key is HTTP-referrer restricted
- Won't work from `file:///` URLs
- Solution: Use local HTTP server or test on deployed URL

**Supabase connection issues:**
- Check project URL and publishable key in HTML
- Verify Supabase project is not paused (free tier pauses after inactivity)

**Photos not uploading:**
- Check storage bucket exists
- Verify RLS policies allow anonymous writes
- Check browser console for errors

**Changes not syncing:**
- Supabase Realtime requires websocket connection
- Check browser network tab for websocket errors
- Verify Realtime is enabled on tables (in schema.sql)

---

## Vault Cross-References

**Domain knowledge:**
- [[life-admin/travel]] - Travel planning and packing notes
- [[family/mom]] - Family contacts for trip coordination
- [[identity/visas]] - Visa requirements for international trips

**Related workflows:**
- No automation workflows (static sites, manual editing)

**Quick references:**
- [[quick-ref/key-dates]] - Trip departure dates

---

## Future Enhancements

1. **Flight tracking:** Integrate flight status APIs
2. **Budget tracking:** Add expense tracking per trip
3. **Weather forecast:** Embed weather widget for trip dates
4. **Translation mode:** Spanish/English toggle for family members
5. **Mobile app:** Progressive Web App wrapper for offline use
6. **Print itinerary:** Generate printable PDF from trip data
7. **Past trips archive:** Section for completed trips with photos
