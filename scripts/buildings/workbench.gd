extends StaticBody3D

const RECIPES = {
	"battery": {"cost": {"silicon": 20, "iron": 10}, "gives": {"energy": 100}},
	"o2_canister": {"cost": {"silicon": 15, "water": 20}, "gives": {"oxygen": 50}},
	"titanium_plate": {"cost": {"iron": 30, "energy": 20}, "gives": {"titanium": 15}},
	"crystal_lens": {"cost": {"crystal": 5, "silicon": 30}, "gives": {"crystal": 8}},
	"fuel_cell": {"cost": {"iron": 20, "silicon": 20, "energy": 50}, "gives": {"energy": 300}},
}

signal craft_complete(item, amount)

func interact(_player):
	# Opens crafting UI - handled by UI system
	get_tree().current_scene.get_node("UI/HUD").get_node("CraftingPanel").visible = true

func craft(recipe_name: String) -> bool:
	if not RECIPES.has(recipe_name):
		return false
	var recipe = RECIPES[recipe_name]
	if not GameManager.spend_resources(recipe["cost"]):
		return false
	for res in recipe["gives"]:
		GameManager.add_resource(res, recipe["gives"][res])
	craft_complete.emit(recipe_name, recipe["gives"])
	return true
