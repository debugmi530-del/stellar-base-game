extends CanvasLayer

@onready var oxygen_bar: ProgressBar    = $HUD/OxygenBar
@onready var oxygen_label: Label        = $HUD/OxygenLabel
@onready var iron_label: Label          = $HUD/Resources/Iron
@onready var silicon_label: Label       = $HUD/Resources/Silicon
@onready var energy_label: Label        = $HUD/Resources/Energy
@onready var titanium_label: Label      = $HUD/Resources/Titanium
@onready var crystal_label: Label       = $HUD/Resources/Crystal
@onready var water_label: Label         = $HUD/Resources/Water
@onready var planet_label: Label        = $HUD/PlanetName
@onready var interact_hint: Label       = $HUD/InteractHint
@onready var notification_label: Label  = $HUD/Notification
@onready var build_btn: Button          = $HUD/BuildBtn
@onready var travel_btn: Button         = $HUD/TravelBtn
@onready var upgrade_btn: Button        = $HUD/UpgradeBtn
@onready var inventory_btn: Button      = $HUD/InventoryBtn

# Sub-screens live as siblings under UI CanvasLayer, not under HUD Control
var travel_screen: Control   = null
var upgrade_screen: Control  = null
var inventory_screen: Control = null

var notification_timer: float = 0.0

func _ready():
	GameManager.resources_changed.connect(_update_resources)
	GameManager.planet_changed.connect(_update_planet)
	_update_resources()
	_update_planet(GameManager.current_planet)
	if build_btn:    build_btn.pressed.connect(_on_build_pressed)
	if travel_btn:   travel_btn.pressed.connect(_on_travel_pressed)
	if upgrade_btn:  upgrade_btn.pressed.connect(_on_upgrade_pressed)
	if inventory_btn:inventory_btn.pressed.connect(_on_inventory_pressed)
	# Cache sibling screens (added by game_world.tscn under UI CanvasLayer)
	await get_tree().process_frame
	travel_screen    = get_node_or_null("TravelScreen")
	upgrade_screen   = get_node_or_null("UpgradeScreen")
	inventory_screen = get_node_or_null("InventoryScreen")

func _process(delta):
	if notification_timer > 0:
		notification_timer -= delta
		if notification_timer <= 0 and notification_label:
			notification_label.visible = false

func update_oxygen(value: float):
	if oxygen_bar:
		oxygen_bar.value = value
		if value < 25:
			oxygen_bar.modulate = Color.RED
		elif value < 50:
			oxygen_bar.modulate = Color.YELLOW
		else:
			oxygen_bar.modulate = Color.CYAN
	if oxygen_label:
		oxygen_label.text = "О2: " + str(int(value)) + "%"

func _update_resources():
	var r = GameManager.resources
	if iron_label:     iron_label.text     = "Fe: "  + str(int(r.get("iron",0)))
	if silicon_label:  silicon_label.text  = "Si: "  + str(int(r.get("silicon",0)))
	if energy_label:   energy_label.text   = "E: "   + str(int(r.get("energy",0)))
	if titanium_label: titanium_label.text = "Ti: "  + str(int(r.get("titanium",0)))
	if crystal_label:  crystal_label.text  = "Cr: "  + str(int(r.get("crystal",0)))
	if water_label:    water_label.text    = "H2O: " + str(int(r.get("water",0)))

func _update_planet(planet_id: int):
	const NAMES = ["Марс-Альфа","Ледяной Европа-7","Вулканический Ио-X","Газовый Нептун-Омега"]
	if planet_label:
		planet_label.text = NAMES[planet_id] if planet_id < NAMES.size() else "Неизвестная планета"

func show_notification(text: String, duration: float = 3.0):
	if notification_label:
		notification_label.text    = text
		notification_label.visible = true
		notification_timer = duration

func show_interact_hint(text: String):
	if interact_hint:
		interact_hint.text    = text
		interact_hint.visible = true

func hide_interact_hint():
	if interact_hint:
		interact_hint.visible = false

func _on_build_pressed():
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and player.has_method("toggle_build_mode"):
		player.toggle_build_mode()

func _on_travel_pressed():
	if travel_screen:
		travel_screen.visible = true

func _on_upgrade_pressed():
	if upgrade_screen:
		upgrade_screen.visible = true

func _on_inventory_pressed():
	if inventory_screen:
		inventory_screen.visible = true
