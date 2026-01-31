extends Control
class_name CityBuildingsDisplay

# Isometric tile dimensions (2:1 ratio)
const HALF_W: float = 40.0
const HALF_H: float = 20.0

# Building slot layout: [building_type] => {gx, gy}
# Back row (gy=0): Monument, Granary, Barracks
# Front row (gy=1): Market, Library
const SLOT_GRID: Dictionary = {
	Building.BuildingType.MONUMENT: Vector2i(0, 0),
	Building.BuildingType.GRANARY: Vector2i(1, 0),
	Building.BuildingType.BARRACKS: Vector2i(2, 0),
	Building.BuildingType.MARKET: Vector2i(0, 1),
	Building.BuildingType.LIBRARY: Vector2i(1, 1),
}

# Draw order: back row first (gy=0), then front row (gy=1), left to right
const DRAW_ORDER: Array[int] = [
	Building.BuildingType.MONUMENT,
	Building.BuildingType.GRANARY,
	Building.BuildingType.BARRACKS,
	Building.BuildingType.MARKET,
	Building.BuildingType.LIBRARY,
]

# Building visuals: color and max height per type
const BUILDING_COLORS: Dictionary = {
	Building.BuildingType.MONUMENT: Color(0.6, 0.3, 0.7),
	Building.BuildingType.GRANARY: Color(0.3, 0.65, 0.2),
	Building.BuildingType.BARRACKS: Color(0.75, 0.2, 0.2),
	Building.BuildingType.MARKET: Color(0.85, 0.7, 0.15),
	Building.BuildingType.LIBRARY: Color(0.2, 0.4, 0.8),
}

const BUILDING_HEIGHTS: Dictionary = {
	Building.BuildingType.MONUMENT: 35.0,
	Building.BuildingType.GRANARY: 25.0,
	Building.BuildingType.BARRACKS: 30.0,
	Building.BuildingType.MARKET: 25.0,
	Building.BuildingType.LIBRARY: 28.0,
}

# State
var _completed: Array[int] = []
var _current_heights: Dictionary = {}  # building_type => current draw height
var _animating_type: int = -1


func _ready():
	# Initialize all heights to 0
	for btype in SLOT_GRID.keys():
		_current_heights[btype] = 0.0


func set_buildings(completed: Array[int], animate_type: int = -1):
	_completed = completed.duplicate()
	_animating_type = animate_type

	# Set all completed buildings to full height instantly
	for btype in SLOT_GRID.keys():
		if btype in _completed and btype != animate_type:
			_current_heights[btype] = BUILDING_HEIGHTS[btype]
		elif btype not in _completed:
			_current_heights[btype] = 0.0

	# If we need to animate one building rising
	if animate_type >= 0 and animate_type in _completed:
		_current_heights[animate_type] = 0.0
		_animate_building_rise(animate_type)
	else:
		queue_redraw()


func _animate_building_rise(building_type: int):
	var target_h = BUILDING_HEIGHTS[building_type]
	var tween = create_tween()
	tween.tween_method(_set_building_height.bind(building_type), 0.0, target_h, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _set_building_height(h: float, building_type: int):
	_current_heights[building_type] = h
	queue_redraw()


func _grid_to_screen(gx: int, gy: int) -> Vector2:
	var center_x = size.x / 2.0
	var center_y = size.y / 2.0 - 20.0  # shift up a bit to leave room for labels
	var sx = center_x + (gx - gy) * HALF_W
	var sy = center_y + (gx + gy) * HALF_H
	return Vector2(sx, sy)


func _draw():
	# Draw all slots in draw order (back to front)
	for btype in DRAW_ORDER:
		var grid_pos = SLOT_GRID[btype]
		var screen_pos = _grid_to_screen(grid_pos.x, grid_pos.y)
		var cx = screen_pos.x
		var cy = screen_pos.y

		if btype in _completed:
			var bh = _current_heights.get(btype, 0.0)
			if bh > 0.1:
				_draw_building_block(cx, cy, bh, BUILDING_COLORS[btype])
			else:
				_draw_ground_tile(cx, cy)
		else:
			_draw_ground_tile(cx, cy)

		_draw_building_label(cx, cy, btype)


func _draw_ground_tile(cx: float, cy: float):
	# Flat isometric diamond (brown ground)
	var ground_color = Color(0.45, 0.32, 0.18)
	var outline_color = Color(0.0, 0.0, 0.0, 0.4)

	var top = Vector2(cx, cy - HALF_H)
	var right = Vector2(cx + HALF_W, cy)
	var bottom = Vector2(cx, cy + HALF_H)
	var left = Vector2(cx - HALF_W, cy)

	var points = PackedVector2Array([top, right, bottom, left])
	draw_colored_polygon(points, ground_color)
	# Outline
	draw_polyline(PackedVector2Array([top, right, bottom, left, top]), outline_color, 1.0)


func _draw_building_block(cx: float, cy: float, bh: float, base_color: Color):
	var outline_color = Color(0.0, 0.0, 0.0, 0.5)

	# Top face color (lightened 25%)
	var top_color = base_color.lightened(0.25)
	# Left wall = base color
	var left_color = base_color
	# Right wall (darkened 30%)
	var right_color = base_color.darkened(0.30)

	# Ground-level corners of the diamond
	var g_top = Vector2(cx, cy - HALF_H)
	var g_right = Vector2(cx + HALF_W, cy)
	var g_bottom = Vector2(cx, cy + HALF_H)
	var g_left = Vector2(cx - HALF_W, cy)

	# Top face corners (shifted up by building height)
	var t_top = Vector2(cx, cy - HALF_H - bh)
	var t_right = Vector2(cx + HALF_W, cy - bh)
	var t_bottom = Vector2(cx, cy + HALF_H - bh)
	var t_left = Vector2(cx - HALF_W, cy - bh)

	# Draw left wall (west/south face): t_left -> t_bottom -> g_bottom -> g_left
	var left_wall = PackedVector2Array([t_left, t_bottom, g_bottom, g_left])
	draw_colored_polygon(left_wall, left_color)
	draw_polyline(PackedVector2Array([t_left, t_bottom, g_bottom, g_left, t_left]), outline_color, 1.0)

	# Draw right wall (south/east face): t_bottom -> t_right -> g_right -> g_bottom
	var right_wall = PackedVector2Array([t_bottom, t_right, g_right, g_bottom])
	draw_colored_polygon(right_wall, right_color)
	draw_polyline(PackedVector2Array([t_bottom, t_right, g_right, g_bottom, t_bottom]), outline_color, 1.0)

	# Draw top face: t_top -> t_right -> t_bottom -> t_left
	var top_face = PackedVector2Array([t_top, t_right, t_bottom, t_left])
	draw_colored_polygon(top_face, top_color)
	draw_polyline(PackedVector2Array([t_top, t_right, t_bottom, t_left, t_top]), outline_color, 1.0)


func _draw_building_label(cx: float, cy: float, building_type: int):
	var bname = Building.get_building_name(building_type)
	var font = ThemeDB.fallback_font
	var font_size = 10
	var text_width = font.get_string_size(bname, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	var label_pos = Vector2(cx - text_width / 2.0, cy + HALF_H + 14)
	draw_string(font, label_pos, bname, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.8, 0.8, 0.8, 0.8))
