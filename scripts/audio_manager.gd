extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

const MUSIC_TRACKS = {
	0: "res://assets/audio/music/mars_theme.ogg",
	1: "res://assets/audio/music/ice_theme.ogg",
	2: "res://assets/audio/music/volcano_theme.ogg",
	3: "res://assets/audio/music/gas_theme.ogg"
}

var current_planet: int = -1

func _ready():
	GameManager.planet_changed.connect(_on_planet_changed)
	_apply_volumes()
	play_planet_music(GameManager.current_planet)

func _apply_volumes():
	var mv = GameManager.settings.get("music_volume", 0.8)
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(mv))
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		var sv = GameManager.settings.get("sfx_volume", 1.0)
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sv))

func play_planet_music(planet_id: int):
	if planet_id == current_planet:
		return
	current_planet = planet_id
	var track_path = MUSIC_TRACKS.get(planet_id, "")
	if track_path != "" and ResourceLoader.exists(track_path):
		var stream = load(track_path)
		if music_player:
			music_player.stream = stream
			music_player.play()

func _on_planet_changed(planet_id: int):
	play_planet_music(planet_id)

func play_sfx(stream: AudioStream, pos: Vector3 = Vector3.ZERO):
	if stream == null:
		return
	var player = AudioStreamPlayer3D.new()
	get_tree().current_scene.add_child(player)
	# Set position AFTER adding to scene tree
	player.global_position = pos
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)
