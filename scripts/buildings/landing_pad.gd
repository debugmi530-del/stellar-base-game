extends StaticBody3D

var is_ship_present: bool = true

func interact(_player):
	get_tree().current_scene.get_node("UI/HUD/TravelScreen").visible = true
