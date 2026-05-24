extends StaticBody3D

var energy_per_second: float = 5.0
var is_active: bool = true

func _ready():
	energy_per_second = 5.0 * GameManager.upgrades.get("auto_solar", 1)

func _process(delta):
	if is_active:
		GameManager.add_resource("energy", energy_per_second * delta)

func interact(_player):
	is_active = !is_active
