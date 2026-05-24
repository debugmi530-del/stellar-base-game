extends Control
# BUGFIX: перезаписан программно — в сцене нет дочерних нод, @onready давали null.

var is_paused: bool = false
var _is_mobile: bool = false

var _resume_btn: Button   = null
var _save_btn: Button     = null
var _status_lbl: Label    = null
var _settings_node: Control = null

func _ready():
	_is_mobile = OS.has_feature("android") or OS.has_feature("mobile")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()

func _build_ui():
	# Полупрозрачный фон
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Центральная панель
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(340, 0)
	var style = StyleBoxFlat.new()
	style.bg_color        = Color(0.08, 0.08, 0.14, 0.97)
	style.border_color    = Color(0.3, 0.5, 1.0, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Отступ сверху
	var top_margin = Control.new(); top_margin.custom_minimum_size.y = 12
	vbox.add_child(top_margin)

	var title = Label.new()
	title.text = "ПАУЗА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	vbox.add_child(title)

	var sep = HSeparator.new(); vbox.add_child(sep)

	_resume_btn = _make_btn("Продолжить", vbox)
	_save_btn   = _make_btn("Сохранить",  vbox)
	var set_btn = _make_btn("Настройки",  vbox)
	var menu_btn = _make_btn("Главное меню", vbox)

	_status_lbl = Label.new()
	_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_lbl.add_theme_color_override("font_color", Color.GREEN)
	_status_lbl.visible = false
	vbox.add_child(_status_lbl)

	# Отступ снизу
	var bot_margin = Control.new(); bot_margin.custom_minimum_size.y = 12
	vbox.add_child(bot_margin)

	_resume_btn.pressed.connect(toggle_pause)
	_save_btn.pressed.connect(_on_save)
	set_btn.pressed.connect(_on_settings)
	menu_btn.pressed.connect(_on_main_menu)

	# Встроенная панель настроек (скрипт подключается динамически)
	_settings_node = Control.new()
	_settings_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_node.visible = false
	var settings_script = load("res://scripts/settings_screen.gd")
	_settings_node.set_script(settings_script)
	add_child(_settings_node)

func _make_btn(text: String, parent: Node) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 58)
	parent.add_child(b)
	return b

func _on_save():
	GameManager.save_game()
	if _status_lbl:
		_status_lbl.text    = "Сохранено!"
		_status_lbl.visible = true
		await get_tree().create_timer(2.0).timeout
		if _status_lbl:
			_status_lbl.visible = false

func _on_settings():
	if _settings_node:
		_settings_node.visible = true

func _on_main_menu():
	GameManager.save_game()
	is_paused         = false
	get_tree().paused = false
	# BUGFIX: мышь — только на ПК
	if not _is_mobile:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func toggle_pause():
	is_paused         = not is_paused
	visible           = is_paused
	get_tree().paused = is_paused
	# BUGFIX: на Android MOUSE_MODE_CAPTURED/VISIBLE игнорируется — не вызываем
	if not _is_mobile:
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED
		)
