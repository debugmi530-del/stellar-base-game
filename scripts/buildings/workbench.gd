extends StaticBody3D

func interact(_player) -> void:
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		var upg = ui.get_node_or_null("UpgradeScreen")
		if upg:
			upg.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
