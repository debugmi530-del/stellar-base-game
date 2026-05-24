extends Node3D

const PLANETS = {
	0: {
		"name": "Марс-Альфа",
		"sky_color": Color(0.6, 0.3, 0.15),
		"ground_color": Color(0.55, 0.25, 0.1),
		"gravity": 3.7,
		"resources": ["iron", "silicon", "water"],
		"ambient_light": Color(0.8, 0.5, 0.3),
		"fog_density": 0.02,
		"description": "Красная пустыня. Богата железом и кремнием."
	},
	1: {
		"name": "Ледяной Европа-7",
		"sky_color": Color(0.5, 0.7, 0.9),
		"ground_color": Color(0.8, 0.9, 1.0),
		"gravity": 1.3,
		"resources": ["water", "silicon", "crystal"],
		"ambient_light": Color(0.6, 0.7, 0.9),
		"fog_density": 0.04,
		"description": "Ледяной мир. Источник кристаллов и воды."
	},
	2: {
		"name": "Вулканический Ио-X",
		"sky_color": Color(0.7, 0.3, 0.0),
		"ground_color": Color(0.3, 0.15, 0.0),
		"gravity": 1.8,
		"resources": ["iron", "titanium", "crystal"],
		"ambient_light": Color(0.9, 0.4, 0.1),
		"fog_density": 0.06,
		"description": "Вулканический ад. Богат титаном и кристаллами."
	},
	3: {
		"name": "Газовый Нептун-Омега",
		"sky_color": Color(0.2, 0.3, 0.7),
		"ground_color": Color(0.3, 0.4, 0.6),
		"gravity": 11.0,
		"resources": ["silicon", "energy", "crystal"],
		"ambient_light": Color(0.3, 0.4, 0.8),
		"fog_density": 0.08,
		"description": "Высокая гравитация. Источник энергии и кристаллов."
	}
}

@onready var sky: WorldEnvironment = $WorldEnvironment
@onready var directional_light: DirectionalLight3D = $Sun
@onready var terrain: Node3D = $Terrain
@onready var resource_spawner: Node3D = $ResourceSpawner

var current_planet_id: int = 0

func _ready():
	GameManager.planet_changed.connect(_on_planet_changed)
	setup_planet(GameManager.current_planet)

func setup_planet(planet_id: int):
	current_planet_id = planet_id
	var data = PLANETS[planet_id]
	_setup_sky(data)
	_setup_lighting(data)
	_spawn_resources(data)

func _setup_sky(data: Dictionary):
	if sky and sky.environment:
		sky.environment.background_color = data["sky_color"]
		sky.environment.ambient_light_color = data["ambient_light"]
		sky.environment.fog_density = data["fog_density"]
		sky.environment.fog_enabled = true

func _setup_lighting(data: Dictionary):
	if directional_light:
		directional_light.light_color = data["ambient_light"]

func _spawn_resources(data: Dictionary):
	for child in resource_spawner.get_children():
		child.queue_free()
	var rng = RandomNumberGenerator.new()
	rng.seed = current_planet_id * 12345
	for i in range(20):
		var res_type = data["resources"][rng.randi() % data["resources"].size()]
		var node = preload("res://scenes/resource_node.tscn").instantiate()
		node.resource_type = res_type
		node.global_position = Vector3(
			rng.randf_range(-80, 80),
			0,
			rng.randf_range(-80, 80)
		)
		resource_spawner.add_child(node)

func _on_planet_changed(planet_id: int):
	setup_planet(planet_id)

func get_planet_name() -> String:
	return PLANETS[current_planet_id]["name"]
