# 🔴 Technical Debt & TODO

**Projekt**: BeeKeeperTD  
**Erstellt**: 2025-01-12  
**Status**: 🟡 **Needs Attention**

---

## 📋 CRITICAL TODO ITEMS

### **1. 🧪 Test-Dateien neu schreiben (GDScript-kompatibel)**

**Priority**: 🟡 MEDIUM  
**Deadline**: Vor Production Launch  
**Assignee**: Development Team

#### **Betroffene Dateien:**
- ❌ `scripts/ComprehensiveVectorTests.gd` (DELETED - 474 lines)
- ❌ `scripts/UIElementVectorTests.gd` (DELETED)
- ✅ `scripts/VectorTypeTests.gd` (FIXED - konvertiert zu GDScript)

#### **Problem:**
Test-Dateien wurden in **Python-Syntax** geschrieben (`try/except`), was in GDScript nicht funktioniert. Dies verursachte Parse Errors beim Godot-Start.

#### **Lösung (Temporär):**
- `VectorTypeTests.gd`: Konvertiert zu GDScript (if-Checks statt try/except)
- `ComprehensiveVectorTests.gd` & `UIElementVectorTests.gd`: **GELÖSCHT**

#### **Richtige Lösung (TODO):**
```gdscript
# GDScript hat KEIN try/except!
# Stattdessen:

func test_example() -> bool:
    var v1 = Vector2(100, 200)
    var v2 = Vector2(50, 75)
    
    var result = v1 + v2
    if result != Vector2(150, 275):
        print("❌ Test failed: Expected Vector2(150, 275), got ", result)
        return false
    
    print("✅ Test passed")
    return true
```

#### **Action Items:**
- [ ] Neu schreiben: `ComprehensiveVectorTests.gd` (10 Tests, ~400 lines)
- [ ] Neu schreiben: `UIElementVectorTests.gd` (~200 lines)
- [ ] Integration in Test-Suite: `tests/Sprint4Tests.tscn`
- [ ] CI/CD Integration (optional)

**Estimated Time**: 2-3 Stunden  
**Impact**: 🔵 LOW - Nur Development/Debug, nicht im Production Build

---

## 📏 FILE SIZE GUIDELINES

### **Regel: Dateien > 500 Zeilen sollten refaktoriert werden**

**Warum?**
- Bessere Wartbarkeit
- Einfacheres Code Review
- Vermeidung von "God Classes"
- Tool-Kompatibilität (z.B. MultiEdit limits)

**Guidelines:**
```
✅ GOOD:  < 300 Zeilen (Ideal)
🟡 OK:    300-500 Zeilen (Akzeptabel)
🟠 WARN:  500-800 Zeilen (Sollte refaktoriert werden)
🔴 BAD:   > 800 Zeilen (MUSS refaktoriert werden)
```

### **Ausnahmen:**
- Scene Files (`.tscn`) - können länger sein
- Auto-Generated Code
- Data Files (JSON, Configuration)

---

## 🔍 CURRENT FILE SIZE AUDIT

### **Dateien über 500 Zeilen (Stand: 2025-01-12)**

#### **🔴 CRITICAL (> 800 Zeilen) - MUSS refaktoriert werden**

| File | Lines | Status | Action Required |
|------|-------|--------|-----------------|
| `scripts/TowerDefense.gd` | 847 | 🔴 CRITICAL | **Refactoring REQUIRED** |

**Empfohlene Aufteilung für TowerDefense.gd:**
```
TowerDefense.gd (Main Controller ~200 lines)
├── tower_defense/TDState.gd (State Management)
├── tower_defense/TDInput.gd (Input Processing)
└── tower_defense/TDEvents.gd (Event Handling)

Note: TDUIManager, TDWaveController, TDMetaprogression bereits ausgelagert ✅
```

**Priority**: 🟡 MEDIUM  
**Deadline**: Nach Production Launch  
**Estimated Time**: 4-6 Stunden

---

#### **🟠 WARNING (500-800 Zeilen) - Sollte refaktoriert werden**

| File | Lines | Status | Action Required |
|------|-------|--------|-----------------|
| `scripts/TestFramework.gd` | 734 | 🟠 WARNING | Review for potential split |
| `autoloads/SaveManager.gd` | 722 | 🟠 WARNING | Consider splitting |

**TestFramework.gd** (734 lines):
- Development-only utility
- Priority: 🔵 LOW
- Action: Review after production launch

**SaveManager.gd** (722 lines):
- Critical autoload
- Priority: 🟡 MEDIUM  
- Possible split:
  ```
  SaveManager.gd (Main API)
  ├── SaveWriter.gd
  ├── SaveReader.gd
  └── CloudSaveSync.gd
  ```

---

#### **🟡 ACCEPTABLE (300-500 Zeilen)**

| File | Lines | Status |
|------|-------|--------|
| `tower_defense/TDMetaprogression.gd` | 461 | 🟡 GOOD |
| `tower_defense/TDUIManager.gd` | 448 | 🟡 GOOD |
| `autoloads/SupabaseClient.gd` | 434 | 🟡 GOOD |
| `TowerPlacer.gd` | 384 | 🟡 GOOD |
| `Projectile.gd` | 351 | 🟡 GOOD |
| `VectorTypeTests.gd` | 312 | 🟡 GOOD |

**Status**: ✅ Acceptable, kein sofortiger Handlungsbedarf

---

#### **✅ IDEAL (< 300 Zeilen)**

**Anzahl**: 32 Dateien  
**Status**: ✅ Excellent file size  
**Details**: Siehe vollständiger Audit-Report unten

---

### **📊 Summary Statistics**

```
Total Files Scanned: 40
├── ✅ IDEAL (< 300):      32 files (80%)
├── 🟡 GOOD (300-500):      6 files (15%)
├── 🟠 WARNING (500-800):   2 files (5%)
└── 🔴 CRITICAL (> 800):    1 file  (2.5%)
```

**Overall Score**: 🟡 **GOOD** (95% under 500 lines)

---

**Scan-Befehl:**
```powershell
Get-ChildItem -Path "scripts","autoloads" -Filter "*.gd" -Recurse | 
    ForEach-Object { 
        $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
        [PSCustomObject]@{
            File = $_.FullName.Replace($PWD.Path + "\", "")
            Lines = $lines
            Status = if ($lines -gt 800) { "🔴 CRITICAL" } 
                     elseif ($lines -gt 500) { "🟠 WARNING" } 
                     elseif ($lines -gt 300) { "🟡 GOOD" } 
                     else { "✅ IDEAL" }
        }
    } | Sort-Object Lines -Descending
```

---

## 📦 REFACTORING CANDIDATES

### **1. TowerDefense.gd (wenn > 800 Zeilen)**

**Potenzielle Splits:**
```
TowerDefense.gd (Main Controller)
├── TowerDefenseState.gd (State Management)
├── TowerDefenseUI.gd (UI Handling)
├── TowerDefenseInput.gd (Input Processing)
└── TowerDefenseEvents.gd (Event Handling)
```

### **2. SaveManager.gd (wenn > 800 Zeilen)**

**Potenzielle Splits:**
```
SaveManager.gd (Main API)
├── SaveWriter.gd (File Writing)
├── SaveReader.gd (File Reading)
├── SaveValidator.gd (Data Validation)
└── CloudSaveSync.gd (Cloud Integration)
```

### **3. SupabaseClient.gd (wenn > 800 Zeilen)**

**Potenzielle Splits:**
```
SupabaseClient.gd (Main API)
├── SupabaseAuth.gd (Authentication)
├── SupabaseDatabase.gd (Database Operations)
└── SupabaseStorage.gd (File Storage)
```

---

## 🛠️ REFACTORING PROCESS

### **Schritt-für-Schritt:**

1. **Analyze**
   - Identifiziere logische Komponenten
   - Prüfe Abhängigkeiten
   - Erstelle Refactoring Plan

2. **Split**
   - Erstelle neue Dateien
   - Move Functions (mit Dokumentation)
   - Update References

3. **Test**
   - Alle Tests durchlaufen
   - Manuelle Funktionsprüfung
   - Performance Check

4. **Document**
   - Update Code Comments
   - Update Architecture Docs
   - Git Commit mit ausführlicher Message

5. **Review**
   - Code Review (optional bei Solo Dev)
   - Integration Test
   - Deployment Test

---

## 📊 TECHNICAL DEBT METRICS

### **Current Debt Score: 🟡 MEDIUM**

| Kategorie | Score | Details |
|-----------|-------|---------|
| Code Quality | 8/10 | ✅ Gut strukturiert, wenig Duplication |
| Test Coverage | 6/10 | ⚠️ Tests teilweise gelöscht (see above) |
| Documentation | 9/10 | ✅ Sehr gut dokumentiert |
| File Size | 7/10 | 🟡 Einige große Dateien (needs audit) |
| Architecture | 9/10 | ✅ Modulare Component-Based Structure |
| Security | 9.5/10 | ✅ Environment Variables, HMAC, SQL Triggers |

**Improvement Plan:**
1. Test-Suite komplett funktionsfähig machen (Priority 1)
2. File Size Audit durchführen (Priority 2)
3. Refactoring wo nötig (Priority 3)

---

## 🎯 ACTION PLAN

### **Phase 1: Immediate (Vor Web Export)**
- [x] TDSaveSystem.gd await fix
- [x] VectorTypeTests.gd konvertiert
- [ ] Dokumentation erstellt (this file)

### **Phase 2: Pre-Production (Diese Woche)**
- [ ] File Size Audit durchführen
- [ ] Refactoring Plan für große Dateien
- [ ] Tests neu schreiben (ComprehensiveVectorTests, UIElementVectorTests)

### **Phase 3: Post-Launch (Nächste Woche)**
- [ ] Refactoring umsetzen (falls nötig)
- [ ] CI/CD Integration (optional)
- [ ] Performance Optimizations

---

## 📝 LESSONS LEARNED

### **Was wir gelernt haben:**

1. **❌ Niemals Python-Syntax in GDScript**
   - GDScript hat kein `try/except`
   - GDScript hat kein `Exception` Typ
   - Verwende `if`-Checks und early returns

2. **✅ File Size Guidelines einhalten**
   - > 500 Zeilen = Refactoring kandidat
   - Früh aufteilen, nicht später
   - Modulare Struktur von Anfang an

3. **✅ Test-Code ist Production-Code**
   - Gleiche Quality Standards
   - Gleiche Syntax Rules
   - Nicht "Quick & Dirty"

4. **✅ Technical Debt dokumentieren**
   - Nicht verstecken
   - Offen kommunizieren
   - Mit Deadline versehen

---

## 🔗 RELATED DOCUMENTS

- `MD-Files/06-Status/Project_Status.md` - Overall Project Status
- `SESSION_SUMMARY_2025-01-12.md` - Today's Session Summary
- `MD-Files/02-Setup/WEB_EXPORT_GUIDE.md` - Web Export Instructions

---

**Last Updated**: 2025-01-12  
**Next Review**: Nach Web Export  
**Owner**: Development Team
