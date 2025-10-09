# 🔒 CORS Verification Guide - BeeKeeperTD

**Datum**: 2025-01-12  
**Security Priority**: HIGH  
**Erforderliche Zeit**: 5 Minuten

---

## 📋 Was ist CORS?

**Cross-Origin Resource Sharing (CORS)** verhindert, dass böswillige Websites auf deine Supabase API zugreifen können.

**Ohne CORS-Schutz**:
- ❌ Jede Website kann deine API aufrufen
- ❌ Angreifer können User-Daten stehlen
- ❌ Fake-Websites können sich als dein Spiel ausgeben

**Mit CORS-Schutz**:
- ✅ Nur autorisierte Domains können API aufrufen
- ✅ Browser blockieren nicht-autorisierte Requests
- ✅ Deine API ist geschützt

---

## 🎯 CORS Konfiguration

### **Schritt 1: Supabase Dashboard öffnen**

1. Gehe zu: [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Wähle dein Projekt: **porfficpmtayqccmpsrw**
3. Navigiere zu: **Settings** → **API**

### **Schritt 2: CORS Origins konfigurieren**

Scrolle zu **"CORS Configuration"** oder **"Additional allowed origins"**

#### **Production Domains hinzufügen:**

```
https://deine-production-domain.com
https://deine-production-domain.netlify.app
https://deine-production-domain.vercel.app
```

**Wichtig**: 
- ✅ **MIT** `https://`
- ✅ **OHNE** trailing slash (`/`)
- ✅ **Nur** deine tatsächlichen Domains

#### **Development Domain hinzufügen:**

```
http://localhost:8060
```

**Hinweis**: `localhost` nur für lokale Entwicklung!

### **Schritt 3: Standard CORS prüfen**

Supabase hat bereits **automatische CORS-Unterstützung** für:
- ✅ Alle Subdomains deines Projekts
- ✅ `*.supabase.co`

**Du musst nur DEINE Domains hinzufügen!**

---

## ✅ Verifikation

### **1. Browser DevTools Check**

Nach dem CORS-Setup:

1. Öffne dein Spiel im Browser (Production URL)
2. Drücke **F12** → **Console**
3. Führe einen API-Call aus (z.B. Login)
4. Prüfe auf CORS-Fehler:

**❌ CORS Fehler (nicht konfiguriert):**
```
Access to fetch at 'https://porfficpmtayqccmpsrw.supabase.co/...' 
from origin 'https://deine-domain.com' has been blocked by CORS policy
```

**✅ Kein CORS-Fehler (richtig konfiguriert):**
```
Status: 200 OK
```

### **2. Curl Test (Optional)**

```bash
curl -X POST https://porfficpmtayqccmpsrw.supabase.co/auth/v1/signup \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Origin: https://deine-domain.com" \
  -d '{"email":"test@example.com","password":"test123456789012"}'
```

**Erwartete Response**: `200 OK` oder spezifischer Auth-Fehler

**Nicht erwartet**: `CORS policy` Error

### **3. Supabase Logs prüfen**

1. Dashboard → **Logs** → **API Logs**
2. Filtere nach **CORS errors**
3. Sollte **leer** sein nach Konfiguration

---

## 🔧 Troubleshooting

### **Problem: "CORS policy blocked"**

**Lösung**:
1. Prüfe, ob Domain in CORS Origins eingetragen ist
2. Prüfe `https://` vs `http://` (muss übereinstimmen!)
3. Prüfe auf trailing slash (sollte NICHT vorhanden sein)
4. Warte 1-2 Minuten nach Änderung (Propagation)

### **Problem: "localhost funktioniert nicht"**

**Lösung**:
- Füge `http://localhost:8060` hinzu (nicht `https://`!)
- Stelle sicher, dass Port übereinstimmt
- Prüfe, ob Browser CORS streng durchsetzt (Chrome vs Firefox)

### **Problem: "Netlify/Vercel Domain nicht akzeptiert"**

**Lösung**:
1. Prüfe exakte Domain (inkl. Subdomain!)
2. Beispiele:
   - ✅ `https://bee-keeper-td.netlify.app`
   - ❌ `https://netlify.app` (zu allgemein!)
   - ❌ `bee-keeper-td.netlify.app` (fehlt https://)

---

## 🎯 Empfohlene CORS-Konfiguration

### **Für Entwicklung:**

```
http://localhost:8060
http://127.0.0.1:8060
```

### **Für Production:**

```
https://deine-production-domain.com
https://www.deine-production-domain.com
https://deine-subdomain.netlify.app
https://deine-subdomain.vercel.app
```

**Wichtig**: 
- Füge **NUR** Domains hinzu, die du kontrollierst!
- **NIEMALS** Wildcard (`*`) in Production verwenden!

---

## 🔐 Security Best Practices

### **✅ DO:**
- Nur spezifische Domains hinzufügen
- HTTPS in Production verwenden
- Regelmäßig CORS-Logs prüfen
- Alte/ungültige Domains entfernen

### **❌ DON'T:**
- Wildcard (`*`) in Production
- HTTP in Production (nur HTTPS!)
- Domains von Dritten hinzufügen
- Port-Ranges (z.B. `localhost:*`)

---

## 📊 CORS Status Checklist

Nach der Konfiguration:

- [ ] **Production Domain** in CORS Origins eingetragen
- [ ] **Localhost** für Entwicklung eingetragen
- [ ] **Browser DevTools** zeigt keine CORS-Fehler
- [ ] **API Requests** funktionieren (200 OK)
- [ ] **Logs** zeigen keine CORS-Blocks
- [ ] **Tests** laufen durch (Auth, Save/Load)

---

## 🔗 Weiterführende Links

- [Supabase CORS Docs](https://supabase.com/docs/guides/api/cors)
- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Chrome DevTools Network Tab](https://developer.chrome.com/docs/devtools/network/)

---

## 🚀 Schnell-Setup

**Für die schnelle Einrichtung (Copy-Paste):**

1. Supabase Dashboard → Settings → API → CORS Configuration
2. Füge hinzu:
   ```
   http://localhost:8060
   https://DEINE-PRODUCTION-DOMAIN.com
   ```
3. Speichern
4. Warte 1-2 Minuten
5. Teste im Browser

**Fertig!** 🎉

---

**Status**: ✅ Ready to Deploy  
**Security Impact**: HIGH  
**Last Updated**: 2025-01-12
