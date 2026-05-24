extends CanvasLayer
# Virtual joystick and buttons for mobile

@onready var left_stick: Control = $LeftStick
@onready var right_stick: Control = $RightStick
@onready var jump_btn: Button = $JumpBtn
@onready var interact_btn: Button = $InteractBtn
@onready var sprint_btn: Button = $SprintBtn
@onready var build_btn: Button = $BuildBtn

var left_active: bool = false
var left_origin: Vector2 = Vector2.ZERO
var left_current: Vector2 = Vector2.ZERO
var right_active: bool = false
var right_origin: Vector2 = Vector2.ZERO
var right_current: Vector2 = Vector2.ZERO

const DEAD_ZONE = 20.0
const MAX_RADIUS = 80.0

func _ready():
	jump_btn.pressed.connect(func(): Input.action_press("jump"))
	jump_btn.button_up.connect(func(): Input.action_release("jump"))
	interact_btn.pressed.connect(func(): Input.action_press("interact"))
	sprint_btn.pressed.connect(func():
		if Input.is_action_pressed("sprint"):
			Input.action_release("sprint")
		else:
			Input.action_press("sprint")
	)

func _input(event):
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch):
	var screen_size = get_viewport().get_visible_rect().size
	if event.pressed:
		if event.position.x < screen_size.x * 0.4:
			left_active = true
			left_origin = event.position
			left_current = event.position
		elif event.position.x > screen_size.x * 0.6:
			right_active = true
			right_origin = event.position
			right_current = event.position
	else:
		if event.position.x < screen_size.x * 0.5:
			left_active = false
			Input.action_release("move_forward")
			Input.action_release("move_back")
			Input.action_release("move_left")
			Input.action_release("move_right")
		else:
			right_active = false

func _handle_drag(event: InputEventScreenDrag):
	var screen_size = get_viewport().get_visible_rect().size
	if event.position.x < screen_size.x * 0.5 and left_active:
		left_current = event.position
		var delta = left_current - left_origin
		if delta.length() > DEAD_ZONE:
			delta = delta.normalized() * min(delta.length(), MAX_RADIUS)
			_apply_movement(delta / MAX_RADIUS)
	elif event.position.x > screen_size.x * 0.5 and right_active:
		right_current = event.position
		var delta = right_current - right_origin
		if delta.length() > DEAD_ZONE:
			_apply_camera(delta * 0.01)

func _apply_movement(dir: Vector2):
	Input.action_release("move_forward")
	Input.action_release("move_back")
	Input.action_release("move_left")
	Input.action_release("move_right")
	if dir.y < -0.2: Input.action_press("move_forward")
	if dir.y > 0.2: Input.action_press("move_back")
	if dir.x < -0.2: Input.action_press("move_left")
	if dir.x > 0.2: Input.action_press("move_right")

func _apply_camera(delta: Vector2):
	# Camera look handled by mouse motion simulation
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		var evt = InputEventMouseMotion.new()
		evt.relative = delta * 50
		Input.parse_input_event(evt)
