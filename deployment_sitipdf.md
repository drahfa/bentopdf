# Deployment: sitipdf.drahfa.com

Self-hosted BentoPDF deployment via Cloudflare Tunnel on a Windows machine.

**Live URL:** https://sitipdf.drahfa.com

---

## Overview

- **Build mode:** Source build (Option B), not Docker
- **White-label:** `SIMPLE_MODE=true` (BentoPDF branding removed)
- **WASM modules:** Loaded from CDN (`cdn.jsdelivr.net`) — no self-hosted WASM
- **CORS proxy:** Cloudflare Worker with `sitipdf.drahfa.com` added to allowed origins
- **Tunnel:** `my-tunnel` (ID: `c74f4b47-830b-4d59-9d61-475be295f329`)
- **Local server:** Node.js static server on port 8090 with COOP/COEP headers
- **Domain routing:** `sitipdf.drahfa.com` -> `localhost:8090` via cloudflared

---

## Files Modified

### `public/robots.txt`
- Updated sitemap URL from `https://www.bentopdf.com/sitemap.xml` to `https://sitipdf.drahfa.com/sitemap.xml`

### `cloudflare/cors-proxy-worker.js` (line 25-28)
- Added `'https://sitipdf.drahfa.com'` to the `ALLOWED_ORIGINS` array (for digital signature certificate fetching)

### `C:\Users\ahmad\.cloudflared\config.yml`
- Added ingress rule: `sitipdf.drahfa.com` -> `http://localhost:8090`

### `serve-local.mjs` (new file, project root)
- Minimal Node.js static file server serving `dist/` on port 8090
- Sets required headers: `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`

---

## Build Steps

### 1. Install dependencies

```bash
npm install
```

### 2. Build (TypeScript + Vite)

On Windows, env vars via `set` in cmd don't propagate reliably with `&&`. Use separate commands:

```bash
set SITE_URL=https://sitipdf.drahfa.com
set SIMPLE_MODE=true
npx tsc && npx vite build
```

### 3. Generate i18n pages and sitemap

Env vars must be set properly. Use a PowerShell script to ensure they propagate:

```powershell
# regen.ps1
$env:SITE_URL = "https://sitipdf.drahfa.com"
$env:SIMPLE_MODE = "true"
node --max-old-space-size=3072 scripts/generate-i18n-pages.mjs
node scripts/generate-sitemap.mjs
```

Run with:

```bash
powershell -ExecutionPolicy Bypass -File regen.ps1
```

This generates 1,612 URLs (124 pages x 13 languages) in the sitemap, all pointing to `sitipdf.drahfa.com`.

---

## Serving

### Local static server (`serve-local.mjs`)

```bash
node serve-local.mjs
```

Serves `dist/` on `http://localhost:8090` with:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`
- `Access-Control-Allow-Origin: *`

These headers are required for SharedArrayBuffer / WASM threading to work in the browser.

### Cloudflare Tunnel

DNS was already configured:

```bash
cloudflared tunnel route dns my-tunnel sitipdf.drahfa.com
# Output: sitipdf.drahfa.com is already configured to route to your tunnel
```

Start the tunnel:

```bash
cloudflared tunnel run my-tunnel
```

---

## Troubleshooting

### Port conflict
Port 8080 was already used by `rdp.drahfa.com` in the cloudflared config, so port 8090 was chosen instead.

### Multiple cloudflared connectors (502 errors)
If cloudflared is running as a Windows service with an old config, requests get load-balanced across old and new connectors. The old connector may point to a stale port (e.g., 5173), causing intermittent 502 errors.

**Fix:** Kill the old cloudflared process. If it's running as a service with elevated privileges:

```powershell
# From an admin terminal:
sc.exe stop cloudflared

# Or force-kill by PID with elevation:
Start-Process taskkill -ArgumentList '/F','/PID','<OLD_PID>' -Verb RunAs
```

### Windows env var propagation
`set VAR=value && npm run build` doesn't reliably pass env vars to Node.js child processes on Windows. Use a `.ps1` script with `$env:VAR = "value"` instead.

---

## Architecture

```
Browser
  |
  v
https://sitipdf.drahfa.com
  |
  v (Cloudflare edge)
cloudflared tunnel (my-tunnel)
  |
  v
localhost:8090 (serve-local.mjs)
  |
  v
dist/ (static files)
  |
  v (browser fetches WASM at runtime)
cdn.jsdelivr.net
  ├── @bentopdf/pymupdf-wasm
  ├── @bentopdf/gs-wasm
  └── coherentpdf
```

All PDF processing happens client-side in the browser. The server only serves static files.
