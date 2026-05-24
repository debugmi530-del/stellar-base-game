extends Control

@onready var resume_btn: Button    = $Panel/VBoxContainer/ResumeBtn
@onready var settings_btn: Button  = $Panel/VBoxContainer/SettingsBtn
@onready var save_btn: Button      = $Panel/VBoxContainer/SaveBtn
@onready var main_menu_btn: Button = $Panel/VBoxContainer/MainMenuBtn
@onready var save_status: Label    = $Panel/VBoxContainer/SaveStatus

var is_paused: bool = false

func _ready():
	visible = false
	if save_status:
		save_status.visible = false
	if resume_btn:
		resume_btn.pressed.connect(toggle_pause)
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
	if main_menu_btn:
		main_menu_btn.pressed.connect(_on_main_menu_pressed)

func _on_save_pressed():
	GameManager.save_game()
	if save_status:
		save_status.text = "Сохранено!"
		save_status.visible = true
		await get_tree().create_timer(2.0).timeout
		if save_status:
			save_status.visible = false

func _on_settings_pressed():
	var settings = get_node_or_null("SettingsPanel")
	if settings:
		settings.visible = true

func _on_main_menu_pressed():
	GameManager.save_game()
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func toggle_pause():
	is_paused = !is_paused
	visible   = is_paused
	get_tree().paused = is_paused
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED
	)
