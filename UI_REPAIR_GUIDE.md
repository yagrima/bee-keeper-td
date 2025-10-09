# UI Repair Guide - TowerDefense.tscn

**Problem**: Nach Refactoring fehlen kritische UI-Nodes in TowerDefense.tscn  
**Symptome**: Keine Tower-Buttons, kein Speed-Toggle, keine Wave-Preview  
**Datum**: 2025-01-10

---

## 🔴 FEHLENDE UI-NODES

### 1. Tower-Buttons (unten rechts)
**Parent**: `UI/GameUI/ControlsPanel/Controls`

Füge nach `StartWaveButton` hinzu:

```
StingerButton (Button)
- Text: "Stinger (Q) - 20🍯"
- tooltip_text: "Fast rapid-fire tower"

PropolisBomberButton (Button)
- Text: "Propolis (W) - 30🍯"  
- tooltip_text: "Area damage tower"

NectarSprayerButton (Button)
- Text: "Nectar (E) - 25🍯"
- tooltip_text: "Slowing tower"

LightningFlowerButton (Button)
- Text: "Lightning (R) - 35🍯"
- tooltip_text: "Chain lightning tower"
```

### 2. Speed Button
**Parent**: `UI/GameUI/ControlsPanel/Controls`

```
SpeedButton (Button)
- Text: "Speed: 1x"
- tooltip_text: "Toggle game speed (1x/2x/3x)"
```

### 3. Wave Composition Label
**Parent**: `UI/WaveInfoPanel/WaveInfoContainer`

```
WaveCompositionLabel (Label)
- Text: "Next: Wave 1: 5 Standard"
- horizontal_alignment: LEFT
- theme_override_colors/font_color: Color(1, 0.9, 0.7, 1)
- theme_override_font_sizes/font_size: 14
```

### 4. Wave Countdown Label (Optional)
**Parent**: `UI/WaveInfoPanel/WaveInfoContainer`

```
WaveCountdownLabel (Label)
- Text: ""
- horizontal_alignment: RIGHT
- theme_override_colors/font_color: Color(1, 0.9, 0.7, 1)
- theme_override_font_sizes/font_size: 14
```

---

## 📝 SCHRITT-FÜR-SCHRITT ANLEITUNG

### Im Godot Editor:

1. **Scene öffnen**: `scenes/main/TowerDefense.tscn`

2. **Tower-Buttons hinzufügen**:
   - Navigiere zu: `UI → GameUI → ControlsPanel → Controls`
   - Rechtsklick auf `Controls` → Add Child Node → `Button`
   - Name: `StingerButton`
   - Properties:
     - Text: `Stinger (Q) - 20🍯`
     - Tooltip Text: `Fast rapid-fire tower`
     - Custom Minimum Size: `(0, 40)`
     - Theme Overrides → Styles:
       - Normal: `SubResource("StyleBoxFlat_ui_button")`
       - Hover: `SubResource("StyleBoxFlat_ui_button_hover")`
     - Theme Overrides → Colors:
       - Font Color: `#ffe6b3` (1, 0.9, 0.7, 1)
     - Theme Overrides → Font Sizes:
       - Font Size: 16
   
   - **Wiederholen** für: `PropolisBomberButton`, `NectarSprayerButton`, `LightningFlowerButton`

3. **Speed Button hinzufügen**:
   - Gleiche Parent: `Controls`
   - Name: `SpeedButton`
   - Text: `Speed: 1x`
   - Tooltip: `Toggle game speed`
   - Gleiche Styling wie Tower-Buttons

4. **Wave Composition Label**:
   - Parent: `UI → WaveInfoPanel → WaveInfoContainer`
   - Add Child Node → `Label`
   - Name: `WaveCompositionLabel`
   - Text: `Next: Wave 1: 5 Standard`
   - Horizontal Alignment: Left
   - Font Color: `#ffe6b3`
   - Font Size: 14

5. **Code-Referenzen aktualisieren**:
   - Öffne `scripts/TowerDefense.gd`
   - Füge hinzu (nach Zeile 40):
   ```gdscript
   @onready var stinger_button: Button = $"UI/GameUI/ControlsPanel/Controls/StingerButton"
   @onready var propolis_bomber_button: Button = $"UI/GameUI/ControlsPanel/Controls/PropolisBomberButton"
   @onready var nectar_sprayer_button: Button = $"UI/GameUI/ControlsPanel/Controls/NectarSprayerButton"
   @onready var lightning_flower_button: Button = $"UI/GameUI/ControlsPanel/Controls/LightningFlowerButton"
   @onready var speed_button: Button = $"UI/GameUI/ControlsPanel/Controls/SpeedButton"
   @onready var wave_composition_label: Label = $"UI/WaveInfoPanel/WaveInfoContainer/WaveCompositionLabel"
   ```

6. **UI Manager Referenzen setzen**:
   - In `_ready()` nach Zeile 103 hinzufügen:
   ```gdscript
   ui_manager.wave_composition_label = wave_composition_label
   ui_manager.speed_button = speed_button
   ui_manager.stinger_button = stinger_button
   ui_manager.propolis_bomber_button = propolis_bomber_button
   ui_manager.nectar_sprayer_button = nectar_sprayer_button
   ui_manager.lightning_flower_button = lightning_flower_button
   ```

7. **Button Signals verbinden**:
   - In `_ready()` nach den anderen Button-Connections:
   ```gdscript
   if stinger_button:
       stinger_button.pressed.connect(func(): _on_tower_hotkey_pressed("stinger"))
   if propolis_bomber_button:
       propolis_bomber_button.pressed.connect(func(): _on_tower_hotkey_pressed("propolis_bomber"))
   if nectar_sprayer_button:
       nectar_sprayer_button.pressed.connect(func(): _on_tower_hotkey_pressed("nectar_sprayer"))
   if lightning_flower_button:
       lightning_flower_button.pressed.connect(func(): _on_tower_hotkey_pressed("lightning_flower"))
   if speed_button:
       speed_button.pressed.connect(_on_speed_toggle_pressed)
   ```

---

## 🐛 ANDERE UI-PROBLEME

### Grid unvollständig / Hintergrund nicht grün
**Ursache**: `setup_basic_map()` funktioniert nicht richtig

**Schneller Fix in TowerDefense.gd**:
```gdscript
func setup_basic_map():
    # Setze Hintergrund grün
    var background = $UI/Background
    if background:
        background.color = Color(0.2, 0.6, 0.2, 1)  # Grün
    
    # Grid manuell zeichnen (falls TileMap nicht funktioniert)
    # TODO: Implementiere Grid-Drawing
```

### Weg geht über Spielbrett hinaus
**Ursache**: Path-Koordinaten nicht an Grid angepasst

**In setup_basic_map()**:
```gdscript
# Adjust path to stay within bounds
var grid_size = Vector2(20, 15)  # 20x15 tiles
var tile_size = 32
```

---

## ✅ NACHDEM ALLES HINZUGEFÜGT WURDE

1. **Scene speichern** (Strg+S)
2. **Spiel neu starten** (F5)
3. **Testen**:
   - Tower-Buttons erscheinen unten rechts ✅
   - Speed-Button funktioniert ✅
   - Wave-Preview zeigt nächste Welle ✅
   - Grid ist vollständig ✅
   - Hintergrund ist grün ✅

---

## 🚨 ALTERNATIVE: SCENE AUS GIT WIEDERHERSTELLEN

Falls zu kompliziert, kannst du auch eine ältere funktionierende Version wiederherstellen:

```bash
# Sichere aktuelle Version
cp scenes/main/TowerDefense.tscn scenes/main/TowerDefense.tscn.broken

# Stelle Version vor Refactoring wieder her
git checkout <commit-hash> -- scenes/main/TowerDefense.tscn
```

**ABER VORSICHT**: Das würde auch das neue schöne Styling verlieren!

---

## 📊 ZUSAMMENFASSUNG

**Fehlend**:
- 4 Tower-Buttons
- 1 Speed-Button  
- 1 Wave Composition Label

**Zeitaufwand**: ~15-20 Minuten im Godot Editor

**Empfehlung**: Folge der Schritt-für-Schritt-Anleitung oben.

---

Erstellt: 2025-01-10
