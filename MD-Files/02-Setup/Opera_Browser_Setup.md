# 🎭 Opera Browser - Developer Tools Setup

**Für**: BeeKeeperTD Web Export Debugging  
**Browser**: Opera (Chromium-based)  
**Status**: Recommended Setup

---

## ⌨️ Opera Developer Tools Hotkeys

### Windows/Linux:
| Funktion | Hotkey | Alternative |
|----------|--------|-------------|
| **Developer Tools öffnen** | `Ctrl + Shift + I` | `F12` |
| **Console direkt öffnen** | `Ctrl + Shift + J` | - |
| **Element inspizieren** | `Ctrl + Shift + C` | - |
| **Console leeren** | `Ctrl + L` | (in Console) |
| **Suche in Developer Tools** | `Ctrl + F` | - |

### macOS:
| Funktion | Hotkey |
|----------|--------|
| **Developer Tools öffnen** | `Cmd + Option + I` |
| **Console direkt öffnen** | `Cmd + Option + J` |
| **Element inspizieren** | `Cmd + Option + C` |

---

## 🚨 Problem: Hotkeys funktionieren nicht auf localhost

### Symptom:
- `F12` oder `Ctrl + Shift + I` öffnet Developer Tools **nicht** auf http://localhost:8060
- Funktioniert aber in anderen Tabs

### Ursache:
**Godot Web Export fängt Tastatur-Events ab!**

Das Godot-Canvas hat Focus und konsumiert alle Keyboard-Events, bevor der Browser sie sieht.

### Lösung 1: Rechtsklick-Menü (Empfohlen)
1. **Rechtsklick** irgendwo auf der localhost-Seite
2. Wähle: **"Untersuchen"** oder **"Inspect"** oder **"Element untersuchen"**
3. Developer Tools öffnen sich

**Das funktioniert immer!** ✅

### Lösung 2: Fokus aus Canvas nehmen
1. **Klicke in die Browser-Addressleiste** (Ctrl + L)
2. Dann drücke **F12** oder **Ctrl + Shift + I**
3. Developer Tools öffnen sich

### Lösung 3: Opera Menü
1. Klicke auf **Opera-Icon** (links oben, O-Symbol)
2. Gehe zu **"Entwickler"** → **"Entwicklertools"**
3. Oder: **"Entwickler"** → **"Konsole"**

### Lösung 4: Tab-Trick
1. Öffne Developer Tools in **einem anderen Tab** (z.B. google.com)
2. Gehe zurück zum **localhost-Tab**
3. Developer Tools bleiben offen

---

## 🎯 Empfohlenes Setup für BeeKeeperTD

### Schritt 1: Developer Tools öffnen
1. Gehe zu http://localhost:8060
2. **Rechtsklick** auf die Seite
3. Wähle **"Untersuchen"** / **"Inspect"**

### Schritt 2: Console Tab auswählen
1. In Developer Tools: Klicke auf **"Console"** Tab
2. Oder drücke **Esc** um zusätzliche Console zu öffnen

### Schritt 3: Filter setzen (Optional)
Um nur relevante Logs zu sehen:
```
Filter: -"[.Offscreen-For-WebGL-"
```
Damit werden Canvas-Warnings gefiltert.

### Schritt 4: Preserve Log aktivieren
1. In Console: Rechtsklick
2. Aktiviere **"Preserve log"**
3. Logs bleiben bei Seiten-Reload erhalten

---

## 🔍 Wichtige Console-Befehle

### Supabase-Status prüfen:
```javascript
console.log("Supabase URL:", window.SUPABASE_URL);
console.log("Anon Key:", window.SUPABASE_ANON_KEY ? "✅ Set" : "❌ Not set");
```

### LocalStorage prüfen:
```javascript
// Alle gespeicherten Daten anzeigen
console.log("LocalStorage:", localStorage);

// Spezifische Keys prüfen
console.log("Auth Token:", sessionStorage.getItem('bktd_auth_token'));
console.log("User ID:", localStorage.getItem('bktd_user_id'));
```

### Logs filtern:
```javascript
// Nur Errors anzeigen
console.log("Show only errors");

// In Filter-Box eingeben:
-info -log -debug
```

### Network-Requests prüfen:
1. Gehe zu **"Network"** Tab
2. Filter auf **"XHR"** (API Requests)
3. Suche nach `supabase.co`
4. Klicke auf Request → **"Response"** Tab

---

## 📊 Debugging Workflow

### 1. Seite laden mit offener Console:
1. Developer Tools öffnen (**Rechtsklick → Untersuchen**)
2. **Console** Tab auswählen
3. **Preserve log** aktivieren
4. Seite neu laden (**F5**)

### 2. Registrierung debuggen:
```
Erwartete Console-Ausgabe:
🔐 AuthScreen initialized
✅ Enter key handling enabled
✅ Enhanced password manager support enabled
(Felder ausfüllen)
📝 Enter pressed on Register tab - Username: true, Email: true...
📝 Triggering register
📝 Registering user: test@example.com
📡 HTTP Response Code: 200
📡 Response Body: {...}
✅ Authentication successful: test@example.com
```

### 3. Errors analysieren:
```javascript
// Im Network Tab:
- Finde fehlgeschlagenen Request (rot)
- Klicke darauf
- Tabs: Headers, Payload, Response, Timing
- Response zeigt Server-Fehlermeldung
```

### 4. Browser Console vs Godot Output:
- **Browser Console**: JavaScript, HTTP Requests, DOM
- **Godot Print**: GDScript `print()` Statements (erscheinen in Browser Console!)

**Beide Outputs erscheinen in der gleichen Console!**

---

## 🛠️ Console nicht verfügbar? Alternative Logs

Falls Developer Tools wirklich nicht öffnen:

### Option 1: Opera Developer Console (Standalone)
1. Opera Menü → **"Entwickler"** → **"JavaScript-Konsole"**
2. Separates Fenster öffnet sich

### Option 2: Externe Console (opera://extensions)
1. Öffne `opera://extensions`
2. Aktiviere **"Entwicklermodus"**
3. Ermöglicht mehr Debugging-Tools

### Option 3: Remote Debugging
1. Opera mit `--remote-debugging-port=9222` starten
2. In anderem Browser: `localhost:9222` öffnen
3. DevTools aus anderem Browser nutzen

---

## 🎨 Opera Developer Tools Features

### Nützliche Panels:
1. **Console**: Logs, Errors, JavaScript ausführen
2. **Network**: HTTP Requests, Response Bodies, Timing
3. **Application**: LocalStorage, SessionStorage, Cookies
4. **Sources**: JavaScript Dateien, Breakpoints setzen
5. **Performance**: FPS, Memory Usage, Bottlenecks

### Console-Tricks:
```javascript
// Clear console
clear();

// Copy Object to clipboard
copy(object);

// Monitor function calls
monitor(functionName);

// Table view for objects
console.table([{name: "User1", age: 25}, {name: "User2", age: 30}]);
```

---

## 📱 Mobile Testing mit Opera

### Opera Touch/Mobile:
1. Öffne http://localhost:8060 auf Opera Mobile
2. **Lange drücken** auf Seite
3. Wähle **"Inspect"**
4. Remote Debugging verbindet sich zu Desktop

### Desktop → Mobile Debugging:
1. Desktop Opera öffnen
2. Gehe zu `opera://inspect`
3. Aktiviere **"USB debugging"**
4. Mobile-Device wird angezeigt
5. **"Inspect"** klicken

---

## 🔧 Troubleshooting

### Problem: "Untersuchen" im Rechtsklick-Menü fehlt
**Lösung:**
1. Opera Menü → **"Einstellungen"**
2. Suche: **"Entwickler"**
3. Aktiviere: **"Entwicklertools anzeigen"**

### Problem: Console zeigt keine Logs
**Lösung:**
1. Prüfe **Log Level** (rechts oben in Console)
2. Aktiviere: `Verbose`, `Info`, `Warnings`, `Errors`
3. Deaktiviere **"Hide network messages"**

### Problem: Zu viele Canvas-Warnings
**Lösung:**
```javascript
// In Console Filter eingeben:
-Offscreen -WebGL -Canvas

// Oder nur eigene Logs anzeigen:
🔐 | 📝 | ✅ | ❌ | 📡
```

### Problem: Request-Bodies nicht sichtbar
**Lösung:**
1. Network Tab öffnen
2. Klicke auf Request
3. **"Payload"** Tab (nicht "Headers")
4. **"View source"** / **"View parsed"** umschalten

---

## 📚 Verwandte Dokumente

- [Web_Export_Quick_Start.md](Web_Export_Quick_Start.md) - Server Setup
- [Auth_Screen_Improvements.md](../04-Features/Auth_Screen_Improvements.md) - Debugging Auth
- [Supabase_Database_Cleanup.md](../03-Security/Supabase_Database_Cleanup.md) - DB Cleanup

---

## 🎯 Quick Reference Card

**Für Opera-Debugging:**

```
✅ FUNKTIONIERT IMMER:
   Rechtsklick → "Untersuchen" → Console Tab

⚠️ FUNKTIONIERT NICHT direkt auf localhost:
   F12, Ctrl+Shift+I (Godot fängt Events ab)

💡 WORKAROUND:
   1. Focus aus Canvas: Ctrl+L (Addressleiste)
   2. Dann: F12
   
   ODER: In anderem Tab öffnen, dann wechseln
```

---

**Browser**: Opera  
**Version**: Chromium-based (aktuell)  
**Debugging**: ✅ Fully Supported  
**Empfehlung**: Rechtsklick-Menü verwenden für schnellsten Zugriff
