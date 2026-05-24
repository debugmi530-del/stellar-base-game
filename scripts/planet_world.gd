extends Node3D

const PLANETS = {
	0: {
		"name":         "Марс-Альфа",
		"sky_color":    Color(0.6, 0.3, 0.15),
		"ground_color": Color(0.55, 0.25, 0.1),
		"gravity":      3.7,
		"resources":    ["iron","silicon","water"],
		"ambient_light":Color(0.8, 0.5, 0.3),
		"fog_density":  0.015,
		"albedo":       "res://assets/textures/planets/mars_albedo.png",
		"normal":       "res://assets/textures/planets/mars_normal.png",
		"skybox":       "res://assets/textures/skybox/mars_sky.png",
		"description":  "Красная пустыня. Богата железом и кремнием."
	},
	1: {
		"name":         "Ледяной Европа-7",
		"sky_color":    Color(0.5, 0.7, 0.9),
		"ground_color": Color(0.8, 0.9, 1.0),
		"gravity":      1.3,
		"resources":    ["water","silicon","crystal"],
		"ambient_light":Color(0.6, 0.7, 0.9),
		"fog_density":  0.03,
		"albedo":       "res://assets/textures/planets/europa_albedo.png",
		"normal":       "res://assets/textures/planets/europa_normal.png",
		"skybox":       "res://assets/textures/skybox/europa_sky.png",
		"description":  "Ледяной мир. Источник кристаллов и воды."
	},
	2: {
		"name":         "Вулканический Ио-X",
		"sky_color":    Color(0.7, 0.3, 0.0),
		"ground_color": Color(0.3, 0.15, 0.0),
		"gravity":      1.8,
		"resources":    ["iron","titanium","crystal"],
		"ambient_light":Color(0.9, 0.4, 0.1),
		"fog_density":  0.05,
		"albedo":       "res://assets/textures/planets/io_albedo.png",
		"normal":       "res://assets/textures/planets/io_normal.png",
		"skybox":       "res://assets/textures/skybox/io_sky.png",
		"description":  "Вулканический ад. Богат титаном и кристаллами."
	},
	3: {
		"name":         "Газовый Нептун-Омега",
		"sky_color":    Color(0.2, 0.3, 0.7),
		"ground_color": Color(0.3, 0.4, 0.6),
		"gravity":      11.0,
		"resources":    ["silicon","energy","crystal"],
		"ambient_light":Color(0.3, 0.4, 0.8),
		"fog_density":  0.07,
		"albedo":       "res://assets/textures/planets/neptune_albedo.png",
		"normal":       "res://assets/textures/planets/neptune_normal.png",
		"skybox":       "res://assets/textures/skybox/neptune_sky.png",
		"description":  "Высокая гравитация. Источник энергии и кристаллов."
	}
}

@onready var sky:               WorldEnvironment   = $WorldEnvironment
@onready var directional_light: DirectionalLight3D = $Sun
@onready var terrain:           Node3D             = $Terrain
@onready var resource_spawner:  Node3D             = $ResourceSpawner
@onready var building_root:     Node3D             = $BuildingRoot

var current_planet_id: int = 0
var _terrain_material: StandardMaterial3D = null

func _ready():
	GameManager.planet_changed.connect(_on_planet_changed)
	setup_planet(GameManager.current_planet)
	# BUGFIX: восстанавливаем постройки из сохранения после загрузки сцены
	call_deferred("_restore_saved_buildings")

func setup_planet(planet_id: int):
	current_planet_id = planet_id
	var data = PLANETS[planet_id]
	_setup_sky(data)
	_setup_lighting(data)
	_setup_terrain(data)
	_spawn_resources(data)

# ---------- Восстановление построек ----------
func _restore_saved_buildings():
	if not building_root:
		return
	# Очищаем старые
	for child in building_root.get_children():
		child.queue_free()

	for obj in GameManager.placed_objects:
		var type_key = obj.get("type", "")
		if not BuildSystem.BUILDABLES.has(type_key):
			continue
		var scene_path = BuildSystem.BUILDABLES[type_key]["scene"]
		if not ResourceLoader.exists(scene_path):
			continue
		var scene = load(scene_path)
		if not scene:
			continue
		var building = scene.instantiate()
		var pos_data = obj.get("position", {"x": 0, "y": 0, "z": 0})
		building.global_position = Vector3(
			pos_data.get("x", 0.0),
			pos_data.get("y", 0.0),
			pos_data.get("z", 0.0)
		)
		building_root.add_child(building)

# ---------- Sky ----------
func _setup_sky(data: Dictionary):
	if not (sky and sky.environment):
		return
	var env = sky.environment
	env.background_color    = data["sky_color"]
	env.ambient_light_color = data["ambient_light"]
	env.fog_density         = data["fog_density"]
	env.fog_enabled         = true
	env.background_mode     = Environment.BG_COLOR

# ---------- Lighting ----------
func _setup_lighting(data: Dictionary):
	if directional_light:
		directional_light.light_color = data["ambient_light"]
		var preset = PerformanceManager.get_preset()
		directional_light.shadow_enabled = preset.get("shadow_enabled", false)

# ---------- Terrain ----------
func _setup_terrain(data: Dictionary):
	var albedo_path = data.get("albedo", "")
	if albedo_path != "" and ResourceLoader.exists(albedo_path):
		if not _terrain_material:
			_terrain_material = StandardMaterial3D.new()
		_terrain_material.albedo_texture = load(albedo_path)
		var normal_path = data.get("normal", "")
		if normal_path != "" and ResourceLoader.exists(normal_path):
			_terrain_material.normal_enabled = true
			_terrain_material.normal_texture  = load(normal_path)
		_apply_material_to_terrain(_terrain_material)
	else:
		if not _terrain_material:
			_terrain_material = StandardMaterial3D.new()
		_terrain_material.albedo_color = data["ground_color"]
		_apply_material_to_terrain(_terrain_material)

func _apply_material_to_terrain(mat: StandardMaterial3D):
	for child in terrain.get_children():
		if child is MeshInstance3D:
			child.material_override = mat

# ---------- Resources ----------
func _spawn_resources(data: Dictionary):
	for child in resource_spawner.get_children():
		child.queue_free()

	if not ResourceLoader.exists("res://scenes/resource_node.tscn"):
		return

	var rng = RandomNumberGenerator.new()
	rng.seed = current_planet_id * 12345

	var preset    = PerformanceManager.get_preset()
	var view_dist = preset.get("view_distance", 60.0)
	var count     = 20 if view_dist > 80.0 else 12

	var scene = preload("res://scenes/resource_node.tscn")
	for i in range(count):
		var res_type = data["resources"][rng.randi() % data["resources"].size()]
		var node = scene.instantiate()
		node.resource_type   = res_type
		node.global_position = Vector3(
			rng.randf_range(-view_dist * 0.8, view_dist * 0.8),
			0.0,
			rng.randf_range(-view_dist * 0.8, view_dist * 0.8)
		)
		resource_spawner.add_child(node)

func _on_planet_changed(planet_id: int):
	setup_planet(planet_id)

func get_planet_name() -> String:
	return PLANETS[current_planet_id]["name"]
