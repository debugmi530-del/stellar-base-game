extends CharacterBody3D

const WALK_SPEED    = 5.0
const SPRINT_SPEED  = 8.0
const JUMP_VELOCITY = 4.5
const GRAVITY       = 18.0

@onready var camera: Camera3D               = $Head/Camera3D
@onready var head: Node3D                   = $Head
@onready var interaction_ray: RayCast3D     = $Head/Camera3D/InteractionRay
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

var current_speed: float  = WALK_SPEED
var oxygen: float         = 100.0
var in_base: bool         = false
var is_sprinting: bool    = false
var footstep_time: float  = 0.0
var look_x: float         = 0.0
var look_y: float         = 0.0
var build_mode: bool      = false

var _interact_cooldown: float = 0.0
var _oxygen_tick: float       = 0.0

signal oxygen_changed(value)
signal entered_base
signal exited_base

# BUGFIX: кэшируем флаг мобильного устройства — убирает лишние OS.has_feature() вызовы
var _is_mobile: bool = false

func _ready():
	_is_mobile = OS.has_feature("android") or OS.has_feature("mobile")
	# BUGFIX: на Android MOUSE_MODE_CAPTURED игнорируется системой — не вызываем
	if not _is_mobile:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	oxygen = 100.0
	camera.add_to_group("player_camera")
	var preset = PerformanceManager.get_preset()
	camera.far = preset.get("view_distance", 60.0)

func _physics_process(delta):
	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_footsteps(delta)
	move_and_slide()

	_oxygen_tick += delta
	if _oxygen_tick >= 0.1:
		_handle_oxygen(_oxygen_tick)
		_oxygen_tick = 0.0

	if _interact_cooldown > 0.0:
		_interact_cooldown -= delta

func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func _handle_movement(delta):
	var speed_mult = 1.0 + (GameManager.upgrades.get("suit_speed", 1) - 1) * 0.2
	is_sprinting   = Input.is_action_pressed("sprint") and not build_mode
	current_speed  = (SPRINT_SPEED if is_sprinting else WALK_SPEED) * speed_mult

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		var friction = current_speed * 8.0
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		var jm = 1.0 + (GameManager.upgrades.get("suit_jump", 1) - 1) * 0.15
		velocity.y = JUMP_VELOCITY * jm

func _handle_footsteps(delta):
	if is_on_floor() and velocity.length() > 1.0:
		footstep_time += delta
		var rate = 0.42 if is_sprinting else 0.60
		if footstep_time >= rate:
			footstep_time = 0.0
			if footstep_player and footstep_player.stream:
				footstep_player.pitch_scale = randf_range(0.88, 1.12)
				footstep_player.play()
	else:
		footstep_time = 0.0

func _handle_oxygen(dt: float):
	if not in_base:
		var drain = 2.0 / float(GameManager.upgrades.get("suit_oxygen", 1))
		oxygen = max(0.0, oxygen - drain * dt)
		oxygen_changed.emit(oxygen)
		if oxygen <= 0:
			_die()
	else:
		oxygen = min(100.0, oxygen + 15.0 * dt)
		oxygen_changed.emit(oxygen)

func _die():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _input(event):
	# BUGFIX: на Android get_mouse_mode() никогда не возвращает CAPTURED
	# — разрешаем MouseMotion всегда на мобиле (touch симулирует его через mobile_input.gd)
	if event is InputEventMouseMotion and (
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or _is_mobile):
		var sens   = GameManager.settings.get("sensitivity", 0.3)
		var invert = GameManager.settings.get("invert_y", false)
		look_y -= event.relative.x * sens * 0.1
		look_x -= event.relative.y * sens * 0.1 * (-1.0 if invert else 1.0)
		look_x = clamp(look_x, -1.4, 1.4)
		head.rotation.y   = look_y
		camera.rotation.x = look_x

	if event.is_action_pressed("interact") and _interact_cooldown <= 0.0:
		_try_interact()
		_interact_cooldown = 0.3

	if event.is_action_pressed("ui_cancel"):
		if build_mode:
			toggle_build_mode()
		else:
			var pause = get_node_or_null("../UI/PauseMenu")
			if pause:
				pause.toggle_pause()

func _try_interact():
	if interaction_ray.is_colliding():
		var obj = interaction_ray.get_collider()
		if obj and obj.has_method("interact"):
			obj.interact(self)

func toggle_build_mode():
	build_mode = not build_mode
	var build_ui = get_node_or_null("../UI/HUD/BuildMenu")
	if build_ui:
		build_ui.visible = build_mode
	# BUGFIX: на мобиле не трогаем mouse_mode — управление только через touch
	if not _is_mobile:
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if build_mode else Input.MOUSE_MODE_CAPTURED
		)

func set_in_base(value: bool):
	in_base = value
	if value: entered_base.emit()
	else:      exited_base.emit()
