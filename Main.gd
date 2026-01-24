extends Node2D

# Scene references
@onready var hex_grid = $HexGrid
@onready var game_camera = $GameCamera
@onready var unit_manager = $UnitManager
@onready var turn_manager = $TurnManager
@onready var game_ui = $GameUI

func _ready():
	# Initialize managers
	unit_manager.initialize(hex_grid)
	turn_manager.initialize(unit_manager)
	game_ui.initialize(turn_manager, unit_manager)
	
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
	"""Handle hex cell clicks - for unit movement"""
	# If a unit is selected, try to move it
	if unit_manager.selected_unit:
		var success = unit_manager.move_selected_unit_to(cell.grid_position)
		if not success:
			print("Cannot move to that hex")
	else:
		# No unit selected, just show hex info
		print("Clicked hex: ", cell.grid_position, " Terrain: ", cell.terrain_type)

func _input(event):
	"""Handle global input"""
	# Deselect unit with right-click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			unit_manager.deselect_unit()
			game_ui.hide_unit_info()
	
	# Quick end turn with spacebar
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			if turn_manager.can_end_turn():
				turn_manager.end_turn()
