# 旅 Trips

**Collaborative family travel planning sites** - One self-contained HTML page per trip, hosted on GitHub Pages with real-time collaboration via Supabase.

✨ **No build step** • 📱 **Mobile-first** • 🔄 **Real-time sync** • 🆓 **Free hosting**

## 🗺️ Current Trips

- **🇯🇵 Japan · November 2026** - [Local folder](./japan/) · [Live site](https://fernandomartinez-de.github.io/trips/japan/)

## 🚀 Quick Start

### For Existing Users (Updating Content)

1. **Clone this repo** (if you haven't already):
   ```bash
   git clone https://github.com/fernandomartinez-de/trips.git
   cd trips
   ```

2. **Edit trip content:**
   - Open `japan/index.html` in your text editor
   - Update the `ITINERARY` array with your dates, cities, activities
   - Modify hero text, photos, or any content

3. **Push changes:**
   ```bash
   git add .
   git commit -m "Update Japan itinerary"
   git push
   ```

4. **Wait ~1 minute** - GitHub Pages redeploys automatically

### For New Users (Setting Up From Scratch)

See **[SETUP.md](./SETUP.md)** for complete first-time setup including:
- Installing Git
- Creating GitHub repository
- Enabling GitHub Pages
- Configuring Supabase
- Setting up Google Maps API

## 📚 Documentation

- **[SETUP.md](./SETUP.md)** - First-time setup walkthrough (Git, GitHub, Supabase, Google Maps)
- **[SECRETS.md](./SECRETS.md)** - API keys, configuration, and how to set up your own
- **[docs/travel-automation.md](./docs/travel-automation.md)** - Architecture and workflow documentation
- **[docs/scripts.md](./docs/scripts.md)** - Technical details (JavaScript modules, no build process)
- **[docs/supabase-tables.md](./docs/supabase-tables.md)** - Database schema documentation

## ✨ Features

### Real-time Collaboration
- Multiple family members can edit simultaneously
- Changes sync across all browsers in ~1 second
- No login required - just pick a name once
- Works on mobile and desktop

### Activity Planning
- Drag-drop activities
- Vote on activities (👍/👎)
- Time-based scheduling
- Day-by-day organization

### Interactive Map
- See your entire itinerary on one map
- Cities and activities plotted
- Hover for details

### Inspiration Gallery
- Collect photos that inspire your trip
- Upload from family members
- Captions and credits

### Offline-Friendly
- LocalStorage caching
- Works without internet (read-only)
- Fast loading

## 🛠️ How to Add a New Trip

1. Duplicate an existing trip folder (e.g. `japan/`) and rename it after the new destination (e.g. `italy/`, `hawaii/`).
2. Edit `index.html` in the new folder: update the `ITINERARY` array with dates, cities, coordinates, and activities. Update the hero copy and page title.
3. If the new trip needs its own database, either add `italy_*`-prefixed tables to the same Supabase project (following the pattern in `japan/schema.sql`), or spin up a separate Supabase project and update the URL + publishable key at the top of the new trip's `index.html`.
4. Add a bullet to the "Trips" list in this README, and add a card for it in the root `index.html`.
5. `git add .`, `git commit -m "Add [trip name] trip"`, `git push`. GitHub Pages redeploys automatically in about a minute.

## How it works

Each trip lives in its own subfolder with a single self-contained `index.html`. The site is a plain static page that pulls in Tailwind (CDN), the Supabase JS SDK (CDN), and Google Maps JS (CDN, keyed). Images live as regular files under each trip's `assets/img/` folder rather than being embedded, so they cache well and the HTML stays small.

Collaboration works through Supabase:

- Every family member opens the same URL. No login. Each person picks their own name once via the "Poner nombre" button.
- Activity edits, votes, day headers, trip glance, and inspiration photos all save to Supabase.
- Supabase Realtime pushes those changes back to everyone else's browser within about a second, so the site feels live.
- Row Level Security policies (all in `japan/schema.sql`) enforce that the anonymous publishable key can read and write only these specific tables.
- localStorage caches state locally so the UI is instant and works offline for reads.

### Keeping the database awake

The Supabase project is on the free plan, which pauses after about a week with no traffic. When paused, the page still loads but every list comes back empty. `.github/workflows/keepalive.yml` pings the database every 3 days to prevent that. If the page ever looks empty anyway, restore the project from the Supabase dashboard (all data is kept) and run the keepalive workflow once from the Actions tab. GitHub disables scheduled workflows after 60 days without commits, so rerun it manually if the repo sits untouched that long.

## 📁 Repository Structure

```
trips/
├── README.md                   this file
├── SETUP.md                    one-time setup guide (Git, GitHub Pages, Supabase)
├── SECRETS.md                  API keys and configuration documentation
├── .gitignore                  git ignore rules
├── .github/workflows/
│   └── keepalive.yml          pings Supabase every 3 days so it never pauses
├── index.html                  landing page listing all trips
│
├── docs/                       workflow documentation (from vault)
│   ├── travel-automation.md   architecture and deployment
│   ├── scripts.md             technical implementation details
│   └── supabase-tables.md     database schema reference
│
└── japan/                      example trip (November 2026)
    ├── index.html             complete trip site (~110 KB)
    ├── schema.sql             Supabase DDL + RLS + Realtime + seed data
    └── assets/
        └── img/               inspiration photos + hero portrait (14 images, ~1.5 MB)
```

## Local development

Open `japan/index.html` directly in a browser. There is no build step.

Two caveats when running locally by double-clicking the file (`file:///...`):

- Google Places autocomplete will not work: the API key is HTTP-referrer restricted and does not match `file://`. To test autocomplete, either serve the folder from a local HTTP server (e.g. `python -m http.server` from the trip folder, then visit `http://localhost:8000`) or just test against the deployed URL.
- Supabase and Realtime work fine from `file://` (no referrer restriction).

## 🔧 Technology Stack

### Frontend
- **Pure HTML/CSS/JavaScript** - No build process, no npm, no bundlers
- **Tailwind CSS** (CDN) - Utility-first styling
- **Google Fonts** - Noto Sans, Noto Serif JP, Noto Sans JP
- **Google Maps JavaScript API** - Map rendering and Places autocomplete

### Backend
- **Supabase** - PostgreSQL database with real-time subscriptions
- **Supabase Storage** - Image hosting for inspiration photos
- **Row Level Security** - Anonymous access with proper permissions

### Hosting
- **GitHub Pages** - Free static hosting
- **GitHub Actions** - Not used (deployment is automatic via Pages)

### Browser Storage
- **localStorage** - Offline caching and user name persistence
- **No cookies** - No authentication required

## 🌐 Deployment

### GitHub Pages Configuration

**Repository Settings:**
- Settings → Pages → Deploy from a branch
- Branch: `main`
- Folder: `/ (root)`

**Live URLs:**
- Landing page: `https://fernandomartinez-de.github.io/trips/`
- Japan trip: `https://fernandomartinez-de.github.io/trips/japan/`

**Deployment:**
- Push to `main` → Automatic deployment in ~1-2 minutes
- No GitHub Actions workflow required
- No build step needed

### Supabase Configuration

**Project:** `trips`  
**Dashboard:** https://supabase.com/dashboard/project/hmeenrnlbdzqhbdbsxjf

**Configuration:**
- Anonymous publishable key embedded in HTML (by design)
- Row Level Security policies enforce access control
- Database tables: `japan_*` prefix per trip
- Storage bucket: `japan-images` for photos

**Schema Management:**
```bash
# Load schema
# 1. Open https://supabase.com/dashboard/project/hmeenrnlbdzqhbdbsxjf
# 2. SQL Editor → New query
# 3. Copy-paste contents of japan/schema.sql
# 4. Run (Ctrl+Enter)
```

**Idempotent:** Safe to re-run schema.sql anytime to reset or update tables.

## 🔐 Secrets & API Keys

**See [SECRETS.md](./SECRETS.md) for:**
- Current Supabase credentials
- Google Maps API key
- How to set up your own
- Security model and best practices
- Cost estimates (spoiler: $0/month)

**Quick reference:**
- Supabase URL: `https://hmeenrnlbdzqhbdbsxjf.supabase.co`
- Supabase key: Embedded in `japan/index.html` (line ~569)
- Google Maps key: Embedded in `japan/index.html` (line ~564)

## 🐛 Troubleshooting

### Google Places autocomplete not working locally

**Problem:** Autocomplete doesn't work when opening `file:///` URLs  
**Cause:** Google Maps API key is HTTP-referrer restricted  
**Solution:** Use local HTTP server:

```bash
cd japan
python -m http.server 8000
# Open http://localhost:8000
```

Or test on the deployed GitHub Pages URL.

### Changes not syncing between browsers

**Check:**
1. Browser console for Supabase connection errors
2. Supabase project is not paused (free tier pauses after inactivity)
3. Network tab shows websocket connection
4. RLS policies allow anonymous access (in schema.sql)

**Fix:**
```bash
# Re-run schema.sql in Supabase SQL Editor
# Verify Realtime is enabled on tables
```

### Photos not uploading

**Check:**
1. Storage bucket exists (`japan-images` in Supabase)
2. RLS policies on bucket allow anonymous writes
3. Browser console for upload errors

### GitHub Pages not updating

**Wait:** Deployment takes 1-2 minutes  
**Check:** Actions tab in GitHub repo for build status  
**Hard refresh:** Ctrl+F5 (Windows) or Cmd+Shift+R (Mac) to bypass cache  
**Verify:** Check the commit hash in the footer of the live site

### Map not showing pins

**Expected:** Empty map until activities have locations filled in  
**User action:** Add "Ubicación" values in the itinerary editor  
**Auto-populate:** Use the Places autocomplete in the activity editor

## 💰 Cost

**Everything is free:**
- ✅ GitHub Pages - Free for public repos
- ✅ Supabase - Free tier (500 MB DB, 1 GB storage, realtime included)
- ✅ Google Maps - $200/month free credit (typical usage: $0-2/month)

**Total: $0/month** for typical family trip planning.

See [SECRETS.md](./SECRETS.md) for detailed cost breakdown.

## 🤝 Contributing

This is a personal/family project, but if you want to:
- Report a bug → Open an issue
- Suggest a feature → Open an issue
- Fork for your own family → Go for it! (update API keys per SECRETS.md)

## 📝 License

Personal project - no formal license. Feel free to fork and adapt for your own family trips.

## 🙏 Acknowledgments

Built with:
- [Tailwind CSS](https://tailwindcss.com/)
- [Supabase](https://supabase.com/)
- [Google Maps Platform](https://developers.google.com/maps)
- [GitHub Pages](https://pages.github.com/)

---

**Questions?** See [SETUP.md](./SETUP.md) for step-by-step setup or [SECRETS.md](./SECRETS.md) for configuration details.
