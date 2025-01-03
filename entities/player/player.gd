extends CharacterBody2D


const SPEED = 300.0
const ACCEL = 100.0

const JUMP_VELOCITY = -400.0

var was_on_floor: bool = false
var has_double_jumped: bool = false

@onready var coyote_time: Timer = $CoyoteTime


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if was_on_floor:
			coyote_time.start()
	else:
		has_double_jumped = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY
		elif not has_double_jumped:
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	move_and_slide()
	
	was_on_floor = is_on_floor()
