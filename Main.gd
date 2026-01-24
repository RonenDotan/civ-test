extends Node2D

# Scene references
@onready var hex_grid = $HexGrid
@onready var game_camera = $GameCamera
@onready var unit_manager = $UnitManager
@onready var city_manager = $CityManager
@onready var turn_manager = $TurnManager
@onready var game_ui = $GameUI

# City name generation
var city_names = [
	"Alexandria", "Rome", "Athens", "Babylon", "Memphis",
	"Carthage", "Sparta", "Thebes", "Corinth", "Syracuse",
	"Antioch", "Persepolis", "Nineveh", "Ur", "Damascus",
	"Jerusalem", "Tyre", "Sidon", "Palmyra", "Petra"
]
var used_city_names: Array[String] = []

func _ready():
	# Initialize managers
	unit_manager.initialize(hex_grid)
	city_manager.initialize(hex_grid)
	turn_manager.initialize(unit_manager, city_manager)
	game_ui.initialize(turn_manager, unit_manager, city_manager)

	# Connect city manager signals
	city_manager.city_selected.connect(_on_city_selected)

	# Connect settler founding signal
	unit_manager.settler_wants_to_found_city.connect(_on_settler_found_city)

	# Spawn some starting units for testing
	spawn_starting_units()

	# Start the game
	turn_manager.start_game()

	# Connect hex grid clicks for unit movement
	for cell in hex_grid.cells.values():
		cell.cell_clicked.connect(_on_hex_clicked)

func spawn_starting_units():
	"""Spawn initial units for the player"""
	# Spawn a settler
	unit_manager.spawn_unit(Unit.UnitType.SETTLER, Vector2i(5, 5), 0)
	
	# Spawn a warrior
	unit_manager.spawn_unit(Unit.UnitType.WARRIOR, Vector2i(6, 5), 0)
	
	# Spawn a scout
	unit_manager.spawn_unit(Unit.UnitType.SCOUT, Vector2i(5, 6), 0)
	
	print("Starting units spawned!")

func _on_hex_clicked(cell: HexCell):
	"""Handle hex cell clicks - for unit movement and city selection"""
	# Check if there's a city at this hex
	var city_at_hex = city_manager.get_city_at(cell.grid_position)
	if city_at_hex:
		# Deselect unit if one is selected
		unit_manager.deselect_unit()
		game_ui.hide_unit_info()
		# Select the city
		city_manager.select_city(city_at_hex)
		return

	# If a unit is selected, try to move it
	if unit_manager.selected_unit:
		# Don't move onto a city
		if city_manager.get_city_at(cell.grid_position):
			print("Cannot move onto a city")
			return

		var success = unit_manager.move_selected_unit_to(cell.grid_position)
		if not success:
			print("Cannot move to that hex")
	else:
		# No unit selected, just show hex info
		print("Clicked hex: ", cell.grid_position, " Terrain: ", cell.terrain_type)

func _input(event):
	"""Handle global input"""
	# Deselect unit and city with right-click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			unit_manager.deselect_unit()
			city_manager.deselect_city()
			game_ui.hide_unit_info()
			game_ui.hide_city_info()

	# Quick end turn with spacebar
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			if turn_manager.can_end_turn():
				turn_manager.end_turn()

func _on_settler_found_city(unit: Unit, grid_pos: Vector2i):
	"""Handle settler attempting to found a city"""
	# Check if terrain is valid for founding
	var cell = hex_grid.get_cell(grid_pos)
	if not cell:
		game_ui.show_message("Invalid location!")
		return

	# Cannot found on water or mountains
	if cell.terrain_type == "water":
		game_ui.show_message("Cannot found city on water!")
		return
	if cell.terrain_type == "mountain":
		game_ui.show_message("Cannot found city on mountains!")
		return

	# Cannot found where a city already exists
	if city_manager.get_city_at(grid_pos):
		game_ui.show_message("A city already exists here!")
		return

	# Generate city name and found the city
	var name = generate_city_name()
	city_manager.found_city(grid_pos, name, unit.owner_id)

	# Remove the settler
	unit_manager.remove_unit(unit)
	game_ui.hide_unit_info()

	game_ui.show_message(name + " has been founded!")

func _on_city_selected(_city):
	"""Handle city selection - deselect any selected unit"""
	unit_manager.deselect_unit()

func generate_city_name() -> String:
	"""Generate a unique city name"""
	for name in city_names:
		if name not in used_city_names:
			used_city_names.append(name)
			return name

	# If all names used, generate numbered name
	var num = used_city_names.size() - city_names.size() + 1
	return "City " + str(num)
