extends StaticBody3D

const OXYGEN_PER_SECOND: float = 1.5
const ZONE_RADIUS: float       = 8.0

func _ready():
	var zone = get_node_or_null("OxygenZone")
	if zone and zone.get_child_count() == 0:
		var shape = SphereShape3D.new()
		shape.radius = ZONE_RADIUS
		var cs = CollisionShape3D.new()
		cs.shape = shape
		zone.add_child(cs)

func get_oxygen_contribution() -> float:
	return OXYGEN_PER_SECOND * float(GameManager.upgrades.get("base_power", 1))
