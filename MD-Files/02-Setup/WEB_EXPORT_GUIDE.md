# 🌐 Godot Web Export Guide - BeeKeeperTD

**Datum**: 2025-01-12  
**Version**: 1.0  
**Godot Version**: 4.5 Stable  
**Status**: ✅ **Ready for Web Export**

---

## 📋 VORAUSSETZUNGEN

### **✅ Bereits erledigt:**
- ✅ Environment Variables System (EnvLoader.gd)
- ✅ CORS in Supabase konfiguriert
- ✅ SQL Anti-Cheat Triggers deployed
- ✅ Security Score 9.5/10
- ✅ Alle Tests funktionsfähig (20/20)

### **Benötigt:**
- ✅ Godot 4.5 Stable installiert
- ✅ Opera/Chrome/Firefox Browser für Testing
- ✅ Python 3 für lokalen Test-Server (optional)
- ✅ Netlify/Vercel Account für Deployment

---

## 🎯 SCHRITT 1: GODOT WEB EXPORT TEMPLATE INSTALLIEREN

### **1.1 Export Templates herunterladen**

#### **Option A: Über Godot Editor (EMPFOHLEN)**
```
1. Godot öffnen
2. Menü: Editor → Manage Export Templates
3. Button: "Download and Install"
4. Warte bis Download abgeschlossen (~500 MB)
5. Templates werden automatisch installiert
```

#### **Option B: Manuelle Installation**
```
1. Gehe zu: https://godotengine.org/download
2. Download: "Export templates" für Version 4.5 Stable
3. Entpacke in: %APPDATA%\Godot\export_templates\4.5.stable\
```

### **1.2 Verifizierung**
```
1. Godot Editor → Project → Export
2. Wenn "No export template found" erscheint:
   → Gehe zurück zu Schritt 1.1
3. Wenn "Add Export Preset" verfügbar ist:
   → ✅ Templates installiert!
```

---

## 🎯 SCHRITT 2: WEB EXPORT PRESET ERSTELLEN

### **2.1 Export Preset hinzufügen**
```
1. Godot Editor öffnen: bee-keeper-td Projekt
2. Menü: Project → Export
3. Button: "Add..."
4. Wähle: "Web"
5. Name: "Web (Production)"
```

### **2.2 Export Settings konfigurieren**

#### **Options → Resources**
```
Export Mode: Export all resources in the project
```

#### **Options → Binary Format**
```
Embed PCK: Enabled (checkmark)
```

#### **Options → Texture Format**
```
BPTC: Enabled
S3TC: Enabled
ETC: Disabled
ETC2: Disabled
```

#### **Options → HTML**
```
Custom HTML Shell: (leer lassen)
Head Include: (siehe Schritt 2.3)
Icon: res://icon.png
```

#### **Options → Progressive Web App**
```
Enabled: Disabled (für ersten Deploy)
Background Color: #1a1a1a
Display: Fullscreen
Orientation: Landscape
```

#### **Options → Vram Texture Compression**
```
For Desktop: Enabled
For Mobile: Disabled
```

### **2.3 Head Include für Environment Variables**

**Kopiere folgenden Code in "Head Include" Field:**

```html
<script>
// BeeKeeperTD - Environment Variables für Web Build
// WICHTIG: Diese müssen in Netlify/Vercel konfiguriert werden!

window.BKTD_ENV = {
    SUPABASE_URL: "%SUPABASE_URL%",
    SUPABASE_ANON_KEY: "%SUPABASE_ANON_KEY%",
    BKTD_HMAC_SECRET: "%BKTD_HMAC_SECRET%"
};

// Fallback für lokales Testen (NICHT für Production!)
if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    console.warn("[BeeKeeperTD] Running on localhost - using development environment variables");
    // ACHTUNG: Diese Werte durch deine lokalen Werte ersetzen!
    window.BKTD_ENV = {
        SUPABASE_URL: "https://porfficpmtayqccmpsrw.supabase.co",
        SUPABASE_ANON_KEY: "DEIN_ANON_KEY_HIER",
        BKTD_HMAC_SECRET: "DEIN_HMAC_SECRET_HIER"
    };
}
</script>
```

**⚠️ WICHTIG:**
- Die `%VARIABLE%` Platzhalter werden von Netlify/Vercel ersetzt
- Für lokales Testen: Ersetze die Platzhalter im `localhost` Block
- **NIEMALS** echte Secrets im Head Include committen!

### **2.4 Advanced Settings**

#### **Options → Export Mode**
```
Export Mode: Release
```

#### **Options → Debugging**
```
Remote Debug: Disabled
Export With Debug: Disabled
```

---

## 🎯 SCHRITT 3: WEB BUILD ERSTELLEN

### **3.1 Build Directory erstellen**
```bash
# Windows PowerShell
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td"
mkdir web-build
```

### **3.2 Export durchführen**
```
1. Godot Editor → Project → Export
2. Wähle Preset: "Web (Production)"
3. Button: "Export Project"
4. Zielordner: G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td\web-build\
5. Dateiname: index.html
6. Button: "Save"
```

**Erwartete Dateien im `web-build` Ordner:**
```
web-build/
├── index.html              # Main HTML file
├── index.wasm              # WebAssembly binary (~20-30 MB)
├── index.pck               # Game data package (~5-10 MB)
├── index.js                # JavaScript loader
└── index.audio.worklet.js  # Audio processing
```

### **3.3 Verifizierung**
```bash
# Prüfe ob alle Dateien vorhanden sind
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td\web-build"
ls
```

**✅ Erfolgreich wenn:**
- Alle 5 Dateien existieren
- index.wasm > 15 MB
- Keine Fehler im Godot Export Log

---

## 🎯 SCHRITT 4: LOKALES TESTING

### **4.1 Lokalen HTTP Server starten**

#### **Option A: Python 3 (EMPFOHLEN)**
```bash
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td\web-build"
python -m http.server 8060
```

#### **Option B: Node.js http-server**
```bash
npx http-server web-build -p 8060 --cors
```

#### **Option C: Godot Editor "Run Exported"**
```
1. Project → Export
2. Button: "Export Project"
3. Checkbox: "Export With Debug" aktivieren
4. Nach Export: Godot öffnet automatisch Browser
```

### **4.2 Browser öffnen**
```
URL: http://localhost:8060
```

### **4.3 Testing Checklist**

#### **Browser DevTools öffnen (F12)**

**Console-Output prüfen:**
```
✅ [BeeKeeperTD] Running on localhost - using development environment variables
✅ HMAC secret loaded from environment (length: 64)
✅ Supabase credentials loaded (URL: https://porfficpmtayqccmpsrw...)
✅ HTTPS verified
✅ SupabaseClient ready (Security Score: 9.5/10)
```

**Fehler prüfen:**
```
❌ SharedArrayBuffer is not defined
   → Lösung: Siehe Schritt 4.4 (CORS Headers)

❌ CORS error when calling Supabase
   → Lösung: Prüfe CORS in Supabase Dashboard

❌ BKTD_ENV is undefined
   → Lösung: Prüfe Head Include Code in Export Preset
```

#### **Funktionstest**
```
1. ✅ Main Menu wird angezeigt
2. ✅ "New Game" Button funktioniert
3. ✅ Tower Defense Scene lädt
4. ✅ Tower Placement funktioniert (Hotkeys Q/W/E/R)
5. ✅ Wave Start funktioniert
6. ✅ 3-Speed System funktioniert (1x, 2x, 3x)
7. ✅ Save System funktioniert (nach Cloud login)
```

### **4.4 SharedArrayBuffer Fix (falls benötigt)**

**Problem:** Moderne Browser benötigen CORS Headers für SharedArrayBuffer

**Lösung: Temporärer Test-Server mit Headers**

**Erstelle Datei: `test-server.py`**
```python
#!/usr/bin/env python3
import http.server
import socketserver

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

PORT = 8060
with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
    print(f"Server running at http://localhost:{PORT}")
    httpd.serve_forever()
```

**Ausführen:**
```bash
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td\web-build"
python test-server.py
```

---

## 🎯 SCHRITT 5: NETLIFY DEPLOYMENT

### **5.1 Netlify Account Setup**
```
1. Gehe zu: https://www.netlify.com
2. Sign up with GitHub/Google/Email
3. Verifiziere Email-Adresse
```

### **5.2 New Site erstellen**

#### **Option A: Drag & Drop (SCHNELL)**
```
1. Netlify Dashboard
2. Button: "Add new site" → "Deploy manually"
3. Ziehe den gesamten `web-build` Ordner ins Browser-Fenster
4. Warte auf Deploy (~2 Minuten)
5. Site URL wird generiert: https://random-name.netlify.app
```

#### **Option B: Git Deploy (EMPFOHLEN)**
```
1. Push web-build zu Git:
   cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td"
   git add web-build
   git commit -m "build: add godot web export"
   git push origin fix/web-build-clickability

2. Netlify Dashboard → "Add new site" → "Import from Git"
3. Connect to GitHub
4. Select Repository: BeeKeeperTD
5. Branch: fix/web-build-clickability
6. Build settings:
   - Build command: (leer lassen)
   - Publish directory: web-build
7. Button: "Deploy site"
```

### **5.3 Environment Variables setzen**
```
1. Site Settings → Environment variables
2. Button: "Add a variable"
3. Füge hinzu:

Key: SUPABASE_URL
Value: https://porfficpmtayqccmpsrw.supabase.co

Key: SUPABASE_ANON_KEY
Value: [DEIN_ANON_KEY_HIER]

Key: BKTD_HMAC_SECRET
Value: [DEIN_64_CHAR_HMAC_SECRET]

4. Button: "Save"
```

### **5.4 netlify.toml konfigurieren**

**Erstelle Datei: `bee-keeper-td/netlify.toml`**
```toml
[build]
  publish = "web-build"
  command = ""

[[headers]]
  for = "/*"
  [headers.values]
    # Security Headers
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    
    # CORS Headers für SharedArrayBuffer
    Cross-Origin-Opener-Policy = "same-origin"
    Cross-Origin-Embedder-Policy = "require-corp"
    
    # Content Security Policy
    Content-Security-Policy = """
      default-src 'self';
      script-src 'self' 'wasm-unsafe-eval';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self' data:;
      connect-src 'self' https://porfficpmtayqccmpsrw.supabase.co https://*.supabase.co;
      media-src 'self';
      object-src 'none';
      frame-ancestors 'none';
      base-uri 'self';
      form-action 'self';
    """

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# Environment Variable Injection
[build.processing.html]
  pretty_urls = false

[build.environment]
  # Diese werden automatisch in %VARIABLE% Platzhalter injiziert
```

### **5.5 Custom Domain (optional)**
```
1. Site Settings → Domain management
2. Button: "Add custom domain"
3. Enter domain: beekeepertd.com
4. Follow DNS setup instructions
5. Netlify konfiguriert automatisch HTTPS (Let's Encrypt)
```

### **5.6 Deployment testen**
```
1. Gehe zu: https://[your-site-name].netlify.app
2. Öffne Browser DevTools (F12)
3. Prüfe Console-Output
4. Führe Funktionstest durch (siehe Schritt 4.3)
```

---

## 🎯 SCHRITT 6: VERCEL DEPLOYMENT (ALTERNATIVE)

### **6.1 Vercel Account Setup**
```
1. Gehe zu: https://vercel.com
2. Sign up with GitHub
3. Import BeeKeeperTD Repository
```

### **6.2 vercel.json konfigurieren**

**Erstelle Datei: `bee-keeper-td/vercel.json`**
```json
{
  "version": 2,
  "builds": [
    {
      "src": "web-build/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "headers": {
        "Cross-Origin-Opener-Policy": "same-origin",
        "Cross-Origin-Embedder-Policy": "require-corp",
        "X-Frame-Options": "DENY",
        "X-Content-Type-Options": "nosniff",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Content-Security-Policy": "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://porfficpmtayqccmpsrw.supabase.co https://*.supabase.co; media-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self';"
      },
      "dest": "/web-build/$1"
    }
  ],
  "env": {
    "SUPABASE_URL": "@supabase-url",
    "SUPABASE_ANON_KEY": "@supabase-anon-key",
    "BKTD_HMAC_SECRET": "@bktd-hmac-secret"
  }
}
```

### **6.3 Environment Variables setzen**
```
1. Vercel Dashboard → Project Settings
2. Environment Variables
3. Add:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - BKTD_HMAC_SECRET
4. Scope: Production, Preview, Development
```

---

## 🎯 SCHRITT 7: CORS PRODUCTION CONFIG

### **7.1 Supabase CORS für Production**
```
1. Supabase Dashboard → Authentication → URL Configuration
2. Site URL aktualisieren:
   https://[your-site-name].netlify.app
   
3. Redirect URLs hinzufügen:
   https://[your-site-name].netlify.app/**
   http://localhost:8060/**  (für lokales Testing behalten)
   
4. Speichern
```

### **7.2 Verifizierung**
```
1. Öffne Production URL
2. Browser DevTools → Network Tab
3. Auth Request zu Supabase prüfen
4. Status sollte sein: 200 oder 401 (aber NICHT CORS error!)
```

---

## 🎯 SCHRITT 8: PRODUCTION TESTING

### **8.1 Security Testing**

#### **CSP Headers testen**
```
1. Öffne: https://securityheaders.com
2. Enter URL: https://[your-site-name].netlify.app
3. Erwartete Grade: A oder höher
```

#### **SSL Testing**
```
1. Öffne: https://www.ssllabs.com/ssltest/
2. Enter URL: [your-site-name].netlify.app
3. Erwartete Grade: A oder A+
```

### **8.2 Performance Testing**

#### **Lighthouse Audit**
```
1. Browser DevTools → Lighthouse Tab
2. Category: Performance, Accessibility, Best Practices
3. Button: "Generate report"
4. Ziel: >80 in allen Kategorien
```

#### **Ladezeiten prüfen**
```
1. Browser DevTools → Network Tab
2. Disable Cache
3. Reload Page (Ctrl+Shift+R)
4. Erwartete Ladezeit: <10 Sekunden
```

### **8.3 Funktionstest (Production)**
```
✅ Registration funktioniert
✅ Login funktioniert
✅ Cloud Save funktioniert
✅ Tower Placement funktioniert
✅ Wave Progression funktioniert
✅ 3-Speed System funktioniert
✅ Metaprogression speichert
✅ HMAC Checksum validiert
```

### **8.4 Browser Kompatibilität**

**Teste in:**
```
✅ Chrome (latest)
✅ Firefox (latest)
✅ Opera (latest)
✅ Safari (latest, macOS/iOS)
✅ Edge (latest)
```

**Bekannte Issues:**
```
⚠️ Safari < 15.2: SharedArrayBuffer Support limitiert
⚠️ iOS Safari: Audio requires user interaction
⚠️ Firefox: Kann längere Ladezeiten haben
```

---

## 🎯 TROUBLESHOOTING

### **Problem: "Failed to load .wasm"**

**Ursache:** MIME Type nicht korrekt

**Lösung:**
```
1. Netlify: Automatisch konfiguriert
2. Vercel: Automatisch konfiguriert
3. Eigener Server: Nginx config:
   types {
       application/wasm wasm;
   }
```

### **Problem: "SharedArrayBuffer is not defined"**

**Ursache:** CORS Headers fehlen

**Lösung:**
```
1. Prüfe netlify.toml Headers
2. Prüfe Browser DevTools → Response Headers
3. Muss enthalten:
   - Cross-Origin-Opener-Policy: same-origin
   - Cross-Origin-Embedder-Policy: require-corp
```

### **Problem: "CORS error when calling Supabase"**

**Ursache:** Domain nicht in Supabase CORS erlaubt

**Lösung:**
```
1. Supabase Dashboard → Authentication → URL Configuration
2. Redirect URLs aktualisieren
3. Warte 1-2 Minuten für Propagation
```

### **Problem: "BKTD_ENV is undefined"**

**Ursache:** Environment Variables nicht injiziert

**Lösung:**
```
1. Prüfe Head Include Code im Export Preset
2. Prüfe Netlify Environment Variables
3. Re-deploy nach Änderungen
```

### **Problem: "Black screen on load"**

**Ursache:** Index.html kann .pck nicht laden

**Lösung:**
```
1. Prüfe alle 5 Dateien im web-build Ordner
2. Prüfe Browser Console für Fehler
3. Export neu durchführen mit "Embed PCK: Enabled"
```

### **Problem: "Authentication fails in production"**

**Ursache:** Environment Variables falsch gesetzt

**Lösung:**
```
1. Browser Console → localStorage prüfen
2. SUPABASE_URL korrekt?
3. SUPABASE_ANON_KEY korrekt?
4. CORS in Supabase korrekt konfiguriert?
```

---

## 🎯 BEST PRACTICES

### **Performance Optimization**
```
1. Texture Compression aktiviert (BPTC, S3TC)
2. Audio-Dateien: Ogg Vorbis statt WAV
3. Mesh-Optimierung: Weniger Vertices
4. Object Pooling für Enemies/Projectiles
```

### **Security**
```
1. ✅ Secrets NIEMALS im Head Include hardcoden
2. ✅ CSP Headers konfiguriert
3. ✅ HTTPS enforced (Netlify/Vercel automatisch)
4. ✅ CORS strikt konfiguriert
```

### **Monitoring**
```
1. Netlify Analytics aktivieren (optional, $9/Monat)
2. Sentry für Error Tracking integrieren
3. Google Analytics für User-Tracking (optional)
```

### **Updates & Deployment**
```
1. Git Workflow:
   - main branch → Stable Production
   - develop branch → Staging Environment
   - feature branches → Preview Deployments

2. Netlify automatisches Deploy:
   - Push to main → Production deploy
   - Push to develop → Preview deploy
   - Pull Request → Deploy Preview
```

---

## 📊 DEPLOYMENT CHECKLIST

### **Pre-Deployment**
- [x] Environment Variables System implementiert
- [x] CORS in Supabase konfiguriert
- [x] SQL Anti-Cheat Triggers deployed
- [x] Tests funktionsfähig (20/20)
- [x] Security Score 9.5/10

### **Export**
- [ ] Godot Export Templates installiert
- [ ] Web Export Preset konfiguriert
- [ ] Head Include mit Environment Variables
- [ ] Web Build erstellt (5 Dateien)
- [ ] Lokales Testing erfolgreich

### **Deployment**
- [ ] Netlify/Vercel Account erstellt
- [ ] Environment Variables gesetzt
- [ ] netlify.toml / vercel.json konfiguriert
- [ ] Site deployed
- [ ] Custom Domain konfiguriert (optional)

### **Post-Deployment**
- [ ] CORS Production Config aktualisiert
- [ ] Security Headers geprüft (securityheaders.com)
- [ ] SSL Grade A+ (ssllabs.com)
- [ ] Lighthouse Score >80
- [ ] Funktionstest Production
- [ ] Browser Kompatibilität getestet

---

## 🎉 FERTIG!

**Dein BeeKeeperTD ist jetzt live! 🚀**

**Nächste Schritte:**
1. Share URL mit Beta-Testern
2. Monitor Performance (Netlify Analytics)
3. Collect Feedback
4. Iterate & Improve

**Support & Updates:**
- Dokumentation: `MD-Files/02-Setup/`
- Session Summary: `SESSION_SUMMARY_2025-01-12.md`
- Project Status: `MD-Files/06-Status/Project_Status.md`

---

**Erstellt**: 2025-01-12  
**Autor**: BeeKeeperTD Development Team  
**Version**: 1.0  
**Status**: ✅ **Production Ready**
