# ⚙️ Environment Setup

## Environment Variables

### Erforderlich für Betrieb:

```bash
# Supabase Credentials
SUPABASE_URL=https://porfficpmtayqccmpsrw.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...  # Siehe .env.example

# Save Data Integrity (KRITISCH!)
BKTD_HMAC_SECRET=<64_zeichen_random_string>
```

### HMAC Secret generieren:

**Windows PowerShell**:
```powershell
-Join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | % {[char]$_})
```

**Linux/Mac**:
```bash
openssl rand -hex 32
```

---

## Deployment Variables

### Netlify/Vercel:

1. Dashboard → Environment Variables
2. Füge alle 3 Variablen hinzu
3. Redeploy Site

**Wichtig**: Keine Leerzeichen um `=` Zeichen!

---

## Optional (Development):

```bash
# Verbose Logging aktivieren
GODOT_DEBUG=1
BEEKEEPER_DEBUG=1
```

**Produktions-Modus**: Diese deaktivieren!

---

## Verifizierung

Nach Godot-Start sollte Console zeigen:
- ✅ HMAC secret loaded (length: 64)
- ✅ Supabase credentials loaded
- ✅ HTTPS verified
- ✅ SupabaseClient ready (Score: 8.8/10)

**Bei Errors**: Siehe `GETTING_STARTED.md` Troubleshooting
