extends Node

const BUILDABLES = {
	"wall": {
		"name": "Стена",
		"cost": {"iron": 10},
		"scene": "res://scenes/buildings/wall.tscn",
		"category": "structure"
	},
	"floor": {
		"name": "Пол",
		"cost": {"iron": 5},
		"scene": "res://scenes/buildings/floor.tscn",
		"category": "structure"
	},
	"door": {
		"name": "Дверь (шлюз)",
		"cost": {"iron": 20, "silicon": 10},
		"scene": "res://scenes/buildings/door.tscn",
		"category": "structure"
	},
	"solar_panel": {
		"name": "Солнечная панель",
		"cost": {"silicon": 30, "iron": 15},
		"scene": "res://scenes/buildings/solar_panel.tscn",
		"category": "power"
	},
	"oxygen_gen": {
		"name": "Генератор кислорода",
		"cost": {"iron": 40, "silicon": 20, "energy": 50},
		"scene": "res://scenes/buildings/oxygen_gen.tscn",
		"category": "life_support"
	},
	"storage_box": {
		"name": "Контейнер",
		"cost": {"iron": 25},
		"scene": "res://scenes/buildings/storage_box.tscn",
		"category": "storage"
	},
	"workbench": {
		"name": "Верстак",
		"cost": {"iron": 50, "silicon": 30},
		"scene": "res://scenes/buildings/workbench.tscn",
		"category": "crafting"
	},
	"auto_miner": {
		"name": "Авто-шахтёр",
		"cost": {"iron": 80, "titanium": 30, "silicon": 40},
		"scene": "res://scenes/buildings/auto_miner.tscn",
		"category": "automation"
	},
	"fabricator": {
		"name": "Фабрикатор",
		"cost": {"titanium": 60, "silicon": 80, "crystal": 10},
		"scene": "res://scenes/buildings/fabricator.tscn",
		"category": "automation"
	},
	"landing_pad": {
		"name": "Посадочная площадка",
		"cost": {"iron": 100, "titanium": 40},
		"scene": "res://scenes/buildings/landing_pad.tscn",
		"category": "travel"
	},
	"greenhouse": {
		"name": "Оранжерея",
		"cost": {"silicon": 60, "iron": 40, "water": 30},
		"scene": "res://scenes/buildings/greenhouse.tscn",
		"category": "life_support"
	},
	"antenna": {
		"name": "Антенна",
		"cost": {"iron": 30, "silicon": 50, "crystal": 5},
		"scene": "res://scenes/buildings/antenna.tscn",
		"category": "tech"
	}
}

var preview_object: Node3D = null
var selected_item: String = ""
var build_active: bool = false
var grid_snap: float = 1.0

signal building_placed(type, position)
signal building_removed(position)

func start_build(item_type: String, parent: Node3D):
	if not BUILDABLES.has(item_type):
		return
	selected_item = item_type
	build_active = true
	if preview_object:
		preview_object.queue_free()
	var scene = load(BUILDABLES[item_type]["scene"])
	if scene:
		preview_object = scene.instantiate()
		parent.add_child(preview_object)
		_set_preview_material(preview_object)

func _set_preview_material(node: Node3D):
	for child in node.get_children():
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.2, 0.8, 0.2, 0.5)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			child.material_override = mat
		_set_preview_material(child)

func update_preview(hit_position: Vector3, hit_normal: Vector3):
	if not preview_object or not build_active:
		return
	var snapped = Vector3(
		snapped(hit_position.x, grid_snap),
		hit_position.y,
		snapped(hit_position.z, grid_snap)
	)
	preview_object.global_position = snapped
	var can_afford = GameManager.can_afford(BUILDABLES[selected_item]["cost"])
	_set_preview_valid(preview_object, can_afford)

func _set_preview_valid(node: Node3D, valid: bool):
	for child in node.get_children():
		if child is MeshInstance3D and child.material_override:
			child.material_override.albedo_color = Color(0.2, 0.8, 0.2, 0.5) if valid else Color(0.8, 0.2, 0.2, 0.5)
		_set_preview_valid(child, valid)

func place_building(hit_position: Vector3) -> bool:
	if not build_active or selected_item == "":
		return false
	var cost = BUILDABLES[selected_item]["cost"]
	if not GameManager.spend_resources(cost):
		return false
	var snapped = Vector3(
		snapped(hit_position.x, grid_snap),
		hit_position.y,
		snapped(hit_position.z, grid_snap)
	)
	var scene = load(BUILDABLES[selected_item]["scene"])
	if scene:
		var building = scene.instantiate()
		get_tree().current_scene.add_child(building)
		building.global_position = snapped
		GameManager.placed_objects.append({
			"type": selected_item,
			"position": {"x": snapped.x, "y": snapped.y, "z": snapped.z}
		})
		GameManager.save_game()
		building_placed.emit(selected_item, snapped)
		return true
	return false

func cancel_build():
	build_active = false
	selected_item = ""
	if preview_object:
		preview_object.queue_free()
		preview_object = null
