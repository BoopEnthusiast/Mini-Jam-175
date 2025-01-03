class_name Player
extends CharacterBody2D

var checkState = func():
	if velocity.y < 20:
		sprite.play("rise")
	else:
		sprite.play("fall")
	
	if is_on_floor:
		setStateGrounded()

const SPEED = 300.0
const ACCEL = 70.0
const JUMP_VELOCITY = -400.0

var was_on_floor := false
var has_double_jumped := false
var has_pressed_jump := false

var health := 3
var direction = 0

@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer
@onready var sprite: AnimatedSprite2D = $Sprite


func _enter_tree() -> void:
	Singleton.player = self
	multiplayer


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if was_on_floor:
			coyote_time.start()
	else:
		has_double_jumped = false
	
	# Handle jump. Only set if is the authority
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
	
	# Get the input direction and handle the movement/deceleration. Only set if is the authority
	direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	checkState.call()

func setStateAirborne() -> void:
	checkState = func():
		setFacing()
		
		if velocity.y < 20:
			sprite.play("rise")
		else:
			sprite.play("fall")
		
		if is_on_floor():
			setStateGrounded()
		elif is_on_wall_only():
			setStateWallslide()

func setStateGrounded() -> void:
	checkState = func():
		setFacing()
		
		if direction:
			sprite.play("walk")
		else:
			sprite.play("default")
		
		if not is_on_floor():
			setStateAirborne()

func setStateWallslide() -> void:
	if get_wall_normal().x == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	checkState = func():
		if is_on_floor():
			setStateGrounded()
		elif not is_on_wall():
			setStateAirborne()

func setFacing() -> void:
	if direction == -1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
