extends Node

@onready var music_player:   AudioStreamPlayer = $MusicPlayer
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

# Используем сгенерированные WAV файлы
const MUSIC_TRACKS = {
	0: "res://assets/audio/music/mars_theme.wav",
	1: "res://assets/audio/music/europa_theme.wav",
	2: "res://assets/audio/music/io_theme.wav",
	3: "res://assets/audio/music/neptune_theme.wav"
}

const SFX_PATHS = {
	"footstep":    "res://assets/audio/sfx/footstep.wav",
	"footstep_2":  "res://assets/audio/sfx/footstep_2.wav",
	"pickup":      "res://assets/audio/sfx/pickup.wav",
	"build":       "res://assets/audio/sfx/build.wav",
	"build_done":  "res://assets/audio/sfx/build_done.wav",
	"error":       "res://assets/audio/sfx/error.wav",
	"success":     "res://assets/audio/sfx/success.wav",
	"menu_click":  "res://assets/audio/sfx/menu_click.wav",
	"oxygen_low":  "res://assets/audio/sfx/oxygen_low.wav",
	"explosion":   "res://assets/audio/sfx/explosion.wav",
	"mine":        "res://assets/audio/sfx/mine.wav",
	"travel":      "res://assets/audio/sfx/travel.wav",
	"upgrade":     "res://assets/audio/sfx/upgrade.wav",
	"death":       "res://assets/audio/sfx/death.wav",
	"ambient_wind":"res://assets/audio/sfx/ambient_wind.wav"
}

# Кэш загруженных SFX
var _sfx_cache: Dictionary = {}
var current_planet: int = -1

func _ready():
	GameManager.planet_changed.connect(_on_planet_changed)
	_apply_volumes()
	play_planet_music(GameManager.current_planet)

func _apply_volumes():
	var mv = GameManager.settings.get("music_volume", 0.8)
	var sv = GameManager.settings.get("sfx_volume",   1.0)
	_set_bus_volume("Music", mv)
	_set_bus_volume("SFX",   sv)

func _set_bus_volume(bus_name: String, linear: float):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func play_planet_music(planet_id: int):
	if planet_id == current_planet:
		return
	current_planet = planet_id
	var path = MUSIC_TRACKS.get(planet_id, "")
	if path != "" and ResourceLoader.exists(path):
		if music_player:
			music_player.stream = load(path)
			music_player.play()

func _on_planet_changed(planet_id: int):
	play_planet_music(planet_id)

# Воспроизвести SFX по имени (с кэшированием)
func play_sfx_named(sfx_name: String):
	var path = SFX_PATHS.get(sfx_name, "")
	if path == "":
		return
	if not _sfx_cache.has(sfx_name):
		if ResourceLoader.exists(path):
			_sfx_cache[sfx_name] = load(path)
		else:
			return
	_play_stream_2d(_sfx_cache[sfx_name])

# Воспроизвести AudioStream в 3D пространстве
func play_sfx(stream: AudioStream, pos: Vector3 = Vector3.ZERO):
	if stream == null:
		return
	var player = AudioStreamPlayer3D.new()
	get_tree().current_scene.add_child(player)
	player.global_position = pos   # после add_child
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)

func _play_stream_2d(stream: AudioStream):
	if stream == null:
		return
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.bus = "SFX"
	player.play()
	player.finished.connect(player.queue_free)
