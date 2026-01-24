extends Node2D
class_name Unit

# Signals
signal unit_clicked(unit: Unit)
signal movement_complete
signal unit_died

# Unit properties
@export var unit_name: String = "Settler"
@export var max_health: int = 100
@export var max_movement: int = 2
@export var attack_strength: int = 0
@export var defense_strength: int = 10

# Current state
var current_health: int
var current_movement: int
var grid_position: Vector2i
var is_selected: bool = false
var owner_id: int = 0  # 0 = player, 1+ = AI players

# Visual elements
var sprite: Sprite2D
var health_bar: ProgressBar
var movement_indicator: Label
var selection_ring: Polygon2D

# Unit types enum
enum UnitType {
	SETTLER,
	WARRIOR,
	SCOUT,
	WORKER
}

var unit_type: UnitType = UnitType.SETTLER

func _ready():
	current_health = max_health
	current_movement = max_movement
	setup_visuals()
	setup_input()

func setup_visuals():
	"""Create the visual representation of the unit"""
	# Create sprite (colored circle for now)
	sprite = Sprite2D.new()
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(get_unit_color())
	
	# Draw a circle on the image
	for x in range(64):
		for y in range(64):
			var dx = x - 32
			var dy = y - 32
			if dx * dx + dy * dy < 28 * 28:
				image.set_pixel(x, y, get_unit_color())
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.scale = Vector2(0.6, 0.6)
	add_child(sprite)
	
	# Create selection ring
	selection_ring = Polygon2D.new()
	selection_ring.polygon = get_circle_polygon(25, 32)
	selection_ring.color = Color(1, 1, 0, 0.5)
	selection_ring.visible = false
	add_child(selection_ring)
	move_child(selection_ring, 0)
	
	# Create health bar
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(40, 6)
	health_bar.position = Vector2(-20, -30)
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.show_percentage = false
	
	# Style the health bar
	var style_green = StyleBoxFlat.new()
	style_green.bg_color = Color(0, 0.8, 0)
	health_bar.add_theme_stylebox_override("fill", style_green)
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.3, 0.3, 0.3)
	health_bar.add_theme_stylebox_override("background", style_bg)
	
	add_child(health_bar)
	
	# Create movement indicator
	movement_indicator = Label.new()
	movement_indicator.text = str(current_movement)
	movement_indicator.position = Vector2(15, -25)
	movement_indicator.add_theme_font_size_override("font_size", 14)
	movement_indicator.add_theme_color_override("font_color", Color.WHITE)
	movement_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	movement_indicator.add_theme_constant_override("outline_size", 2)
	add_child(movement_indicator)

func get_circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	"""Generate a circle polygon"""
	var points = PackedVector2Array()
	for i in range(segments):
		var angle = (PI * 2 * i) / segments
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	return points

func get_unit_color() -> Color:
	"""Get color based on unit type and owner"""
	var base_color: Color
	
	match unit_type:
		UnitType.SETTLER:
			base_color = Color(0.2, 0.6, 0.9)  # Blue
		UnitType.WARRIOR:
			base_color = Color(0.9, 0.2, 0.2)  # Red
		UnitType.SCOUT:
			base_color = Color(0.9, 0.7, 0.2)  # Yellow
		UnitType.WORKER:
			base_color = Color(0.6, 0.4, 0.2)  # Brown
		_:
			base_color = Color.WHITE
	
	# Darken for AI units
	if owner_id > 0:
		base_color = base_color.darkened(0.3)
	
	return base_color

func setup_input():
	"""Setup input detection"""
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	
	area.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	"""Handle clicks on this unit"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			unit_clicked.emit(self)

func set_selected(selected: bool):
	"""Set selection state"""
	is_selected = selected
	selection_ring.visible = selected

func move_to_hex(target_position: Vector2i, hex_grid):
	"""Move unit to a target hex position"""
	if current_movement <= 0:
		print("No movement points left!")
		return false
	
	# Calculate path (for now, just direct movement)
	var distance = abs(target_position.x - grid_position.x) + abs(target_position.y - grid_position.y)
	
	if distance > current_movement:
		print("Target too far! Need ", distance, " movement, have ", current_movement)
		return false
	
	# Update position
	grid_position = target_position
	current_movement -= distance
	movement_indicator.text = str(current_movement)
	
	# Animate movement
	var target_pixel_pos = hex_grid.hex_to_pixel(target_position)
	var tween = create_tween()
	tween.tween_property(self, "position", target_pixel_pos, 0.3)
	tween.finished.connect(func(): movement_complete.emit())
	
	return true

func start_turn():
	"""Called at the start of each turn"""
	current_movement = max_movement
	movement_indicator.text = str(current_movement)

func take_damage(amount: int):
	"""Apply damage to the unit"""
	current_health -= amount
	current_health = max(0, current_health)
	health_bar.value = current_health
	
	if current_health <= 0:
		die()

func heal(amount: int):
	"""Heal the unit"""
	current_health += amount
	current_health = min(max_health, current_health)
	health_bar.value = current_health

func die():
	"""Handle unit death"""
	unit_died.emit()
	queue_free()

func can_move() -> bool:
	"""Check if unit can move this turn"""
	return current_movement > 0

func get_info_text() -> String:
	"""Get formatted info about this unit"""
	return "%s\nHP: %d/%d\nMove: %d/%d\nAttack: %d\nDefense: %d" % [
		unit_name,
		current_health,
		max_health,
		current_movement,
		max_movement,
		attack_strength,
		defense_strength
	]
