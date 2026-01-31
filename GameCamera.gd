extends Camera2D

# Camera settings
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 2.0
@export var pan_speed: float = 500.0

# Camera state
var is_panning: bool = false
var pan_start_position: Vector2

func _ready():
	# Set initial zoom
	zoom = Vector2(1.0, 1.0)

func _process(delta):
	handle_keyboard_pan(delta)

func _input(event):
	handle_zoom(event)
	handle_mouse_pan(event)

func handle_zoom(event: InputEvent):
	"""Handle mouse wheel zoom"""
	if event is InputEventMouseButton:
		var zoom_factor = 1.0
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_factor = 1.0 + zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_factor = 1.0 - zoom_speed
		
		if zoom_factor != 1.0:
			var new_zoom = zoom * zoom_factor
			new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
			new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
			zoom = new_zoom

func handle_mouse_pan(event: InputEvent):
	"""Handle middle mouse button drag panning"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = get_global_mouse_position()
			else:
				is_panning = false
	
	if event is InputEventMouseMotion and is_panning:
		var mouse_pos = get_global_mouse_position()
		var delta_pos = pan_start_position - mouse_pos
		position += delta_pos

func handle_keyboard_pan(delta: float):
	"""Handle WASD or arrow key panning"""
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * pan_speed * delta / zoom.x

func center_on(target_position: Vector2):
	"""Smoothly move camera to focus on a position"""
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func set_zoom_level(level: float):
	"""Set zoom to a specific level"""
	var new_zoom = Vector2(level, level)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	
	var tween = create_tween()
	tween.tween_property(self, "zoom", new_zoom, 0.3).set_trans(Tween.TRANS_QUAD)
