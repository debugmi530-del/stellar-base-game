extends CanvasLayer
# Виртуальный джойстик и кнопки для Android.
# Все визуальные элементы создаются программно — нет зависимости от .tscn.

const MAX_RADIUS = 72.0
const DEAD_ZONE  = 16.0

var _left_id: int  = -1
var _right_id: int = -1
var _left_origin: Vector2  = Vector2.ZERO
var _right_origin: Vector2 = Vector2.ZERO

var _base_panel: Panel = null
var _knob_panel: Panel = null
var _sprint_active: bool = false
var _sprint_btn: Button  = null

func _ready():
	layer = 8  # Выше всего UI

	# ── Визуал джойстика (изначально скрыт) ─────────────────────
	_base_panel = _circle(72, Color(1, 1, 1, 0.18))
	_base_panel.visible = false
	add_child(_base_panel)

	_knob_panel = _circle(30, Color(1, 1, 1, 0.55))
	_knob_panel.visible = false
	add_child(_knob_panel)

	# Лейбл подсказки для правой зоны
	var look_label = Label.new()
	look_label.text = "Взгляд →"
	look_label.anchor_left   = 0.75; look_label.anchor_right  = 1.0
	look_label.anchor_top    = 0.45; look_label.anchor_bottom = 0.55
	look_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	look_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
	look_label.add_theme_font_size_override("font_size", 13)
	add_child(look_label)

	# ── Кнопки управления (правый нижний угол) ──────────────────
	var vbox = VBoxContainer.new()
	vbox.anchor_right  = 1.0; vbox.anchor_bottom = 1.0
	vbox.anchor_left   = 1.0; vbox.anchor_top    = 1.0
	vbox.offset_left   = -185; vbox.offset_top   = -275
	vbox.offset_right  = -12;  vbox.offset_bottom = -10
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)

	var interact_btn = _btn("Взаимодействие", Color(0.1, 0.6, 0.2, 0.88))
	var jump_btn     = _btn("Прыжок",         Color(0.1, 0.35, 0.85, 0.88))
	_sprint_btn      = _btn("Бег: ВЫКЛ",      Color(0.55, 0.35, 0.05, 0.88))
	vbox.add_child(interact_btn)
	vbox.add_child(jump_btn)
	vbox.add_child(_sprint_btn)

	# Сигналы кнопок
	interact_btn.pressed.connect(func():
		var ev = InputEventAction.new()
		ev.action = "interact"; ev.pressed = true
		Input.parse_input_event(ev)
	)
	jump_btn.pressed.connect(func():   Input.action_press("jump"))
	jump_btn.button_up.connect(func(): Input.action_release("jump"))
	_sprint_btn.pressed.connect(_toggle_sprint)

func _toggle_sprint():
	_sprint_active = not _sprint_active
	_sprint_btn.text = "Бег: ВКЛ" if _sprint_active else "Бег: ВЫКЛ"
	if _sprint_active:
		Input.action_press("sprint")
	else:
		Input.action_release("sprint")

func _circle(radius: int, color: Color) -> Panel:
	var p = Panel.new()
	p.custom_minimum_size = Vector2(radius * 2, radius * 2)
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left    = radius; s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left = radius; s.corner_radius_bottom_right = radius
	p.add_theme_stylebox_override("panel", s)
	return p

func _btn(text: String, color: Color) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(170, 62)
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left    = 8; s.corner_radius_top_right    = 8
	s.corner_radius_bottom_left = 8; s.corner_radius_bottom_right = 8
	b.add_theme_stylebox_override("normal",  s)
	b.add_theme_stylebox_override("hover",   s)
	b.add_theme_stylebox_override("pressed", s)
	return b

func _input(event):
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)

func _on_touch(ev: InputEventScreenTouch):
	var sw = get_viewport().get_visible_rect().size.x
	if ev.pressed:
		# Левая половина экрана → джойстик движения
		if ev.position.x < sw * 0.45 and _left_id < 0:
			_left_id     = ev.index
			_left_origin = ev.position
			_show_stick(ev.position)
		# Правая половина → вращение камеры
		elif ev.position.x >= sw * 0.55 and _right_id < 0:
			_right_id     = ev.index
			_right_origin = ev.position
	else:
		if ev.index == _left_id:
			_left_id = -1
			_hide_stick()
			_release_move()
		elif ev.index == _right_id:
			_right_id = -1

func _on_drag(ev: InputEventScreenDrag):
	if ev.index == _left_id:
		var delta   = ev.position - _left_origin
		var clamped = delta if delta.length() <= MAX_RADIUS else delta.normalized() * MAX_RADIUS
		_knob_panel.position = _left_origin - Vector2(30, 30) + clamped
		if delta.length() > DEAD_ZONE:
			_apply_move(clamped / MAX_RADIUS)
		else:
			_release_move()
	elif ev.index == _right_id:
		_apply_look(ev.relative)

func _show_stick(pos: Vector2):
	_base_panel.position = pos - Vector2(72, 72)
	_knob_panel.position = pos - Vector2(30, 30)
	_base_panel.visible  = true
	_knob_panel.visible  = true

func _hide_stick():
	_base_panel.visible = false
	_knob_panel.visible = false

func _apply_move(dir: Vector2):
	_release_move()
	if dir.y < -0.22: Input.action_press("move_forward")
	if dir.y >  0.22: Input.action_press("move_back")
	if dir.x < -0.22: Input.action_press("move_left")
	if dir.x >  0.22: Input.action_press("move_right")

func _release_move():
	Input.action_release("move_forward")
	Input.action_release("move_back")
	Input.action_release("move_left")
	Input.action_release("move_right")

func _apply_look(delta: Vector2):
	var evt      = InputEventMouseMotion.new()
	evt.relative = delta * 1.4
	Input.parse_input_event(evt)
