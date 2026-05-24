extends Control

@onready var close_btn:       Button      = $Panel/CloseBtn
@onready var music_slider:    HSlider     = $Panel/VBox/MusicSlider
@onready var sfx_slider:      HSlider     = $Panel/VBox/SFXSlider
@onready var sens_slider:     HSlider     = $Panel/VBox/SensSlider
@onready var invert_y:        CheckButton = $Panel/VBox/InvertY
@onready var quality_low:     Button      = $Panel/VBox/QualityRow/LowBtn
@onready var quality_medium:  Button      = $Panel/VBox/QualityRow/MedBtn
@onready var quality_high:    Button      = $Panel/VBox/QualityRow/HighBtn
@onready var quality_label:   Label       = $Panel/VBox/QualityRow/CurrentLabel
@onready var fps_label:       Label       = $Panel/VBox/FPSLabel

func _ready():
	visible = false
	if close_btn:    close_btn.pressed.connect(func(): visible = false)
	if music_slider: music_slider.value = GameManager.settings.get("music_volume", 0.8)
	if sfx_slider:   sfx_slider.value   = GameManager.settings.get("sfx_volume",   1.0)
	if sens_slider:  sens_slider.value  = GameManager.settings.get("sensitivity",  0.3)
	if invert_y:     invert_y.button_pressed = GameManager.settings.get("invert_y", false)

	if music_slider: music_slider.value_changed.connect(_on_music)
	if sfx_slider:   sfx_slider.value_changed.connect(_on_sfx)
	if sens_slider:  sens_slider.value_changed.connect(_on_sens)
	if invert_y:     invert_y.toggled.connect(_on_invert)

	if quality_low:    quality_low.pressed.connect(func():    _set_quality(0))
	if quality_medium: quality_medium.pressed.connect(func(): _set_quality(1))
	if quality_high:   quality_high.pressed.connect(func():   _set_quality(2))

	PerformanceManager.quality_changed.connect(_update_quality_ui)
	_update_quality_ui(PerformanceManager.current_quality)

func _process(_delta):
	if fps_label and visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _set_quality(level: int):
	PerformanceManager.set_quality(level)
	GameManager.save_game()

func _update_quality_ui(level: int):
	if quality_label:
		var labels = ["Низкое (рекомендуется)", "Среднее", "Высокое"]
		quality_label.text = labels[level]

	var colors = [Color.GREEN, Color.YELLOW, Color.ORANGE_RED]
	if quality_low:    quality_low.modulate    = colors[0] if level == 0 else Color.WHITE
	if quality_medium: quality_medium.modulate = colors[1] if level == 1 else Color.WHITE
	if quality_high:   quality_high.modulate   = colors[2] if level == 2 else Color.WHITE

func _on_music(v: float):
	GameManager.settings["music_volume"] = v
	AudioManager._apply_volumes()

func _on_sfx(v: float):
	GameManager.settings["sfx_volume"] = v
	AudioManager._apply_volumes()

func _on_sens(v: float):
	GameManager.settings["sensitivity"] = v

func _on_invert(v: bool):
	GameManager.settings["invert_y"] = v
