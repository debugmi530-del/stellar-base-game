extends Control
# Экран улучшений — UI создаётся программно (не требует .tscn)

var upgrade_grid: GridContainer = null
var close_btn: Button           = null

const UPGRADE_CATEGORIES = {
	"Скафандр":     ["suit_oxygen", "suit_speed", "suit_jump"],
	"База":          ["base_power", "base_storage"],
	"Автоматизация": ["auto_miner", "auto_fabricator", "auto_solar"],
	"Корабль":       ["ship_fuel", "scanner"]
}

const UPGRADE_NAMES = {
	"suit_oxygen":     "Кислородный бак",
	"suit_speed":      "Двигатели скафандра",
	"suit_jump":       "Прыжковые ускорители",
	"base_power":      "Базовый реактор",
	"base_storage":    "Склады базы",
	"auto_miner":      "Авто-шахтёр",
	"auto_fabricator": "Авто-фабрикатор",
	"auto_solar":      "Авто-солнечные панели",
	"ship_fuel":       "Топливные баки корабля",
	"scanner":         "Сканер ресурсов"
}

const UPGRADE_DESC = {
	"suit_oxygen":     "Увеличивает запас и скорость восполнения кислорода",
	"suit_speed":      "Увеличивает скорость передвижения",
	"suit_jump":       "Увеличивает высоту прыжка",
	"base_power":      "Повышает мощность базы",
	"base_storage":    "Увеличивает максимальный запас ресурсов",
	"auto_miner":      "Автоматически добывает ресурсы",
	"auto_fabricator": "Автоматически создаёт предметы",
	"auto_solar":      "Автоматически генерирует энергию",
	"ship_fuel":       "Увеличивает дальность перелётов",
	"scanner":         "Увеличивает добычу ресурсов"
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
	panel.custom_minimum_size = Vector2(560, 620)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Дерево улучшений"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 520)
	vbox.add_child(scroll)

	var scroll_vbox = VBoxContainer.new()
	scroll_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(scroll_vbox)

	upgrade_grid = GridContainer.new()
	upgrade_grid.columns = 2
	upgrade_grid.add_theme_constant_override("h_separation", 8)
	upgrade_grid.add_theme_constant_override("v_separation", 6)
	scroll_vbox.add_child(upgrade_grid)

	close_btn = Button.new()
	close_btn.text = "Закрыть"
	close_btn.pressed.connect(func(): visible = false)
	vbox.add_child(close_btn)

	GameManager.upgrades_changed.connect(_build_ui)
	_build_ui()

func _build_ui():
	if not upgrade_grid:
		return
	for child in upgrade_grid.get_children():
		child.queue_free()

	for category in UPGRADE_CATEGORIES:
		var cat_lbl = Label.new()
		cat_lbl.text = "── %s ──" % category
		cat_lbl.add_theme_font_size_override("font_size", 16)
		upgrade_grid.add_child(cat_lbl)
		# Пустой разделитель для второй колонки
		upgrade_grid.add_child(Control.new())

		for upg_id in UPGRADE_CATEGORIES[category]:
			_add_upgrade_row(upg_id)

func _add_upgrade_row(upg_id: String):
	var level     = GameManager.upgrades.get(upg_id, 0)
	var base_cost = GameManager.upgrade_costs.get(upg_id, {})
	var actual_cost: Dictionary = {}
	for res in base_cost:
		actual_cost[res] = int(base_cost[res] * pow(1.5, level))
	var can_afford = GameManager.can_afford(actual_cost)

	var cost_str = ""
	for res in actual_cost:
		cost_str += "%s:%d  " % [res, actual_cost[res]]

	var btn = Button.new()
	btn.text = "%s\nУр.%d  %s" % [UPGRADE_NAMES.get(upg_id, upg_id), level, cost_str]
	btn.custom_minimum_size = Vector2(240, 72)
	btn.disabled            = not can_afford
	btn.tooltip_text        = UPGRADE_DESC.get(upg_id, "")
	btn.pressed.connect(func():
		if GameManager.upgrade(upg_id):
			_build_ui()
	)
	upgrade_grid.add_child(btn)

	var desc = Label.new()
	desc.text         = UPGRADE_DESC.get(upg_id, "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_grid.add_child(desc)
