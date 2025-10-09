# Bee Keeper TD - Save System Documentation

## Overview

The save system for Bee Keeper TD provides comprehensive game state persistence, including player data, tower defense progress, hotkey configurations, and auto-save functionality.

## Architecture

### Core Components

1. **SaveManager** (`autoloads/SaveManager.gd`) - Central save/load system
2. **GameManager** - Updated with save/load integration
3. **HotkeyManager** - Configuration persistence
4. **TowerDefense Scene** - Scene-specific save data

### Save Data Structure

```gdscript
{
    "version": "1.0",
    "timestamp": 1234567890,
    "game_state": GameManager.GameState.TOWER_DEFENSE,
    "player_data": {
        "account_level": 1,
        "honey": 100,
        "honeygems": 0,
        "wax": 50,
        "wood": 0,
        "buildings": {},
        "towers": [],
        "soldiers": []
    },
    "hotkeys": {
        "place_tower": KEY_T,
        "start_wave": KEY_R,
        "save_game": KEY_F5,
        "load_game": KEY_F9
    },
    "tower_defense": {
        "current_wave": 1,
        "player_health": 20,
        "placed_towers": [...],
        "wave_data": {...}
    },
    "settlement": {
        "buildings_unlocked": [],
        "upgrades_purchased": [],
        "settlement_level": 1
    }
}
```

## Features

### 1. Save Operations

#### Manual Save
- **F5** - Save Game (opens dialog)
- **F6** - Quick Save (saves to "quick_save" slot)
- **F9** - Load Game (opens dialog)
- **F7** - Quick Load (loads from "quick_save" slot)

#### Auto-Save
- Automatic saving every 60 seconds (configurable)
- Only saves when not in main menu
- Saves to "auto_save" slot

### 2. Save File Management

#### File Locations
- Save files: `user://saves/`
- Configuration: `user://config.cfg`
- Auto-save: `user://saves/auto_save.save`
- Quick save: `user://saves/quick_save.save`

#### Save File Operations
```gdscript
# Get list of save files
var save_files = GameManager.get_save_files()

# Check if save exists
var exists = GameManager.save_file_exists("my_save")

# Get save file info
var info = GameManager.get_save_file_info("my_save")

# Delete save file
var deleted = GameManager.delete_save_file("my_save")
```

### 3. Data Persistence

#### Player Data
- Account level and progression
- Resources (honey, honeygems, wax, wood)
- Building ownership
- Tower and soldier collections

#### Tower Defense State
- Current wave number
- Player health
- Placed towers (position, type, level, stats)
- Wave progress and status

#### Configuration
- Hotkey assignments
- Auto-save settings
- Game preferences

## Usage Examples

### Basic Save/Load

```gdscript
# Save current game
var success = GameManager.save_game("my_save")

# Load a save file
var success = GameManager.load_game("my_save")

# Quick save/load
GameManager.save_game("quick_save")
GameManager.load_game("quick_save")
```

### Save Data Access

```gdscript
# Get current save data
var save_data = SaveManager.get_save_data()

# Export save data as JSON
var json_string = SaveManager.export_save_data()

# Import save data from JSON
var success = SaveManager.import_save_data(json_string)
```

### Scene-Specific Saving

```gdscript
# In TowerDefense scene
func get_tower_defense_data() -> Dictionary:
    # Return scene-specific save data
    return {
        "current_wave": current_wave,
        "player_health": player_health,
        "placed_towers": tower_data
    }

func load_tower_defense_data(data: Dictionary):
    # Apply loaded data to scene
    current_wave = data.get("current_wave", 1)
    player_health = data.get("player_health", 20)
    # ... restore towers, etc.
```

## UI Integration

### Main Menu
- **Load Game** button opens save file browser
- Shows save file information (level, honey, timestamp)
- Error handling for failed loads

### Tower Defense Scene
- **F5** - Save Game dialog
- **F6** - Quick Save
- **F9** - Load Game dialog  
- **F7** - Quick Load
- Visual notifications for save/load operations

### Save Dialog Features
- Custom save names with timestamp suggestions
- Save file browser with detailed information
- Error messages for failed operations
- Auto-closing notifications

## Configuration

### Auto-Save Settings
```gdscript
# Enable/disable auto-save
SaveManager.auto_save_enabled = true

# Set auto-save interval (seconds)
SaveManager.auto_save_interval = 60.0
```

### Hotkey Configuration
```gdscript
# Add new hotkeys
HotkeyManager.hotkeys["new_action"] = KEY_X

# Set hotkey
HotkeyManager.set_hotkey("save_game", KEY_F5)

# Reset to defaults
HotkeyManager.reset_to_defaults()
```

## Error Handling

### Save Errors
- File system permissions
- Disk space issues
- Invalid save data
- JSON parsing errors

### Load Errors
- Missing save files
- Corrupted save data
- Version incompatibility
- Scene loading failures

### Error Recovery
- Graceful fallback to defaults
- User notification of errors
- Automatic retry mechanisms
- Data validation

## Performance Considerations

### Save Frequency
- Auto-save every 60 seconds (configurable)
- Manual saves on demand
- Quick save for frequent saves

### Data Size
- JSON format for human readability
- Compressed save data (future enhancement)
- Incremental saves (future enhancement)

### Memory Usage
- Save data cached in memory
- Automatic cleanup of old data
- Efficient data structures

## Future Enhancements

### Planned Features
1. **Save File Compression** - Reduce file sizes
2. **Incremental Saves** - Only save changed data
3. **Cloud Saves** - Online save synchronization
4. **Save File Encryption** - Security for save data
5. **Save File Validation** - Integrity checking
6. **Multiple Save Slots** - More organized save management
7. **Save File Backup** - Automatic backup creation
8. **Save File Sharing** - Export/import save files

### Technical Improvements
1. **Binary Save Format** - Faster save/load
2. **Save Data Versioning** - Backward compatibility
3. **Async Save/Load** - Non-blocking operations
4. **Save Data Compression** - Smaller file sizes
5. **Save Data Validation** - Data integrity checks

## Troubleshooting

### Common Issues

#### Save Files Not Found
- Check `user://saves/` directory exists
- Verify file permissions
- Check for typos in save names

#### Load Failures
- Verify save file integrity
- Check version compatibility
- Clear corrupted save data

#### Auto-Save Not Working
- Check auto-save is enabled
- Verify timer is running
- Check for scene state issues

### Debug Information

```gdscript
# Print current save data
SaveManager.get_save_data()

# Print save file list
GameManager.get_save_files()

# Print hotkey configuration
HotkeyManager.print_current_hotkeys()
```

## API Reference

### SaveManager Methods

```gdscript
# Core save/load
save_game(save_name: String) -> bool
load_game(save_name: String) -> bool

# File management
get_save_files() -> Array[String]
save_file_exists(save_name: String) -> bool
delete_save_file(save_name: String) -> bool
get_save_file_info(save_name: String) -> Dictionary

# Configuration
save_config()
load_config()

# Data access
get_save_data() -> Dictionary
export_save_data() -> String
import_save_data(json_string: String) -> bool
```

### GameManager Methods

```gdscript
# Save/load integration
save_game(save_name: String) -> bool
load_game(save_name: String) -> bool
get_save_files() -> Array[String]
save_file_exists(save_name: String) -> bool
delete_save_file(save_name: String) -> bool
get_save_file_info(save_name: String) -> Dictionary
```

This save system provides a robust foundation for game state persistence while maintaining flexibility for future enhancements and expansions.
