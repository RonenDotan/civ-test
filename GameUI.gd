extends CanvasLayer
class_name GameUI

# UI Elements
var turn_label: Label
var resources_label: Label
var unit_info_panel: Panel
var unit_info_label: Label
var end_turn_button: Button
var found_city_button: Button

# City view (full-screen overlay)
var city_view_panel: Panel
var city_view_title: Label
var city_view_close_btn: Button
var city_view_stats_label: Label
var city_view_hp_bar: ProgressBar
var city_view_production_label: Label
var city_view_production_bar: ProgressBar
var city_view_turns_label: Label
var city_view_completed_container: VBoxContainer
var city_view_available_container: VBoxContainer
var city_buildings_display: CityBuildingsDisplay

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

	# Total resources display (Food, Production, Gold, Science, Culture) - top-left
	resources_label = Label.new()
	resources_label.text = "Food: 0  Prod: 0  Gold: 0  Science: 0  Culture: 0"
	resources_label.position = Vector2(10, 35)
	resources_label.add_theme_font_size_override("font_size", 14)
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

	# Full-screen city view
	_setup_city_view()

func _setup_city_view():
	"""Create the full-screen city view overlay"""
	var viewport_size = Vector2(1180, 720)

	# Main panel - full screen overlay
	city_view_panel = Panel.new()
	city_view_panel.position = Vector2(0, 0)
	city_view_panel.size = viewport_size
	city_view_panel.visible = false

	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.1, 0.08, 0.05, 0.95)
	style_bg.border_width_left = 0
	style_bg.border_width_right = 0
	style_bg.border_width_top = 0
	style_bg.border_width_bottom = 0
	city_view_panel.add_theme_stylebox_override("panel", style_bg)
	add_child(city_view_panel)

	# ---- HEADER ----
	var header = Panel.new()
	header.position = Vector2(0, 0)
	header.size = Vector2(viewport_size.x, 50)
	var style_header = StyleBoxFlat.new()
	style_header.bg_color = Color(0.15, 0.12, 0.07, 1.0)
	style_header.border_width_bottom = 2
	style_header.border_color = Color(0.6, 0.4, 0.2)
	header.add_theme_stylebox_override("panel", style_header)
	city_view_panel.add_child(header)

	# City name title
	city_view_title = Label.new()
	city_view_title.position = Vector2(20, 8)
	city_view_title.size = Vector2(600, 40)
	city_view_title.text = "City Name"
	city_view_title.add_theme_font_size_override("font_size", 26)
	city_view_title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	header.add_child(city_view_title)

	# Close button
	city_view_close_btn = Button.new()
	city_view_close_btn.text = "X"
	city_view_close_btn.position = Vector2(viewport_size.x - 60, 5)
	city_view_close_btn.size = Vector2(40, 40)
	city_view_close_btn.pressed.connect(_close_city_view)

	var style_close = StyleBoxFlat.new()
	style_close.bg_color = Color(0.5, 0.15, 0.1)
	style_close.corner_radius_top_left = 5
	style_close.corner_radius_top_right = 5
	style_close.corner_radius_bottom_left = 5
	style_close.corner_radius_bottom_right = 5
	city_view_close_btn.add_theme_stylebox_override("normal", style_close)

	var style_close_hover = StyleBoxFlat.new()
	style_close_hover.bg_color = Color(0.7, 0.2, 0.15)
	style_close_hover.corner_radius_top_left = 5
	style_close_hover.corner_radius_top_right = 5
	style_close_hover.corner_radius_bottom_left = 5
	style_close_hover.corner_radius_bottom_right = 5
	city_view_close_btn.add_theme_stylebox_override("hover", style_close_hover)

	header.add_child(city_view_close_btn)

	# ---- BODY (3 columns) ----
	var body_y = 60
	var body_h = viewport_size.y - body_y - 10
	var col_w = (viewport_size.x - 40) / 3.0  # 3 columns with padding
	var col_padding = 20

	# --- Column 1: CITY STATS ---
	var col1_x = col_padding
	var stats_header = Label.new()
	stats_header.position = Vector2(col1_x, body_y + 10)
	stats_header.size = Vector2(col_w - 20, 30)
	stats_header.text = "CITY STATS"
	stats_header.add_theme_font_size_override("font_size", 18)
	stats_header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	city_view_panel.add_child(stats_header)

	# HP bar
	var hp_label = Label.new()
	hp_label.position = Vector2(col1_x, body_y + 50)
	hp_label.text = "HP:"
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	city_view_panel.add_child(hp_label)

	city_view_hp_bar = ProgressBar.new()
	city_view_hp_bar.position = Vector2(col1_x + 40, body_y + 50)
	city_view_hp_bar.size = Vector2(col_w - 80, 20)
	city_view_hp_bar.max_value = 100
	city_view_hp_bar.value = 100
	city_view_hp_bar.show_percentage = true

	var style_hp_fill = StyleBoxFlat.new()
	style_hp_fill.bg_color = Color(0, 0.8, 0)
	city_view_hp_bar.add_theme_stylebox_override("fill", style_hp_fill)
	var style_hp_bg = StyleBoxFlat.new()
	style_hp_bg.bg_color = Color(0.3, 0.1, 0.1)
	city_view_hp_bar.add_theme_stylebox_override("background", style_hp_bg)
	city_view_panel.add_child(city_view_hp_bar)

	# Per-turn yields
	city_view_stats_label = Label.new()
	city_view_stats_label.position = Vector2(col1_x, body_y + 90)
	city_view_stats_label.size = Vector2(col_w - 20, body_h - 100)
	city_view_stats_label.text = "Per Turn:\n  Food:    +0\n  Prod:    +0\n  Gold:    +0\n  Science: +0\n  Culture: +0"
	city_view_stats_label.add_theme_font_size_override("font_size", 16)
	city_view_stats_label.add_theme_color_override("font_color", Color.WHITE)
	city_view_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	city_view_panel.add_child(city_view_stats_label)

	# --- Column 2: PRODUCTION ---
	var col2_x = col1_x + col_w + 10

	# Separator line
	var sep1 = ColorRect.new()
	sep1.position = Vector2(col2_x - 10, body_y + 5)
	sep1.size = Vector2(2, body_h - 10)
	sep1.color = Color(0.6, 0.4, 0.2, 0.5)
	city_view_panel.add_child(sep1)

	var prod_header = Label.new()
	prod_header.position = Vector2(col2_x, body_y + 10)
	prod_header.size = Vector2(col_w - 20, 30)
	prod_header.text = "PRODUCTION"
	prod_header.add_theme_font_size_override("font_size", 18)
	prod_header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	city_view_panel.add_child(prod_header)

	# Current production target
	city_view_production_label = Label.new()
	city_view_production_label.position = Vector2(col2_x, body_y + 50)
	city_view_production_label.size = Vector2(col_w - 20, 40)
	city_view_production_label.text = "Currently Building:\nNothing"
	city_view_production_label.add_theme_font_size_override("font_size", 14)
	city_view_production_label.add_theme_color_override("font_color", Color.WHITE)
	city_view_production_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	city_view_panel.add_child(city_view_production_label)

	# Production progress bar
	city_view_production_bar = ProgressBar.new()
	city_view_production_bar.position = Vector2(col2_x, body_y + 100)
	city_view_production_bar.size = Vector2(col_w - 20, 20)
	city_view_production_bar.max_value = 100
	city_view_production_bar.value = 0
	city_view_production_bar.show_percentage = false
	city_view_production_bar.visible = false

	var style_prod_fill = StyleBoxFlat.new()
	style_prod_fill.bg_color = Color(0.7, 0.5, 0.2)
	city_view_production_bar.add_theme_stylebox_override("fill", style_prod_fill)
	var style_prod_bg = StyleBoxFlat.new()
	style_prod_bg.bg_color = Color(0.2, 0.2, 0.2)
	city_view_production_bar.add_theme_stylebox_override("background", style_prod_bg)
	city_view_panel.add_child(city_view_production_bar)

	# Turns remaining label
	city_view_turns_label = Label.new()
	city_view_turns_label.position = Vector2(col2_x, body_y + 125)
	city_view_turns_label.size = Vector2(col_w - 20, 20)
	city_view_turns_label.text = ""
	city_view_turns_label.add_theme_font_size_override("font_size", 12)
	city_view_turns_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	city_view_panel.add_child(city_view_turns_label)

	# Isometric buildings display (below production info)
	city_buildings_display = CityBuildingsDisplay.new()
	city_buildings_display.position = Vector2(col2_x, body_y + 155)
	city_buildings_display.size = Vector2(col_w - 20, body_h - 165)
	city_view_panel.add_child(city_buildings_display)

	# --- Column 3: BUILDINGS ---
	var col3_x = col2_x + col_w + 10

	# Separator line
	var sep2 = ColorRect.new()
	sep2.position = Vector2(col3_x - 10, body_y + 5)
	sep2.size = Vector2(2, body_h - 10)
	sep2.color = Color(0.6, 0.4, 0.2, 0.5)
	city_view_panel.add_child(sep2)

	var buildings_header = Label.new()
	buildings_header.position = Vector2(col3_x, body_y + 10)
	buildings_header.size = Vector2(col_w - 20, 30)
	buildings_header.text = "BUILDINGS"
	buildings_header.add_theme_font_size_override("font_size", 18)
	buildings_header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	city_view_panel.add_child(buildings_header)

	# Completed buildings section
	var completed_header = Label.new()
	completed_header.position = Vector2(col3_x, body_y + 50)
	completed_header.size = Vector2(col_w - 20, 20)
	completed_header.text = "-- Completed --"
	completed_header.add_theme_font_size_override("font_size", 13)
	completed_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	city_view_panel.add_child(completed_header)

	city_view_completed_container = VBoxContainer.new()
	city_view_completed_container.position = Vector2(col3_x, body_y + 75)
	city_view_completed_container.size = Vector2(col_w - 20, 200)
	city_view_panel.add_child(city_view_completed_container)

	# Available buildings section
	var available_header = Label.new()
	available_header.position = Vector2(col3_x, body_y + 290)
	available_header.size = Vector2(col_w - 20, 20)
	available_header.text = "-- Available --"
	available_header.add_theme_font_size_override("font_size", 13)
	available_header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	city_view_panel.add_child(available_header)

	city_view_available_container = VBoxContainer.new()
	city_view_available_container.position = Vector2(col3_x, body_y + 315)
	city_view_available_container.size = Vector2(col_w - 20, 350)
	city_view_panel.add_child(city_view_available_container)

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
		city_manager.building_completed.connect(_on_building_completed)

func _on_turn_started(turn_number: int):
	"""Update UI when turn starts"""
	turn_label.text = "Turn: " + str(turn_number)

func _on_resources_updated(food: int, production: int, gold: int, science: int, culture: int):
	"""Update total resources display (Food, Production, Gold, Science, Culture)"""
	resources_label.text = "Food: %d  Prod: %d  Gold: %d  Science: %d  Culture: %d" % [food, production, gold, science, culture]

func _on_unit_selected(unit: Unit):
	"""Show unit info when selected"""
	unit_info_panel.visible = true
	var info_text = unit.get_info_text()
	if unit.can_found_city():
		info_text += "\n\n[Press F to Found City]"
	unit_info_label.text = info_text

	# Show found city button only for settlers
	found_city_button.visible = unit.can_found_city()

	# Close city view when selecting a unit
	if is_city_view_open():
		_close_city_view()

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

var _last_selected_city_for_production: City = null

func _on_city_selected(city):
	"""Show city info when selected - open full-screen city view"""
	_open_city_view(city)

	# Connect to production target changes (disconnect previous city to avoid duplicates)
	if _last_selected_city_for_production and _last_selected_city_for_production != city:
		if _last_selected_city_for_production.production_target_changed.is_connected(_on_city_production_changed):
			_last_selected_city_for_production.production_target_changed.disconnect(_on_city_production_changed)
	if city and not city.production_target_changed.is_connected(_on_city_production_changed):
		city.production_target_changed.connect(_on_city_production_changed)
	_last_selected_city_for_production = city

	# Hide unit info when selecting a city
	unit_info_panel.visible = false
	found_city_button.visible = false

func _open_city_view(city):
	"""Open the full-screen city view for the given city"""
	_refresh_city_view(city)
	city_buildings_display.set_buildings(city.completed_buildings, -1)
	city_view_panel.visible = true

func _close_city_view():
	"""Close the full-screen city view"""
	city_view_panel.visible = false
	if city_manager:
		city_manager.deselect_city()

func is_city_view_open() -> bool:
	"""Check if the city view is currently open"""
	return city_view_panel.visible

func _refresh_city_view(city):
	"""Refresh all data in the full-screen city view"""
	# Title
	city_view_title.text = city.city_name

	# HP bar
	city_view_hp_bar.max_value = city.max_health
	city_view_hp_bar.value = city.current_health

	# Per-turn yields
	var yields = city.get_total_yields()
	city_view_stats_label.text = "Per Turn:\n  Food:      +%d\n  Prod:      +%d\n  Gold:      +%d\n  Science:  +%d\n  Culture:  +%d" % [
		yields.food, yields.production, yields.gold, yields.science, yields.culture
	]

	# Production info
	if city.current_production_target >= 0:
		var bname = Building.get_building_name(city.current_production_target)
		var cost = Building.get_cost(city.current_production_target)
		city_view_production_label.text = "Currently Building:\n%s" % bname
		city_view_production_bar.max_value = cost
		city_view_production_bar.value = city.production_progress
		city_view_production_bar.visible = true
		var turns_left = city.get_turns_remaining()
		if turns_left > 0:
			city_view_turns_label.text = "%d/%d  ~%d turn%s left" % [city.production_progress, cost, turns_left, "s" if turns_left != 1 else ""]
		else:
			city_view_turns_label.text = "%d/%d" % [city.production_progress, cost]
	else:
		city_view_production_label.text = "Currently Building:\nNothing"
		city_view_production_bar.visible = false
		city_view_turns_label.text = ""

	# Completed buildings
	for child in city_view_completed_container.get_children():
		child.queue_free()
	if city.completed_buildings.is_empty():
		var none_label = Label.new()
		none_label.text = "(none)"
		none_label.add_theme_font_size_override("font_size", 13)
		none_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		city_view_completed_container.add_child(none_label)
	else:
		for type in city.completed_buildings:
			var blabel = Label.new()
			var bname = Building.get_building_name(type)
			var bonus_parts: Array[String] = []
			var fb = Building.get_food_bonus(type)
			var gb = Building.get_gold_bonus(type)
			var cb = Building.get_culture_bonus(type)
			var sb = Building.get_science_bonus(type)
			if fb > 0:
				bonus_parts.append("+%d Food" % fb)
			if gb > 0:
				bonus_parts.append("+%d Gold" % gb)
			if cb > 0:
				bonus_parts.append("+%d Culture" % cb)
			if sb > 0:
				bonus_parts.append("+%d Science" % sb)
			var bonus_text = ""
			if not bonus_parts.is_empty():
				bonus_text = " (" + ", ".join(bonus_parts) + ")"
			blabel.text = bname + bonus_text
			blabel.add_theme_font_size_override("font_size", 14)
			blabel.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
			city_view_completed_container.add_child(blabel)

	# Available buildings (buttons)
	for child in city_view_available_container.get_children():
		child.queue_free()
	var available = city.get_available_buildings()
	if available.is_empty():
		var none_label = Label.new()
		none_label.text = "(all built)"
		none_label.add_theme_font_size_override("font_size", 13)
		none_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		city_view_available_container.add_child(none_label)
	else:
		for building_type in available:
			var btn = Button.new()
			var bname = Building.get_building_name(building_type)
			var cost = Building.get_cost(building_type)
			var bonus_parts: Array[String] = []
			var fb = Building.get_food_bonus(building_type)
			var gb = Building.get_gold_bonus(building_type)
			var cb = Building.get_culture_bonus(building_type)
			var sb = Building.get_science_bonus(building_type)
			if fb > 0:
				bonus_parts.append("+%d Food" % fb)
			if gb > 0:
				bonus_parts.append("+%d Gold" % gb)
			if cb > 0:
				bonus_parts.append("+%d Culture" % cb)
			if sb > 0:
				bonus_parts.append("+%d Science" % sb)
			var bonus_text = ""
			if not bonus_parts.is_empty():
				bonus_text = " - " + ", ".join(bonus_parts)
			btn.text = "Build %s  [%d]%s" % [bname, cost, bonus_text]
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var style_btn = StyleBoxFlat.new()
			style_btn.bg_color = Color(0.25, 0.18, 0.08)
			style_btn.corner_radius_top_left = 3
			style_btn.corner_radius_top_right = 3
			style_btn.corner_radius_bottom_left = 3
			style_btn.corner_radius_bottom_right = 3
			style_btn.border_width_left = 1
			style_btn.border_width_right = 1
			style_btn.border_width_top = 1
			style_btn.border_width_bottom = 1
			style_btn.border_color = Color(0.6, 0.4, 0.2)
			btn.add_theme_stylebox_override("normal", style_btn)

			var style_btn_hover = StyleBoxFlat.new()
			style_btn_hover.bg_color = Color(0.35, 0.25, 0.12)
			style_btn_hover.corner_radius_top_left = 3
			style_btn_hover.corner_radius_top_right = 3
			style_btn_hover.corner_radius_bottom_left = 3
			style_btn_hover.corner_radius_bottom_right = 3
			style_btn_hover.border_width_left = 1
			style_btn_hover.border_width_right = 1
			style_btn_hover.border_width_top = 1
			style_btn_hover.border_width_bottom = 1
			style_btn_hover.border_color = Color(0.8, 0.6, 0.3)
			btn.add_theme_stylebox_override("hover", style_btn_hover)

			btn.pressed.connect(_on_build_button_pressed.bind(city, building_type))
			city_view_available_container.add_child(btn)

	# Sync isometric buildings display
	city_buildings_display.set_buildings(city.completed_buildings, -1)

func _on_city_production_changed(city):
	"""Refresh panel when city production target changes"""
	if city_manager and city_manager.selected_city == city and is_city_view_open():
		_refresh_city_view(city)

func _on_build_button_pressed(city, building_type: int):
	"""Click building button to set as production target"""
	if city.set_production_target(building_type):
		_refresh_city_view(city)

func _on_building_completed(city, building_type: int):
	"""Refresh city view when building completes (if that city is selected)"""
	if city_manager and city_manager.selected_city == city and is_city_view_open():
		_refresh_city_view(city)
		city_buildings_display.set_buildings(city.completed_buildings, building_type)

func hide_city_info():
	"""Hide the city view"""
	if is_city_view_open():
		_close_city_view()

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
