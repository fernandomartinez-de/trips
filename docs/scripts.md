---
tags: [travel, javascript, html, no-build]
category: travel
last_updated: 2026-09-13
---

# Travel Scripts

**No Python scripts** - Travel planning sites are pure HTML + JavaScript.

**Location:** `C:\Users\fmartine\Personal\repos\personal\travel\`

---

## Architecture: No Scripts, No Build

Travel workflows use **self-contained HTML files** with embedded JavaScript. No separate Python scripts, no build step, no server.

**Why this approach:**
- **Simplicity:** One HTML file = complete trip site
- **Portability:** Can be opened offline, emailed, or served anywhere
- **No dependencies:** No npm install, no pip install, no build process
- **GitHub Pages ready:** Push to main → live site in ~1 minute

**Everything runs in the browser:**
- UI rendering (HTML + Tailwind CSS via CDN)
- Database access (Supabase JS SDK via CDN)
- Real-time sync (Supabase Realtime websockets)
- Maps (Google Maps JS API via CDN)

---

## Trip Site Structure

### index.html

**Location:** `travel/{trip-name}/index.html`

**Example:** `travel/japan/index.html`

**Complete single-file application containing:**

1. **HTML structure**
   - Hero section
   - Trip glance (dates, travelers, budget)
   - Day-by-day itinerary
   - Activity voting interface
   - Inspiration photo gallery

2. **Embedded CSS**
   - Tailwind CSS (loaded from CDN)
   - Custom styles in `<style>` block

3. **Embedded JavaScript**
   - Supabase client initialization
   - CRUD operations for activities, votes, photos
   - Real-time subscription setup
   - localStorage for offline caching
   - Google Maps integration

**File size:** ~100-200 KB per trip

**No external JS files** - everything embedded for portability

---

## JavaScript Modules (Embedded)

### Supabase Client Setup

```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-publishable-key';

const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

**Configuration:**
- Project URL and publishable key embedded
- Anonymous access (no user authentication)
- Row Level Security enforces permissions

### Activity Management

**Functions in index.html:**
- `loadActivities()` - Fetch activities from Supabase
- `addActivity(dayDate, time, description)` - INSERT new activity
- `voteActivity(activityId, userName, vote)` - UPDATE votes JSONB
- `deleteActivity(activityId)` - DELETE activity

**Example CRUD:**
```javascript
// Add activity
async function addActivity(dayDate, time, description) {
  const { data, error } = await supabase
    .from('japan_activities')
    .insert([
      { 
        day_date: dayDate, 
        time: time, 
        description: description,
        created_by: userName,
        votes: {}
      }
    ]);
  if (error) console.error('Error:', error);
  else refreshActivities();
}

// Vote on activity
async function voteActivity(activityId, userName, voteValue) {
  // Fetch current votes
  const { data } = await supabase
    .from('japan_activities')
    .select('votes')
    .eq('id', activityId)
    .single();
  
  // Update vote count
  const votes = data.votes || {};
  votes[userName] = voteValue;
  
  // Save back
  await supabase
    .from('japan_activities')
    .update({ votes })
    .eq('id', activityId);
}
```

### Real-time Subscriptions

**Live collaboration via Supabase Realtime:**

```javascript
// Subscribe to activity changes
const channel = supabase
  .channel('trip-changes')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'japan_activities' },
    (payload) => {
      console.log('Activity changed:', payload);
      refreshActivities();
    }
  )
  .subscribe();

// Subscribe to photo uploads
supabase
  .channel('photos')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'japan_inspiration' },
    (payload) => {
      addPhotoToGallery(payload.new);
    }
  )
  .subscribe();
```

**Events handled:**
- `INSERT` - New activity/photo added → Append to UI
- `UPDATE` - Vote changed → Update vote counts
- `DELETE` - Activity removed → Remove from UI

**Latency:** Typically < 1 second from DB change to all clients

### localStorage Caching

**Offline capability:**

```javascript
// Cache activities locally
function cacheActivities(activities) {
  localStorage.setItem('japan_activities', JSON.stringify(activities));
}

// Load from cache on page load
function loadCachedActivities() {
  const cached = localStorage.getItem('japan_activities');
  if (cached) {
    displayActivities(JSON.parse(cached));
    // Then fetch fresh data in background
    fetchActivities();
  } else {
    fetchActivities();
  }
}
```

**What's cached:**
- Activities list
- Day headers
- Trip glance fields
- User's selected name

**Cache invalidation:** Fresh fetch on every page load, cache updated after

### User Name Management

**Name selection (no authentication):**

```javascript
// Get user name from localStorage
let userName = localStorage.getItem('userName');

// Prompt if not set
if (!userName) {
  userName = prompt('¿Cómo te llamas? / What's your name?');
  localStorage.setItem('userName', userName);
}

// Use in all writes
const activity = {
  description: 'Visit Meiji Shrine',
  created_by: userName
};
```

**Name persistence:** Stored in localStorage, persists across sessions

---

## No Build Process

**Development workflow:**

1. **Edit** `travel/japan/index.html` directly in VS Code
2. **Test** by opening in browser (file:/// or local server)
3. **Commit** and push to GitHub
4. **Deploy** happens automatically via GitHub Pages (~1 minute)

**No compilation, no bundling, no transpilation.**

**Why this works:**
- Modern browsers support ES6+ JavaScript
- CDN libraries (Tailwind, Supabase SDK) handle heavy lifting
- File size small enough to embed everything

---

## Local Development

### Option 1: Direct File Open

```bash
# macOS/Linux
open travel/japan/index.html

# Windows
start travel/japan/index.html
```

**Caveats:**
- Google Places autocomplete won't work (API key is HTTP-referrer restricted to domain)
- Supabase and Realtime work fine from `file:///`

### Option 2: Local Server

```bash
cd travel/japan
python -m http.server 8000
# Visit http://localhost:8000
```

**Advantages:**
- Google Places autocomplete works
- Mimics production environment

**When to use:** Testing Google Maps integration

---

## CDN Dependencies

All external libraries loaded from CDN (no local copies):

### Tailwind CSS

```html
<script src="https://cdn.tailwindcss.com"></script>
```

**Purpose:** Utility-first CSS framework  
**Version:** Latest (automatically updated)

### Supabase JS SDK

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

**Purpose:** Database client + Realtime  
**Version:** v2 (latest)

### Google Maps JavaScript API

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY&libraries=places"></script>
```

**Purpose:** Maps rendering + Places autocomplete  
**API Key:** HTTP-referrer restricted to `fernandomartinez-de.github.io`

---

## Database Schema Management

### schema.sql

**Location:** `travel/{trip-name}/schema.sql`

**Example:** `travel/japan/schema.sql`

**Purpose:** Complete database setup for a trip

**Contents:**
- Table definitions (CREATE TABLE IF NOT EXISTS)
- Row Level Security policies
- Realtime publication configuration
- Seed data (optional)

**Execution:** Copy-paste into Supabase SQL Editor and run

**Idempotent:** Safe to re-run (uses IF NOT EXISTS)

**Example:**
```sql
-- Activities table
CREATE TABLE IF NOT EXISTS japan_activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  day_date date NOT NULL,
  time text,
  description text NOT NULL,
  votes jsonb DEFAULT '{}'::jsonb,
  created_by text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE japan_activities ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read/write
CREATE POLICY "Allow anonymous access" 
ON japan_activities FOR ALL 
USING (true);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE japan_activities;
```

**Not a Python script** - manually run SQL

---

## Creating a New Trip

**Step-by-step (no scripts required):**

1. **Duplicate existing trip folder**
   ```bash
   cd travel
   cp -r japan/ italy/
   ```

2. **Edit `italy/index.html`:**
   - Update `ITINERARY` array (dates, cities, coordinates)
   - Update hero copy and page title
   - Replace `japan_` table prefixes with `italy_`
   - Update Supabase bucket name (if uploading photos)

3. **Create database schema:**
   - Copy `italy/schema.sql`
   - Replace `japan_` with `italy_` throughout
   - Paste into Supabase SQL Editor
   - Run

4. **Update landing page:**
   - Edit `travel/index.html`
   - Add card for Italy trip
   - Edit `travel/README.md`
   - Add bullet under "Trips" list

5. **Deploy:**
   ```bash
   git add .
   git commit -m "Add Italy trip"
   git push
   ```

**No build, no script execution - just edit and push.**

---

## Debugging

**Browser Console:**

All errors appear in browser DevTools console.

**Common issues:**

**Supabase connection fails:**
- Check project URL and publishable key
- Verify Supabase project not paused
- Check browser console for CORS errors

**Realtime not syncing:**
- Check websocket connection in Network tab
- Verify Realtime enabled on tables (in schema.sql)
- Check Row Level Security policies

**Photos not uploading:**
- Verify storage bucket exists
- Check RLS policies on bucket
- Review browser console for upload errors

**Google Maps not loading:**
- Check API key is valid
- Verify referrer restrictions on key
- Check browser console for API errors

---

## Future Enhancements (Would Require Scripts)

**If automation needed, these would require Python scripts:**

1. **Automated trip initialization**
   - Script to duplicate folder, rename files, update table prefixes
   - Generate schema.sql from template

2. **Data export**
   - Export trip data to PDF or Excel for offline use
   - Requires querying Supabase from Python

3. **Bulk photo upload**
   - Upload folder of photos to Supabase Storage
   - Batch INSERT into inspiration table

4. **Trip archival**
   - Export completed trip data
   - Archive to Google Drive

**For now:** All manual (sufficient for ~1-2 trips per year)

---

## Related Files

**Workflow documentation:** [[travel/travel-automation]]

**Tables documentation:** [[travel/supabase-tables]]

**Live sites:**
- Landing: `https://fernandomartinez-de.github.io/trips/`
- Japan: `https://fernandomartinez-de.github.io/trips/japan/`

**No GitHub Actions:** No scheduled workflows, all triggered by git push

**No Python:** All logic in browser JavaScript
