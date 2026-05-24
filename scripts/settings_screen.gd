extends Control
# Панель настроек — UI строится программно.
# Работает и в главном меню, и в паузе.

var close_btn:      Button      = null
var music_slider:   HSlider     = null
var sfx_slider:     HSlider     = null
var sens_slider:    HSlider     = null
var invert_y:       CheckButton = null
var quality_low:    Button      = null
var quality_medium: Button      = null
var quality_high:   Button      = null
var quality_label:  Label       = null
var fps_label:      Label       = null

func _ready():
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Затемнение фона
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Основная панель
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 520)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Заголовок
	var title = Label.new()
	title.text = "Настройки"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())

	# Музыка
	var m_row = HBoxContainer.new()
	var m_lbl = Label.new(); m_lbl.text = "Музыка"; m_lbl.custom_minimum_size.x = 160
	music_slider = HSlider.new()
	music_slider.min_value = 0.0; music_slider.max_value = 1.0
	music_slider.step      = 0.05
	music_slider.value     = GameManager.settings.get("music_volume", 0.8)
	music_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m_row.add_child(m_lbl); m_row.add_child(music_slider)
	vbox.add_child(m_row)

	# SFX
	var s_row = HBoxContainer.new()
	var s_lbl = Label.new(); s_lbl.text = "Звуки"; s_lbl.custom_minimum_size.x = 160
	sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0; sfx_slider.max_value = 1.0
	sfx_slider.step      = 0.05
	sfx_slider.value     = GameManager.settings.get("sfx_volume", 1.0)
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s_row.add_child(s_lbl); s_row.add_child(sfx_slider)
	vbox.add_child(s_row)

	# Чувствительность
	var c_row = HBoxContainer.new()
	var c_lbl = Label.new(); c_lbl.text = "Чувствительность"; c_lbl.custom_minimum_size.x = 160
	sens_slider = HSlider.new()
	sens_slider.min_value = 0.05; sens_slider.max_value = 1.0
	sens_slider.step      = 0.05
	sens_slider.value     = GameManager.settings.get("sensitivity", 0.3)
	sens_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c_row.add_child(c_lbl); c_row.add_child(sens_slider)
	vbox.add_child(c_row)

	# Инвертировать Y
	invert_y = CheckButton.new()
	invert_y.text = "Инвертировать Y-ось"
	invert_y.button_pressed = GameManager.settings.get("invert_y", false)
	vbox.add_child(invert_y)

	vbox.add_child(HSeparator.new())

	# Качество графики
	var q_lbl = Label.new(); q_lbl.text = "Качество графики:"
	vbox.add_child(q_lbl)

	var q_row = HBoxContainer.new()
	q_row.add_theme_constant_override("separation", 8)

	quality_low    = Button.new(); quality_low.text    = "Низкое";  quality_low.size_flags_horizontal    = Control.SIZE_EXPAND_FILL
	quality_medium = Button.new(); quality_medium.text = "Среднее"; quality_medium.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quality_high   = Button.new(); quality_high.text   = "Высокое"; quality_high.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	q_row.add_child(quality_low); q_row.add_child(quality_medium); q_row.add_child(quality_high)
	vbox.add_child(q_row)

	quality_label = Label.new()
	quality_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(quality_label)

	fps_label = Label.new()
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(fps_label)

	vbox.add_child(HSeparator.new())

	# Кнопка закрыть
	close_btn = Button.new()
	close_btn.text = "Закрыть и сохранить"
	vbox.add_child(close_btn)

	# Сигналы
	music_slider.value_changed.connect(_on_music)
	sfx_slider.value_changed.connect(_on_sfx)
	sens_slider.value_changed.connect(_on_sens)
	invert_y.toggled.connect(_on_invert)
	quality_low.pressed.connect(func():    _set_quality(0))
	quality_medium.pressed.connect(func(): _set_quality(1))
	quality_high.pressed.connect(func():   _set_quality(2))
	close_btn.pressed.connect(func():
		GameManager.save_game()
		visible = false
	)

	PerformanceManager.quality_changed.connect(_update_quality_ui)
	_update_quality_ui(PerformanceManager.current_quality)

func _process(_delta):
	if fps_label and visible:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _set_quality(level: int):
	PerformanceManager.set_quality(level)
	GameManager.settings["graphics_quality"] = level
	GameManager.save_game()

func _update_quality_ui(level: int):
	if not quality_label:
		return
	var names = ["Низкое (рекомендуется)", "Среднее", "Высокое"]
	quality_label.text = "Текущее: " + names[clamp(level, 0, 2)]
	var cols = [Color.GREEN, Color.YELLOW, Color.ORANGE_RED]
	if quality_low:    quality_low.modulate    = cols[0] if level == 0 else Color.WHITE
	if quality_medium: quality_medium.modulate = cols[1] if level == 1 else Color.WHITE
	if quality_high:   quality_high.modulate   = cols[2] if level == 2 else Color.WHITE

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
