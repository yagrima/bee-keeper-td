extends Node

# Error Handler - Centralized Error Management
# Handles network errors, auth errors, validation errors

signal error_occurred(error_type: String, error_message: String)

enum ErrorType {
	NETWORK,
	AUTHENTICATION,
	VALIDATION,
	SAVE_LOAD,
	RATE_LIMIT,
	UNKNOWN
}

func handle_error(type: ErrorType, message: String, details: Dictionary = {}):
	"""Central error handling with user-friendly messages"""

	var user_message = _get_user_friendly_message(type, message, details)
	var error_type_str = ErrorType.keys()[type]

	# Emit signal
	error_occurred.emit(error_type_str, user_message)

	# Log to console
	push_error("[%s] %s | Details: %s" % [error_type_str, message, JSON.stringify(details)])

	# Show notification
	if NotificationManager:
		NotificationManager.show_error(user_message, 6.0)  # Longer duration for errors

	# Additional actions based on error type
	match type:
		ErrorType.NETWORK:
			_handle_network_error(details)
		ErrorType.AUTHENTICATION:
			_handle_auth_error(details)
		ErrorType.RATE_LIMIT:
			_handle_rate_limit_error(details)

func _get_user_friendly_message(type: ErrorType, technical_message: String, details: Dictionary) -> String:
	"""Convert technical errors to user-friendly messages"""

	match type:
		ErrorType.NETWORK:
			if "timeout" in technical_message.to_lower():
				return "⚠️ Connection timeout. Please check your internet connection."
			elif "refused" in technical_message.to_lower():
				return "⚠️ Could not connect to server. Please try again later."
			elif "dns" in technical_message.to_lower():
				return "⚠️ Server not found. Please check your connection."
			else:
				return "⚠️ Network error. Using offline mode."

		ErrorType.AUTHENTICATION:
			if "invalid" in technical_message.to_lower() and "password" in technical_message.to_lower():
				return "❌ Invalid email or password"
			elif "already exists" in technical_message.to_lower():
				return "❌ An account with this email already exists"
			elif "expired" in technical_message.to_lower():
				return "⚠️ Session expired. Please log in again."
			elif "unauthorized" in technical_message.to_lower():
				return "❌ Unauthorized. Please log in."
			else:
				return "❌ Authentication error: " + technical_message

		ErrorType.VALIDATION:
			if "password" in technical_message.to_lower():
				return "❌ Password must be at least 14 characters"
			elif "email" in technical_message.to_lower():
				return "❌ Please enter a valid email address"
			elif "username" in technical_message.to_lower():
				return "❌ Username is required"
			else:
				return "❌ Validation error: " + technical_message

		ErrorType.SAVE_LOAD:
			if "cloud" in technical_message.to_lower():
				return "⚠️ Cloud save failed. Saved locally instead."
			elif "corrupted" in technical_message.to_lower():
				return "❌ Save data corrupted. Starting fresh."
			elif "not found" in technical_message.to_lower():
				return "ℹ️ No save data found. Starting new game."
			else:
				return "❌ Save/Load error: " + technical_message

		ErrorType.RATE_LIMIT:
			var retry_after = details.get("retry_after", 60)
			return "⏳ Too many requests. Please wait %d seconds." % retry_after

		ErrorType.UNKNOWN:
			return "❌ An unexpected error occurred: " + technical_message

	return technical_message  # Fallback

func _handle_network_error(details: Dictionary):
	"""Handle network-specific errors"""
	# Could implement retry logic, offline mode switching, etc.
	print("Network error detected. Details: ", details)

func _handle_auth_error(details: Dictionary):
	"""Handle auth-specific errors"""
	var status_code = details.get("status_code", 0)

	if status_code == 401:  # Unauthorized
		# Clear invalid session
		if SupabaseClient:
			SupabaseClient.logout()
		# Redirect to auth screen
		if SceneManager:
			SceneManager.goto_auth_screen()

	print("Auth error detected. Status: ", status_code)

func _handle_rate_limit_error(details: Dictionary):
	"""Handle rate limit errors"""
	var retry_after = details.get("retry_after", 60)
	print("Rate limited. Retry after: ", retry_after, " seconds")

# Helper functions for common error scenarios

func handle_http_error(response_code: int, body: String):
	"""Handle HTTP response errors"""
	var details = {
		"response_code": response_code,
		"body": body
	}

	match response_code:
		400:
			handle_error(ErrorType.VALIDATION, "Bad request", details)
		401:
			handle_error(ErrorType.AUTHENTICATION, "Unauthorized", details)
		403:
			handle_error(ErrorType.AUTHENTICATION, "Forbidden", details)
		404:
			handle_error(ErrorType.NETWORK, "Resource not found", details)
		429:
			handle_error(ErrorType.RATE_LIMIT, "Rate limit exceeded", details)
		500, 502, 503, 504:
			handle_error(ErrorType.NETWORK, "Server error", details)
		_:
			handle_error(ErrorType.UNKNOWN, "HTTP error %d" % response_code, details)

func handle_validation_error(field: String, reason: String):
	"""Handle validation errors"""
	var message = "Validation failed for %s: %s" % [field, reason]
	handle_error(ErrorType.VALIDATION, message, {"field": field, "reason": reason})

func handle_network_timeout():
	"""Handle network timeout"""
	handle_error(ErrorType.NETWORK, "Request timeout", {})

func handle_save_error(reason: String):
	"""Handle save errors"""
	handle_error(ErrorType.SAVE_LOAD, "Save failed: " + reason, {})

func handle_load_error(reason: String):
	"""Handle load errors"""
	handle_error(ErrorType.SAVE_LOAD, "Load failed: " + reason, {})
