extends StaticBody3D

func interact(_player) -> void:
	# Antenna boosts scanner temporarily
	var hud_layer = get_tree().current_scene.get_node_or_null("UI")
	if hud_layer:
		var hud = hud_layer.get_node_or_null("HUD")
		if hud and hud.has_method("show_notification"):
			hud.show_notification("Антенна активна: сканер усилен!", 5.0)
