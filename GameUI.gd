extends CanvasLayer
class_name GameUI

# UI Elements
var turn_label: Label
var resources_label: Label
var unit_info_panel: Panel
var unit_info_label: Label
var end_turn_button: Button
var found_city_button: Button
var city_info_panel: Panel
var city_info_label: Label

# References
var turn_manager: TurnManager
var unit_manager: UnitManager
var city_manager  # CityManager

func _ready():
	setup_ui()

func setup_ui():
	"""Create all UI elements"""
	# Turn counter (top-left)
	turn_label = Label.new()
	turn_label.text = "Turn: 1"
	turn_label.position = Vector2(10, 10)
	turn_label.add_theme_font_size_override("font_size", 20)
	turn_label.add_theme_color_override("font_color", Color.WHITE)
	turn_label.add_theme_color_override("font_outline_color", Color.BLACK)
	turn_label.add_theme_constant_override("outline_size", 2)
	add_child(turn_label)

	# Total resources display (Food, Production, Gold) - top-left
	resources_label = Label.new()
	resources_label.text = "Food: 0  Production: 0  Gold: 0"
	resources_label.position = Vector2(10, 35)
	resources_label.add_theme_font_size_override("font_size", 16)
	resources_label.add_theme_color_override("font_color", Color.WHITE)
	resources_label.add_theme_color_override("font_outline_color", Color.BLACK)
	resources_label.add_theme_constant_override("outline_size", 2)
	add_child(resources_label)

	# End turn button (top-right)
	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.position = Vector2(1050, 10)
	end_turn_button.size = Vector2(120, 40)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.4, 0.8)
	style_normal.corner_radius_top_left = 5
	style_normal.corner_radius_top_right = 5
	style_normal.corner_radius_bottom_left = 5
	style_normal.corner_radius_bottom_right = 5
	end_turn_button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.5, 0.9)
	style_hover.corner_radius_top_left = 5
	style_hover.corner_radius_top_right = 5
	style_hover.corner_radius_bottom_left = 5
	style_hover.corner_radius_bottom_right = 5
	end_turn_button.add_theme_stylebox_override("hover", style_hover)
	
	add_child(end_turn_button)
	
	# Unit info panel (bottom-left)
	unit_info_panel = Panel.new()
	unit_info_panel.position = Vector2(10, 550)
	unit_info_panel.size = Vector2(200, 150)
	unit_info_panel.visible = false
	
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style_panel.corner_radius_top_left = 5
	style_panel.corner_radius_top_right = 5
	style_panel.corner_radius_bottom_left = 5
	style_panel.corner_radius_bottom_right = 5
	style_panel.border_width_left = 2
	style_panel.border_width_right = 2
	style_panel.border_width_top = 2
	style_panel.border_width_bottom = 2
	style_panel.border_color = Color(0.4, 0.4, 0.4)
	unit_info_panel.add_theme_stylebox_override("panel", style_panel)
	
	add_child(unit_info_panel)
	
	# Unit info label
	unit_info_label = Label.new()
	unit_info_label.position = Vector2(10, 10)
	unit_info_label.size = Vector2(180, 130)
	unit_info_label.add_theme_font_size_override("font_size", 14)
	unit_info_label.add_theme_color_override("font_color", Color.WHITE)
	unit_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	unit_info_panel.add_child(unit_info_label)

	# Found city button (inside unit panel, only visible for settlers)
	found_city_button = Button.new()
	found_city_button.text = "Found City"
	found_city_button.position = Vector2(10, 110)
	found_city_button.size = Vector2(180, 30)
	found_city_button.visible = false
	found_city_button.pressed.connect(_on_found_city_pressed)

	var style_found = StyleBoxFlat.new()
	style_found.bg_color = Color(0.6, 0.4, 0.1)
	style_found.corner_radius_top_left = 3
	style_found.corner_radius_top_right = 3
	style_found.corner_radius_bottom_left = 3
	style_found.corner_radius_bottom_right = 3
	found_city_button.add_theme_stylebox_override("normal", style_found)

	var style_found_hover = StyleBoxFlat.new()
	style_found_hover.bg_color = Color(0.7, 0.5, 0.2)
	style_found_hover.corner_radius_top_left = 3
	style_found_hover.corner_radius_top_right = 3
	style_found_hover.corner_radius_bottom_left = 3
	style_found_hover.corner_radius_bottom_right = 3
	found_city_button.add_theme_stylebox_override("hover", style_found_hover)

	unit_info_panel.add_child(found_city_button)

	# City info panel (bottom-right)
	city_info_panel = Panel.new()
	city_info_panel.position = Vector2(970, 530)
	city_info_panel.size = Vector2(200, 170)
	city_info_panel.visible = false

	var style_city_panel = StyleBoxFlat.new()
	style_city_panel.bg_color = Color(0.15, 0.1, 0.05, 0.9)
	style_city_panel.corner_radius_top_left = 5
	style_city_panel.corner_radius_top_right = 5
	style_city_panel.corner_radius_bottom_left = 5
	style_city_panel.corner_radius_bottom_right = 5
	style_city_panel.border_width_left = 2
	style_city_panel.border_width_right = 2
	style_city_panel.border_width_top = 2
	style_city_panel.border_width_bottom = 2
	style_city_panel.border_color = Color(0.6, 0.4, 0.2)
	city_info_panel.add_theme_stylebox_override("panel", style_city_panel)

	add_child(city_info_panel)

	# City info label
	city_info_label = Label.new()
	city_info_label.position = Vector2(10, 10)
	city_info_label.size = Vector2(180, 150)
	city_info_label.add_theme_font_size_override("font_size", 13)
	city_info_label.add_theme_color_override("font_color", Color.WHITE)
	city_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	city_info_panel.add_child(city_info_label)

func initialize(turn_mgr: TurnManager, unit_mgr: UnitManager, city_mgr = null):
	"""Initialize with references to managers"""
	turn_manager = turn_mgr
	unit_manager = unit_mgr
	city_manager = city_mgr

	# Connect signals
	if turn_manager:
		turn_manager.turn_started.connect(_on_turn_started)
		turn_manager.resources_updated.connect(_on_resources_updated)

	if unit_manager:
		unit_manager.unit_selected.connect(_on_unit_selected)

	if city_manager:
		city_manager.city_selected.connect(_on_city_selected)

func _on_turn_started(turn_number: int):
	"""Update UI when turn starts"""
	turn_label.text = "Turn: " + str(turn_number)

func _on_resources_updated(food: int, production: int, gold: int):
	"""Update total resources display (Food, Production, Gold)"""
	resources_label.text = "Food: %d  Production: %d  Gold: %d" % [food, production, gold]

func _on_unit_selected(unit: Unit):
	"""Show unit info when selected"""
	unit_info_panel.visible = true
	var info_text = unit.get_info_text()
	if unit.can_found_city():
		info_text += "\n\n[Press F to Found City]"
	unit_info_label.text = info_text

	# Show found city button only for settlers
	found_city_button.visible = unit.can_found_city()

	# Hide city info when selecting a unit
	city_info_panel.visible = false

func _on_end_turn_pressed():
	"""Handle end turn button press"""
	if turn_manager and turn_manager.can_end_turn():
		# Hide unit info panel
		unit_info_panel.visible = false
		
		# End the turn
		turn_manager.end_turn()

func hide_unit_info():
	"""Hide the unit info panel"""
	unit_info_panel.visible = false
	found_city_button.visible = false

func _on_city_selected(city):
	"""Show city info when selected"""
	city_info_panel.visible = true
	city_info_label.text = city.get_info_text()

	# Hide unit info when selecting a city
	unit_info_panel.visible = false
	found_city_button.visible = false

func hide_city_info():
	"""Hide the city info panel"""
	city_info_panel.visible = false

func _on_found_city_pressed():
	"""Handle found city button press"""
	if unit_manager and unit_manager.selected_unit:
		var unit = unit_manager.selected_unit
		if unit.can_found_city():
			unit.found_city()

func show_message(message: String, duration: float = 2.0):
	"""Show a temporary message to the player"""
	var message_label = Label.new()
	message_label.text = message
	message_label.position = Vector2(400, 300)
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.add_theme_color_override("font_color", Color.YELLOW)
	message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	message_label.add_theme_constant_override("outline_size", 3)
	add_child(message_label)
	
	# Fade out and remove
	await get_tree().create_timer(duration).timeout
	message_label.queue_free()
