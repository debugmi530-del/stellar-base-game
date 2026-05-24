extends Control

@onready var close_btn: Button           = $Panel/CloseBtn
@onready var planet_container: VBoxContainer = $Panel/ScrollContainer/PlanetList
@onready var fuel_label: Label           = $Panel/FuelLabel

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
	if close_btn:
		close_btn.pressed.connect(func(): _close())
	# Use visibility_changed signal correctly
	visibility_changed.connect(_on_visibility_changed)

func _close():
	visible = false

func _on_visibility_changed():
	if not is_inside_tree():
		return
	if visible:
		_build_planet_list()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _build_planet_list():
	if not planet_container:
		return
	for child in planet_container.get_children():
		child.queue_free()
	if fuel_label:
		fuel_label.text = "Энергия: " + str(int(GameManager.resources.get("energy", 0)))

	for i in range(4):
		var panel = PanelContainer.new()
		var hbox  = HBoxContainer.new()
		panel.add_child(hbox)

		var info      = VBoxContainer.new()
		var name_lbl  = Label.new()
		var desc_lbl  = Label.new()
		var visit_lbl = Label.new()

		name_lbl.text  = PLANET_NAMES[i]
		name_lbl.add_theme_font_size_override("font_size", 20)
		desc_lbl.text  = PLANET_DESC[i]
		visit_lbl.text = "Посещена" if GameManager.planets_visited[i] else "Не исследована"
		visit_lbl.modulate = Color.GREEN if GameManager.planets_visited[i] else Color.GRAY

		info.add_child(name_lbl)
		info.add_child(desc_lbl)
		info.add_child(visit_lbl)
		hbox.add_child(info)

		var btn = Button.new()
		if i == GameManager.current_planet:
			btn.text     = "Текущая"
			btn.disabled = true
		else:
			btn.text     = "Лететь\n(Энергия: 80)"
			btn.disabled = not GameManager.can_afford(TRAVEL_COST)
			var pid = i
			btn.pressed.connect(func():
				if GameManager.spend_resources(TRAVEL_COST):
					GameManager.travel_to_planet(pid)
					_close()
					get_tree().reload_current_scene()
			)
		hbox.add_child(btn)
		planet_container.add_child(panel)
