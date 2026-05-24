extends CanvasLayer

@onready var oxygen_bar: ProgressBar = $HUD/OxygenBar
@onready var oxygen_label: Label = $HUD/OxygenLabel
@onready var iron_label: Label = $HUD/Resources/Iron
@onready var silicon_label: Label = $HUD/Resources/Silicon
@onready var energy_label: Label = $HUD/Resources/Energy
@onready var titanium_label: Label = $HUD/Resources/Titanium
@onready var crystal_label: Label = $HUD/Resources/Crystal
@onready var water_label: Label = $HUD/Resources/Water
@onready var planet_label: Label = $HUD/PlanetName
@onready var crosshair: TextureRect = $HUD/Crosshair
@onready var interact_hint: Label = $HUD/InteractHint
@onready var notification_label: Label = $HUD/Notification
@onready var build_btn: Button = $HUD/BuildBtn
@onready var travel_btn: Button = $HUD/TravelBtn
@onready var upgrade_btn: Button = $HUD/UpgradeBtn
@onready var inventory_btn: Button = $HUD/InventoryBtn

var notification_timer: float = 0.0

func _ready():
	GameManager.resources_changed.connect(_update_resources)
	GameManager.planet_changed.connect(_update_planet)
	_update_resources()
	_update_planet(GameManager.current_planet)
	build_btn.pressed.connect(_on_build_pressed)
	travel_btn.pressed.connect(_on_travel_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	inventory_btn.pressed.connect(_on_inventory_pressed)

func _process(delta):
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_label.visible = false

func update_oxygen(value: float):
	if oxygen_bar:
		oxygen_bar.value = value
	if oxygen_label:
		oxygen_label.text = "О2: " + str(int(value)) + "%"
	if value < 25:
		oxygen_bar.modulate = Color.RED
	elif value < 50:
		oxygen_bar.modulate = Color.YELLOW
	else:
		oxygen_bar.modulate = Color.CYAN

func _update_resources():
	var r = GameManager.resources
	if iron_label: iron_label.text = "Fe: " + str(int(r.get("iron",0)))
	if silicon_label: silicon_label.text = "Si: " + str(int(r.get("silicon",0)))
	if energy_label: energy_label.text = "E: " + str(int(r.get("energy",0)))
	if titanium_label: titanium_label.text = "Ti: " + str(int(r.get("titanium",0)))
	if crystal_label: crystal_label.text = "Cr: " + str(int(r.get("crystal",0)))
	if water_label: water_label.text = "H2O: " + str(int(r.get("water",0)))

func _update_planet(planet_id: int):
	var names = ["Марс-Альфа", "Ледяной Европа-7", "Вулканический Ио-X", "Газовый Нептун-Омега"]
	if planet_label:
		planet_label.text = names[planet_id] if planet_id < names.size() else "Неизвестная планета"

func show_notification(text: String, duration: float = 3.0):
	notification_label.text = text
	notification_label.visible = true
	notification_timer = duration

func show_interact_hint(text: String):
	interact_hint.text = text
	interact_hint.visible = true

func hide_interact_hint():
	interact_hint.visible = false

func _on_build_pressed():
	get_tree().current_scene.get_node("Player").toggle_build_mode()

func _on_travel_pressed():
	$TravelScreen.visible = true

func _on_upgrade_pressed():
	$UpgradeScreen.visible = true

func _on_inventory_pressed():
	$InventoryScreen.visible = true
