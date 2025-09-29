# 🧪 BeeKeeperTD Testing Framework Documentation

## 📋 Overview

Das **BeeKeeperTD Testing Framework** ist ein umfassendes, automatisiertes Testsystem, das die Qualität und Stabilität des Spiels sicherstellt. Es wurde speziell für Tower Defense Gameplay entwickelt und bietet kontinuierliche Überwachung der kritischen Systeme.

**Version**: 2.0  
**Letzte Aktualisierung**: 2024-12-19  
**Status**: Production Ready

---

## 🎯 Framework Features

### **Automatisierte Tests**
- **Continuous Testing**: Kontinuierliche Überwachung der Systeme
- **Event-Driven Testing**: Tests werden bei bestimmten Ereignissen ausgelöst
- **Performance Monitoring**: Überwachung der Systemleistung
- **Error Detection**: Automatische Fehlererkennung

### **Test-Kategorien**
1. **Speed Tests** 🏃 - Geschwindigkeits- und Performance-Tests
2. **Mechanics Tests** 🎮 - Gameplay-Mechaniken
3. **UI Tests** 🖥️ - Benutzeroberfläche und Interaktionen
4. **Save System Tests** 💾 - Speicher- und Lade-System
5. **Tower Defense Tests** 🏰 - Kern-Tower Defense Funktionalität

---

## 🏗️ Architecture

### **Core Components**

#### **TestFramework.gd** - Haupt-Test-Framework
```gdscript
class_name TestFramework
extends Node

# Haupt-Test-Framework für BeeKeeperTD
# Verantwortlich für:
# - Test-Ausführung
# - Ergebnis-Sammlung
# - Bericht-Generierung
```

#### **TestRunner.gd** - Test-Ausführung
```gdscript
class_name TestRunner
extends Node

# Test-Ausführung und -Verwaltung
# Verantwortlich für:
# - Test-Orchestrierung
# - Ergebnis-Validierung
# - Performance-Überwachung
```

#### **ContinuousTesting.gd** - Kontinuierliche Tests
```gdscript
class_name ContinuousTesting
extends Node

# Kontinuierliche Test-Ausführung
# Verantwortlich für:
# - Automatische Test-Auslösung
# - Event-basierte Tests
# - Performance-Überwachung
```

#### **TestingConfig.gd** - Test-Konfiguration
```gdscript
class_name TestingConfig
extends Node

# Test-Konfiguration und -Einstellungen
# Verantwortlich für:
# - Environment-Detection
# - Test-Parameter
# - Performance-Einstellungen
```

---

## 🧪 Test Categories

### **1. Speed Tests** 🏃

#### **Test: Projectile Speed Ratios**
```gdscript
func test_projectile_speed_ratios():
    # Testet Geschwindigkeitsverhältnisse zwischen Projektilen und Gegnern
    # Bei verschiedenen Geschwindigkeitsmodi (1x, 2x, 3x)
    # Erwartet: Projektile sind immer schneller als Gegner
```

#### **Test: Speed Mode Transitions**
```gdscript
func test_speed_mode_transitions():
    # Testet Übergänge zwischen Geschwindigkeitsmodi
    # Zyklus: 0 -> 1 -> 2 -> 0
    # Erwartet: Korrekte Modi-Abfolge
```

#### **Test: Performance Scaling**
```gdscript
func test_performance_scaling():
    # Testet Performance bei verschiedenen Geschwindigkeiten
    # Erwartet: Stabile Performance bei allen Modi
```

### **2. Mechanics Tests** 🎮

#### **Test: Tower Placement**
```gdscript
func test_tower_placement():
    # Testet Turm-Platzierung
    # Erwartet: Türme können mit ausreichend Honey platziert werden
```

#### **Test: Enemy Spawning**
```gdscript
func test_enemy_spawning():
    # Testet Gegner-Spawning
    # Erwartet: Gegner spawnen mit korrekten Eigenschaften
```

#### **Test: Projectile Homing**
```gdscript
func test_projectile_homing():
    # Testet zielsuchende Projektile
    # Erwartet: Projektile verfolgen Ziele korrekt
```

#### **Test: Collision Detection**
```gdscript
func test_collision_detection():
    # Testet Kollisionserkennung
    # Erwartet: Projektile treffen Gegner korrekt
```

### **3. UI Tests** 🖥️

#### **Test: Button Functionality**
```gdscript
func test_button_functionality():
    # Testet Button-Funktionalität
    # Erwartet: Alle Buttons funktionieren korrekt
```

#### **Test: Hotkey System**
```gdscript
func test_hotkey_system():
    # Testet Tastenkürzel-System
    # Erwartet: Hotkeys funktionieren wie erwartet
```

#### **Test: Range Indicators**
```gdscript
func test_range_indicators():
    # Testet Reichweiten-Indikatoren
    # Erwartet: Reichweiten werden korrekt angezeigt
```

### **4. Save System Tests** 💾

#### **Test: Save Data Structure**
```gdscript
func test_save_data_structure():
    # Testet Speicher-Datenstruktur
    # Erwartet: Alle erforderlichen Felder sind vorhanden
```

#### **Test: Load Functionality**
```gdscript
func test_load_functionality():
    # Testet Lade-Funktionalität
    # Erwartet: Spielstand wird korrekt geladen
```

#### **Test: Data Persistence**
```gdscript
func test_data_persistence():
    # Testet Daten-Persistenz
    # Erwartet: Daten bleiben zwischen Sessions erhalten
```

### **5. Tower Defense Tests** 🏰

#### **Test: Wave Management**
```gdscript
func test_wave_management():
    # Testet Wellen-Management
    # Erwartet: Wellen starten und enden korrekt
```

#### **Test: Tower Attacks**
```gdscript
func test_tower_attacks():
    # Testet Turm-Angriffe
    # Erwartet: Türme greifen Gegner korrekt an
```

#### **Test: Enemy Movement**
```gdscript
func test_enemy_movement():
    # Testet Gegner-Bewegung
    # Erwartet: Gegner folgen dem Pfad korrekt
```

#### **Test: Victory Conditions**
```gdscript
func test_victory_conditions():
    # Testet Sieg-Bedingungen
    # Erwartet: Sieg wird korrekt erkannt
```

---

## ⚙️ Configuration

### **Environment Detection**

#### **Development Mode**
```gdscript
# Automatische Erkennung von Development-Builds
is_development = (
    OS.is_debug_build() or
    OS.has_feature("debug") or
    OS.get_environment("GODOT_DEBUG") == "1" or
    OS.get_environment("BEEKEEPER_DEBUG") == "1"
)
```

#### **Production Mode**
```gdscript
# Production-Builds haben minimale Tests
is_production = not is_development
testing_enabled = OS.get_environment("BEEKEEPER_TESTING") == "1"
```

### **Test Frequency**

#### **Development Mode**
- **Test Frequency**: 30 Sekunden
- **Test Categories**: Alle aktiviert
- **Performance Impact**: 2-5%
- **Memory Usage**: +5-10MB

#### **Production Mode**
- **Test Frequency**: 120 Sekunden (nur wenn aktiviert)
- **Test Categories**: Nur kritische Tests
- **Performance Impact**: <1%
- **Memory Usage**: +2-3MB

---

## 🚀 Usage

### **Automatic Testing**

#### **Development Builds**
```gdscript
# Tests laufen automatisch in Development-Builds
# Keine manuelle Konfiguration erforderlich
```

#### **Production Builds**
```bash
# Tests nur aktivieren wenn gewünscht
set BEEKEEPER_TESTING=1
```

### **Manual Testing**

#### **Run All Tests**
```gdscript
var test_runner = TestRunner.new()
add_child(test_runner)
test_runner.run_all_tests()
```

#### **Run Specific Categories**
```gdscript
test_runner.run_speed_tests()
test_runner.run_mechanics_tests()
test_runner.run_ui_tests()
test_runner.run_save_tests()
test_runner.run_tower_defense_tests()
```

#### **Quick Checks**
```gdscript
test_runner.quick_speed_check()
test_runner.quick_mechanics_check()
test_runner.quick_ui_check()
```

---

## 📊 Test Results

### **Test Report Format**

#### **Individual Test Results**
```
✅ PASS: Projectile Speed Ratios - All projectiles are faster than enemies
❌ FAIL: Tower Placement - Cannot place tower with insufficient honey
```

#### **Test Suite Summary**
```
📊 TEST REPORT
============================================================
Total Tests: 25
Passed: 23
Failed: 2
Success Rate: 92.0%
============================================================
```

### **Performance Metrics**

#### **Speed Test Results**
```
--- Testing Normal (1x) (time_scale: 1.0) ---
Enemy Speed: 60.0 px/s
Basic Shooter Projectile: 375.0 px/s (6.25x faster)
Piercing Shooter Projectile: 312.5 px/s (5.21x faster)
✅ PASS: All projectiles are faster than enemies
```

#### **Performance Impact**
```
📊 Current Testing Status:
  Auto testing: true
  Frequency: 30.0 seconds
  Triggers: {speed_change: true, tower_placement: true, wave_start: true, save_load: true}
```

---

## 🔧 Integration

### **Game Event Integration**

#### **Speed Change Events**
```gdscript
func on_speed_mode_changed(new_mode: int):
    if test_on_speed_change and is_development_build:
        test_runner.run_speed_tests()
```

#### **Tower Placement Events**
```gdscript
func on_tower_placed(tower_type: String, position: Vector2):
    if test_on_tower_placement and is_development_build:
        test_runner.run_tests_on_tower_placement()
```

#### **Wave Start Events**
```gdscript
func on_wave_started(wave_number: int):
    if test_on_wave_start and is_development_build:
        test_runner.run_tests_on_wave_start()
```

### **Test Reminder System**

#### **Feature Update Notifications**
```gdscript
# In Main.gd
func add_new_feature(feature_name: String, description: String, required_tests: Array[String]):
    pending_test_updates.append(feature_name)
    print("📝 Added new feature '%s' - tests required!" % feature_name)
```

#### **Test Completion Tracking**
```gdscript
func mark_feature_tested(feature_name: String):
    if feature_name in pending_test_updates:
        pending_test_updates.erase(feature_name)
        print("✅ Feature '%s' tests completed!" % feature_name)
```

---

## 📈 Performance Monitoring

### **Memory Usage**

#### **Development Mode**
- **Base Memory**: ~50MB
- **Testing Overhead**: +5-10MB
- **Total Memory**: ~60MB

#### **Production Mode**
- **Base Memory**: ~50MB
- **Testing Overhead**: +2-3MB (nur wenn aktiviert)
- **Total Memory**: ~53MB

### **CPU Usage**

#### **Test Execution**
- **Speed Tests**: <1% CPU
- **Mechanics Tests**: <2% CPU
- **UI Tests**: <1% CPU
- **Save Tests**: <1% CPU
- **Total Overhead**: <5% CPU

### **Frame Rate Impact**

#### **During Testing**
- **Normal Gameplay**: 60 FPS
- **Test Execution**: 58-60 FPS
- **Performance Impact**: Minimal

---

## 🛠️ Troubleshooting

### **Common Issues**

#### **Tests Not Running**
```gdscript
# Check environment detection
print("Development Mode: %s" % is_development)
print("Testing Enabled: %s" % testing_enabled)
```

#### **Performance Issues**
```gdscript
# Disable testing in production
TestingConfig.disable_testing()
```

#### **Test Failures**
```gdscript
# Check test results
test_runner.print_test_status()
```

### **Debug Information**

#### **Enable Verbose Logging**
```gdscript
TestingConfig.enable_verbose_mode()
```

#### **Check Test Configuration**
```gdscript
TestingConfig.print_configuration()
```

---

## 📝 Best Practices

### **Adding New Features**

#### **1. Add to Reminder System**
```gdscript
# In Main.gd
quick_test_new_tower_type("Laser Tower")
```

#### **2. Implement Tests**
```gdscript
# In TestFramework.gd
func test_laser_tower_placement():
    # Test laser tower specific placement logic
    pass
```

#### **3. Mark as Tested**
```gdscript
# In Main.gd
mark_feature_tested("tower_laser_tower")
```

### **Test Maintenance**

#### **Regular Updates**
- Update tests when features change
- Add new test cases for new features
- Remove obsolete tests
- Update test documentation

#### **Performance Monitoring**
- Monitor test execution time
- Check memory usage
- Verify frame rate impact
- Optimize slow tests

---

## 🎯 Future Enhancements

### **Planned Features**

#### **Advanced Testing**
- **Visual Testing**: Screenshot comparison
- **Load Testing**: Stress testing with many objects
- **Integration Testing**: Cross-system testing
- **Regression Testing**: Automated regression detection

#### **Enhanced Reporting**
- **HTML Reports**: Web-based test reports
- **Trend Analysis**: Performance trend tracking
- **Alert System**: Automatic failure notifications
- **Dashboard**: Real-time test status

#### **CI/CD Integration**
- **Automated Builds**: Test on every commit
- **Quality Gates**: Block releases on test failures
- **Performance Baselines**: Track performance over time
- **Release Validation**: Comprehensive pre-release testing

---

## 📚 Additional Resources

### **Documentation**
- **TESTING_README.md**: Quick start guide
- **PRD_BeeKeeperTD_v2.0.md**: Product requirements
- **DEVELOPMENT_PLAN_v2.0.md**: Development roadmap

### **Code Examples**
- **TestFramework.gd**: Main framework implementation
- **TestRunner.gd**: Test execution examples
- **ContinuousTesting.gd**: Automated testing setup
- **TestingConfig.gd**: Configuration examples

### **Troubleshooting**
- **Common Issues**: Frequently encountered problems
- **Debug Guide**: Step-by-step debugging
- **Performance Guide**: Optimization tips
- **Integration Guide**: System integration help

---

**Document Status**: Active  
**Last Updated**: 2024-12-19  
**Next Review**: 2024-12-26  
**Maintainer**: Development Team
