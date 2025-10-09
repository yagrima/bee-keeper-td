# 📐 BeeKeeperTD Coding Standards

**Projekt**: BeeKeeperTD  
**Version**: 1.0  
**Erstellt**: 2025-01-12  
**Status**: ✅ **Active**

---

## 🎯 OVERVIEW

Dieses Dokument definiert die Coding Standards für das BeeKeeperTD Projekt. Diese Standards sind **verpflichtend** für alle Code Contributions.

---

## 📏 FILE SIZE GUIDELINES

### **Hard Limits**

```
✅ IDEAL:     < 300 Zeilen
🟡 GOOD:      300-500 Zeilen  
🟠 WARNING:   500-800 Zeilen (Refactoring empfohlen)
🔴 CRITICAL:  > 800 Zeilen (MUSS refaktoriert werden)
```

### **Rationale**

- **Maintainability**: Kleinere Dateien sind einfacher zu verstehen und zu warten
- **Testing**: Kleinere Komponenten sind einfacher zu testen
- **Code Review**: Kürzere Dateien sind schneller zu reviewen
- **Tool Compatibility**: Viele Tools haben Limits (z.B. MultiEdit)
- **Single Responsibility**: Große Dateien verletzen oft das Single Responsibility Principle

### **Exceptions**

**Erlaubt über 800 Zeilen:**
- Scene Files (`.tscn`, `.tres`)
- Auto-Generated Code
- Configuration Files (JSON, TOML)
- Resource Files
- **Mit ausführlicher Begründung** im File Header

**Beispiel Header:**
```gdscript
# =============================================================================
# LARGE FILE JUSTIFICATION
# =============================================================================
# File: TowerDefense.gd
# Lines: 1040
# Reason: Main game controller - Split würde zu viel Overhead erzeugen
# Review Date: 2025-01-12
# Next Review: 2025-02-01
# Refactoring Plan: Split in TowerDefenseState, TowerDefenseUI after Launch
# =============================================================================
```

---

## 🧩 CODE ORGANIZATION

### **File Structure**

```gdscript
# =============================================================================
# FILE HEADER
# =============================================================================
# Description: What this file does
# Author: Development Team
# Created: 2025-01-12
# Dependencies: List major dependencies
# =============================================================================

extends Node  # or other base class

# =============================================================================
# SIGNALS
# =============================================================================
signal game_started()
signal game_ended(victory: bool)

# =============================================================================
# CONSTANTS
# =============================================================================
const MAX_TOWERS = 50
const BASE_HEALTH = 20

# =============================================================================
# ENUMS
# =============================================================================
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

# =============================================================================
# EXPORTED VARIABLES
# =============================================================================
@export var tower_scene: PackedScene
@export var enemy_scene: PackedScene

# =============================================================================
# PUBLIC VARIABLES
# =============================================================================
var current_wave: int = 0
var player_health: int = 20

# =============================================================================
# PRIVATE VARIABLES
# =============================================================================
var _internal_state: Dictionary = {}
var _timer: Timer

# =============================================================================
# NODE REFERENCES
# =============================================================================
@onready var ui_manager = $UIManager
@onready var wave_manager = $WaveManager

# =============================================================================
# LIFECYCLE METHODS
# =============================================================================
func _ready():
    pass

func _process(delta):
    pass

# =============================================================================
# PUBLIC METHODS
# =============================================================================
func start_game():
    pass

func end_game():
    pass

# =============================================================================
# PRIVATE METHODS
# =============================================================================
func _initialize_game():
    pass

func _cleanup():
    pass

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================
func _on_wave_completed():
    pass

func _on_enemy_died():
    pass
```

### **Section Order (Fixed)**

1. File Header
2. extends
3. Signals
4. Constants
5. Enums
6. Exported Variables
7. Public Variables
8. Private Variables (mit _ prefix)
9. Node References (@onready)
10. Lifecycle Methods (_ready, _process, etc.)
11. Public Methods
12. Private Methods (mit _ prefix)
13. Signal Handlers (_on_* methods)

---

## 🔤 NAMING CONVENTIONS

### **Files**

```
✅ GOOD:  TowerDefense.gd, SaveManager.gd, WaveController.gd
❌ BAD:   towerdefense.gd, save_mgr.gd, WCtrl.gd
```

**Rules:**
- PascalCase for classes
- Descriptive names (no abbreviations)
- Match class name

### **Classes**

```gdscript
✅ GOOD:  class_name TowerDefense
❌ BAD:   class_name towerDefense, class_name TD
```

### **Variables**

```gdscript
# Public variables
✅ GOOD:  var current_wave: int
✅ GOOD:  var player_health: int
❌ BAD:   var cw: int, var HP: int

# Private variables (use _ prefix)
✅ GOOD:  var _internal_timer: float
✅ GOOD:  var _cached_data: Dictionary
❌ BAD:   var internal_timer: float  # missing _
```

### **Constants**

```gdscript
✅ GOOD:  const MAX_TOWERS = 50
✅ GOOD:  const BASE_HEALTH = 20
❌ BAD:   const maxTowers = 50, const max_towers = 50
```

### **Functions**

```gdscript
# Public functions
✅ GOOD:  func start_wave():
✅ GOOD:  func calculate_damage(tower: Tower) -> int:
❌ BAD:   func startWave():, func calc_dmg():

# Private functions (use _ prefix)
✅ GOOD:  func _initialize_enemies():
✅ GOOD:  func _cleanup_towers():
❌ BAD:   func initEnemies():, func cleanup():  # missing _
```

### **Signals**

```gdscript
✅ GOOD:  signal wave_started()
✅ GOOD:  signal enemy_died(enemy: Enemy)
✅ GOOD:  signal game_state_changed(old_state: GameState, new_state: GameState)
❌ BAD:   signal WaveStarted(), signal EnemyDead()
```

### **Signal Handlers**

```gdscript
✅ GOOD:  func _on_wave_started():
✅ GOOD:  func _on_enemy_died(enemy: Enemy):
✅ GOOD:  func _on_tower_button_pressed():
❌ BAD:   func on_wave_started():  # missing _
❌ BAD:   func wave_started_handler():  # nicht _on_ prefix
```

---

## 💬 COMMENTS & DOCUMENTATION

### **File Headers** (Required)

```gdscript
# =============================================================================
# TOWER DEFENSE GAME CONTROLLER
# =============================================================================
# Main controller for the Tower Defense game scene.
# Handles wave progression, tower placement, and game state.
#
# Dependencies:
# - TowerPlacer (autoload)
# - WaveManager (child node)
# - UIManager (child node)
#
# Signals:
# - game_started(): Emitted when game begins
# - wave_completed(wave_number): Emitted when wave ends
# - game_over(victory): Emitted when game ends
# =============================================================================
```

### **Function Documentation** (Required for Public Functions)

```gdscript
func calculate_tower_damage(tower: Tower, enemy: Enemy) -> int:
    """
    Calculate damage dealt by tower to enemy
    
    Args:
        tower: The attacking tower
        enemy: The target enemy
        
    Returns:
        int: Damage amount after modifiers
        
    Notes:
        - Applies tower damage modifiers
        - Considers enemy armor
        - Handles critical hits
    """
    var base_damage = tower.damage
    var armor_reduction = enemy.armor * 0.1
    return max(1, base_damage - armor_reduction)
```

### **Inline Comments** (Sparingly)

```gdscript
# ✅ GOOD: Explain WHY, not WHAT
# Delay spawn to prevent frame drops
await get_tree().create_timer(0.1).timeout

# ❌ BAD: Obvious comment
# Set health to 100
player_health = 100
```

### **TODO Comments**

```gdscript
# TODO: Implement tower upgrade system (Priority: HIGH, ETA: 2025-01-15)
# TODO: Add sound effects (Priority: LOW)
# FIXME: Memory leak in enemy pool (Bug #123)
# HACK: Temporary fix for clickability issue - refactor after launch
```

---

## 🧪 TESTING STANDARDS

### **Test File Naming**

```
✅ GOOD:  TowerTests.gd, SaveManagerTests.gd, AuthFlowTests.gd
❌ BAD:   test_tower.gd, tower_test.gd, TowerTestSuite.gd
```

### **Test Function Naming**

```gdscript
✅ GOOD:  func test_tower_attacks_enemy():
✅ GOOD:  func test_save_file_creation():
✅ GOOD:  func test_login_with_valid_credentials():
❌ BAD:   func testTowerAttack():, func test1():
```

### **Test Structure**

```gdscript
func test_example_feature() -> bool:
    """Test description: What this test validates"""
    print("Test: Example feature...")
    
    # Arrange
    var tower = Tower.new()
    var enemy = Enemy.new()
    
    # Act
    var damage = tower.attack(enemy)
    
    # Assert
    if damage <= 0:
        print("❌ Test failed: Damage should be positive")
        return false
    
    print("✅ Test passed")
    return true
```

---

## 🚫 ANTI-PATTERNS

### **Avoid**

```gdscript
# ❌ Magic Numbers
if player_health < 20:  # What does 20 mean?

# ✅ Use Constants
const MIN_HEALTH = 20
if player_health < MIN_HEALTH:

# ❌ Deep Nesting (> 3 levels)
if condition1:
    if condition2:
        if condition3:
            if condition4:  # TOO DEEP!

# ✅ Early Returns
if not condition1:
    return
if not condition2:
    return

# ❌ God Classes (> 800 lines)
# ✅ Split into smaller components

# ❌ Hardcoded Strings
print("Player died")  # Hard to localize

# ✅ Use Constants
const MSG_PLAYER_DIED = "player_died"  # For translation keys
print(tr(MSG_PLAYER_DIED))
```

---

## 🔒 SECURITY STANDARDS

### **Never Commit**

- ❌ API Keys
- ❌ Passwords
- ❌ HMAC Secrets
- ❌ Private Keys
- ❌ .env files

### **Always Use**

- ✅ Environment Variables
- ✅ .env.example templates
- ✅ .gitignore for secrets
- ✅ Production fallbacks

```gdscript
# ❌ BAD
const API_KEY = "sk_live_abc123..."

# ✅ GOOD
var api_key = OS.get_environment("API_KEY")
if api_key.is_empty():
    push_error("API_KEY not set in environment!")
```

---

## 📦 DEPENDENCY MANAGEMENT

### **Autoloads**

```
✅ GOOD:  Klare Abhängigkeiten, dokumentiert
✅ GOOD:  Minimale Kopplung
❌ BAD:   Circular dependencies
❌ BAD:   God autoloads mit 1000+ Zeilen
```

### **Scene Dependencies**

```gdscript
# Document dependencies in file header
# Dependencies:
# - res://scenes/towers/Tower.tscn
# - res://scenes/enemies/Enemy.tscn
```

---

## 🎯 PERFORMANCE GUIDELINES

### **Object Pooling** (für häufige Instanziierung)

```gdscript
# ✅ GOOD: Pool für Enemies/Projectiles
var enemy_pool: Array[Enemy] = []

# ❌ BAD: Jedes Mal neu instanziieren
var enemy = enemy_scene.instantiate()
```

### **Signal Optimization**

```gdscript
# ✅ GOOD: Disconnect signals when done
func _ready():
    SupabaseClient.auth_state_changed.connect(_on_auth_changed)

func _exit_tree():
    if SupabaseClient.auth_state_changed.is_connected(_on_auth_changed):
        SupabaseClient.auth_state_changed.disconnect(_on_auth_changed)
```

---

## ✅ CODE REVIEW CHECKLIST

Before committing code, verify:

- [ ] File < 800 Zeilen (oder justified)
- [ ] Alle Functions dokumentiert
- [ ] Naming Conventions eingehalten
- [ ] Keine Magic Numbers
- [ ] Keine Secrets im Code
- [ ] Tests geschrieben (für neue Features)
- [ ] Alle Tests passing
- [ ] Keine Debug-Prints (außer hinter Feature Flag)
- [ ] Performance acceptable
- [ ] Git commit message beschreibend

---

## 🔗 RELATED DOCUMENTS

- `TECHNICAL_DEBT.md` - Current Technical Debt
- `MD-Files/06-Status/Project_Status.md` - Project Status
- `PRD_BeeKeeperTD_v3.0.md` - Product Requirements

---

**Last Updated**: 2025-01-12  
**Next Review**: 2025-02-01  
**Owner**: Development Team
