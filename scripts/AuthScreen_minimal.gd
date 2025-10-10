extends Control

@onready var email_input = $CenterContainer/VBoxContainer/EmailInput
@onready var password_input = $CenterContainer/VBoxContainer/PasswordInput
@onready var login_button = $CenterContainer/VBoxContainer/LoginButton
@onready var error_label = $CenterContainer/VBoxContainer/ErrorLabel

func _ready():
	print("🔐 Minimal AuthScreen initialized")
	
	login_button.pressed.connect(_on_login_pressed)
	password_input.text_submitted.connect(_on_password_submitted)
	
	error_label.text = ""
	
	SupabaseClient.auth_completed.connect(_on_auth_completed)
	SupabaseClient.auth_error.connect(_on_auth_error)
	
	if SupabaseClient.is_authenticated():
		print("✅ Already authenticated")
		SceneManager.goto_main_menu()

func _on_login_pressed():
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	error_label.text = ""
	
	if email.is_empty() or password.is_empty():
		error_label.text = "Please enter email and password"
		return
	
	print("🔑 Login: %s" % email)
	login_button.disabled = true
	SupabaseClient.login(email, password)

func _on_password_submitted(_text: String):
	_on_login_pressed()

func _on_auth_completed(success: bool, user_data: Dictionary):
	login_button.disabled = false
	if success:
		print("✅ Auth successful")
		SceneManager.goto_main_menu()
	else:
		error_label.text = "Authentication failed"

func _on_auth_error(error_message: String):
	login_button.disabled = false
	error_label.text = error_message
	print("❌ Auth error: %s" % error_message)
