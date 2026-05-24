extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 20.0
const MOUSE_SENSITIVITY = 0.3

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay
@onready var oxygen_timer: Timer = $OxygenTimer
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var suit_audio: AudioStreamPlayer3D = $SuitAudio

var current_speed: float = WALK_SPEED
var oxygen: float = 100.0
var in_base: bool = false
var is_sprinting: bool = false
var footstep_time: float = 0.0
var look_x: float = 0.0
var look_y: float = 0.0
var build_mode: bool = false
var selected_build_item: int = 0

signal oxygen_changed(value)
signal entered_base
signal exited_base
signal interact_with(object)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	oxygen = 100.0
	_update_speed()

func _physics_process(delta):
	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_footsteps(delta)
	_handle_oxygen(delta)
	move_and_slide()

func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func _handle_movement(delta):
	var speed_mult = 1.0 + (GameManager.upgrades.get("suit_speed", 1) - 1) * 0.2
	is_sprinting = Input.is_action_pressed("sprint") and not build_mode
	current_speed = (SPRINT_SPEED if is_sprinting else WALK_SPEED) * speed_mult
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		var jump_mult = 1.0 + (GameManager.upgrades.get("suit_jump", 1) - 1) * 0.15
		velocity.y = JUMP_VELOCITY * jump_mult

func _handle_footsteps(delta):
	if is_on_floor() and velocity.length() > 0.5:
		footstep_time += delta
		var step_rate = 0.45 if is_sprinting else 0.65
		if footstep_time >= step_rate:
			footstep_time = 0.0
			if footstep_player and footstep_player.stream:
				footstep_player.pitch_scale = randf_range(0.9, 1.1)
				footstep_player.play()
	else:
		footstep_time = 0.0

func _handle_oxygen(delta):
	if not in_base:
		var drain_rate = 2.0 / GameManager.upgrades.get("suit_oxygen", 1)
		oxygen -= drain_rate * delta
		oxygen = max(oxygen, 0.0)
		oxygen_changed.emit(oxygen)
		if oxygen <= 0:
			_die()
	else:
		oxygen = min(oxygen + 10.0 * delta, 100.0)
		oxygen_changed.emit(oxygen)

func _die():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var sens = GameManager.settings.get("sensitivity", 0.3)
		var invert = GameManager.settings.get("invert_y", false)
		look_y -= event.relative.x * sens * 0.1
		look_x -= event.relative.y * sens * 0.1 * (-1.0 if invert else 1.0)
		look_x = clamp(look_x, -1.4, 1.4)
		head.rotation.y = look_y
		camera.rotation.x = look_x
	
	if event.is_action_pressed("interact"):
		_try_interact()
	
	if event.is_action_pressed("ui_cancel"):
		if build_mode:
			toggle_build_mode()
		else:
			$"../UI/PauseMenu".toggle_pause()

func _try_interact():
	if interaction_ray.is_colliding():
		var obj = interaction_ray.get_collider()
		if obj.has_method("interact"):
			obj.interact(self)
		interact_with.emit(obj)

func toggle_build_mode():
	build_mode = !build_mode
	$"../UI/BuildMenu".visible = build_mode
	if build_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_in_base(value: bool):
	in_base = value
	if value:
		entered_base.emit()
	else:
		exited_base.emit()
