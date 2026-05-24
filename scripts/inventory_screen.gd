extends Control

@onready var close_btn: Button = $Panel/CloseBtn
@onready var res_grid: GridContainer = $Panel/ScrollContainer/VBoxContainer/ResourceGrid
@onready var objects_list: VBoxContainer = $Panel/ScrollContainer/VBoxContainer/ObjectsList
@onready var playtime_label: Label = $Panel/PlaytimeLabel

const RES_ICONS = {
	"iron": "🔩 Железо",
	"silicon": "💎 Кремний",
	"energy": "⚡ Энергия",
	"oxygen": "💨 Кислород",
	"water": "💧 Вода",
	"titanium": "🔧 Титан",
	"crystal": "🔮 Кристалл"
}

func _ready():
	close_btn.pressed.connect(func(): visible = false)
	GameManager.resources_changed.connect(func():
		if visible: _refresh()
	)
	visible = false

func _on_visibility_changed():
	if visible:
		_refresh()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _refresh():
	for child in res_grid.get_children():
		child.queue_free()
	for res_key in RES_ICONS:
		var name_lbl = Label.new()
		name_lbl.text = RES_ICONS[res_key]
		var val_lbl = Label.new()
		val_lbl.text = str(int(GameManager.resources.get(res_key, 0)))
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		res_grid.add_child(name_lbl)
		res_grid.add_child(val_lbl)
	var secs = int(GameManager.play_time)
	var hours = secs / 3600
	var mins = (secs % 3600) / 60
	playtime_label.text = "Время игры: %02d:%02d" % [hours, mins]
	for child in objects_list.get_children():
		child.queue_free()
	var title = Label.new()
	title.text = "Построено объектов: " + str(GameManager.placed_objects.size())
	objects_list.add_child(title)
