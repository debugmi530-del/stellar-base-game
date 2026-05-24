extends StaticBody3D

var energy_per_second: float = 2.0
# BUGFIX: был _process каждый кадр → resources_changed каждый кадр перегружал HUD
# Обновление раз в секунду через аккумулятор
var _tick: float = 0.0
const TICK_INTERVAL: float = 1.0

func _process(delta: float):
	_tick += delta
	if _tick >= TICK_INTERVAL:
		var cap  = 500.0 + GameManager.upgrades.get("base_storage", 1) * 200.0
		var rate = energy_per_second * _tick
		GameManager.resources["energy"] = min(
			GameManager.resources.get("energy", 0.0) + rate, cap
		)
		GameManager.resources_changed.emit()
		_tick = 0.0
