# 🚀 Getting Started - BeeKeeperTD

## Quick Setup (5 Minuten)

### 1. Environment Variables

```bash
# Kopiere Template
cp .env.example .env

# Generiere HMAC Secret (PowerShell)
-Join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | % {[char]$_})

# Füge generierten Secret in .env ein:
# BKTD_HMAC_SECRET=<dein_generierter_string>
```

### 2. Godot Editor

1. Öffne Godot 4.5
2. Öffne Projekt: `project.godot`
3. **NEU STARTEN** (Environment Variables werden beim Start geladen!)

### 3. Verifizierung

Console sollte zeigen:
```
✅ HMAC secret loaded from environment (length: 64)
✅ Supabase credentials loaded
✅ HTTPS verified
```

### 4. Testen

- Play Button → Spiel startet
- Auth testen: Registrierung/Login
- Gameplay: Türme platzieren, Wellen starten

---

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| "HMAC_SECRET not set!" | `.env` Datei erstellt? Secret generiert? |
| "Supabase credentials not configured" | Godot neu gestartet? |
| Keine Consolenausgabe | Environment-Module geladen? |

**Siehe**: `ENVIRONMENT_SETUP.md` für Details

---

## Next Steps

- [Deployment](DEPLOYMENT.md) - Netlify/Vercel Setup
- [Security](../security/SECURITY_OVERVIEW.md) - Sicherheitsfeatures
- [Features](../features/GAME_FEATURES.md) - Was ist implementiert
