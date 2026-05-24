extends StaticBody3D

const CONVERT_INTERVAL: float = 10.0
var _timer: float = 0.0

func _process(delta: float):
	if GameManager.upgrades.get("auto_fabricator", 0) < 1:
		return
	_timer += delta
	if _timer >= CONVERT_INTERVAL:
		_timer = 0.0
		_convert()

func _convert():
	# iron + silicon → titanium
	var cost = {"iron": 20, "silicon": 15}
	if GameManager.spend_resources(cost):
		GameManager.add_resource("titanium", 5.0)
