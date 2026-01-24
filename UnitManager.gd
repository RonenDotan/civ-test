extends Node2D
class_name UnitManager

# Signals
signal unit_selected(unit: Unit)
signal unit_moved(unit: Unit)
signal settler_wants_to_found_city(unit: Unit, grid_position: Vector2i)

# References
var hex_grid: HexGrid
var units: Array[Unit] = []
var selected_unit: Unit = null

# Unit scene
var unit_scene = preload("res://Unit.tscn")

func _ready():
	pass

func initialize(grid: HexGrid):
	"""Initialize with reference to hex grid"""
	hex_grid = grid

func spawn_unit(unit_type: int, grid_pos: Vector2i, owner_id: int = 0) -> Unit:
	"""Spawn a new unit at the given grid position"""
	var unit = unit_scene.instantiate()
	unit.unit_type = unit_type
	unit.grid_position = grid_pos
	unit.owner_id = owner_id
	
	# Set unit stats based on type
	match unit_type:
		Unit.UnitType.SETTLER:
			unit.unit_name = "Settler"
			unit.max_health = 100
			unit.max_movement = 2
			unit.attack_strength = 0
			unit.defense_strength = 10
		Unit.UnitType.WARRIOR:
			unit.unit_name = "Warrior"
			unit.max_health = 100
			unit.max_movement = 2
			unit.attack_strength = 20
			unit.defense_strength = 15
		Unit.UnitType.SCOUT:
			unit.unit_name = "Scout"
			unit.max_health = 60
			unit.max_movement = 3
			unit.attack_strength = 10
			unit.defense_strength = 8
		Unit.UnitType.WORKER:
			unit.unit_name = "Worker"
			unit.max_health = 80
			unit.max_movement = 2
			unit.attack_strength = 0
			unit.defense_strength = 10
	
	# Position the unit
	unit.position = hex_grid.hex_to_pixel(grid_pos)
	
	# Connect signals
	unit.unit_clicked.connect(_on_unit_clicked)
	unit.unit_died.connect(_on_unit_died.bind(unit))

	# Connect settler-specific signal
	if unit_type == Unit.UnitType.SETTLER:
		unit.settler_found_city.connect(_on_settler_found_city)

	# Add to scene and tracking array
	add_child(unit)
	units.append(unit)

	return unit

func _on_settler_found_city(unit: Unit, grid_pos: Vector2i):
	"""Forward settler founding request to Main"""
	settler_wants_to_found_city.emit(unit, grid_pos)

func _on_unit_clicked(unit: Unit):
	"""Handle unit click"""
	select_unit(unit)

func select_unit(unit: Unit):
	"""Select a unit"""
	# Deselect previous unit
	if selected_unit:
		selected_unit.set_selected(false)
	
	# Select new unit
	selected_unit = unit
	unit.set_selected(true)
	unit_selected.emit(unit)
	
	print("Selected: ", unit.unit_name, " at ", unit.grid_position)

func deselect_unit():
	"""Deselect current unit"""
	if selected_unit:
		selected_unit.set_selected(false)
		selected_unit = null

func move_selected_unit_to(target_pos: Vector2i) -> bool:
	"""Move the selected unit to target position"""
	if not selected_unit:
		return false
	
	if not selected_unit.can_move():
		print("Unit has no movement points!")
		return false
	
	# Check if there's already a unit at target
	var unit_at_target = get_unit_at(target_pos)
	if unit_at_target:
		print("Another unit is already at that position!")
		return false
	
	# Move the unit
	var success = selected_unit.move_to_hex(target_pos, hex_grid)
	if success:
		unit_moved.emit(selected_unit)
	
	return success

func get_unit_at(grid_pos: Vector2i) -> Unit:
	"""Get unit at the specified grid position"""
	for unit in units:
		if unit.grid_position == grid_pos:
			return unit
	return null

func start_turn():
	"""Called at the start of each turn - refresh all units"""
	for unit in units:
		if unit.owner_id == 0:  # Only player units for now
			unit.start_turn()

func get_player_units() -> Array[Unit]:
	"""Get all units belonging to the player"""
	var player_units: Array[Unit] = []
	for unit in units:
		if unit.owner_id == 0:
			player_units.append(unit)
	return player_units

func get_all_units() -> Array[Unit]:
	"""Get all units in the game"""
	return units

func _on_unit_died(unit: Unit):
	"""Handle unit death"""
	units.erase(unit)
	if selected_unit == unit:
		selected_unit = null
	print(unit.unit_name, " has died!")

func remove_unit(unit: Unit):
	"""Remove a unit from the game (e.g., settler consumed when founding city)"""
	units.erase(unit)
	if selected_unit == unit:
		selected_unit = null
	unit.queue_free()

func remove_all_units():
	"""Remove all units from the game"""
	for unit in units:
		unit.queue_free()
	units.clear()
	selected_unit = null
