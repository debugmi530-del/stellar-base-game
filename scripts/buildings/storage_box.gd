extends StaticBody3D

func interact(_player) -> void:
	var ui = get_tree().current_scene.get_node_or_null("UI")
	if ui:
		var inv = ui.get_node_or_null("InventoryScreen")
		if inv:
			inv.visible = true
	# BUGFIX: не меняем mouse_mode на Android
	if not (OS.has_feature("android") or OS.has_feature("mobile")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
