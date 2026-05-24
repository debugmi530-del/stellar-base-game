extends StaticBody3D

const MINE_INTERVAL: float = 5.0
const MINE_RADIUS: float   = 4.0

var _timer: float = 0.0

func _process(delta: float):
	if GameManager.upgrades.get("auto_miner", 0) < 1:
		return
	_timer += delta
	if _timer >= MINE_INTERVAL:
		_timer = 0.0
		_do_mine()

func _do_mine():
	var space = get_world_3d().direct_space_state
	var query  = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = MINE_RADIUS
	query.shape         = sphere
	query.transform     = global_transform
	query.collision_mask = 1
	var results = space.intersect_shape(query)
	for r in results:
		var body = r.get("collider")
		if body and body.has_method("interact"):
			body.interact(null)
			break
