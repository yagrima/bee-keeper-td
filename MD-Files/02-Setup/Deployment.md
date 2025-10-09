# 🚀 Deployment Guide

## Pre-Deployment Checklist

- [x] Alle Security-Fixes implementiert
- [x] Environment Variables konfiguriert
- [x] `.env` Datei erstellt (lokal)
- [x] DEBUG_ENABLED = false in Code
- [x] Tests laufen durch
- [ ] **Environment Variables in Deployment-Platform**
- [ ] **Web Build erstellt**

---

## Netlify Deployment

### 1. Godot Web Export

```bash
# In Godot:
Project → Export → Web
Export Path: builds/web/index.html
```

### 2. Netlify Setup

```bash
# CLI (optional)
npm install -g netlify-cli
netlify login
netlify init
```

### 3. Environment Variables

Dashboard → Site Settings → Environment Variables:

```
SUPABASE_URL = https://porfficpmtayqccmpsrw.supabase.co
SUPABASE_ANON_KEY = <dein_anon_key>
BKTD_HMAC_SECRET = <dein_hmac_secret>
```

### 4. Deploy

```bash
netlify deploy --prod --dir=builds/web
```

---

## Vercel Deployment

### 1. Vercel Setup

```bash
npm i -g vercel
vercel login
vercel
```

### 2. Environment Variables

Dashboard → Settings → Environment Variables (gleiche wie Netlify)

### 3. Deploy

```bash
vercel --prod
```

---

## Post-Deployment Verification

### CSP Headers testen:

```bash
curl -I https://your-domain.com
# Sollte enthalten:
# Content-Security-Policy: ...
# Strict-Transport-Security: ...
```

### Funktionstest:

1. Website öffnen
2. Registrierung testen
3. Login testen
4. Spiel starten
5. Save/Load testen

---

## Config Files

- `netlify.toml` - Netlify Config (bereits erstellt)
- `vercel.json` - Vercel Config (bereits erstellt)

**Location**: Root-Verzeichnis

---

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| CSP blockiert Scripts | `netlify.toml` prüfen: `wasm-unsafe-eval` vorhanden? |
| 401 Unauthorized | Environment Variables gesetzt? |
| CORS Error | Supabase Dashboard → CORS Settings prüfen |
| White Screen | Browser Console für Errors prüfen |

**Siehe**: `../security/SECURITY_OVERVIEW.md` für Security-Details
