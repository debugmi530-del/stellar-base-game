extends Node

# Quality levels:
# 0 = LOW   — Helio G80/G85, Snapdragon 662, 4GB RAM (целевое)
# 1 = MEDIUM — Helio G99, Snapdragon 695, 6GB RAM
# 2 = HIGH  — Dimensity 1080+, Snapdragon 778+, 8GB RAM

const QUALITY_LOW    = 0
const QUALITY_MEDIUM = 1
const QUALITY_HIGH   = 2

const PRESETS = {
	QUALITY_LOW: {
		"render_scale":          0.60,
		"shadow_size":           512,
		"shadow_enabled":        false,
		"msaa":                  0,
		"max_fps":               30,
		"view_distance":         60.0,
		"particle_multiplier":   0.0,
		"lod_bias":              2.0,
		"texture_filter":        0,
		"occlusion_culling":     true,
		"label": "Низкое"
	},
	QUALITY_MEDIUM: {
		"render_scale":          0.80,
		"shadow_size":           1024,
		"shadow_enabled":        true,
		"msaa":                  0,
		"max_fps":               45,
		"view_distance":         100.0,
		"particle_multiplier":   0.5,
		"lod_bias":              1.0,
		"texture_filter":        1,
		"occlusion_culling":     true,
		"label": "Среднее"
	},
	QUALITY_HIGH: {
		"render_scale":          1.00,
		"shadow_size":           2048,
		"shadow_enabled":        true,
		"msaa":                  2,
		"max_fps":               60,
		"view_distance":         200.0,
		"particle_multiplier":   1.0,
		"lod_bias":              0.5,
		"texture_filter":        2,
		"occlusion_culling":     true,
		"label": "Высокое"
	}
}

var current_quality: int = QUALITY_LOW

# BUGFIX: кэш оригинальных значений amount у частиц
# чтобы правильно восстанавливать их при смене качества
var _particle_original_amounts: Dictionary = {}

signal quality_changed(level)

func _ready():
	var saved = GameManager.settings.get("graphics_quality", QUALITY_LOW)
	set_quality(saved)

func set_quality(level: int):
	level = clampi(level, QUALITY_LOW, QUALITY_HIGH)
	current_quality = level
	GameManager.settings["graphics_quality"] = level
	var p = PRESETS[level]

	get_viewport().scaling_3d_scale = p["render_scale"]
	Engine.max_fps = p["max_fps"]

	var viewport = get_viewport()
	if p["shadow_enabled"]:
		RenderingServer.directional_shadow_atlas_set_size(p["shadow_size"], true)
	else:
		RenderingServer.directional_shadow_atlas_set_size(0, false)

	viewport.msaa_3d = p["msaa"]

	get_tree().call_group("lod_targets", "set_lod_bias", p["lod_bias"])
	_update_camera_far(p["view_distance"])
	_update_particles(p["particle_multiplier"])

	quality_changed.emit(level)
	print("PerformanceManager: качество = ", p["label"],
		" | рендер ", int(p["render_scale"]*100), "%",
		" | FPS ", p["max_fps"],
		" | тени ", p["shadow_size"])

func get_preset() -> Dictionary:
	return PRESETS[current_quality]

func get_label() -> String:
	return PRESETS[current_quality]["label"]

func _update_camera_far(dist: float):
	var cam = _find_camera()
	if cam:
		cam.far = dist

func _find_camera() -> Camera3D:
	if not get_tree():
		return null
	var nodes = get_tree().get_nodes_in_group("player_camera")
	if nodes.size() > 0:
		return nodes[0] as Camera3D
	return null

func _update_particles(mult: float):
	if not get_tree():
		return
	var pnodes = get_tree().get_nodes_in_group("game_particles")
	for particle_node in pnodes:
		if particle_node is GPUParticles3D:
			var node_id = particle_node.get_instance_id()
			# BUGFIX: сохраняем оригинальное количество частиц один раз
			if not _particle_original_amounts.has(node_id):
				_particle_original_amounts[node_id] = particle_node.amount
			var original = _particle_original_amounts[node_id]
			if mult <= 0.0:
				particle_node.emitting = false
				# Не меняем amount — сохраняем для будущего восстановления
			else:
				particle_node.emitting = true
				particle_node.amount = max(1, int(original * mult))

func detect_recommended_quality() -> int:
	if OS.get_name() == "Android":
		return QUALITY_LOW
	return QUALITY_MEDIUM
