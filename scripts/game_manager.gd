extends Node

const SAVE_PATH = "user://savegame.tres"

var current_planet: int = 0
var resources: Dictionary = {
	"iron": 100,
	"silicon": 50,
	"energy": 200,
	"oxygen": 100,
	"water": 80,
	"titanium": 20,
	"crystal": 0
}

var upgrades: Dictionary = {
	"suit_oxygen": 1,
	"suit_speed": 1,
	"suit_jump": 1,
	"base_power": 1,
	"base_storage": 1,
	"auto_miner": 0,
	"auto_fabricator": 0,
	"auto_solar": 0,
	"ship_fuel": 1,
	"scanner": 1
}

var upgrade_costs: Dictionary = {
	"suit_oxygen": {"oxygen": 50, "silicon": 30},
	"suit_speed": {"iron": 40, "energy": 60},
	"suit_jump": {"titanium": 20, "energy": 50},
	"base_power": {"silicon": 80, "iron": 60},
	"base_storage": {"iron": 100, "titanium": 30},
	"auto_miner": {"iron": 150, "titanium": 50, "silicon": 80},
	"auto_fabricator": {"titanium": 100, "crystal": 20, "silicon": 120},
	"auto_solar": {"silicon": 200, "crystal": 50},
	"ship_fuel": {"iron": 80, "energy": 100},
	"scanner": {"silicon": 60, "crystal": 30}
}

var placed_objects: Array = []
var planets_visited: Array = [true, false, false, false]
var play_time: float = 0.0
var settings: Dictionary = {
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"graphics_quality": 1,
	"invert_y": false,
	"sensitivity": 0.3
}

signal resources_changed
signal upgrades_changed
signal planet_changed(planet_id)

func _ready():
	load_game()

func _process(delta):
	play_time += delta
	_tick_automation(delta)

func _tick_automation(delta: float):
	if upgrades["auto_miner"] > 0:
		var mine_rate = upgrades["auto_miner"] * 0.5 * delta
		resources["iron"] += mine_rate
		resources["silicon"] += mine_rate * 0.6
		resources_changed.emit()
	if upgrades["auto_solar"] > 0:
		var energy_rate = upgrades["auto_solar"] * 2.0 * delta
		resources["energy"] = min(resources["energy"] + energy_rate, 500 + upgrades["base_storage"] * 200)
		resources_changed.emit()

func add_resource(type: String, amount: float):
	if resources.has(type):
		resources[type] = resources.get(type, 0.0) + amount
		resources_changed.emit()

func spend_resources(cost: Dictionary) -> bool:
	for res in cost:
		if resources.get(res, 0) < cost[res]:
			return false
	for res in cost:
		resources[res] -= cost[res]
	resources_changed.emit()
	return true

func can_afford(cost: Dictionary) -> bool:
	for res in cost:
		if resources.get(res, 0) < cost[res]:
			return false
	return true

func upgrade(upgrade_name: String) -> bool:
	if not upgrade_costs.has(upgrade_name):
		return false
	var base_cost = upgrade_costs[upgrade_name]
	var level = upgrades.get(upgrade_name, 0)
	var actual_cost = {}
	for res in base_cost:
		actual_cost[res] = int(base_cost[res] * pow(1.5, level))
	if spend_resources(actual_cost):
		upgrades[upgrade_name] += 1
		upgrades_changed.emit()
		save_game()
		return true
	return false

func travel_to_planet(planet_id: int):
	current_planet = planet_id
	planets_visited[planet_id] = true
	planet_changed.emit(planet_id)
	save_game()

func save_game():
	var save_data = ResourceSaver
	var data = {
		"resources": resources.duplicate(),
		"upgrades": upgrades.duplicate(),
		"placed_objects": placed_objects.duplicate(true),
		"planets_visited": planets_visited.duplicate(),
		"current_planet": current_planet,
		"play_time": play_time,
		"settings": settings.duplicate()
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if data:
			if data.has("resources"): resources = data["resources"]
			if data.has("upgrades"): upgrades = data["upgrades"]
			if data.has("placed_objects"): placed_objects = data["placed_objects"]
			if data.has("planets_visited"): planets_visited = data["planets_visited"]
			if data.has("current_planet"): current_planet = data["current_planet"]
			if data.has("play_time"): play_time = data["play_time"]
			if data.has("settings"): settings = data["settings"]

func reset_game():
	resources = {"iron": 100, "silicon": 50, "energy": 200, "oxygen": 100, "water": 80, "titanium": 20, "crystal": 0}
	upgrades = {"suit_oxygen": 1, "suit_speed": 1, "suit_jump": 1, "base_power": 1, "base_storage": 1, "auto_miner": 0, "auto_fabricator": 0, "auto_solar": 0, "ship_fuel": 1, "scanner": 1}
	placed_objects = []
	planets_visited = [true, false, false, false]
	current_planet = 0
	play_time = 0.0
	save_game()
