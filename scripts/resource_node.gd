extends StaticBody3D

@export var resource_type: String = "iron"
@export var max_amount: float = 500.0
@export var mine_rate: float = 10.0
@export var respawn_time: float = 120.0

var current_amount: float
var is_depleted: bool = false
var respawn_timer: float = 0.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D
@onready var particles: GPUParticles3D = $MineParticles

signal mined(type, amount)

func _ready():
	current_amount = max_amount
	_update_label()

func _process(delta):
	if is_depleted:
		respawn_timer += delta
		if respawn_timer >= respawn_time:
			respawn()

func interact(player):
	if is_depleted:
		return
	var scan_bonus = GameManager.upgrades.get("scanner", 1)
	var amount = mine_rate * scan_bonus
	amount = min(amount, current_amount)
	current_amount -= amount
	GameManager.add_resource(resource_type, amount)
	mined.emit(resource_type, amount)
	if particles:
		particles.emitting = true
	_update_label()
	if current_amount <= 0:
		_deplete()

func _deplete():
	is_depleted = true
	respawn_timer = 0.0
	if mesh:
		mesh.visible = false
	_update_label()

func respawn():
	is_depleted = false
	current_amount = max_amount
	respawn_timer = 0.0
	if mesh:
		mesh.visible = true
	_update_label()

func _update_label():
	if label:
		if is_depleted:
			label.text = "Истощено"
		else:
			var res_names = {"iron":"Железо","silicon":"Кремний","titanium":"Титан","crystal":"Кристалл","water":"Вода"}
			label.text = res_names.get(resource_type, resource_type) + "\n" + str(int(current_amount))
