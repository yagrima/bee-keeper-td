# 🚨 WICHTIG: .env Datei - Nächste Schritte

## ✅ Was wurde gemacht:

1. ✅ `.env.example` wurde auf die aktuelle Supabase-Version aktualisiert
2. ✅ `.env` Datei wurde erstellt mit deinen Supabase-Credentials

## 🔴 Was DU JETZT tun musst:

### **Schritt 1: HMAC Secret generieren** 🔴 **KRITISCH!**

Die `.env` Datei enthält noch einen Platzhalter für `BKTD_HMAC_SECRET`. Du **MUSST** diesen jetzt generieren!

#### **Windows PowerShell** (Empfohlen):
```powershell
# Öffne PowerShell und führe aus:
-Join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | % {[char]$_})
```

Das generiert einen 64-Zeichen zufälligen String. Kopiere den Output!

#### **Linux/Mac Terminal**:
```bash
openssl rand -hex 32
```

Das generiert einen 64-Zeichen Hex-String. Kopiere den Output!

#### **Online** (nur für Development):
- Gehe zu: https://www.random.org/strings/
- Settings: 64 characters, alphanumeric
- Generate und kopiere

### **Schritt 2: .env Datei bearbeiten**

1. Öffne die Datei: `bee-keeper-td/.env`
2. Suche die Zeile:
   ```
   BKTD_HMAC_SECRET=GENERATE_ME_WITH_OPENSSL_RAND_HEX_32_BEFORE_FIRST_START
   ```
3. Ersetze den Platzhalter mit deinem generierten Secret:
   ```
   BKTD_HMAC_SECRET=dein_64_zeichen_langer_zufaelliger_string_hier
   ```
4. **Speichern!**

### **Schritt 3: Godot Editor NEU STARTEN** 🔴 **WICHTIG!**

Environment-Variablen werden nur beim Start geladen!

1. Schließe Godot Editor komplett
2. Öffne Godot Editor neu
3. Öffne das BeeKeeperTD Projekt

### **Schritt 4: Verifizierung**

Nach dem Start solltest du in der **Godot Console** folgendes sehen:

```
✅ HMAC secret loaded from environment (length: 64)
✅ Supabase credentials loaded (URL: https://porfficpmtayqccmps...)
✅ HTTPS verified
✅ SupabaseClient ready (Security Score: 8.8/10)
```

#### **Wenn du ERRORS siehst:**

##### ❌ "CRITICAL: HMAC_SECRET not set!"
→ `.env` Datei wurde nicht gefunden oder BKTD_HMAC_SECRET ist noch der Platzhalter
→ Lösung: Siehe Schritt 1-3 nochmal

##### ❌ "CRITICAL: Supabase credentials not configured!"
→ Environment-Variablen wurden nicht geladen
→ Lösung: Godot neu starten, .env Datei im richtigen Verzeichnis?

##### ⚠️ "Using development HMAC secret"
→ Du bist im Debug-Modus, ist OK für Development
→ Für Production: Echten Secret setzen!

---

## 📋 Vollständige Checklist

- [ ] **HMAC Secret generiert** (PowerShell/Terminal)
- [ ] **.env Datei bearbeitet** (Platzhalter ersetzt)
- [ ] **Godot Editor neu gestartet**
- [ ] **Console-Output verifiziert** (alle ✅ grün)
- [ ] **Projekt funktioniert** (Teststart ohne Errors)

---

## 🎮 Nach erfolgreichem Setup

Wenn alle ✅ grün sind, kannst du:

1. **Projekt testen**: Starte das Spiel im Godot Editor
2. **Auth testen**: Registrierung/Login sollte funktionieren
3. **Save/Load testen**: Spielstand speichern/laden
4. **Web Build erstellen**: Für Deployment vorbereiten

---

## 🚀 Deployment (Später)

Wenn du bereit für Production bist:

### **Netlify**:
1. Dashboard → Site Settings → Environment Variables
2. Füge hinzu:
   - `SUPABASE_URL` = `https://porfficpmtayqccmpsrw.supabase.co`
   - `SUPABASE_ANON_KEY` = (dein Key aus .env)
   - `BKTD_HMAC_SECRET` = (dein generierter Secret aus .env)
3. Redeploy

### **Vercel**:
Gleiche 3 Variables in Vercel Dashboard → Settings → Environment Variables

---

## ⚠️ WICHTIGE SICHERHEITSHINWEISE

### **NIEMALS:**
- ❌ .env Datei in Git committen (ist bereits in .gitignore)
- ❌ HMAC Secret nach ersten Saves ändern (Checksum-Fehler!)
- ❌ Secrets in Code hardcoden
- ❌ Secrets in Screenshots/Logs teilen

### **IMMER:**
- ✅ .env Datei lokal halten
- ✅ Für Deployment: Environment Variables im Dashboard setzen
- ✅ HMAC Secret sicher speichern (Password Manager)
- ✅ Bei Team-Arbeit: Jeder generiert eigenen Development-Secret

---

## 📞 Bei Problemen

1. **Prüfe Console-Output** (Godot Editor → Output Tab)
2. **Prüfe .env Datei**:
   - Liegt sie im richtigen Verzeichnis? (`bee-keeper-td/.env`)
   - Ist BKTD_HMAC_SECRET gesetzt? (nicht mehr der Platzhalter)
   - Keine Leerzeichen um `=` Zeichen?
3. **Godot neu gestartet?** (Kritisch für Environment Variables!)
4. **Siehe Dokumentation**:
   - `QUICKSTART_SECURITY.md` - Quick Start
   - `SECURITY_FIXES.md` - Details zu Fixes
   - `PROJECT_STATUS_AND_ROADMAP.md` - Gesamtübersicht

---

## 🎯 Status

- [x] ✅ `.env.example` aktualisiert (Supabase Credentials)
- [x] ✅ `.env` Datei erstellt
- [ ] 🔴 **BKTD_HMAC_SECRET generieren** ← **DU BIST HIER!**
- [ ] 🔴 **Godot neu starten**
- [ ] 🔴 **Verifizierung**

---

**Nächster Schritt**: HMAC Secret generieren und in `.env` einfügen! 🚀
