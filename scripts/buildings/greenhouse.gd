extends StaticBody3D

const RATE: float = 0.3
# BUGFIX: был _process каждый кадр → resources_changed каждый кадр перегружал HUD
# Теперь обновление раз в секунду через аккумулятор
var _tick: float = 0.0
const TICK_INTERVAL: float = 1.0

func _process(delta: float):
	_tick += delta
	if _tick >= TICK_INTERVAL:
		GameManager.add_resource("oxygen", RATE * _tick)
		GameManager.add_resource("water",  RATE * 0.5 * _tick)
		_tick = 0.0
