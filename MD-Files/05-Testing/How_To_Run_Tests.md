# 🧪 How to Run Tests

**BeeKeeperTD Test Suite**  
**Umfang**: 20 Tests (AuthFlow + CloudSave + Component Integration)  
**Status**: ✅ All tests updated to Signal-based pattern

---

## 🚀 Quick Start

### Option 1: Godot Editor (Empfohlen)
1. Öffne Godot Editor mit dem Projekt
2. Navigiere zu: `scenes/tests/Sprint4Tests.tscn`
3. Drücke **F6** oder klicke auf **"Run Current Scene"**
4. Beobachte die Konsolen-Ausgabe

### Option 2: Via Command Line
```bash
# Im Projektverzeichnis
cd "G:\My Drive\KI-Dev\BeeKeeperTD\bee-keeper-td"

# Tests ausführen
"G:\My Drive\KI-Dev\Godot_v4.5-stable_win64.exe" --path . scenes/tests/Sprint4Tests.tscn
```

### Option 3: Einzelne Test-Suites
```gdscript
# In einer beliebigen Szene/Script
var auth_tests = AuthFlowTests.new()
add_child(auth_tests)
await auth_tests.run_all_tests()

var cloud_tests = CloudSaveTests.new()
add_child(cloud_tests)
await cloud_tests.run_all_tests()
```

---

## 📋 Test-Suites

### 1. **AuthFlowTests** (10 Tests)
- ✅ test_registration_valid_credentials
- ✅ test_registration_weak_password
- ✅ test_registration_duplicate_email
- ✅ test_login_valid_credentials
- ✅ test_login_invalid_password
- ✅ test_login_nonexistent_user
- ✅ test_logout
- ✅ test_token_refresh
- ✅ test_session_persistence
- ✅ test_session_expiration

**Voraussetzungen:**
- Aktive Supabase-Verbindung
- Environment Variables gesetzt (.env Datei)

### 2. **CloudSaveTests** (10 Tests)
- ✅ test_local_save_basic
- ✅ test_local_load_basic
- ✅ test_cloud_save_authenticated
- ✅ test_cloud_load_authenticated
- ✅ test_cloud_first_strategy
- ✅ test_hmac_checksum_generation
- ✅ test_hmac_checksum_validation
- ✅ test_save_data_structure
- ✅ test_offline_fallback
- ✅ test_rate_limiting

**Voraussetzungen:**
- SaveManager autoload geladen
- HMAC_SECRET in .env gesetzt
- Optionally: Authentifizierter User für Cloud-Tests

### 3. **ComponentIntegrationTests** (Variable)
- Tower Placement Tests
- Wave Management Tests
- UI Integration Tests

---

## ⚙️ Setup

### 1. Environment Variables prüfen
```bash
# Prüfe ob .env Datei existiert
ls bee-keeper-td/.env

# Sollte enthalten:
# SUPABASE_URL=https://porfficpmtayqccmpsrw.supabase.co
# SUPABASE_ANON_KEY=eyJ...
# BKTD_HMAC_SECRET=...
```

### 2. Godot neu starten (falls .env geändert wurde)
Environment Variables werden beim Start geladen.

### 3. Testbenutzer erstellen (optional für Auth-Tests)
Die Auth-Tests erstellen automatisch Testbenutzer, aber du kannst auch manuell einen erstellen:
```gdscript
# In Supabase Dashboard → Authentication → Users → Add User
Email: test@example.com
Password: SecureTestPassword123!@#
```

---

## 📊 Erwartete Ausgabe

### Erfolgreich:
```
████████████████████████████████████████████████████████████
SPRINT 4 - COMPREHENSIVE TEST SUITE
████████████████████████████████████████████████████████████
Starting all tests...

📦 Running Component Integration Tests...
  ✅ PASS: Component test 1
  ✅ PASS: Component test 2
  ...
✅ Component Integration Tests Complete: 5/5 passed

☁️ Running Cloud Save/Load Tests...
  ✅ PASS: Local Save - Basic
  ✅ PASS: Local Load - Basic
  ✅ PASS: HMAC Checksum - Generation
  ...
✅ Cloud Save Tests Complete: 10/10 passed

🔐 Running Auth Flow Tests...
  ✅ PASS: Registration - Valid Credentials
  ✅ PASS: Login - Valid Credentials
  ...
✅ Auth Flow Tests Complete: 10/10 passed

████████████████████████████████████████████████████████████
FINAL TEST SUMMARY - SPRINT 4
████████████████████████████████████████████████████████████
Total Test Suites: 3
Total Tests: 25
✅ Passed: 25
❌ Failed: 0
Success Rate: 100.0%
████████████████████████████████████████████████████████████

Tests complete. Exiting in 3 seconds...
```

### Mit Fehlern:
```
...
🔐 Running Auth Flow Tests...
  ✅ PASS: Registration - Valid Credentials
  ❌ FAIL: Login - Invalid Password: Timeout (no signal received)
  ...

████████████████████████████████████████████████████████████
FINAL TEST SUMMARY
████████████████████████████████████████████████████████████
Total Tests: 25
✅ Passed: 24
❌ Failed: 1
Success Rate: 96.0%
████████████████████████████████████████████████████████████
```

---

## 🐛 Troubleshooting

### Problem: Tests hängen / Timeout
**Ursache**: Signal wird nicht empfangen (Netzwerk, API-Fehler)  
**Lösung**:
- Prüfe Internetverbindung
- Prüfe Supabase-Status: https://status.supabase.com
- Erhöhe Timeout in Tests (default 5 Sekunden)

### Problem: "SupabaseClient not available"
**Ursache**: Autoload nicht geladen  
**Lösung**:
```
Project Settings → Autoload → Prüfe ob SupabaseClient aktiv ist
```

### Problem: "HMAC secret not found"
**Ursache**: .env Datei fehlt oder BKTD_HMAC_SECRET nicht gesetzt  
**Lösung**:
```bash
# Erstelle .env aus Template
cp .env.example .env

# Generiere HMAC Secret
echo "BKTD_HMAC_SECRET=$(openssl rand -hex 32)" >> .env

# Godot neu starten
```

### Problem: "Could not authenticate for test"
**Ursache**: Supabase-Credentials fehlen oder falsch  
**Lösung**:
```bash
# Prüfe .env
cat .env | grep SUPABASE

# Sollte enthalten:
SUPABASE_URL=https://porfficpmtayqccmpsrw.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

### Problem: Cloud-Tests werden übersprungen
**Ursache**: Nicht authentifiziert (erwartet)  
**Lösung**: Dies ist normal. Cloud-Tests benötigen einen authentifizierten User.
- Entweder: Registrierung in Auth-Tests laufen lassen (passiert automatisch)
- Oder: Manuell im Spiel einloggen vor Test-Ausführung

---

## 🎯 Test-Strategie

### Für Entwicklung:
```bash
# Nur lokale Tests (schnell, kein Netzwerk nötig)
- test_local_save_basic
- test_local_load_basic
- test_hmac_checksum_generation
- test_hmac_checksum_validation
- test_save_data_structure
- test_rate_limiting
- Component Integration Tests
```

### Für Pre-Deployment:
```bash
# Alle Tests (inkl. Cloud + Auth)
- AuthFlowTests (alle 10 Tests)
- CloudSaveTests (alle 10 Tests)
- ComponentIntegrationTests
```

### Für CI/CD:
```bash
# Headless Godot mit Test-Runner
godot --headless --path . scenes/tests/Sprint4Tests.tscn

# Exit Code prüfen (0 = success, 1 = failure)
if [ $? -eq 0 ]; then
  echo "All tests passed"
else
  echo "Tests failed"
  exit 1
fi
```

---

## 📝 Test-Ergebnisse Auswerten

### Logs:
- **Godot Console**: Echtzeit-Ausgabe während Tests
- **Godot Output Panel**: Nach Test-Ausführung
- **Log-Datei**: `user://logs/test_results.log` (falls konfiguriert)

### Metriken:
```
Total Tests: Anzahl aller ausgeführten Tests
Passed: Erfolgreich abgeschlossene Tests
Failed: Fehlgeschlagene Tests
Success Rate: Prozentsatz erfolgreicher Tests

Ziel: 100% Success Rate
Minimum: 90% Success Rate (10% dürfen fehlschlagen wegen Netzwerk)
```

---

## 🧪 Test-Framework (für Entwickler)

### Test-Kategorien:
- **Speed Tests**: Projektil vs Enemy Geschwindigkeit, Speed-Modi (1x, 2x, 3x)
- **Game Mechanics Tests**: Tower Placement, Enemy Spawning, Projektil-Homing
- **UI Tests**: Buttons, Hotkeys, Range-Indikatoren
- **Save System Tests**: Datenstruktur, Load/Save, Persistenz

### Neue Features hinzufügen:
```gdscript
# 1. Feature zum Reminder-System hinzufügen
quick_test_new_tower_type("Laser Tower")

# 2. Feature implementieren

# 3. Tests hinzufügen zu TestFramework.gd
func test_laser_tower_placement():
    # Test implementation
    pass

# 4. Als getestet markieren
mark_feature_tested("tower_laser_tower")
```

### Test-Coverage prüfen:
```gdscript
# In Main.gd
print_test_coverage_report()
```

**Performance Impact:**
- Production (keine Tests): 0% Overhead
- Development (alle Tests): 2-5% Overhead, +5-10MB RAM
- Debug (alle Tests + Verbose): 5-10% Overhead, +10-15MB RAM

---

## 🚀 Nächste Schritte nach erfolgreichen Tests

1. ✅ Alle Tests laufen erfolgreich (100%)
2. → Server-Side Validation deployen (SQL Triggers in Supabase)
3. → Production Environment Variables setzen (Netlify/Vercel)
4. → CORS in Supabase verifizieren
5. → Production Deployment

---

## 📞 Support

- **Test-Pattern Docs**: `tests/TEST_FIXES_README.md`
- **Projekt Status**: `PROJECT_STATUS_AND_ROADMAP.md`
- **Testing Summary**: `TESTING_AND_VALIDATION_SUMMARY.md`

---

**Status**: ✅ Ready to Run  
**Test Coverage**: 20/20 Tests (100%)  
**Last Updated**: 2025-01-12
