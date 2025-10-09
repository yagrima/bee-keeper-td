# Anforderungskatalog - BeeKeeperTD Audit & Cleanup

**Projekt**: BeeKeeperTD v3.3  
**Status**: Systematische Projektbereinigung & Deployment-Vorbereitung  
**Erstellt**: 2025-01-10  
**Browser**: Opera (Incognito statt Hard Refresh)

---

## 1. ANALYSE-ANFORDERUNGEN

### 1.1 Ist-Zustand Erfassung
- [x] Projektstruktur analysiert
- [x] Haupt-Dokumentation gelesen (README.md, TECHNICAL_DEBT.md, Project_Status.md)
- [x] Code-Struktur erfasst (scripts/, autoloads/, scenes/)
- [ ] Git-Historie überprüfen
- [ ] Build-Status verifizieren

### 1.2 Dateigröße Audit
**Laut TECHNICAL_DEBT.md**:
- 🔴 KRITISCH: `TowerDefense.gd` (847 Zeilen) → Refactoring erforderlich
- 🟠 WARNING: `TestFramework.gd` (734 Zeilen), `SaveManager.gd` (722 Zeilen)
- Empfehlung: Dateien >500 Zeilen sollten aufgeteilt werden

---

## 2. BEREINIGUNGS-ANFORDERUNGEN

### 2.1 Backup-Dateien Entfernen
**Identifizierte Backup-Dateien**:
- `scripts/TowerDefense.gd.backup` (35,707 bytes)
- `scripts/TowerDefense.gd.old` (35,707 bytes)
- `scripts/TestFramework.gd.backup` (25,071 bytes)
- `scripts/TestFramework.gd.old` (25,071 bytes)
- `autoloads/SaveManager.gd.backup` (25,990 bytes)
- `autoloads/SaveManager.gd.old` (25,990 bytes)

**Aktion**: Löschen nach Verifizierung, dass aktuelle Versionen funktionieren

### 2.2 UID-Dateien Überprüfen
**Beobachtung**: Viele `.gd.uid` Dateien (Godot-Metadaten)
**Aktion**: Prüfen ob alle notwendig, ggf. .gitignore Update

### 2.3 Obsolete Dateien
- `ComprehensiveVectorTests.gd.uid` (Datei existiert nicht mehr)
- `UIElementVectorTests.gd.uid` (Datei existiert nicht mehr)
- `PATH_BACKUP_2025-09-29_22-07-48.txt` (alter Backup)

---

## 3. DOKUMENTATIONS-ANFORDERUNGEN

### 3.1 Dokumentations-Konsolidierung
**Aktuelle Struktur**:
```
Root:
├── README.md ✅
├── README_WEB_BUILD.md
├── SAVE_SYSTEM_README.md
├── SUPABASE_SETUP_GUIDE.md
├── TOWER_HOTKEY_SOLUTION_DOCUMENTATION.md
├── TOWER_HOTKEY_TOGGLE_SOLUTION_DOCUMENTATION.md
├── TOWER_PLACEMENT_BLOCKING_DOCUMENTATION.md
├── WEB_APP_IMPLEMENTATION_PLAN_SECURITY_REVIEW.md
├── TECHNICAL_DEBT.md ✅
├── PRD_BeeKeeperTD_v3.0.md
├── DEVELOPMENT_PLAN_v3.0.md
├── PHASE_2_CHANGELOG.md
├── SESSION_SUMMARY_2025-01-12.md
├── CODING_STANDARDS.md
├── QUICK_DEBUG.md
├── GODOT_UI_EXPORT_ANLEITUNG.md
└── JETZT_NEU_EXPORTIEREN.txt

MD-Files/ (organisiert)
├── INDEX.md ✅
├── 01-Planning/
├── 02-Setup/
├── 03-Security/
├── 04-Features/
├── 05-Testing/
├── 06-Status/
└── Archive/

old_documentation/ (v2.0 Dokumente)
test_documentation/ (Test-Dokumentation)
docs/ (existiert?)
```

**Aktion**:
1. Alle losen MD-Dateien im Root prüfen
2. Entweder nach `MD-Files/` verschieben oder löschen (wenn redundant)
3. `old_documentation/` und `test_documentation/` → `MD-Files/Archive/`
4. Root nur behalten: README.md, TECHNICAL_DEBT.md, .env, project.godot

### 3.2 Dokumentation Aktualisieren
**Zu prüfen**:
- [ ] INDEX.md vollständig?
- [ ] Alle Links funktionieren?
- [ ] Veraltete Informationen entfernen
- [ ] Deployment-Anleitung für Opera-Browser

---

## 4. CODE-QUALITÄTS-ANFORDERUNGEN

### 4.1 Doppelte Funktionen Identifizieren
**Zu prüfen**:
- [ ] Tower-Skripte (4 Tower-Typen + BasicShooter/PiercingTower)
- [ ] Save-System (SaveManager vs. save_system/ Unterordner)
- [ ] Test-Framework Funktionen

### 4.2 Code-Refactoring (nach Deployment)
**TowerDefense.gd** (847 Zeilen):
- Aufteilen in: TDState.gd, TDInput.gd, TDEvents.gd
- Bereits ausgelagert: TDUIManager, TDWaveController, TDMetaprogression ✅

**TestFramework.gd** (734 Zeilen):
- Development-only, niedrige Priorität

**SaveManager.gd** (722 Zeilen):
- Eventuell aufteilen in SaveWriter, SaveReader, CloudSync

### 4.3 Tests Verifizieren
**Laut Project_Status.md**:
- ✅ AuthFlowTests (10/10 gefixt)
- ✅ CloudSaveTests (10/10 gefixt)
- ✅ TowerPlacementTests (funktionsfähig)
- ✅ ComponentTests (funktionsfähig)

**Aktion**: Tests lokal ausführen und verifizieren

---

## 5. DEPLOYMENT-ANFORDERUNGEN

### 5.1 Lokaler Build
- [ ] Godot Editor öffnen und Projekt laden
- [ ] Console auf Errors prüfen
- [ ] Spiel lokal testen (AuthScreen → TowerDefense)
- [ ] Alle Features durchspielen

### 5.2 Web-Export Vorbereitung
**Laut TECHNICAL_DEBT.md nächster Schritt**:
1. [ ] Export-Preset für HTML5 prüfen (`export_presets.cfg` existiert ✅)
2. [ ] Environment Variables für Web-Build (JavaScript Injection)
3. [ ] CSP Headers testen (netlify.toml, vercel.json vorhanden ✅)
4. [ ] Opera-Browser spezifische Anpassungen prüfen

### 5.3 Environment Variables
**Erforderlich** (.env Datei):
```
SUPABASE_URL=https://porfficpmtayqccmpsrw.supabase.co
SUPABASE_ANON_KEY=[key]
BKTD_HMAC_SECRET=[64 Zeichen hex]
```

**Status laut Project_Status.md**: ✅ Bereits erstellt und getestet

---

## 6. OPERA-BROWSER SPEZIFISCHE ANFORDERUNGEN

### 6.1 Testing-Workflow
- Incognito-Fenster für Tests (statt Hard Refresh)
- DevTools für CSP/CORS Verifizierung
- Local Server für Web-Build (z.B. `start_server.bat`)

### 6.2 Bekannte Issues
**Zu dokumentieren**:
- WebAssembly Support in Opera
- SharedArrayBuffer Requirements
- CORS Konfiguration für Supabase

---

## 7. SICHERHEITS-ANFORDERUNGEN

**Laut Project_Status.md**: Security Score 9.5/10 ✅

### 7.1 Verifizierung
- [ ] .env nicht im Git (✅ .gitignore vorhanden)
- [ ] HMAC Secret aus Environment Variable (✅ implementiert)
- [ ] Supabase Keys externalisiert (✅ implementiert)
- [ ] CSP Headers konfiguriert (✅ netlify.toml/vercel.json)
- [ ] Server-Side Validation deployed (✅ SQL Triggers)

### 7.2 Pre-Deployment Security Check
- [ ] Keine Secrets in Code
- [ ] Keine Debug-Outputs in Production
- [ ] CORS korrekt konfiguriert
- [ ] HTTPS Enforcement

---

## 8. QUALITÄTSSICHERUNGS-ANFORDERUNGEN

### 8.1 Vor jedem Commit
- [ ] Alle Tests laufen durch
- [ ] Keine Parse-Errors in Godot
- [ ] Git-Diff prüfen (keine Secrets)
- [ ] Commit-Message dokumentiert Änderungen

### 8.2 Vor Deployment
- [ ] Lokaler Build funktioniert
- [ ] Web-Build funktioniert
- [ ] Tests in Production-Modus
- [ ] Dokumentation aktualisiert

### 8.3 Nach Deployment
- [ ] Smoke-Test in Opera (Incognito)
- [ ] Registrierung/Login testen
- [ ] Save/Load testen
- [ ] Performance-Check (3x Speed)

---

## 9. FEATURE-ANFORDERUNGEN (Post-Launch)

**Aus PRD v3.0 & Project_Status.md**:

### 9.1 Geplante Features
- [ ] Tower Upgrade System (High Priority)
- [ ] Tower Persistence in Metaprogression (High Priority)
- [ ] Zusätzliche Enemy Types (Medium Priority)
- [ ] Settlement System (Medium Priority)
- [ ] Visual & Audio Polish (Low Priority)

### 9.2 Security Enhancements
- [ ] CAPTCHA Integration (Post-Launch)
- [ ] Have I Been Pwned API (Post-Launch)
- [ ] Penetration Testing (bei >1000 Users)
- [ ] WAF Setup (bei >10k DAU)

---

## 10. DOKUMENTATIONS-PFLEGE

### 10.1 Kontinuierliche Aktualisierung
Nach jedem abgeschlossenen Themenkomplex:
- [ ] ANFORDERUNGEN.md aktualisieren (dieses Dokument)
- [ ] PROJECT_STATUS.md aktualisieren
- [ ] TECHNICAL_DEBT.md aktualisieren
- [ ] CHANGELOG.md erstellen (wenn nicht vorhanden)

### 10.2 Anforderungen Verifizieren
Nach jeder Kompression:
- [ ] Alle abgeschlossenen Anforderungen markieren
- [ ] Neue Anforderungen hinzufügen
- [ ] Obsolete Anforderungen entfernen (mit Begründung)

---

## PRIORISIERUNG

### 🔴 KRITISCH (Sofort)
1. Backup-Dateien bereinigen
2. Obsolete .uid-Dateien entfernen
3. Dokumentation konsolidieren (Root → MD-Files/)
4. Git-Status prüfen

### 🟡 HOCH (Diese Woche)
1. Doppelte Funktionen identifizieren
2. Tests lokal ausführen
3. Web-Export erstellen
4. Opera-Browser Testing

### 🟢 MITTEL (Nächste Woche)
1. TowerDefense.gd Refactoring
2. Code-Duplikate bereinigen
3. Feature-Dokumentation vervollständigen

### 🔵 NIEDRIG (Post-Launch)
1. TestFramework.gd Refactoring
2. SaveManager.gd Refactoring
3. Additional Features implementieren

---

## ERFOLGSKRITERIEN

### Definition of Done
- ✅ Keine Backup-Dateien im Repository
- ✅ Dokumentation in strukturiertem Ordner (MD-Files/)
- ✅ Keine redundanten Funktionen
- ✅ Alle Tests grün
- ✅ Web-Build funktioniert in Opera
- ✅ Dokumentation aktuell und vollständig
- ✅ Lauffähiger Commit markiert und dokumentiert
- ✅ Keine technischen Schulden in kritischen Bereichen

---

**Nächste Schritte**: 
1. Git-Status prüfen
2. Backup-Dateien liste erstellen und bereinigen
3. Dokumentation konsolidieren
4. Doppelte Funktionen suchen
