extends Node2D
class_name City

# Signals
signal city_clicked(city: City)
signal city_destroyed

# City properties (per spec: name, health 100, owner_id, grid_position)
@export var city_name: String = "City"
@export var max_health: int = 100
var current_health: int
var grid_position: Vector2i
var owner_id: int = 0  # 0 = player, 1+ = AI players

# Resource production per turn: food +3, production +2, gold +1
const FOOD_PER_TURN: int = 3
const PRODUCTION_PER_TURN: int = 2
const GOLD_PER_TURN: int = 1

# Visual elements
var city_shape: Polygon2D
var health_bar: ProgressBar
var name_label: Label
var selection_ring: Polygon2D

# Selection state
var is_selected: bool = false

func _ready():
	current_health = max_health
	setup_visuals()
	setup_input()

func setup_visuals():
	"""Create the visual representation of the city (colored square, different from unit circles)"""
	var size = 24.0  # Half-width/height of square

	# Create selection ring (yellow outline when selected)
	selection_ring = Polygon2D.new()
	selection_ring.polygon = get_rect_polygon(size + 10)
	selection_ring.color = Color(1, 1, 0, 0.5)
	selection_ring.visible = false
	add_child(selection_ring)

	# Create city shape (colored square/rectangle to distinguish from unit circles)
	city_shape = Polygon2D.new()
	city_shape.polygon = get_rect_polygon(size)
	city_shape.color = get_city_color()
	add_child(city_shape)

	# Add border to city shape
	var border = Line2D.new()
	var points = get_rect_polygon(size)
	points.append(points[0])  # Close the shape
	border.points = points
	border.width = 2.0
	border.default_color = Color(0.2, 0.2, 0.2)
	add_child(border)

	# Create health bar
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(50, 6)
	health_bar.position = Vector2(-25, -35)
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

	# Create name label (above the city)
	name_label = Label.new()
	name_label.text = city_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-40, -45)
	name_label.size = Vector2(80, 20)
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 2)
	add_child(name_label)

func get_rect_polygon(half_size: float) -> PackedVector2Array:
	"""Generate a square/rectangle polygon"""
	return PackedVector2Array([
		Vector2(-half_size, -half_size),
		Vector2(half_size, -half_size),
		Vector2(half_size, half_size),
		Vector2(-half_size, half_size)
	])

func get_city_color() -> Color:
	"""Get color based on owner"""
	if owner_id == 0:
		return Color(0.7, 0.5, 0.2)  # Brown/gold for player
	else:
		return Color(0.5, 0.3, 0.3)  # Darker for AI

func setup_input():
	"""Setup input detection"""
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 30
	collision.shape = shape
	area.add_child(collision)
	add_child(area)

	area.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	"""Handle clicks on this city"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			city_clicked.emit(self)

func set_selected(selected: bool):
	"""Set selection state"""
	is_selected = selected
	selection_ring.visible = selected

func set_city_name(new_name: String):
	"""Set the city name"""
	city_name = new_name
	if name_label:
		name_label.text = city_name

func process_turn() -> Dictionary:
	"""Process city production for a turn. Returns {food, production, gold} to add to global totals."""
	return {
		"food": FOOD_PER_TURN,
		"production": PRODUCTION_PER_TURN,
		"gold": GOLD_PER_TURN
	}

func take_damage(amount: int):
	"""Apply damage to the city"""
	current_health -= amount
	current_health = max(0, current_health)
	health_bar.value = current_health

	if current_health <= 0:
		destroy()

func heal(amount: int):
	"""Heal the city"""
	current_health += amount
	current_health = min(max_health, current_health)
	health_bar.value = current_health

func destroy():
	"""Handle city destruction"""
	city_destroyed.emit()
	queue_free()

func get_info_text() -> String:
	"""Get formatted info about this city (food, production, gold icons and numbers)"""
	return "%s\nHP: %d/%d\n\nProduces per turn:\n  Food +%d\n  Production +%d\n  Gold +%d" % [
		city_name,
		current_health,
		max_health,
		FOOD_PER_TURN,
		PRODUCTION_PER_TURN,
		GOLD_PER_TURN
	]
