extends CharacterBody3D

# 1. Variables and Constants at the top
const SPEED = 5.5
const JUMP_VELOCITY = 8.0
const GRAVITY = 20.0

var can_move : bool = true
var respawn_position : Vector3

# 2. Onready variables (Must be above _ready)
@onready var countdown_label = $CanvasLayer/CountdownLabel 

# 3. Built-in Godot functions
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	respawn_position = global_position
	if countdown_label:
		countdown_label.hide() # Hide the UI at start

func _unhandled_input(event):
	# Mouse Look
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		$Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x, -60.0, 60.0)
	
	# Unlock Mouse
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# If player fell off the map
	if global_position.y < -15.0:
		respawn()

	# If frozen for countdown, still apply gravity but stop movement logic
	if not can_move:
		velocity.y -= GRAVITY * delta
		move_and_slide()
		return 

	# Movement Logic
	var input_direction_2D = Input.get_vector("move_right", "move_left", "move_back", "move_front")
	var input_direction_3D = Vector3(input_direction_2D.x, 0.0, input_direction_2D.y)
	var direction = transform.basis * input_direction_3D

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# Gravity and Jumping
	velocity.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

# 4. Custom functions
func respawn():
	global_position = respawn_position
	velocity = Vector3.ZERO
	can_move = false
	
	if countdown_label:
		countdown_label.show()
		# Countdown loop
		for i in range(3, 0, -1):
			countdown_label.text = str(i)
			await get_tree().create_timer(1.0).timeout
		
		countdown_label.text = "GO!"
	
	can_move = true # Enable controls
	
	await get_tree().create_timer(0.5).timeout
	if countdown_label:
		countdown_label.hide()
