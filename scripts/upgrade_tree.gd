extends Control

@onready var upgrade_grid: GridContainer = $Panel/ScrollContainer/VBoxContainer/UpgradeGrid
@onready var close_btn: Button = $Panel/CloseBtn
@onready var info_label: Label = $Panel/InfoLabel

const UPGRADE_CATEGORIES = {
	"Скафандр": ["suit_oxygen", "suit_speed", "suit_jump"],
	"База": ["base_power", "base_storage"],
	"Автоматизация": ["auto_miner", "auto_fabricator", "auto_solar"],
	"Корабль": ["ship_fuel", "scanner"]
}

const UPGRADE_NAMES = {
	"suit_oxygen": "Кислородный бак",
	"suit_speed": "Двигатели скафандра",
	"suit_jump": "Прыжковые ускорители",
	"base_power": "Базовый реактор",
	"base_storage": "Склады базы",
	"auto_miner": "Авто-шахтёр",
	"auto_fabricator": "Авто-фабрикатор",
	"auto_solar": "Авто-солнечная панель",
	"ship_fuel": "Топливные баки корабля",
	"scanner": "Сканер ресурсов"
}

const UPGRADE_DESC = {
	"suit_oxygen": "Увеличивает запас кислорода и скорость восполнения",
	"suit_speed": "Увеличивает скорость передвижения",
	"suit_jump": "Увеличивает высоту прыжка",
	"base_power": "Повышает мощность базы",
	"base_storage": "Увеличивает максимальный запас ресурсов",
	"auto_miner": "Автоматически добывает ресурсы",
	"auto_fabricator": "Автоматически создаёт предметы",
	"auto_solar": "Автоматически генерирует энергию",
	"ship_fuel": "Увеличивает дальность перелётов",
	"scanner": "Показывает больше ресурсов, увеличивает добычу"
}

func _ready():
	close_btn.pressed.connect(func(): visible = false)
	GameManager.upgrades_changed.connect(_refresh)
	visible = false

func _refresh():
	_build_ui()

func _build_ui():
	for child in upgrade_grid.get_children():
		child.queue_free()
	for category in UPGRADE_CATEGORIES:
		var cat_label = Label.new()
		cat_label.text = "── " + category + " ──"
		cat_label.add_theme_font_size_override("font_size", 18)
		upgrade_grid.add_child(cat_label)
		var spacer = Control.new()
		upgrade_grid.add_child(spacer)
		for upg_id in UPGRADE_CATEGORIES[category]:
			_add_upgrade_button(upg_id)

func _add_upgrade_button(upg_id: String):
	var level = GameManager.upgrades.get(upg_id, 0)
	var base_cost = GameManager.upgrade_costs.get(upg_id, {})
	var actual_cost = {}
	for res in base_cost:
		actual_cost[res] = int(base_cost[res] * pow(1.5, level))
	var can_afford = GameManager.can_afford(actual_cost)
	
	var btn = Button.new()
	var name_str = UPGRADE_NAMES.get(upg_id, upg_id)
	var cost_str = ""
	for res in actual_cost:
		cost_str += res + ":" + str(actual_cost[res]) + " "
	btn.text = name_str + "\nУровень: " + str(level) + "\n" + cost_str
	btn.custom_minimum_size = Vector2(200, 80)
	btn.disabled = not can_afford
	btn.tooltip_text = UPGRADE_DESC.get(upg_id, "")
	btn.pressed.connect(func():
		if GameManager.upgrade(upg_id):
			_build_ui()
	)
	upgrade_grid.add_child(btn)
	
	var desc = Label.new()
	desc.text = UPGRADE_DESC.get(upg_id, "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	upgrade_grid.add_child(desc)
