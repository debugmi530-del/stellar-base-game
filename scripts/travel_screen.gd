extends Control
# Экран путешествий — UI создаётся программно (не требует .tscn)

var close_btn: Button         = null
var planet_container: VBoxContainer = null
var fuel_label: Label         = null

const PLANET_NAMES = ["Марс-Альфа", "Ледяной Европа-7", "Вулканический Ио-X", "Газовый Нептун-Омега"]
const PLANET_DESC  = [
	"Красная пустыня. Железо, кремний, вода.",
	"Ледяной мир. Вода, кремний, кристаллы.",
	"Вулканы. Железо, титан, кристаллы.",
	"Высокая гравитация. Кремний, энергия, кристаллы."
]
const TRAVEL_COST = {"energy": 80}

func _ready():
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Затемнение фона
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Панель
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(520, 580)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Перемещение между планетами"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	fuel_label = Label.new()
	fuel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(fuel_label)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(500, 400)
	vbox.add_child(scroll)

	planet_container = VBoxContainer.new()
	planet_container.add_theme_constant_override("separation", 6)
	scroll.add_child(planet_container)

	close_btn = Button.new()
	close_btn.text = "Закрыть"
	close_btn.pressed.connect(_close)
	vbox.add_child(close_btn)

	visibility_changed.connect(_on_visibility_changed)

func _close():
	visible = false

func _on_visibility_changed():
	if not is_inside_tree():
		return
	var _mob = OS.has_feature("android") or OS.has_feature("mobile")
	if visible:
		_build_planet_list()
		if not _mob:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if not _mob:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _build_planet_list():
	for child in planet_container.get_children():
		child.queue_free()

	fuel_label.text = "Энергия: %d  (стоимость перелёта: 80)" % int(GameManager.resources.get("energy", 0))

	for i in range(4):
		var row = HBoxContainer.new()

		var info      = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl = Label.new()
		name_lbl.text = PLANET_NAMES[i]
		name_lbl.add_theme_font_size_override("font_size", 18)

		var desc_lbl = Label.new()
		desc_lbl.text = PLANET_DESC[i]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD

		var visit_lbl = Label.new()
		visit_lbl.text    = "✔ Посещена" if GameManager.planets_visited[i] else "Не исследована"
		visit_lbl.modulate = Color.GREEN  if GameManager.planets_visited[i] else Color.GRAY

		info.add_child(name_lbl)
		info.add_child(desc_lbl)
		info.add_child(visit_lbl)

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(130, 60)
		if i == GameManager.current_planet:
			btn.text     = "Вы здесь"
			btn.disabled = true
		else:
			btn.text     = "Лететь\n(80 энергии)"
			btn.disabled = not GameManager.can_afford(TRAVEL_COST)
		var pid = i
		btn.pressed.connect(func():
			if GameManager.spend_resources(TRAVEL_COST):
				GameManager.travel_to_planet(pid)
				_close()
				get_tree().reload_current_scene()
		)

		row.add_child(info)
		row.add_child(btn)

		var sep = HSeparator.new()
		planet_container.add_child(row)
		planet_container.add_child(sep)
