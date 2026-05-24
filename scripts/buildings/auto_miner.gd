extends StaticBody3D

var mine_interval: float = 5.0
var timer: float = 0.0
var resource_type: String = "iron"
var amount_per_cycle: float = 15.0

@onready var particles: GPUParticles3D = $Particles
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	amount_per_cycle = 15.0 * GameManager.upgrades.get("auto_miner", 1)
	if anim:
		anim.play("working")

func _process(delta):
	timer += delta
	if timer >= mine_interval:
		timer = 0.0
		_mine()

func _mine():
	GameManager.add_resource(resource_type, amount_per_cycle)
	if particles:
		particles.emitting = true

func interact(_player):
	var types = ["iron", "silicon", "titanium", "crystal"]
	var idx = types.find(resource_type)
	resource_type = types[(idx + 1) % types.size()]
