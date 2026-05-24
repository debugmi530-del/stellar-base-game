extends StaticBody3D

var produce_interval: float = 30.0
var timer: float = 0.0

func _process(delta):
	if GameManager.resources.get("water", 0) > 5:
		timer += delta
		if timer >= produce_interval:
			timer = 0.0
			GameManager.resources["water"] -= 5
			GameManager.add_resource("oxygen", 20)
			GameManager.add_resource("water", 3)

func interact(_player):
	pass
