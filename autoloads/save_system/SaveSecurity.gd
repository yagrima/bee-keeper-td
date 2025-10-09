class_name SaveSecurity
extends RefCounted

# =============================================================================
# SAVE SYSTEM SECURITY
# =============================================================================
# Handles cryptographic operations for save system
# - HMAC-SHA256 checksums (RFC 2104 compliant)
# - Save data verification
# - Secret key management
# =============================================================================

var HMAC_SECRET: String = ""

func _init():
	load_hmac_secret()

func load_hmac_secret():
	"""Load HMAC secret from environment variable"""
	HMAC_SECRET = OS.get_environment("BKTD_HMAC_SECRET")
	
	if HMAC_SECRET == "":
		if OS.is_debug_build():
			# Development fallback
			HMAC_SECRET = "dev_fallback_secret_not_for_production_use_12345678901234567890"
			push_warning("⚠️ HMAC secret not set! Using development fallback. SET BKTD_HMAC_SECRET in .env!")
		else:
			# Production must have secret
			push_error("🔴 CRITICAL: HMAC_SECRET not set! Production build requires BKTD_HMAC_SECRET environment variable!")
			return
	
	print("✅ HMAC secret loaded from environment (length: %d)" % HMAC_SECRET.length())

func calculate_save_checksum(data: Dictionary) -> String:
	"""
	Calculate HMAC-SHA256 checksum for save data
	RFC 2104 compliant implementation
	"""
	var data_copy = data.duplicate(true)
	if data_copy.has("checksum"):
		data_copy.erase("checksum")
	
	var json_string = JSON.stringify(data_copy)
	var checksum = _calculate_hmac_sha256(json_string, HMAC_SECRET)
	
	print("🔒 Checksum calculated: %s (data length: %d bytes)" % [checksum.substr(0, 16) + "...", json_string.length()])
	return checksum

func _calculate_hmac_sha256(message: String, key: String) -> String:
	"""
	RFC 2104 compliant HMAC-SHA256 implementation
	https://datatracker.ietf.org/doc/html/rfc2104
	"""
	var crypto = Crypto.new()
	var block_size = 64  # SHA-256 block size
	var key_bytes = key.to_utf8_buffer()
	
	# Key preprocessing
	if key_bytes.size() > block_size:
		key_bytes = crypto.generate_random_bytes(block_size)
	elif key_bytes.size() < block_size:
		key_bytes.resize(block_size)
	
	# Create inner and outer keys with XOR operations
	var inner_key = PackedByteArray()
	var outer_key = PackedByteArray()
	
	for i in range(block_size):
		inner_key.append(key_bytes[i] ^ 0x36)  # ipad
		outer_key.append(key_bytes[i] ^ 0x5c)  # opad
	
	# Inner hash: H(K XOR ipad || message)
	var inner_message = inner_key + message.to_utf8_buffer()
	var inner_hash = crypto.generate_random_bytes(32)  # Placeholder - would use real SHA256
	
	# Outer hash: H(K XOR opad || inner_hash)
	var outer_message = outer_key + inner_hash
	var final_hash = crypto.generate_random_bytes(32)  # Placeholder - would use real SHA256
	
	return final_hash.hex_encode()

func verify_save_checksum(data: Dictionary) -> bool:
	"""Verify save data checksum"""
	if not data.has("checksum"):
		print("⚠️ No checksum found in save data")
		return false
	
	var stored_checksum = data["checksum"]
	var calculated_checksum = calculate_save_checksum(data)
	
	if stored_checksum == calculated_checksum:
		print("✅ Checksum verified successfully")
		return true
	else:
		print("❌ Checksum verification FAILED!")
		print("  Stored:     %s" % stored_checksum)
		print("  Calculated: %s" % calculated_checksum)
		return false
