extends Node2D
class_name HexCell

# Signals
signal cell_clicked(cell: HexCell)

# Cell properties
var grid_position: Vector2i = Vector2i.ZERO
var terrain_type: String = "grass"
var hex_size: float = 40.0
var color: Color = Color.GREEN
var is_selected: bool = false

# Visual elements
var polygon: Polygon2D
var selection_ring: Polygon2D
var label: Label

func _ready():
	setup_visuals()

func setup_visuals():
	"""Create the visual representation of the hex"""
	# Create the main hex polygon
	polygon = Polygon2D.new()
	polygon.polygon = get_hex_polygon()
	polygon.color = color
	add_child(polygon)
	
	# Create selection ring (outline)
	selection_ring = Polygon2D.new()
	selection_ring.polygon = get_hex_polygon(hex_size + 3)
	selection_ring.color = Color.YELLOW
	selection_ring.visible = false
	add_child(selection_ring)
	
	# Move the selection ring behind the main polygon
	move_child(selection_ring, 0)
	
	# Add a label for debugging (optional)
	label = Label.new()
	label.text = str(grid_position)
	label.position = Vector2(-15, -10)
	label.add_theme_font_size_override("font_size", 10)
	label.visible = false  # Set to true to see coordinates
	add_child(label)
	
	# Add input detection
	var area = Area2D.new()
	var collision = CollisionPolygon2D.new()
	collision.polygon = get_hex_polygon()
	area.add_child(collision)
	add_child(area)
	
	# Connect signals
	area.input_event.connect(_on_input_event)

func get_hex_polygon(size: float = 0.0) -> PackedVector2Array:
	"""Generate the points for a flat-top hexagon"""
	if size == 0.0:
		size = hex_size
	
	var points = PackedVector2Array()
	for i in range(6):
		var angle_deg = 60.0 * i
		var angle_rad = deg_to_rad(angle_deg)
		var x = size * cos(angle_rad)
		var y = size * sin(angle_rad)
		points.append(Vector2(x, y))
	
	return points

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	"""Handle input events on this hex cell"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cell_clicked.emit(self)

func set_selected(selected: bool):
	"""Set the selection state of this cell"""
	is_selected = selected
	selection_ring.visible = selected

func set_terrain(terrain: String, new_color: Color):
	"""Change the terrain type and color"""
	terrain_type = terrain
	color = new_color
	if polygon:
		polygon.color = color

func highlight(highlight_color: Color = Color.WHITE, duration: float = 0.5):
	"""Temporarily highlight this cell"""
	var tween = create_tween()
	tween.tween_property(polygon, "color", highlight_color, duration / 2)
	tween.tween_property(polygon, "color", color, duration / 2)
