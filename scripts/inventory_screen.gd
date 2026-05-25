extends Control
# Экран инвентаря — UI создаётся программно (не требует .tscn)

var res_grid: GridContainer    = null
var objects_list: VBoxContainer = null
var playtime_label: Label      = null
var close_btn: Button          = null

const RES_NAMES = {
	"iron":     "Железо",
	"silicon":  "Кремний",
	"energy":   "Энергия",
	"oxygen":   "Кислород",
	"water":    "Вода",
	"titanium": "Титан",
	"crystal":  "Кристалл"
}

func _ready():
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 560)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Инвентарь"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	playtime_label = Label.new()
	playtime_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(playtime_label)

	var sep1 = HSeparator.new()
	vbox.add_child(sep1)

	var res_title = Label.new()
	res_title.text = "Ресурсы:"
	res_title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(res_title)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(460, 300)
	vbox.add_child(scroll)

	var scroll_vbox = VBoxContainer.new()
	scroll.add_child(scroll_vbox)

	res_grid = GridContainer.new()
	res_grid.columns = 2
	res_grid.add_theme_constant_override("h_separation", 20)
	res_grid.add_theme_constant_override("v_separation", 4)
	scroll_vbox.add_child(res_grid)

	var sep2 = HSeparator.new()
	scroll_vbox.add_child(sep2)

	objects_list = VBoxContainer.new()
	scroll_vbox.add_child(objects_list)

	close_btn = Button.new()
	close_btn.text = "Закрыть"
	close_btn.pressed.connect(func(): visible = false)
	vbox.add_child(close_btn)

	visibility_changed.connect(_on_visibility_changed)
	GameManager.resources_changed.connect(func():
		if visible: _refresh()
	)

func _on_visibility_changed():
	if not is_inside_tree():
		return
	var _mob = OS.has_feature("android") or OS.has_feature("mobile")
	if visible:
		_refresh()
		if not _mob:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if not _mob:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _refresh():
	# Ресурсы
	for child in res_grid.get_children():
		child.queue_free()

	for res_key in RES_NAMES:
		var name_lbl = Label.new()
		name_lbl.text = RES_NAMES[res_key]

		var val_lbl  = Label.new()
		val_lbl.text = str(int(GameManager.resources.get(res_key, 0)))
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		res_grid.add_child(name_lbl)
		res_grid.add_child(val_lbl)

	# Время игры
	var secs  = int(GameManager.play_time)
	var hours = secs / 3600
	var mins  = (secs % 3600) / 60
	playtime_label.text = "Время игры: %02d:%02d" % [hours, mins]

	# Построенные объекты
	for child in objects_list.get_children():
		child.queue_free()

	var built_lbl = Label.new()
	built_lbl.text = "Построено объектов: %d" % GameManager.placed_objects.size()
	objects_list.add_child(built_lbl)

	var placed_counts: Dictionary = {}
	for obj in GameManager.placed_objects:
		var t = obj.get("type", "?")
		placed_counts[t] = placed_counts.get(t, 0) + 1

	for btype in placed_counts:
		var lbl = Label.new()
		var bname = BuildSystem.BUILDABLES.get(btype, {}).get("name", btype)
		lbl.text = "  • %s × %d" % [bname, placed_counts[btype]]
		objects_list.add_child(lbl)
