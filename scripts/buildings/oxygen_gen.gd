extends StaticBody3D

const OXYGEN_PER_SECOND: float = 1.5
const ZONE_RADIUS: float       = 8.0

func _ready():
	var zone = get_node_or_null("OxygenZone")
	if zone:
		# BUGFIX: подключаем сигналы для обнаружения игрока в зоне кислорода.
		# Без этого player.in_base никогда не становится true → O2 никогда
		# не пополняется → игрок умирает через ~50 секунд неизбежно.
		if not zone.body_entered.is_connected(_on_player_entered):
			zone.body_entered.connect(_on_player_entered)
		if not zone.body_exited.is_connected(_on_player_exited):
			zone.body_exited.connect(_on_player_exited)

func _on_player_entered(body: Node3D) -> void:
	if body.has_method("set_in_base"):
		body.set_in_base(true)

func _on_player_exited(body: Node3D) -> void:
	if body.has_method("set_in_base"):
		body.set_in_base(false)

func get_oxygen_contribution() -> float:
	return OXYGEN_PER_SECOND * float(GameManager.upgrades.get("base_power", 1))
