extends StaticBody3D

var scan_radius: float = 50.0
var active: bool = true

func _ready():
	scan_radius = 50.0 * GameManager.upgrades.get("scanner", 1)

func interact(_player):
	active = !active
	if active:
		_scan_area()

func _scan_area():
	var space = get_world_3d().direct_space_state
	for node in get_tree().get_nodes_in_group("resources"):
		if global_position.distance_to(node.global_position) < scan_radius:
			node.visible = true
