class_name Player
extends CharacterBody2D

var new_func = Callable(self, "_checkState")



const SPEED = 300.0
const ACCEL = 70.0
const JUMP_VELOCITY = -400.0

@export var direction: float
@export var velocity_copy: Vector2

var was_on_floor := false
var has_double_jumped := false
var has_pressed_jump := false

var health := 3

@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer
@onready var sprite: AnimatedSprite2D = $Sprite


func _enter_tree() -> void:
	Singleton.player = self
	multiplayer


func _physics_process(delta: float) -> void:
	# Mimic velocity to be seen by MultiplayerSyncronizer and copied to the other player
	if is_multiplayer_authority():
		velocity_copy = velocity
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if was_on_floor:
			coyote_time.start()
	else:
		has_double_jumped = false
	
	# Handle jump. Only set if is the authority
	if Input.is_action_just_pressed("jump_spawn") and is_multiplayer_authority():
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
	if is_multiplayer_authority():
		direction = Input.get_axis("left", "right")
	
	if direction:
		if direction == -1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# I usually do this through a state machine, but this'll do for now. <(o3o)/
	if is_on_floor():
		if direction:
			sprite.play("walk")
		else:
			sprite.play("default")
	else:
		if velocity.y < 20:
			sprite.play("rise")
		else:
			sprite.play("fall")

func _checkState() -> void:
	print("awawa")
