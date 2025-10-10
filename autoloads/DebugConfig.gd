extends Node

# =============================================================================
# DEBUG CONFIGURATION - ZENTRALE DEBUG-TOGGLES
# =============================================================================
# WICHTIG: Vor Production-Release alle auf false setzen!
# Diese Datei steuert alle Debug-Features im gesamten Projekt
# =============================================================================

# =============================================================================
# MASTER DEBUG TOGGLE
# =============================================================================
# Wenn false: Alle Debug-Features sind deaktiviert (Production Mode)
# Wenn true: Debug-Features sind verfügbar (Development Mode)
const DEBUG_ENABLED: bool = true  # ⚠️ SET TO FALSE FOR PRODUCTION!

# =============================================================================
# FEATURE-SPEZIFISCHE DEBUG TOGGLES
# =============================================================================

# Input & Controls
const DEBUG_INPUT: bool = true          # Keyboard/Mouse Input Logs
const DEBUG_HOTKEYS: bool = true        # Hotkey Detection Logs
const DEBUG_WEB_INPUT: bool = true      # Web Input Fix Logs

# Gameplay Systems
const DEBUG_WAVES: bool = true          # Wave Management Logs
const DEBUG_TOWERS: bool = true         # Tower Placement/Attack Logs
const DEBUG_ENEMIES: bool = true        # Enemy Spawning/Movement Logs
const DEBUG_PROJECTILES: bool = true    # Projectile Tracking Logs

# Resources & Economy
const DEBUG_RESOURCES: bool = true      # Honey/Health Changes
const DEBUG_METAPROGRESSION: bool = true  # XP/Unlocks/Upgrades

# Save System
const DEBUG_SAVE_SYSTEM: bool = true    # Save/Load Operations
const DEBUG_AUTOSAVE: bool = true       # Auto-Save Triggers
const DEBUG_MANUAL_SAVE: bool = true    # Manual Save (F5/F9) - Should be disabled for players!

# Network & Backend
const DEBUG_SUPABASE: bool = true       # Supabase API Calls
const DEBUG_AUTH: bool = true           # Authentication Flow
const DEBUG_ENCRYPTION: bool = true     # Data Encryption/Decryption

# UI & Visual
const DEBUG_UI: bool = false            # UI Updates/State Changes
const DEBUG_OVERLAY: bool = true        # Debug Overlay Display
const DEBUG_PERFORMANCE: bool = false   # FPS/Performance Metrics

# =============================================================================
# PLAYER-FACING DEBUG FEATURES (Should be disabled in production!)
# =============================================================================

# Save/Load Hotkeys for Players
const ALLOW_MANUAL_SAVE_HOTKEYS: bool = true  # ⚠️ F5/F9 for players (SET TO FALSE FOR PRODUCTION!)

# Cheat/Test Features
const ALLOW_DEV_CHEATS: bool = true           # ⚠️ Dev cheat codes (SET TO FALSE FOR PRODUCTION!)
const ALLOW_SKIP_WAVES: bool = true           # ⚠️ Skip wave requirements (SET TO FALSE FOR PRODUCTION!)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func is_debug_enabled() -> bool:
	"""Check if master debug is enabled"""
	return DEBUG_ENABLED

func is_feature_debug_enabled(feature: String) -> bool:
	"""Check if specific feature debug is enabled"""
	match feature:
		"input": return DEBUG_ENABLED and DEBUG_INPUT
		"hotkeys": return DEBUG_ENABLED and DEBUG_HOTKEYS
		"web_input": return DEBUG_ENABLED and DEBUG_WEB_INPUT
		"waves": return DEBUG_ENABLED and DEBUG_WAVES
		"towers": return DEBUG_ENABLED and DEBUG_TOWERS
		"enemies": return DEBUG_ENABLED and DEBUG_ENEMIES
		"projectiles": return DEBUG_ENABLED and DEBUG_PROJECTILES
		"resources": return DEBUG_ENABLED and DEBUG_RESOURCES
		"metaprogression": return DEBUG_ENABLED and DEBUG_METAPROGRESSION
		"save_system": return DEBUG_ENABLED and DEBUG_SAVE_SYSTEM
		"autosave": return DEBUG_ENABLED and DEBUG_AUTOSAVE
		"manual_save": return DEBUG_ENABLED and DEBUG_MANUAL_SAVE
		"supabase": return DEBUG_ENABLED and DEBUG_SUPABASE
		"auth": return DEBUG_ENABLED and DEBUG_AUTH
		"encryption": return DEBUG_ENABLED and DEBUG_ENCRYPTION
		"ui": return DEBUG_ENABLED and DEBUG_UI
		"overlay": return DEBUG_ENABLED and DEBUG_OVERLAY
		"performance": return DEBUG_ENABLED and DEBUG_PERFORMANCE
		_: return DEBUG_ENABLED

func print_production_check():
	"""Print production readiness check"""
	print("========================================")
	print("🔍 PRODUCTION READINESS CHECK")
	print("========================================")
	
	var warnings = []
	
	if DEBUG_ENABLED:
		warnings.append("⚠️ DEBUG_ENABLED is TRUE (should be FALSE for production)")
	
	if ALLOW_MANUAL_SAVE_HOTKEYS:
		warnings.append("⚠️ ALLOW_MANUAL_SAVE_HOTKEYS is TRUE (F5/F9 accessible to players!)")
	
	if ALLOW_DEV_CHEATS:
		warnings.append("⚠️ ALLOW_DEV_CHEATS is TRUE (cheat codes enabled!)")
	
	if ALLOW_SKIP_WAVES:
		warnings.append("⚠️ ALLOW_SKIP_WAVES is TRUE (wave requirements can be skipped!)")
	
	if warnings.size() == 0:
		print("✅ All debug settings ready for production!")
	else:
		print("❌ NOT READY FOR PRODUCTION:")
		for warning in warnings:
			print("   " + warning)
	
	print("========================================")

func _ready():
	"""Auto-check on startup"""
	if DEBUG_ENABLED:
		print_production_check()
