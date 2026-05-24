extends Control
# HUD — все элементы создаются программно.
# BUGFIX: был "extends CanvasLayer" при ноде типа Control → скрипт не применялся вообще.

var oxygen_bar: ProgressBar    = null
var oxygen_label: Label        = null
var iron_label: Label          = null
var silicon_label: Label       = null
var energy_label: Label        = null
var titanium_label: Label      = null
var crystal_label: Label       = null
var water_label: Label         = null
var planet_label: Label        = null
var interact_hint: Label       = null
var notification_label: Label  = null
var build_btn: Button          = null
var travel_btn: Button         = null
var upgrade_btn: Button        = null
var inventory_btn: Button      = null

var travel_screen: Control    = null
var upgrade_screen: Control   = null
var inventory_screen: Control = null
var notification_timer: float = 0.0

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

	GameManager.resources_changed.connect(_update_resources)
	GameManager.planet_changed.connect(_update_planet)
	_update_resources()
	_update_planet(GameManager.current_planet)

	build_btn.pressed.connect(_on_build_pressed)
	travel_btn.pressed.connect(_on_travel_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	inventory_btn.pressed.connect(_on_inventory_pressed)

	# Экраны — братья по иерархии под UI CanvasLayer
	await get_tree().process_frame
	travel_screen    = get_node_or_null("../TravelScreen")
	upgrade_screen   = get_node_or_null("../UpgradeScreen")
	inventory_screen = get_node_or_null("../InventoryScreen")
	# BUGFIX: подключаем сигнал oxygen_changed от Player — без этого шкала O2 не обновляется
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		player.oxygen_changed.connect(update_oxygen)

func _build_ui():
	# ── ВЕРХНЯЯ ПАНЕЛЬ ──────────────────────────────────────────
	var top = PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size.y = 52
	var top_s = StyleBoxFlat.new()
	top_s.bg_color = Color(0, 0, 0, 0.55)
	top.add_theme_stylebox_override("panel", top_s)
	add_child(top)

	var top_hbox = HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 18)
	top.add_child(top_hbox)

	planet_label = Label.new()
	planet_label.text = "Марс-Альфа"
	planet_label.add_theme_font_size_override("font_size", 17)
	planet_label.custom_minimum_size.x = 200
	top_hbox.add_child(planet_label)

	var sp = Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(sp)

	iron_label     = _res_lbl("Fe: 0",    top_hbox)
	silicon_label  = _res_lbl("Si: 0",    top_hbox)
	energy_label   = _res_lbl("E: 0",     top_hbox)
	titanium_label = _res_lbl("Ti: 0",    top_hbox)
	crystal_label  = _res_lbl("Cr: 0",    top_hbox)
	water_label    = _res_lbl("H2O: 0",   top_hbox)

	# ── O2 (левый верх) ─────────────────────────────────────────
	var o2_vbox = VBoxContainer.new()
	o2_vbox.position = Vector2(12, 60)
	add_child(o2_vbox)

	oxygen_label = Label.new()
	oxygen_label.text = "O2: 100%"
	oxygen_label.add_theme_font_size_override("font_size", 15)
	o2_vbox.add_child(oxygen_label)

	oxygen_bar = ProgressBar.new()
	oxygen_bar.custom_minimum_size = Vector2(175, 16)
	oxygen_bar.max_value     = 100
	oxygen_bar.value         = 100
	oxygen_bar.show_percentage = false
	o2_vbox.add_child(oxygen_bar)

	# ── ПОДСКАЗКА ВЗАИМОДЕЙСТВИЯ (центр) ────────────────────────
	interact_hint = Label.new()
	interact_hint.anchor_left   = 0.5; interact_hint.anchor_right  = 0.5
	interact_hint.anchor_top    = 0.5; interact_hint.anchor_bottom = 0.5
	interact_hint.offset_left   = -220; interact_hint.offset_right  = 220
	interact_hint.offset_top    = -22;  interact_hint.offset_bottom = 22
	interact_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_hint.add_theme_color_override("font_color", Color.YELLOW)
	interact_hint.visible = false
	add_child(interact_hint)

	# ── УВЕДОМЛЕНИЕ (чуть ниже центра) ──────────────────────────
	notification_label = Label.new()
	notification_label.anchor_left   = 0.5; notification_label.anchor_right  = 0.5
	notification_label.anchor_top    = 0.65; notification_label.anchor_bottom = 0.65
	notification_label.offset_left   = -300; notification_label.offset_right  = 300
	notification_label.offset_top    = -22;  notification_label.offset_bottom = 22
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.add_theme_color_override("font_color", Color.CYAN)
	notification_label.visible = false
	add_child(notification_label)

	# ── НИЖНЯЯ ПАНЕЛЬ (кнопки) ──────────────────────────────────
	var bot = PanelContainer.new()
	bot.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bot.custom_minimum_size.y = 82
	var bot_s = StyleBoxFlat.new()
	bot_s.bg_color = Color(0, 0, 0, 0.55)
	bot.add_theme_stylebox_override("panel", bot_s)
	add_child(bot)

	var btn_hbox = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 12)
	bot.add_child(btn_hbox)

	build_btn     = _hud_btn("Строить",   btn_hbox)
	travel_btn    = _hud_btn("Перелёт",   btn_hbox)
	upgrade_btn   = _hud_btn("Апгрейды",  btn_hbox)
	inventory_btn = _hud_btn("Инвентарь", btn_hbox)

	var sp2 = Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_hbox.add_child(sp2)

	var pause_btn = _hud_btn("Пауза", btn_hbox)
	pause_btn.pressed.connect(func():
		var pm = get_tree().current_scene.get_node_or_null("UI/PauseMenu")
		if pm and pm.has_method("toggle_pause"):
			pm.toggle_pause()
	)

func _res_lbl(text: String, parent: Node) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	parent.add_child(l)
	return l

func _hud_btn(text: String, parent: Node) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(148, 70)
	parent.add_child(b)
	return b

func _process(delta):
	if notification_timer > 0.0:
		notification_timer -= delta
		if notification_timer <= 0.0 and notification_label:
			notification_label.visible = false

func update_oxygen(value: float):
	if oxygen_bar:
		oxygen_bar.value = value
		oxygen_bar.modulate = Color.RED if value < 25 else Color.YELLOW if value < 50 else Color.WHITE
	if oxygen_label:
		oxygen_label.text = "O2: %d%%" % int(value)

func _update_resources():
	var r = GameManager.resources
	if iron_label:      iron_label.text     = "Fe: %d"  % int(r.get("iron",     0))
	if silicon_label:   silicon_label.text  = "Si: %d"  % int(r.get("silicon",  0))
	if energy_label:    energy_label.text   = "E: %d"   % int(r.get("energy",   0))
	if titanium_label:  titanium_label.text = "Ti: %d"  % int(r.get("titanium", 0))
	if crystal_label:   crystal_label.text  = "Cr: %d"  % int(r.get("crystal",  0))
	if water_label:     water_label.text    = "H2O: %d" % int(r.get("water",    0))

func _update_planet(planet_id: int):
	const NAMES = ["Марс-Альфа","Ледяной Европа-7","Вулканический Ио-X","Газовый Нептун-Омега"]
	if planet_label:
		planet_label.text = NAMES[clamp(planet_id, 0, NAMES.size()-1)]

func show_notification(text: String, duration: float = 3.0):
	if notification_label:
		notification_label.text = text
		notification_label.visible = true
		notification_timer = duration

func show_interact_hint(text: String):
	if interact_hint:
		interact_hint.text = text
		interact_hint.visible = true

func hide_interact_hint():
	if interact_hint:
		interact_hint.visible = false

func _on_build_pressed():
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.has_method("toggle_build_mode"):
		player.toggle_build_mode()

func _on_travel_pressed():
	if travel_screen: travel_screen.visible = true

func _on_upgrade_pressed():
	if upgrade_screen: upgrade_screen.visible = true

func _on_inventory_pressed():
	if inventory_screen: inventory_screen.visible = true
