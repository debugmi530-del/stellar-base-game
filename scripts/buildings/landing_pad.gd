extends StaticBody3D

var is_ship_present: bool = true

func interact(_player):
	# BUGFIX: был get_node с хардкодным путём "UI/HUD/TravelScreen" → краш
	# TravelScreen — сиблинг HUD, путь "UI/TravelScreen"
	var travel = get_tree().current_scene.get_node_or_null("UI/TravelScreen")
	if travel:
		travel.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# Запасной вариант: ищем через HUD
		var hud = get_tree().current_scene.get_node_or_null("UI/HUD")
		if hud and hud.has_method("show_notification"):
			hud.show_notification("Посадочная площадка готова к вылету", 2.0)
