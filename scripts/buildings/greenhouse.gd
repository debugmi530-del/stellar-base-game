extends StaticBody3D

const RATE: float = 0.3

func _process(delta: float):
	GameManager.add_resource("oxygen", RATE * delta)
	GameManager.add_resource("water",  RATE * 0.5 * delta)
