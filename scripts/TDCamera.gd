extends Camera2D

var zoom_speed: float = 0.1
var zoom_min: float = 0.5
var zoom_max: float = 2.0

var pan_speed: float = 300.0
var is_panning: bool = false
var last_mouse_position: Vector2

func _ready():
	# Set initial zoom and position to center of screen (where map will be)
	zoom = Vector2(1.0, 1.0)

	# Center camera on middle of window (where the centered map is)
	var window_size = get_viewport().get_visible_rect().size
	position = window_size / 2

	# Enable camera
	enabled = true
	make_current()

	# Debug camera position
	print("Camera initialized at position: ", position, " with zoom: ", zoom)
	print("Window size: ", window_size)

func _input(event):
	handle_zoom(event)
	handle_panning(event)

func handle_zoom(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func handle_panning(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				last_mouse_position = event.position
			else:
				is_panning = false

	elif event is InputEventMouseMotion and is_panning:
		var delta = last_mouse_position - event.position
		position += delta / zoom
		last_mouse_position = event.position

func _process(delta):
	handle_keyboard_movement(delta)

func handle_keyboard_movement(delta):
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1

	if velocity.length() > 0:
		velocity = velocity.normalized()
		position += velocity * pan_speed * delta / zoom.x

func zoom_in():
	var new_zoom = zoom * (1.0 + zoom_speed)
	if new_zoom.x <= zoom_max:
		zoom = new_zoom

func zoom_out():
	var new_zoom = zoom * (1.0 - zoom_speed)
	if new_zoom.x >= zoom_min:
		zoom = new_zoom