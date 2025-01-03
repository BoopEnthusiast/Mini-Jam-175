class_name Player
extends CharacterBody2D


const SPEED = 300.0
const ACCEL = 70.0
const JUMP_VELOCITY = -400.0

var was_on_floor := false
var has_double_jumped := false
var has_pressed_jump := false

@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer


func _enter_tree() -> void:
	Singleton.player = self


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if was_on_floor:
			coyote_time.start()
	else:
		has_double_jumped = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump_spawn"):
		if is_on_floor() or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY
		elif not has_double_jumped:
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
		elif not jump_buffer.is_stopped() and is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			jump_buffer.start()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
