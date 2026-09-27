# Secrets & Configuration

This document lists all the secrets and API keys embedded in the trips HTML files. These are **intentionally public** (by design) but you'll need to update them if you fork this repo or create new trips.

## Overview

The trips workflow uses:
1. **Supabase** - Database + real-time collaboration backend
2. **Google Maps JavaScript API** - Maps rendering and Places autocomplete

Both services have free tiers sufficient for family trip planning.

---

## Current Configuration (Japan Trip)

### Supabase

**Project:** `trips`  
**Project URL:** `https://hmeenrnlbdzqhbdbsxjf.supabase.co`  
**Publishable (Anonymous) Key:** `sb_publishable_n0GbcnDhojPMzKOVAGDp3Q_tSrLYnlX`

**Where used:**
- `japan/index.html` (lines ~568-569)

**Security model:**
- The publishable key is **meant to be public** and embedded in client-side code
- Security is enforced by Row Level Security (RLS) policies in Supabase
- RLS policies are defined in `japan/schema.sql`
- Anonymous users can read/write only the `japan_*` tables

**Database tables:**
- `japan_activities` - Collaborative activity planning
- `japan_day_headers` - Day section titles
- `japan_glance` - Quick trip summary fields
- `japan_inspiration` - Photo gallery
- `japan_geocache` - Cached geocoding results

**Storage bucket:**
- `japan-images` - For uploaded inspiration photos

### Google Maps JavaScript API

**API Key:** `AIzaSyCzVi_vQMDVzkzivFo010pRSu1NoRC41Aw`

**Where used:**
- `japan/index.html` (line ~564)

**Restrictions:**
- HTTP referrer restricted to: `fernandomartinez-de.github.io/*`
- This is why autocomplete doesn't work from `file://` URLs in local development
- To test locally: use `python -m http.server` or update the referrer restrictions

**APIs enabled:**
- Maps JavaScript API
- Places API (for autocomplete)

---

## Setting Up Your Own (For New Users)

If you're forking this repo or creating your own trips site, follow these steps:

### 1. Set Up Supabase

1. **Create a free account:** https://supabase.com/dashboard
2. **Create a new project:**
   - Name: `trips` (or whatever you prefer)
   - Database password: save this somewhere secure
   - Region: choose closest to your family
3. **Get your credentials:**
   - Project Settings → API → Project URL
   - Project Settings → API → `anon` `public` key (this is the publishable key)
4. **Load the schema:**
   - SQL Editor → New query
   - Copy contents of `japan/schema.sql`
   - Replace `japan_` prefix with your trip name if creating a new trip
   - Click Run
5. **Create storage bucket (if using photo uploads):**
   - Storage → Create bucket
   - Name: `{trip-name}-images` (e.g., `japan-images`)
   - Public bucket: Yes
   - RLS policies: Allow all operations (or configure as needed)

### 2. Set Up Google Maps API

1. **Create a Google Cloud project:** https://console.cloud.google.com
2. **Enable APIs:**
   - APIs & Services → Enable APIs and Services
   - Search for "Maps JavaScript API" → Enable
   - Search for "Places API" → Enable
3. **Create API key:**
   - APIs & Services → Credentials → Create Credentials → API Key
   - Copy the key
4. **Restrict the key (recommended):**
   - Click on your new key → Application restrictions
   - Select "HTTP referrers (web sites)"
   - Add your GitHub Pages URL: `your-username.github.io/*`
   - API restrictions → Restrict key
   - Select: Maps JavaScript API, Places API
   - Save
5. **Set up billing (required but free tier is generous):**
   - Billing → Link billing account
   - Google gives $200/month free credit
   - Family trip planning typically uses < $5/month

### 3. Update Your HTML Files

For each trip's `index.html`:

**Find these lines (near the top of the `<script>` section):**
```javascript
const GOOGLE_PLACES_KEY = 'AIzaSyCzVi_vQMDVzkzivFo010pRSu1NoRC41Aw';

// Supabase (family collaboration backend)
const SUPABASE_URL = 'https://hmeenrnlbdzqhbdbsxjf.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_n0GbcnDhojPMzKOVAGDp3Q_tSrLYnlX';
```

**Replace with your own:**
```javascript
const GOOGLE_PLACES_KEY = 'YOUR_GOOGLE_API_KEY';

const SUPABASE_URL = 'https://your-project-ref.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'your-anon-public-key';
```

### 4. Update Supabase Table Prefixes (if creating new trip)

If duplicating an existing trip folder:
1. Search and replace `japan_` with `{your-trip}_` throughout the HTML
2. Do the same in the schema.sql file
3. Run the updated schema.sql in Supabase

---

## GitHub Secrets (Not Required)

**This project does NOT use GitHub Actions** so no GitHub Secrets are needed.

Deployment happens automatically via GitHub Pages when you push to the `main` branch. The HTML files already contain the embedded keys.

---

## Security Notes

### Why are these "secrets" in the HTML?

They're not actually secrets in the traditional sense:

1. **Supabase publishable key:**
   - Designed to be public
   - Cannot be used to access admin functions
   - Security enforced by Row Level Security policies
   - Similar to how Firebase/Parse/etc work

2. **Google Maps API key:**
   - HTTP referrer restricted (only works from your domain)
   - API restrictions limit to Maps + Places only
   - Can set usage quotas to prevent abuse
   - Industry standard for client-side maps

### What if someone copies my keys?

**Supabase key:**
- They can only read/write the specific tables your RLS policies allow
- For anonymous access, this is just your trip tables
- Worst case: someone trolls your trip itinerary
- Fix: Reset the key in Supabase project settings

**Google Maps key:**
- Only works from your GitHub Pages domain (referrer restriction)
- If copied, won't work on their site
- If you disable referrer restrictions and it gets abused:
  - Set usage quotas in Google Cloud Console
  - Regenerate the key

### Best Practices

1. **Enable billing alerts** in Google Cloud (set to $10 or whatever you're comfortable with)
2. **Monitor Supabase usage** in your dashboard
3. **Use separate Supabase projects** for different trip groups if you have privacy concerns
4. **Keep RLS policies strict** - only allow what's actually needed
5. **Consider separate API keys per trip** if you want granular control

---

## Rotating Keys

### Rotate Supabase Key

1. Supabase Dashboard → Project Settings → API
2. Click "Reset" next to the `anon` key
3. Copy the new key
4. Update all trip HTML files
5. Commit and push

### Rotate Google Maps Key

1. Google Cloud Console → Credentials
2. Click your key → Regenerate Key
3. Copy new key
4. Update all trip HTML files
5. Commit and push

---

## Environment Variables (Not Used)

This project doesn't use environment variables or `.env` files because:
- No build step
- No server-side code
- Pure client-side HTML/JavaScript
- Keys must be in the HTML for the browser to use them

If you want to use environment variables (e.g., for a build process), you'd need to:
1. Add a build step (e.g., Vite, Webpack)
2. Use templating to inject `import.meta.env.VITE_SUPABASE_URL` etc
3. Configure GitHub Actions to build before deploying

For now, the "no build" approach is simpler and sufficient for family trip planning.

---

## Cost Estimates

### Supabase (Free Tier)
- ✅ 500 MB database storage
- ✅ 1 GB file storage
- ✅ 2 GB bandwidth/month
- ✅ 50,000 monthly active users
- ✅ Realtime included

**Typical usage for family trip:**
- Database: < 1 MB (mostly text)
- Storage: 10-50 MB (photos)
- Bandwidth: < 100 MB/month
- Users: 2-10 family members

**Cost:** $0/month (well within free tier)

### Google Maps (Free Tier)
- $200/month free credit
- Maps loads: $7 per 1,000 loads
- Places Autocomplete: $17 per 1,000 requests

**Typical usage for family trip:**
- Map loads: 100-500/month
- Autocomplete: 50-200/month

**Cost:** $0-2/month (well within free credit)

### GitHub Pages
- ✅ Free for public repos
- ✅ 100 GB bandwidth/month
- ✅ 10 builds/hour

**Cost:** $0/month

**Total: $0/month** for typical family trip planning usage.
