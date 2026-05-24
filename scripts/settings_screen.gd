extends Control

@onready var music_slider: HSlider = $Panel/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXSlider
@onready var sensitivity_slider: HSlider = $Panel/VBoxContainer/SensSlider
@onready var invert_y_check: CheckButton = $Panel/VBoxContainer/InvertYCheck
@onready var quality_option: OptionButton = $Panel/VBoxContainer/QualityOption
@onready var close_btn: Button = $Panel/CloseBtn
@onready var apply_btn: Button = $Panel/ApplyBtn

func _ready():
	close_btn.pressed.connect(func(): visible = false)
	apply_btn.pressed.connect(_apply_settings)
	visible = false

func _on_visibility_changed():
	if visible:
		_load_settings()

func _load_settings():
	var s = GameManager.settings
	music_slider.value = s.get("music_volume", 0.8)
	sfx_slider.value = s.get("sfx_volume", 1.0)
	sensitivity_slider.value = s.get("sensitivity", 0.3)
	invert_y_check.button_pressed = s.get("invert_y", false)
	quality_option.selected = s.get("graphics_quality", 1)

func _apply_settings():
	GameManager.settings["music_volume"] = music_slider.value
	GameManager.settings["sfx_volume"] = sfx_slider.value
	GameManager.settings["sensitivity"] = sensitivity_slider.value
	GameManager.settings["invert_y"] = invert_y_check.button_pressed
	GameManager.settings["graphics_quality"] = quality_option.selected
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_slider.value))
	GameManager.save_game()
	visible = false
