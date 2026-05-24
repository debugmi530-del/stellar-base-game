extends StaticBody3D

var craft_interval: float = 10.0
var timer: float = 0.0
var active: bool = true

const AUTO_RECIPES = [
	{"cost": {"iron": 5, "silicon": 3}, "gives": {"titanium": 2}},
	{"cost": {"silicon": 10, "energy": 20}, "gives": {"crystal": 1}},
]

var current_recipe: int = 0

func _process(delta):
	if not active:
		return
	timer += delta
	if timer >= craft_interval:
		timer = 0.0
		_auto_craft()

func _auto_craft():
	var recipe = AUTO_RECIPES[current_recipe]
	if GameManager.can_afford(recipe["cost"]):
		GameManager.spend_resources(recipe["cost"])
		for res in recipe["gives"]:
			GameManager.add_resource(res, recipe["gives"][res])

func interact(_player):
	current_recipe = (current_recipe + 1) % AUTO_RECIPES.size()
	active = !active
