extends Node2D
class_name CityManager

# Signals
signal city_selected(city: City)
signal city_founded(city: City)
signal city_destroyed(city: City)

# References
var hex_grid: HexGrid
var cities: Array[City] = []
var selected_city: City = null

# City scene
var city_scene = preload("res://City.tscn")

func _ready():
	pass

func initialize(grid: HexGrid):
	"""Initialize with reference to hex grid"""
	hex_grid = grid

func found_city(grid_pos: Vector2i, name: String, owner_id: int = 0) -> City:
	"""Found a new city at the given grid position"""
	var city = city_scene.instantiate()
	city.grid_position = grid_pos
	city.owner_id = owner_id
	city.set_city_name(name)

	# Position the city
	city.position = hex_grid.hex_to_pixel(grid_pos)

	# Connect signals
	city.city_clicked.connect(_on_city_clicked)
	city.city_destroyed.connect(_on_city_destroyed.bind(city))

	# Add to scene and tracking array
	add_child(city)
	cities.append(city)

	city_founded.emit(city)
	print("City '", name, "' founded at ", grid_pos)

	return city

func _on_city_clicked(city: City):
	"""Handle city click"""
	select_city(city)

func select_city(city: City):
	"""Select a city"""
	# Deselect previous city
	if selected_city:
		selected_city.set_selected(false)

	# Select new city
	selected_city = city
	city.set_selected(true)
	city_selected.emit(city)

	print("Selected city: ", city.city_name, " at ", city.grid_position)

func deselect_city():
	"""Deselect current city"""
	if selected_city:
		selected_city.set_selected(false)
		selected_city = null

func get_city_at(grid_pos: Vector2i) -> City:
	"""Get city at the specified grid position"""
	for city in cities:
		if city.grid_position == grid_pos:
			return city
	return null

func start_turn() -> Dictionary:
	"""Called at the start of each turn - process all cities. Returns {food, production, gold} for player."""
	var totals = {"food": 0, "production": 0, "gold": 0}
	for city in cities:
		if city.owner_id == 0:  # Only player cities for now
			var yields = city.process_turn()
			totals.food += yields.food
			totals.production += yields.production
			totals.gold += yields.gold
	return totals

func get_player_cities() -> Array[City]:
	"""Get all cities belonging to the player"""
	var player_cities: Array[City] = []
	for city in cities:
		if city.owner_id == 0:
			player_cities.append(city)
	return player_cities

func get_all_cities() -> Array[City]:
	"""Get all cities in the game"""
	return cities

func _on_city_destroyed(city: City):
	"""Handle city destruction"""
	cities.erase(city)
	if selected_city == city:
		selected_city = null
	city_destroyed.emit(city)
	print(city.city_name, " has been destroyed!")

func remove_all_cities():
	"""Remove all cities from the game"""
	for city in cities:
		city.queue_free()
	cities.clear()
	selected_city = null
