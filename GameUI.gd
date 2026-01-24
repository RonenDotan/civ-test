extends CanvasLayer
class_name GameUI

# UI Elements
var turn_label: Label
var unit_info_panel: Panel
var unit_info_label: Label
var end_turn_button: Button

# References
var turn_manager: TurnManager
var unit_manager: UnitManager

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

func initialize(turn_mgr: TurnManager, unit_mgr: UnitManager):
	"""Initialize with references to managers"""
	turn_manager = turn_mgr
	unit_manager = unit_mgr
	
	# Connect signals
	if turn_manager:
		turn_manager.turn_started.connect(_on_turn_started)
	
	if unit_manager:
		unit_manager.unit_selected.connect(_on_unit_selected)

func _on_turn_started(turn_number: int):
	"""Update UI when turn starts"""
	turn_label.text = "Turn: " + str(turn_number)

func _on_unit_selected(unit: Unit):
	"""Show unit info when selected"""
	unit_info_panel.visible = true
	unit_info_label.text = unit.get_info_text()

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
