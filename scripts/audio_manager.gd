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
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(mv))

func play_planet_music(planet_id: int):
	if planet_id == current_planet:
		return
	current_planet = planet_id
	var track_path = MUSIC_TRACKS.get(planet_id, "")
	if track_path != "" and ResourceLoader.exists(track_path):
		var stream = load(track_path)
		music_player.stream = stream
		music_player.play()

func _on_planet_changed(planet_id: int):
	play_planet_music(planet_id)

func play_sfx(stream: AudioStream, position: Vector3 = Vector3.ZERO):
	var player = AudioStreamPlayer3D.new()
	get_tree().current_scene.add_child(player)
	player.stream = stream
	player.global_position = position
	player.play()
	player.finished.connect(player.queue_free)
