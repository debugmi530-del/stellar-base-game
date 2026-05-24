extends StaticBody3D

var energy_per_second: float = 2.0

func _process(delta: float):
	var cap  = 500.0 + GameManager.upgrades.get("base_storage", 1) * 200.0
	var rate = energy_per_second * delta
	GameManager.resources["energy"] = min(
		GameManager.resources.get("energy", 0.0) + rate, cap
	)
	GameManager.resources_changed.emit()
