extends Control

@onready var new_game_btn: Button = $CenterContainer/VBoxContainer/NewGameBtn
@onready var continue_btn: Button = $CenterContainer/VBoxContainer/ContinueBtn
@onready var settings_btn: Button = $CenterContainer/VBoxContainer/SettingsBtn
@onready var exit_btn: Button = $CenterContainer/VBoxContainer/ExitBtn
@onready var version_label: Label = $VersionLabel
@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var settings_panel: Control = $SettingsPanel
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	version_label.text = "v0.1.0 Alpha"
	title_label.text = "STELLAR BASE"
	subtitle_label.text = "Космический симулятор выживания"
	# BUGFIX: был "savegame.tres" — должен быть "savegame.json" (как в GameManager.SAVE_PATH)
	var save_exists = FileAccess.file_exists(GameManager.SAVE_PATH)
	continue_btn.disabled = not save_exists
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	settings_btn.pressed.connect(func(): settings_panel.visible = true)
	exit_btn.pressed.connect(func(): get_tree().quit())
	# BUGFIX: проверяем существование анимации перед воспроизведением
	if anim and anim.has_animation("intro"):
		anim.play("intro")
