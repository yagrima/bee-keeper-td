# 🌐 Web Export Quick Start

**Status**: ✅ Web Export erstellt und Server läuft  
**URL**: http://localhost:8060  
**Port**: 8060

---

## 🚀 Server gestartet

Der lokale Webserver wurde automatisch gestartet und läuft im Hintergrund.

### Zugriff:
- **URL**: http://localhost:8060
- **Port**: 8060
- **Pfad**: `builds/web/`

---

## 🎮 BeeKeeperTD im Browser testen

1. **Browser öffnen** (sollte automatisch passiert sein)
   - Falls nicht: http://localhost:8060 manuell öffnen

2. **Warten auf Ladevorgang**
   - WASM-Datei ist ~38 MB
   - Erste Ladezeit: 10-30 Sekunden (je nach System)

3. **Testen**
   - Registrierung/Login
   - Tower Placement (Q/W/E/R Hotkeys)
   - Wave Management
   - Save/Load System

---

## 🛠️ Server-Befehle

### Server neu starten:
```bash
# Stoppe aktuellen Server (Ctrl+C im Server-Fenster)
# Dann ausführen:
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td\builds\web"
python -m http.server 8060
```

### Oder Batch-Datei verwenden:
```bash
# Doppelklick auf:
builds/web/start_server.bat
```

### Server stoppen:
- **Ctrl+C** im Server-Fenster drücken
- Oder Fenster schließen

---

## 🔍 Debugging

### Browser Console öffnen:
- **Chrome/Edge**: F12 oder Rechtsklick → "Inspect"
- **Firefox**: F12 oder Rechtsklick → "Element untersuchen"
- **Safari**: Cmd+Option+I (Mac)

### Nützliche Console-Befehle:
```javascript
// Check if game is loaded
console.log("Game loaded:", window.Engine !== undefined);

// Check Godot version
console.log("Godot:", window.Engine?.version);

// Monitor errors
window.addEventListener('error', (e) => console.error('Error:', e));
```

### Godot Console Output:
- Alle `print()` Statements erscheinen in der Browser Console
- Errors sind rot markiert
- Warnings sind gelb

---

## ⚙️ Environment Variables für Web

### Wichtig für Cloud-Features:
Die `.env` Datei funktioniert **nicht** im Web Export!

Stattdessen müssen Environment Variables zur Build-Zeit injiziert werden:

```javascript
// In custom HTML shell oder index.html:
<script>
    window.SUPABASE_URL = "https://porfficpmtayqccmpsrw.supabase.co";
    window.SUPABASE_ANON_KEY = "eyJhbGci...";
    window.BKTD_HMAC_SECRET = "your-secret-here";
</script>
```

**Aktuell**: Der Export verwendet Fallback-Werte aus dem Code (Development Mode)

---

## 📊 Export-Details

### Generierte Dateien:
```
builds/web/
├── index.html              # Haupt-HTML (5.4 KB)
├── index.js                # Godot Engine JS (305 KB)
├── index.wasm              # Godot Engine WASM (38 MB)
├── index.pck               # Game Assets (305 KB)
├── index.audio.worklet.js  # Audio Processing (7.3 KB)
└── index.*.png             # Icons
```

### Performance:
- **WASM Size**: ~38 MB
- **First Load**: 10-30 Sekunden
- **Subsequent Loads**: Cached (~instant)
- **FPS Target**: 60 FPS
- **Memory Usage**: ~100-150 MB

---

## 🚨 Bekannte Probleme & Lösungen

### Problem: "Failed to load .wasm"
**Lösung**: 
- Server neu starten
- Browser-Cache leeren (Ctrl+Shift+Delete)
- Prüfe ob Port 8060 frei ist

### Problem: "SharedArrayBuffer not defined"
**Lösung**: 
- Cross-Origin-Isolation Headers benötigt
- Für Deployment: netlify.toml oder vercel.json konfigurieren
- Local: Python Server ist OK

### Problem: Slow Loading
**Lösung**: 
- WASM ist groß (38 MB)
- Normal für erste Ladezeit
- Browser cached danach

### Problem: Audio nicht funktioniert
**Lösung**: 
- Browser benötigt User-Interaction für Audio
- Klicke einmal auf die Seite
- Audio.worklet.js sollte geladen werden

### Problem: Supabase Connection Error
**Lösung**: 
- Prüfe Browser Console
- Environment Variables müssen injiziert werden
- Fallback-Credentials sollten funktionieren (Development)

---

## 🔄 Web Export neu erstellen

### Via Godot Editor:
1. Öffne Godot Editor
2. Project → Export
3. Web → Export Project
4. Ziel: `builds/web/index.html`

### Via Command Line:
```bash
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td"
& "G:\My Drive\KI-Dev\Godot_v4.5-stable_win64.exe" --headless --export-release "Web" "builds/web/index.html"
```

**Dauer**: ~30-60 Sekunden

---

## 📱 Mobile Testing

### Im Browser:
1. Öffne http://localhost:8060 auf Smartphone
   - Computer und Smartphone müssen im gleichen Netzwerk sein
   - Verwende Computer-IP statt localhost: http://192.168.x.x:8060

2. Oder nutze ngrok für öffentlichen Zugriff:
```bash
ngrok http 8060
```

### Touch-Controls:
- Touch-Input wird automatisch erkannt
- UI sollte responsiv sein
- Test mit verschiedenen Screen-Größen

---

## 🚀 Production Deployment

### Für Netlify:
```bash
# 1. Erstelle Production Build
godot --headless --export-release "Web" "builds/web/index.html"

# 2. Deploy zu Netlify
# - Drag & Drop builds/web/ Ordner zu Netlify
# - Oder: netlify deploy --prod --dir=builds/web
```

### Für Vercel:
```bash
# 1. Erstelle vercel.json (bereits vorhanden)
# 2. Deploy
vercel --prod
```

### Environment Variables setzen:
- Netlify/Vercel Dashboard → Environment Variables
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `BKTD_HMAC_SECRET`
- JavaScript injection in HTML template

**Siehe**: [Deployment.md](Deployment.md) für Details

---

## 🎯 Testing Checklist

Teste folgende Features im Browser:

### Auth & Account:
- [ ] Registrierung (neuer User)
- [ ] Login (bestehender User)
- [ ] Logout
- [ ] Session Persistence (Browser neu laden)

### Gameplay:
- [ ] Tower Placement (Klick + Drag)
- [ ] Hotkeys (Q/W/E/R)
- [ ] Tower Toggle (gleiche Taste zweimal)
- [ ] Wave Start
- [ ] Speed Control (1x, 2x, 3x)

### Save System:
- [ ] Auto-Save
- [ ] Manual Save
- [ ] Cloud Save (wenn authentifiziert)
- [ ] Load Game

### Performance:
- [ ] 60 FPS @ 1x Speed
- [ ] ~30-45 FPS @ 3x Speed
- [ ] Kein Memory Leak (längeres Spielen)

### Browser Compatibility:
- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari (Mac/iOS)

---

## 📞 Troubleshooting

### Server läuft nicht:
```bash
# Prüfe ob Port 8060 belegt ist
netstat -ano | findstr :8060

# Kill Process falls nötig
taskkill /PID <PID> /F

# Server neu starten
start_server.bat
```

### Browser zeigt weiße Seite:
1. Browser Console öffnen (F12)
2. Errors prüfen
3. Network Tab prüfen (alle Dateien geladen?)
4. Browser-Cache leeren

### Performance-Probleme:
1. Browser-Hardware-Acceleration aktiviert?
2. Andere Tabs schließen
3. FPS-Counter im Game prüfen
4. Console auf Warnings prüfen

---

## 📚 Verwandte Dokumente

- [Deployment.md](Deployment.md) - Production Deployment
- [Getting_Started.md](Getting_Started.md) - Development Setup
- [Web_Build.md](Web_Build.md) - Web Export Konfiguration

---

**Server Status**: ✅ Running  
**URL**: http://localhost:8060  
**Erstellt**: 2025-01-12  
**Build Size**: ~38.5 MB
