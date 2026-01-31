extends Node2D
class_name HexGrid

# Hex grid configuration
@export var grid_width: int = 20
@export var grid_height: int = 15
@export var hex_size: float = 40.0

# Terrain colors
const TERRAIN_COLORS = {
	"grass": Color(0.4, 0.7, 0.3),
	"water": Color(0.2, 0.4, 0.8),
	"mountain": Color(0.5, 0.5, 0.5),
	"desert": Color(0.9, 0.8, 0.5),
	"forest": Color(0.2, 0.5, 0.2)
}

# Store all hex cells
var cells: Dictionary = {}
var selected_cell: HexCell = null

# Hex math constants
const SQRT3 = 1.732050808

# Preload the HexCell scene
var hex_cell_scene = preload("res://HexCell.tscn")

func _ready():
	generate_map()

func generate_map():
	"""Generate the hex grid map with random terrain"""
	for q in range(grid_width):
		for r in range(grid_height):
			var cell = hex_cell_scene.instantiate()
			cell.grid_position = Vector2i(q, r)
			cell.hex_size = hex_size
			
			# Set random terrain
			var terrain = get_random_terrain(q, r)
			cell.terrain_type = terrain
			cell.color = TERRAIN_COLORS[terrain]
			
			# Position the cell
			cell.position = hex_to_pixel(Vector2i(q, r))
			
			# Connect cell signals
			cell.cell_clicked.connect(_on_cell_clicked)
			
			# Add to scene and dictionary
			add_child(cell)
			cells[Vector2i(q, r)] = cell

func get_random_terrain(q: int, r: int) -> String:
	"""Generate terrain based on position (you can make this more sophisticated)"""
	var noise_value = (sin(q * 0.3) + cos(r * 0.3)) / 2.0
	
	if noise_value < -0.3:
		return "water"
	elif noise_value < 0.0:
		return "grass"
	elif noise_value < 0.3:
		return "forest"
	elif noise_value < 0.5:
		return "desert"
	else:
		return "mountain"

func hex_to_pixel(hex_pos: Vector2i) -> Vector2:
	"""Convert hex grid coordinates to pixel position (flat-top hexagons)"""
	var x = hex_size * (3.0/2.0 * hex_pos.x)
	var y = hex_size * (SQRT3/2.0 * hex_pos.x + SQRT3 * hex_pos.y)
	return Vector2(x, y)

func pixel_to_hex(pixel_pos: Vector2) -> Vector2i:
	"""Convert pixel position to hex grid coordinates"""
	var q = (2.0/3.0 * pixel_pos.x) / hex_size
	var r = (-1.0/3.0 * pixel_pos.x + SQRT3/3.0 * pixel_pos.y) / hex_size
	return hex_round(Vector2(q, r))

func hex_round(hex: Vector2) -> Vector2i:
	"""Round fractional hex coordinates to nearest hex"""
	var q = round(hex.x)
	var r = round(hex.y)
	var s = round(-hex.x - hex.y)
	
	var q_diff = abs(q - hex.x)
	var r_diff = abs(r - hex.y)
	var s_diff = abs(s - (-hex.x - hex.y))
	
	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	
	return Vector2i(int(q), int(r))

func get_cell(grid_pos: Vector2i) -> HexCell:
	"""Get a hex cell at the given grid position"""
	return cells.get(grid_pos)

func get_neighbors(grid_pos: Vector2i) -> Array[HexCell]:
	"""Get all neighboring hex cells"""
	var neighbors: Array[HexCell] = []
	var directions = [
		Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
	]
	
	for direction in directions:
		var neighbor_pos = grid_pos + direction
		var neighbor = get_cell(neighbor_pos)
		if neighbor:
			neighbors.append(neighbor)
	
	return neighbors

func _on_cell_clicked(cell: HexCell):
	"""Handle cell click events"""
	# Deselect previous cell
	if selected_cell:
		selected_cell.set_selected(false)
	
	# Select new cell
	selected_cell = cell
	cell.set_selected(true)
	
	print("Selected cell at: ", cell.grid_position, " Terrain: ", cell.terrain_type)
