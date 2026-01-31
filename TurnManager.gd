extends Node
class_name TurnManager

# Signals
signal turn_started(turn_number: int)
signal turn_ended(turn_number: int)
signal player_turn_started
signal ai_turn_started
signal resources_updated(food: int, production: int, gold: int, science: int, culture: int)

# Turn state - total resources globally for the player
var current_turn: int = 1
var player_food: int = 0
var player_production: int = 0
var player_gold: int = 0
var player_science: int = 0
var player_culture: int = 0
var is_player_turn: bool = true
var units_with_moves_left: int = 0

# References
var unit_manager: UnitManager
var city_manager  # CityManager - not typed to avoid circular dependency

func _ready():
	pass

func initialize(units: UnitManager, cities = null):
	"""Initialize with reference to unit manager and city manager"""
	unit_manager = units
	city_manager = cities

func start_game():
	"""Start the first turn"""
	start_turn()

func start_turn():
	"""Start a new turn"""
	print("=== Turn ", current_turn, " Started ===")

	# Process city production (food, production, gold, science, culture per turn)
	if city_manager:
		var yields = city_manager.start_turn()
		player_food += yields.food
		player_production += yields.production
		player_gold += yields.gold
		player_science += yields.science
		player_culture += yields.culture
		resources_updated.emit(player_food, player_production, player_gold, player_science, player_culture)
		if yields.food > 0 or yields.production > 0 or yields.gold > 0 or yields.science > 0 or yields.culture > 0:
			print("Cities produced: Food +%d, Prod +%d, Gold +%d, Science +%d, Culture +%d" % [yields.food, yields.production, yields.gold, yields.science, yields.culture])

	# Refresh all units
	if unit_manager:
		unit_manager.start_turn()
		units_with_moves_left = count_units_with_moves()

	turn_started.emit(current_turn)
	
	if is_player_turn:
		player_turn_started.emit()
		print("Player's turn")
	else:
		ai_turn_started.emit()
		print("AI turn (not implemented yet)")

func end_turn():
	"""End the current turn and start the next"""
	print("=== Turn ", current_turn, " Ended ===")
	turn_ended.emit(current_turn)
	
	# Increment turn counter
	current_turn += 1
	
	# Switch between player and AI (for now just player)
	# is_player_turn = !is_player_turn
	
	# Start next turn
	start_turn()

func count_units_with_moves() -> int:
	"""Count how many units still have movement points"""
	if not unit_manager:
		return 0
	
	var count = 0
	for unit in unit_manager.get_player_units():
		if unit.can_move():
			count += 1
	return count

func can_end_turn() -> bool:
	"""Check if the turn can be ended"""
	return is_player_turn

func get_current_turn() -> int:
	"""Get the current turn number"""
	return current_turn

func is_it_player_turn() -> bool:
	"""Check if it's the player's turn"""
	return is_player_turn
