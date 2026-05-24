extends Control

@onready var resume_btn: Button = $Panel/VBoxContainer/ResumeBtn
@onready var settings_btn: Button = $Panel/VBoxContainer/SettingsBtn
@onready var save_btn: Button = $Panel/VBoxContainer/SaveBtn
@onready var main_menu_btn: Button = $Panel/VBoxContainer/MainMenuBtn
@onready var settings_panel: Control = $SettingsPanel

var is_paused: bool = false

func _ready():
	visible = false
	resume_btn.pressed.connect(toggle_pause)
	save_btn.pressed.connect(func():
		GameManager.save_game()
		$Panel/VBoxContainer/SaveLabel.visible = true
		await get_tree().create_timer(2.0).timeout
		$Panel/VBoxContainer/SaveLabel.visible = false
	)
	settings_btn.pressed.connect(func(): settings_panel.visible = true)
	main_menu_btn.pressed.connect(func():
		GameManager.save_game()
		is_paused = false
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

func toggle_pause():
	is_paused = !is_paused
	visible = is_paused
	get_tree().paused = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED)
