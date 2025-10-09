# 🐝 BeeKeeperTD - Product Requirements Document v2.0

## 📋 Executive Summary

**BeeKeeperTD** ist ein Tower Defense Spiel im Bienen-Theme, das sich durch innovative Gameplay-Mechaniken, umfassende Test-Automatisierung und skalierbare Schwierigkeitsgrade auszeichnet.

**Version**: 2.0  
**Letzte Aktualisierung**: 2024-12-19  
**Status**: Active Development

---

## 🎯 Core Gameplay

### **Tower Defense Mechaniken**
- **Tower Placement**: Strategische Turmplatzierung auf 20x15 Grid
- **Enemy Waves**: 5 Wellen mit steigender Schwierigkeit
- **Resource Management**: Honey-basierte Wirtschaft
- **Tower Types**: 4 verschiedene Turmtypen mit einzigartigen Fähigkeiten

### **Neue Features (v2.0)**

#### **1. Wave Scaling System** 🎯
- **Progressive Difficulty**: Gegner werden mit jeder Welle 35% stärker
- **Skalierungsfaktor**: 1.35x pro Welle (konfigurierbar)
- **Beispiel**: Welle 5 = 3.32x HP (132.8 HP statt 40 HP)
- **Health Bar Updates**: Automatische Anpassung der Lebensbalken

#### **2. 3-Stufiges Speed System** ⚡
- **Geschwindigkeiten**: 1x (normal), 2x (doppelt), 3x (dreifach)
- **Hotkey**: Q-Taste zum Wechseln zwischen Modi
- **Projektile**: Automatische Geschwindigkeitsanpassung
- **UI Integration**: Geschwindigkeitsanzeige im Button

#### **3. Erweiterte Tower-Funktionalität** 🏰
- **Tower Selection**: Klick auf Türme zeigt Reichweite
- **Range Indicators**: Runde, blaue Reichweitenanzeige
- **Homing Projectiles**: Konfigurierbare zielsuchende Geschosse
- **Tower Types**: Basic Shooter, Piercing Shooter mit unterschiedlichen Eigenschaften

#### **4. Automatisiertes Testing Framework** 🧪
- **Vollständiges Testsystem**: Umfassende Test-Automatisierung
- **Test-Kategorien**: Speed, Mechanics, UI, Save System, Tower Defense
- **Development/Production Modes**: Automatische Erkennung
- **Test-Erinnerungen**: Automatische Benachrichtigungen für neue Features

---

## 🏗️ Technical Architecture

### **Core Systems**

#### **Game State Management**
- **GameManager**: Zentrale Spielzustandsverwaltung
- **SceneManager**: Szenenübergänge und Navigation
- **HotkeyManager**: Konfigurierbare Tastenkürzel
- **SaveManager**: JSON-basierte Speicherung

#### **Tower Defense Core**
- **Tower System**: Modulare Turm-Implementierung
- **Enemy System**: Skalierbare Gegner mit Health Bars
- **Projectile System**: Homing-Geschosse mit Kollisionserkennung
- **Wave Management**: Dynamische Wellen-Generierung

#### **UI System**
- **Dynamic UI**: Automatische UI-Generierung
- **Range Indicators**: Visuelle Reichweitenanzeige
- **Speed Controls**: 3-stufiges Geschwindigkeitssystem
- **Tower Selection**: Sichere Turmauswahl

### **Testing Framework**

#### **Test Categories**
- **Speed Tests**: Projektile vs. Gegner-Geschwindigkeiten
- **Mechanics Tests**: Tower Placement, Enemy Spawning, Collision Detection
- **UI Tests**: Button Functionality, Hotkey System, Range Indicators
- **Save System Tests**: Data Structure, Load/Save Functionality
- **Tower Defense Tests**: Wave Management, Victory Conditions

#### **Performance Optimization**
- **Development Mode**: Umfassende Tests (2-5% Performance Impact)
- **Production Mode**: Minimale Tests (0% Performance Impact)
- **Automatic Detection**: Environment-basierte Konfiguration

---

## 🎮 Game Features

### **Tower Types**

#### **Basic Shooter** 🔫
- **Damage**: 15.0
- **Range**: 120.0
- **Cost**: 25 Honey
- **Special**: Homing projectiles, 1.5s attack speed

#### **Piercing Shooter** ⚡
- **Damage**: 10.0
- **Range**: 140.0
- **Cost**: 35 Honey
- **Special**: Penetrates 3 enemies, 1.2s attack speed

### **Enemy System**

#### **Standard Enemy (Worker Wasp)**
- **Base Health**: 40.0 HP
- **Movement Speed**: 60.0 px/s
- **Honey Reward**: 3
- **Wave Scaling**: 1.35x per wave

### **Wave Progression**

| Wave | Enemies | Scaling Factor | Total HP | Shots to Kill |
|------|---------|----------------|----------|---------------|
| 1    | 5       | 1.0x          | 40.0     | 3             |
| 2    | 8       | 1.35x         | 54.0     | 4             |
| 3    | 9       | 1.82x         | 72.8     | 5             |
| 4    | 10      | 2.46x         | 98.4     | 7             |
| 5    | 12      | 3.32x         | 132.8    | 9             |

---

## 🎨 User Interface

### **Main Menu**
- **Play Button**: Start Tower Defense
- **Settlement Button**: Settlement Management
- **Load Button**: Save Game Loading
- **Quit Button**: Exit Game

### **Tower Defense UI**
- **Resource Display**: Honey, Health, Wave Information
- **Tower Buttons**: Individual buttons for each tower type
- **Speed Button**: 3-speed mode toggle (Q key)
- **Range Indicators**: Visual tower range display
- **Wave Composition**: Real-time enemy count display

### **Tower Selection**
- **Click to Select**: Left-click on towers to show range
- **Range Display**: Round, blue range indicator
- **Right-click to Deselect**: Clear selection
- **Safe Implementation**: Crash-free tower selection

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
      "type": "Basic Shooter",
      "position": {"x": 100, "y": 200},
      "level": 1,
      "damage": 15.0,
      "range": 120.0
    }
  ],
  "wave_data": {
    "current_wave": 3,
    "is_wave_active": false,
    "wave_progress": {"spawned": 9, "total": 9, "killed": 9}
  }
}
```

### **Save Features**
- **JSON Format**: Human-readable save files
- **Tower Persistence**: Complete tower state saving
- **Wave Progress**: Current wave and enemy status
- **Resource Management**: Honey and health tracking

---

## 🧪 Testing & Quality Assurance

### **Automated Testing Framework**

#### **Test Coverage**
- **Speed System**: 100% (projectile speed ratios, speed mode transitions)
- **Tower System**: 100% (tower placement, tower attacks)
- **Enemy System**: 100% (enemy spawning, enemy movement)
- **Projectile System**: 100% (projectile homing, collision detection)
- **UI System**: 100% (button functionality, hotkey system, range indicators)
- **Save System**: 100% (save data structure, load functionality)

#### **Test Automation**
- **Development Mode**: Comprehensive testing every 30 seconds
- **Production Mode**: Minimal testing (disabled by default)
- **Automatic Triggers**: Speed changes, tower placement, wave starts
- **Test Reminders**: Automatic notifications for new features

### **Performance Monitoring**
- **Memory Usage**: Optimized for minimal impact
- **CPU Usage**: Efficient test execution
- **Frame Rate**: Maintained 60 FPS during testing
- **Load Times**: Fast scene transitions

---

## 🚀 Development Roadmap

### **Phase 1: Core Systems (Completed)**
- ✅ Basic Tower Defense gameplay
- ✅ Enemy spawning and movement
- ✅ Projectile system with collision detection
- ✅ Resource management (Honey)
- ✅ Wave progression system

### **Phase 2: Enhanced Features (Completed)**
- ✅ 3-speed system implementation
- ✅ Tower selection and range indicators
- ✅ Homing projectiles
- ✅ Wave scaling system
- ✅ Automated testing framework

### **Phase 3: Advanced Features (In Progress)**
- 🔄 Additional tower types (Stinger, Propolis Bomber, Nectar Sprayer, Lightning Flower)
- 🔄 Advanced enemy types
- 🔄 Tower upgrades
- 🔄 Special abilities

### **Phase 4: Polish & Optimization (Planned)**
- 📋 Visual effects and animations
- 📋 Sound system
- 📋 Advanced UI features
- 📋 Performance optimization

---

## 📊 Success Metrics

### **Technical Metrics**
- **Test Coverage**: 100% for core systems
- **Performance**: 60 FPS maintained
- **Memory Usage**: < 100MB
- **Load Times**: < 3 seconds

### **Gameplay Metrics**
- **Wave Completion**: 5 waves with scaling difficulty
- **Tower Variety**: 4+ tower types
- **Enemy Scaling**: 1.35x per wave
- **Speed Modes**: 3-speed system (1x, 2x, 3x)

### **User Experience**
- **Intuitive Controls**: Q for speed, click for tower selection
- **Visual Feedback**: Range indicators, health bars
- **Smooth Gameplay**: No crashes, responsive UI
- **Save System**: Reliable game state persistence

---

## 🔧 Technical Requirements

### **Development Environment**
- **Engine**: Godot 4.x
- **Language**: GDScript
- **Platform**: Windows (primary), Linux, macOS
- **Testing**: Automated test framework included

### **Performance Requirements**
- **Minimum**: 2GB RAM, DirectX 11
- **Recommended**: 4GB RAM, DirectX 12
- **Target**: 60 FPS at 1920x1080

### **Quality Standards**
- **Code Coverage**: 100% for critical systems
- **Error Handling**: Comprehensive error management
- **Documentation**: Complete API documentation
- **Testing**: Automated test suite

---

## 📝 Change Log

### **Version 2.0 (2024-12-19)**
- ✅ Wave scaling system implementation
- ✅ 3-speed system (1x, 2x, 3x)
- ✅ Tower selection and range indicators
- ✅ Homing projectiles
- ✅ Automated testing framework
- ✅ Enhanced save/load system
- ✅ Performance optimizations

### **Version 1.0 (2024-12-18)**
- ✅ Basic tower defense gameplay
- ✅ Enemy spawning and movement
- ✅ Projectile system
- ✅ Resource management
- ✅ Wave progression

---

**Document Status**: Active  
**Last Updated**: 2024-12-19  
**Next Review**: 2024-12-26
