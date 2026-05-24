extends StaticBody3D

var o2_per_second: float = 3.0
var power_needed: float = 2.0
var in_base_zone: bool = true

@onready var area: Area3D = $OxygenZone

func _ready():
	o2_per_second = 3.0 * GameManager.upgrades.get("base_power", 1)
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _process(delta):
	if GameManager.resources.get("energy", 0) >= power_needed * delta:
		GameManager.resources["energy"] -= power_needed * delta
		# Oxygenate area - handled by player proximity check

func _on_body_entered(body):
	if body.has_method("set_in_base"):
		body.set_in_base(true)

func _on_body_exited(body):
	if body.has_method("set_in_base"):
		body.set_in_base(false)
