# 🧪 BeeKeeperTD Testing System

## Overview
This document explains how to use the automated testing system for BeeKeeperTD and how to keep tests updated when adding new features.

## 🚀 Quick Start

### For Developers
The testing system automatically detects development builds and enables comprehensive testing.

### For Production
Testing is disabled by default for optimal performance. Enable only if needed:
```bash
set BEEKEEPER_TESTING=1
```

## 📋 Adding New Features

### When you add a new feature, you MUST:

1. **Add the feature to the reminder system:**
```gdscript
# In Main.gd, call one of these:
quick_test_new_tower_type("Laser Tower")
quick_test_new_enemy_type("Boss Enemy") 
quick_test_new_ui_feature("Settings Menu")
```

2. **Update the test framework:**
   - Add tests to `TestFramework.gd`
   - Update test categories in `TestingConfig.gd`
   - Add specific test functions

3. **Mark as tested when done:**
```gdscript
# In Main.gd
mark_feature_tested("tower_laser_tower")
```

## 🔧 Test Categories

### Speed Tests
- Projectile vs enemy speed ratios
- Speed mode transitions (1x, 2x, 3x)
- Performance scaling

### Game Mechanics Tests
- Tower placement and attacks
- Enemy spawning and movement
- Projectile homing and collision
- Wave management

### UI Tests
- Button functionality
- Hotkey system
- Range indicators
- Menu interactions

### Save System Tests
- Data structure validation
- Load/save functionality
- Data persistence

## 📊 Test Coverage

### Current Coverage (as of 2024-12-19):
- ✅ Speed System (3-speed modes)
- ✅ Tower System (Basic/Piercing Shooters)
- ✅ Enemy System (Standard enemies)
- ✅ Projectile System (Homing projectiles)
- ✅ UI System (Buttons, hotkeys, indicators)
- ✅ Save System (JSON-based)

### Pending Updates:
- Add new features here when implementing them

## 🛠️ Development Workflow

### 1. Adding a New Tower Type
```gdscript
# Step 1: Add to reminder system
quick_test_new_tower_type("Laser Tower")

# Step 2: Implement the tower
# (Create LaserTower.gd, add to tower types, etc.)

# Step 3: Add tests to TestFramework.gd
func test_laser_tower_placement():
    # Test laser tower specific placement logic
    pass

func test_laser_tower_attacks():
    # Test laser tower attack mechanics
    pass

# Step 4: Mark as tested
mark_feature_tested("tower_laser_tower")
```

### 2. Adding a New Enemy Type
```gdscript
# Step 1: Add to reminder system
quick_test_new_enemy_type("Boss Enemy")

# Step 2: Implement the enemy
# (Create BossEnemy.gd, add to wave definitions, etc.)

# Step 3: Add tests
func test_boss_enemy_spawning():
    # Test boss enemy spawning logic
    pass

func test_boss_enemy_movement():
    # Test boss enemy movement patterns
    pass

# Step 4: Mark as tested
mark_feature_tested("enemy_boss_enemy")
```

### 3. Adding UI Features
```gdscript
# Step 1: Add to reminder system
quick_test_new_ui_feature("Settings Menu")

# Step 2: Implement the UI
# (Create settings menu, add buttons, etc.)

# Step 3: Add tests
func test_settings_menu():
    # Test settings menu functionality
    pass

# Step 4: Mark as tested
mark_feature_tested("ui_settings_menu")
```

## 🔍 Manual Testing

### Run All Tests
```gdscript
var test_runner = TestRunner.new()
add_child(test_runner)
test_runner.run_all_tests()
```

### Run Specific Test Categories
```gdscript
test_runner.run_speed_tests()
test_runner.run_mechanics_tests()
test_runner.run_ui_tests()
test_runner.run_save_tests()
```

### Quick Checks
```gdscript
test_runner.quick_speed_check()
test_runner.quick_mechanics_check()
test_runner.quick_ui_check()
```

## 📈 Test Reports

### View Coverage Report
```gdscript
# In Main.gd
print_test_coverage_report()
```

### Check Status
```gdscript
var status = get_test_coverage_status()
print("Coverage: %.1f%%" % status.coverage_percentage)
```

## ⚙️ Configuration

### Enable/Disable Reminders
```gdscript
enable_test_reminders()    # Enable reminders
disable_test_reminders()   # Disable reminders
```

### Set Reminder Interval
```gdscript
set_reminder_interval(60.0)  # Check every 60 seconds
```

### Environment Variables
```bash
# Enable testing in production
set BEEKEEPER_TESTING=1

# Enable debug mode
set BEEKEEPER_DEBUG=1
set GODOT_DEBUG=1
```

## 🚨 Important Notes

### ⚠️ CRITICAL: Always Update Tests
- **NEVER** add features without updating tests
- The reminder system will notify you of pending updates
- Test coverage should be maintained at 100%

### 🎯 Best Practices
1. Add features to reminder system FIRST
2. Implement the feature
3. Add comprehensive tests
4. Mark as tested when complete
5. Run full test suite before committing

### 🔧 Troubleshooting
- If tests fail, check the console output
- Use `print_test_coverage_report()` to see what needs testing
- Enable verbose logging for detailed test information

## 📝 Example: Complete Feature Addition

```gdscript
# 1. Add to reminder system
quick_test_new_tower_type("Ice Tower")

# 2. Implement Ice Tower
# (Create IceTower.gd with freezing mechanics)

# 3. Add tests to TestFramework.gd
func test_ice_tower_placement():
    var honey_cost = 50
    var player_honey = 100
    var can_place = player_honey >= honey_cost
    record_test_result("Ice Tower Placement", can_place, "Can place with sufficient honey")

func test_ice_tower_freezing():
    var freeze_duration = 2.0
    var valid_duration = freeze_duration > 0
    record_test_result("Ice Tower Freezing", valid_duration, "Freeze duration: %.1f" % freeze_duration)

# 4. Mark as tested
mark_feature_tested("tower_ice_tower")

# 5. Run tests to verify
test_runner.run_all_tests()
```

## 🎮 Performance Impact

| Mode | Tests Enabled | Performance Impact | Memory Usage |
|------|---------------|-------------------|--------------|
| Production | None | 0% | Minimal |
| Production (Testing) | Critical only | <1% | +2-3MB |
| Development | All | 2-5% | +5-10MB |
| Debug | All + Verbose | 5-10% | +10-15MB |

---

**Remember: The testing system is your safety net. Keep it updated and it will keep your game stable!** 🛡️✨
