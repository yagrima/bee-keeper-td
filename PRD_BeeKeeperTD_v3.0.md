# 🐝 BeeKeeperTD - Product Requirements Document v3.0

## 📋 Executive Summary

**BeeKeeperTD** ist ein Tower Defense Spiel im Bienen-Theme mit innovativen Gameplay-Mechaniken, Metaprogression-System und umfassender Test-Automatisierung.

**Version**: 3.0  
**Letzte Aktualisierung**: 2025-09-29  
**Status**: Active Development - Web App & Session System Phase

---

## 🎯 Core Gameplay

### **Tower Defense Mechaniken**
- **Tower Placement**: Strategische Turmplatzierung auf 20x15 Grid (640x480 px)
- **Enemy Waves**: 5 Wellen mit progressiver Schwierigkeit
- **Resource Management**: Honey-basierte Wirtschaft
- **Tower Types**: 4 Bienen-thematische Turmtypen mit einzigartigen Fähigkeiten
- **Metaprogression Fields**: 5 Felder für tower-basierte Metaprogression

### **Aktuelle Features (v3.0)**

#### **1. Metaprogression System** 🎯
- **5 Metaprogression Fields**: 2x2 Grid-Felder unterhalb des Spielfelds
- **Random Tower Assignment**: Zufällige Zuweisung der 4 Basisturmtypen
- **Free Placement**: Türme aus Feldern können kostenlos platziert werden
- **Tower Pickup**: Linksklick zum Aufnehmen, Linksklick zum Platzieren
- **Return on Fail**: Turm kehrt bei ungültiger Platzierung zum Feld zurück
- **Visual Feedback**: Zentrierte Türme in Feldern, keine Beschriftungen

#### **2. Tower Hotkey System** ⌨️
- **Q/W/E/R Hotkeys**: Direkter Zugriff auf alle 4 Turmtypen
- **Toggle Functionality**: Erneuter Druck schließt Baumenü
- **Tower Switching**: Nahtloser Wechsel zwischen Turmtypen
- **Grid Snapping**: Automatische Grid-Ausrichtung
- **Instant Preview**: Turm erscheint sofort am Mauszeiger

#### **3. Wave Scaling System** 📈
- **Progressive Difficulty**: Gegner werden mit jeder Welle 35% stärker
- **Skalierungsfaktor**: 1.35x pro Welle (konfigurierbar in WaveScalingConfig)
- **Beispiel**: Welle 5 = 3.32x HP (132.8 HP statt 40 HP)
- **Health Bar Updates**: Automatische Anpassung der Lebensbalken
- **Honey Rewards**: Skalierte Belohnungen für stärkere Gegner

#### **4. 3-Stufiges Speed System** ⚡
- **Geschwindigkeiten**: 1x (normal), 2x (doppelt), 3x (dreifach)
- **Hotkey**: Q-Taste zum Wechseln zwischen Modi
- **Projektile**: Automatische Geschwindigkeitsanpassung (1.25x Multiplikator)
- **UI Integration**: Geschwindigkeitsanzeige im Button ("Q (1x)", "Q (2x)", "Q (3x)")
- **Wave Countdown**: Geschwindigkeitsabhängige Auto-Wave-Progression (15s/10s/5s)

#### **5. Automatic Wave Progression** ⏱️
- **Speed-Dependent Delays**: 15s (1x), 10s (2x), 5s (3x) zwischen Wellen
- **Countdown Timer**: Sekundengenauer Countdown bis zur nächsten Welle
- **Visual Feedback**: Timer unterhalb der Wellenanzeige
- **Manual Override**: Start Wave Button überspringt Countdown

#### **6. Tower Placement Blocking** 🚫
- **Occupation Check**: Verhindert Platzierung auf belegten Positionen
- **Cross-System**: Funktioniert für Hotkey- und Metaprogression-Türme
- **Real-Time Validation**: Kontinuierliche Überprüfung während Placement
- **Visual Feedback**: Rote Preview bei ungültiger Position

#### **7. Automatisiertes Testing Framework** 🧪
- **Vollständiges Testsystem**: Umfassende Test-Automatisierung
- **Test-Kategorien**: Speed, Mechanics, UI, Save System, Tower Defense, Placement Blocking
- **Development/Production Modes**: Automatische Erkennung
- **Continuous Testing**: Tower Placement Blocking Test läuft alle 1s
- **Test-Erinnerungen**: Automatische Benachrichtigungen für neue Features

---

## 🏗️ Technical Architecture

### **Core Systems**

#### **Game State Management**
- **GameManager**: Zentrale Spielzustandsverwaltung, Resource Management
- **SceneManager**: Szenenübergänge und Navigation
- **HotkeyManager**: Konfigurierbare Tastenkürzel (JSON-Config)
- **SaveManager**: JSON-basierte Speicherung mit Tower Persistence

#### **Tower Defense Core**
- **Tower System**: Modulare Turm-Implementierung mit 4 Basistypen
- **Enemy System**: Skalierbare Gegner mit dynamischen Health Bars
- **Projectile System**: Homing-Geschosse mit Geschwindigkeitsanpassung
- **Wave Management**: Automatische Wave-Progression mit Countdown
- **TowerPlacer**: Unified placement system für Hotkey- und Metaprogression-Türme

#### **Metaprogression System**
- **Field Management**: 5 Felder mit 2x2 Grid-Größe
- **Tower Assignment**: Zufällige Zuweisung bei Map-Start
- **Pickup System**: Tower Pickup mit Original-Position-Speicherung
- **Placement Validation**: Cross-system validation mit Koordinatensystem-Handling
- **Return System**: Automatische Rückkehr bei fehlgeschlagener Platzierung

#### **UI System**
- **Dynamic UI**: Automatische UI-Generierung mit map_offset
- **Range Indicators**: Visuelle Reichweitenanzeige (rund, blau-weiß)
- **Speed Controls**: 3-stufiges Geschwindigkeitssystem mit UI-Feedback
- **Tower Selection**: Crash-freie Turmauswahl mit Range-Display
- **Wave Countdown**: Sekundengenauer Timer mit Farbcodierung

#### **Coordinate Systems**
- **Map Coordinates**: Spielfeld-relative Koordinaten (0-640, 0-480)
- **UI Coordinates**: Screen-Koordinaten mit map_offset
- **Grid Coordinates**: 32x32 Grid-Zellen (20x15)
- **Conversion Logic**: Konsistente Koordinaten-Umrechnung

### **Testing Framework**

#### **Test Categories**
- **Speed Tests**: Projektile vs. Gegner-Geschwindigkeiten bei allen Speed-Modi
- **Mechanics Tests**: Tower Placement, Enemy Spawning, Collision Detection
- **UI Tests**: Button Functionality, Hotkey System, Range Indicators
- **Save System Tests**: Data Structure, Load/Save Functionality
- **Tower Defense Tests**: Wave Management, Victory Conditions, Scaling
- **Placement Blocking Tests**: Occupation Check, Cross-System Blocking, Grid Boundary

#### **Continuous Testing**
- **TowerPlacementBlockingTest**: Läuft alle 1s während Gameplay
- **Validates**: Occupied positions, Metaprogression positions, Cross-system blocking
- **Auto-Summary**: Alle 30s Zusammenfassung der Test-Ergebnisse
- **Manual Triggers**: Force-Test-Now Funktion für sofortige Validierung

#### **Performance Optimization**
- **Development Mode**: Umfassende Tests (2-5% Performance Impact)
- **Production Mode**: Minimale Tests (0% Performance Impact)
- **Automatic Detection**: Environment-basierte Konfiguration

---

## 🎮 Game Features

### **Tower Types**

#### **Stinger Tower** 🔫
- **Damage**: 8.0 (Low)
- **Range**: 80.0 (Short)
- **Attack Speed**: 2.5 (Very Fast)
- **Cost**: 20 Honey
- **Special**: Schnelle Einzelziel-Angriffe
- **Hotkey**: Q
- **Projectile**: Klein, rot

#### **Propolis Bomber Tower** 💣
- **Damage**: 35.0 (Very High)
- **Range**: 100.0 (Medium)
- **Attack Speed**: 0.8 (Slow)
- **Cost**: 45 Honey
- **Special**: Explosions-Spezialist, Flächenschaden
- **Hotkey**: W
- **Projectile**: Groß, dunkel-bernsteinbraun (16x12 px), leuchtender Kern
- **Splash**: 40.0 Radius

#### **Nectar Sprayer Tower** 🌼
- **Damage**: 15.0 (Medium)
- **Range**: 100.0 (Medium)
- **Attack Speed**: 1.5 (Medium)
- **Cost**: 30 Honey
- **Special**: Penetriert 3 Gegner
- **Hotkey**: E
- **Projectile**: Golden

#### **Lightning Flower Tower** ⚡
- **Damage**: 12.0 (Medium-Low)
- **Range**: 90.0 (Short-Medium)
- **Attack Speed**: 2.0 (Fast)
- **Cost**: 35 Honey
- **Special**: Chain-Angriffe zwischen Gegnern
- **Hotkey**: R
- **Projectile**: Elektrisch

### **Enemy System**

#### **Standard Enemy (Worker Wasp)**
- **Base Health**: 40.0 HP
- **Movement Speed**: 60.0 px/s
- **Honey Reward**: 3 (base), skaliert mit Welle
- **Wave Scaling**: 1.35x per wave
- **Visual**: Health bar mit dynamischer Anpassung

### **Wave Progression**

| Wave | Enemies | Scaling Factor | Total HP | Shots to Kill (Stinger) | Auto-Start Delay |
|------|---------|----------------|----------|-------------------------|------------------|
| 1    | 5       | 1.0x          | 40.0     | 5                       | 15s (1x), 10s (2x), 5s (3x) |
| 2    | 8       | 1.35x         | 54.0     | 7                       | 15s (1x), 10s (2x), 5s (3x) |
| 3    | 9       | 1.82x         | 72.8     | 9                       | 15s (1x), 10s (2x), 5s (3x) |
| 4    | 10      | 2.46x         | 98.4     | 12                      | 15s (1x), 10s (2x), 5s (3x) |
| 5    | 12      | 3.32x         | 132.8    | 17                      | - (Game End) |

---

## 🎨 User Interface

### **Main Menu**
- **Play Button**: Start Tower Defense
- **Settlement Button**: Settlement Management (Coming Soon)
- **Load Button**: Save Game Loading
- **Quit Button**: Exit Game

### **Tower Defense UI**

#### **Top-Left: Game Information**
- **Resource Display**: Honey count
- **Health Display**: Player life points
- **Wave Information**: Current wave / Total waves
- **Wave Composition**: Real-time enemy count display
- **Wave Countdown**: "Next wave in MM:SS" timer (unterhalb)

#### **Bottom-Right: Control Buttons**
- **Start Wave Button**: Manual wave start / Skip countdown
- **Speed Button**: "Q (1x)" / "Q (2x)" / "Q (3x)" toggle
- **Tower Placement Buttons**: Q/W/E/R Hotkeys angezeigt

#### **Bottom: Metaprogression Fields**
- **5 Fields**: 2x2 Grid-Felder (64x64 px each)
- **Visual**: Dunkelblaues Hintergrund, Cyan Border
- **Content**: Zentrierte Türme (zufällig zugewiesen)
- **Interaction**: Linksklick zum Pickup

### **Tower Placement**

#### **Hotkey Placement (Q/W/E/R)**
1. Hotkey drücken → Preview erscheint am Mauszeiger
2. Maus bewegen → Preview folgt mit Grid-Snapping
3. Linksklick → Turm wird platziert (wenn gültig)
4. Erneuter Hotkey-Druck → Abbruch

#### **Metaprogression Placement**
1. Linksklick auf Feld-Turm → Turm folgt Mauszeiger
2. Maus bewegen → Turm und Range-Indikator folgen
3. Linksklick auf gültige Position → Turm wird platziert
4. Linksklick auf ungültige Position → Turm kehrt zum Feld zurück

### **Visual Feedback**

#### **Range Indicators**
- **Form**: Runder Kreis (Line2D-basiert)
- **Farbe**: Blau-Weiß, halbtransparent
- **Anzeige**: Beim Pickup, während Platzierung, bei Tower-Selection

#### **Placement Preview**
- **Gültig**: Grüne Preview
- **Ungültig (keine Honey)**: Gelbe Preview
- **Ungültig (Position)**: Rote Preview

---

## 💾 Save System

### **Save Data Structure**
```json
{
  "current_wave": 3,
  "player_health": 20,
  "honey": 150,
  "placed_towers": [
    {
      "type": "stinger",
      "position": {"x": 144, "y": 272},
      "level": 1,
      "damage": 8.0,
      "range": 80.0
    },
    {
      "type": "propolis_bomber",
      "position": {"x": 240, "y": 180},
      "level": 1,
      "damage": 35.0,
      "range": 100.0
    }
  ],
  "wave_data": {
    "current_wave": 3,
    "is_wave_active": false,
    "wave_progress": {"spawned": 9, "total": 9, "killed": 9}
  },
  "speed_mode": 1
}
```

### **Save Features**
- **JSON Format**: Human-readable save files
- **Tower Persistence**: Complete tower state with new tower types
- **Wave Progress**: Current wave and scaling status
- **Resource Management**: Honey and health tracking
- **Speed Mode**: Persistent speed setting

---

## 🧪 Testing & Quality Assurance

### **Automated Testing Framework**

#### **Test Coverage**
- **Speed System**: 100% (alle 3 Geschwindigkeiten, Projektil-Multiplikatoren)
- **Tower System**: 100% (alle 4 Turmtypen, Hotkey-Platzierung, Metaprogression-Pickup)
- **Enemy System**: 100% (Spawning, Movement, Scaling)
- **Projectile System**: 100% (Homing, Collision, Speed-Anpassung)
- **UI System**: 100% (Buttons, Hotkeys, Range Indicators, Wave Countdown)
- **Save System**: 100% (Save Data Structure, Load Functionality)
- **Placement Blocking**: 100% (Occupation Check, Cross-System Validation)

#### **Continuous Testing**
- **Tower Placement Blocking**: Alle 1s während Gameplay
  - Validates: Occupied positions, Metaprogression positions, Cross-system blocking, Grid boundaries
  - Success Rate: 99.9% target
  - Auto-Summary: Alle 30s

#### **Test Automation**
- **Development Mode**: Comprehensive testing alle 30-60s
- **Production Mode**: Minimal testing (disabled by default)
- **Automatic Triggers**: Speed changes, tower placement, wave starts, tower pickup
- **Test Reminders**: Automatische Notifications für neue Features

### **Performance Monitoring**
- **Memory Usage**: <100MB target, optimiert für minimalen Impact
- **CPU Usage**: <1% für Continuous Testing
- **Frame Rate**: 60 FPS maintained bei allen Speed-Modi
- **Load Times**: <3s für Scene-Transitions

---

## 🚀 Development Roadmap

### **Phase 1: Core Systems** ✅ **Completed**
- ✅ Basic Tower Defense gameplay
- ✅ Enemy spawning and movement
- ✅ Projectile system with collision detection
- ✅ Resource management (Honey)
- ✅ Wave progression system

### **Phase 2: Enhanced Features** ✅ **Completed**
- ✅ 3-speed system implementation
- ✅ Tower selection and range indicators
- ✅ Homing projectiles with speed adjustment
- ✅ Wave scaling system (1.35x per wave)
- ✅ Automated testing framework

### **Phase 3: Tower System Overhaul** ✅ **Completed**
- ✅ 4 Bienen-thematische Turmtypen (Stinger, Propolis Bomber, Nectar Sprayer, Lightning Flower)
- ✅ Q/W/E/R Hotkey system mit Toggle-Funktionalität
- ✅ Tower placement blocking (occupation check)
- ✅ Unified placement system (Hotkey + Metaprogression)
- ✅ Automatic wave progression mit Countdown

### **Phase 4: Metaprogression Foundation** ✅ **Completed**
- ✅ 5 Metaprogression fields (2x2 Grid)
- ✅ Random tower assignment
- ✅ Tower pickup system
- ✅ Free placement from fields
- ✅ Return-on-fail functionality
- ✅ Coordinate system unification

### **Phase 5: Metaprogression Expansion** 🔄 **In Progress**
- 🔄 Settlement system
- 📋 Tower persistence zwischen Runs
- 📋 Upgrade system
- 📋 Unlock progression
- 📋 Meta-currency

### **Phase 6: Polish & Content** 📋 **Planned**
- 📋 Visual effects and animations
- 📋 Sound system
- 📋 Additional enemy types
- 📋 More tower variants
- 📋 Advanced special abilities

---

## 📊 Success Metrics

### **Technical Metrics**
- **Test Coverage**: 100% für alle Core Systems ✅
- **Performance**: 60 FPS maintained bei allen Speed-Modi ✅
- **Memory Usage**: <100MB ✅
- **Load Times**: <3 seconds ✅
- **Continuous Test Success Rate**: 99.9% ✅

### **Gameplay Metrics**
- **Wave Completion**: 5 waves mit 1.35x Scaling ✅
- **Tower Variety**: 4 unique tower types ✅
- **Placement Methods**: 2 (Hotkey, Metaprogression) ✅
- **Speed Modes**: 3-speed system (1x, 2x, 3x) ✅
- **Auto-Wave Delays**: Speed-dependent (15s, 10s, 5s) ✅

### **User Experience**
- **Intuitive Controls**: Q/W/E/R für Türme, Q für Speed ✅
- **Visual Feedback**: Range indicators, health bars, countdown timer ✅
- **Smooth Gameplay**: No crashes, responsive UI ✅
- **Save System**: Reliable game state persistence ✅
- **Metaprogression**: Seamless tower pickup und placement ✅

---

## 🔧 Technical Requirements

### **Development Environment**
- **Engine**: Godot 4.5 stable
- **Language**: GDScript
- **Platform**: Windows (primary), Linux, macOS
- **Testing**: Automated test framework included
- **Version Control**: Git

### **Performance Requirements**
- **Minimum**: 2GB RAM, DirectX 11, OpenGL 3.3
- **Recommended**: 4GB RAM, DirectX 12
- **Target**: 60 FPS at 1920x1080
- **Speed Modes**: Stable at 1x, 2x, 3x

### **Quality Standards**
- **Code Coverage**: 100% for critical systems
- **Error Handling**: Comprehensive error management
- **Documentation**: Complete API documentation
- **Testing**: Automated test suite mit Continuous Testing
- **Debug Logging**: Comprehensive debug output für Troubleshooting

---

## 📝 Change Log

### **Version 3.0 (2024-12-29)** 🆕
- ✅ **Metaprogression Fields**: 5 Fields mit random tower assignment
- ✅ **Tower Pickup System**: Free placement aus Metaprogression-Feldern
- ✅ **Tower Hotkeys**: Q/W/E/R system mit Toggle-Funktionalität
- ✅ **Tower Placement Blocking**: Verhindert Platzierung auf belegten Positionen
- ✅ **Automatic Wave Progression**: Speed-dependent delays (15s/10s/5s)
- ✅ **Wave Countdown Timer**: Sekundengenaue Anzeige
- ✅ **4 New Tower Types**: Stinger, Propolis Bomber, Nectar Sprayer, Lightning Flower
- ✅ **Propolis Visual Update**: Authentische Bernstein-Farbe, größere Projektile
- ✅ **Coordinate System Unification**: Konsistente Map/UI Koordinaten
- ✅ **Continuous Testing**: Tower Placement Blocking Test (alle 1s)
- ✅ **Comprehensive Debug Logging**: Step-by-step troubleshooting

### **Version 2.0 (2024-12-19)**
- ✅ Wave scaling system (1.35x per wave)
- ✅ 3-speed system (1x, 2x, 3x)
- ✅ Tower selection and range indicators
- ✅ Homing projectiles
- ✅ Automated testing framework
- ✅ Enhanced save/load system

### **Version 1.0 (2024-12-18)**
- ✅ Basic tower defense gameplay
- ✅ Enemy spawning and movement
- ✅ Projectile system
- ✅ Resource management
- ✅ Wave progression

---

## 🐛 Known Issues & Limitations

### **Current Limitations**
- Metaprogression towers lost after game restart (persistence not yet implemented)
- No tower upgrades yet
- Single enemy type (Worker Wasp)
- No sound effects
- No visual effects for explosions/chains

### **Planned Fixes**
- Tower persistence system (Phase 5)
- Settlement integration (Phase 5)
- Additional enemy types (Phase 6)
- Sound and VFX system (Phase 6)

---

## 📚 Documentation

### **Technical Documentation**
- `TOWER_HOTKEY_TOGGLE_SOLUTION_DOCUMENTATION.md` - Complete hotkey system documentation
- `TOWER_PLACEMENT_BLOCKING_DOCUMENTATION.md` - Placement validation system
- `TOWER_PLACEMENT_BLOCKING_TEST_DOCUMENTATION.md` - Continuous testing system
- `TESTING_FRAMEWORK_DOCUMENTATION.md` - Automated testing framework
- `SAVE_SYSTEM_README.md` - Save/load system documentation

### **Development Documentation**
- `DEVELOPMENT_PLAN_v3.0.md` - Detailed development roadmap
- `FEATURE_MATRIX_v3.0.md` - Feature implementation status
- `TESTING_README.md` - Testing guide

---

**Document Status**: Active  
**Last Updated**: 2025-09-29  
**Next Review**: 2025-10-06  
**Version**: 3.0
