extends RefCounted
class_name Building

## Building data class - name, cost, effects (food_bonus, gold_bonus, culture_bonus, science_bonus, military_bonus)
## Buildings are unique per city (can't build same building twice)

# Building type IDs
enum BuildingType {
	MONUMENT,
	GRANARY,
	BARRACKS,
	MARKET,
	LIBRARY
}

# Building definitions: { type => { name, cost, food, gold, culture, science, military_bonus } }
const BUILDING_DATA: Dictionary = {
	BuildingType.MONUMENT: {
		"name": "Monument",
		"cost": 60,
		"food_bonus": 0,
		"gold_bonus": 0,
		"culture_bonus": 1,
		"science_bonus": 0,
		"military_training_bonus": 0.0
	},
	BuildingType.GRANARY: {
		"name": "Granary",
		"cost": 80,
		"food_bonus": 2,
		"gold_bonus": 0,
		"culture_bonus": 0,
		"science_bonus": 0,
		"military_training_bonus": 0.0
	},
	BuildingType.BARRACKS: {
		"name": "Barracks",
		"cost": 100,
		"food_bonus": 0,
		"gold_bonus": 0,
		"culture_bonus": 0,
		"science_bonus": 0,
		"military_training_bonus": 0.5  # 50% faster military unit training
	},
	BuildingType.MARKET: {
		"name": "Market",
		"cost": 120,
		"food_bonus": 0,
		"gold_bonus": 3,
		"culture_bonus": 0,
		"science_bonus": 0,
		"military_training_bonus": 0.0
	},
	BuildingType.LIBRARY: {
		"name": "Library",
		"cost": 100,
		"food_bonus": 0,
		"gold_bonus": 0,
		"culture_bonus": 0,
		"science_bonus": 2,
		"military_training_bonus": 0.0
	}
}

static func get_building_name(building_type: BuildingType) -> String:
	return BUILDING_DATA[building_type].name

static func get_cost(building_type: BuildingType) -> int:
	return BUILDING_DATA[building_type].cost

static func get_food_bonus(building_type: BuildingType) -> int:
	return BUILDING_DATA[building_type].food_bonus

static func get_gold_bonus(building_type: BuildingType) -> int:
	return BUILDING_DATA[building_type].gold_bonus

static func get_culture_bonus(building_type: BuildingType) -> int:
	return BUILDING_DATA[building_type].culture_bonus

static func get_science_bonus(building_type: BuildingType) -> int:
	return BUILDING_DATA[building_type].science_bonus

static func get_military_training_bonus(building_type: BuildingType) -> float:
	return BUILDING_DATA[building_type].military_training_bonus

static func get_all_types() -> Array[BuildingType]:
	return [
		BuildingType.MONUMENT,
		BuildingType.GRANARY,
		BuildingType.BARRACKS,
		BuildingType.MARKET,
		BuildingType.LIBRARY
	]
