extends Control

@onready var respawn_btn: Button = $CenterContainer/VBoxContainer/RespawnBtn
@onready var menu_btn: Button = $CenterContainer/VBoxContainer/MenuBtn

func _ready():
	get_tree().paused = false
	respawn_btn.pressed.connect(func():
		GameManager.resources["oxygen"] = 30
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	)
	menu_btn.pressed.connect(func():
		GameManager.save_game()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
