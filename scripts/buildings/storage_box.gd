extends StaticBody3D

var bonus_storage: float = 200.0

func _ready():
	_apply_storage_bonus()

func _apply_storage_bonus():
	pass

func interact(_player):
	get_tree().current_scene.get_node("UI/HUD/InventoryScreen").visible = true
