class_name Player
extends CharacterBody2D


const SPEED = 300.0
const ACCEL = 70.0
const JUMP_VELOCITY = -400.0

var spr_idle = load("res://entities/player/spr_player_idle.png")
# var spr_walk = load() TODO figure out animated sprites.
var spr_rise = load("res://entities/player/spr_player_rise.png")
var spr_fall = load("res://entities/player/spr_player_fall.png")

var was_on_floor := false
var has_double_jumped := false
var has_pressed_jump := false

@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer


func _enter_tree() -> void:
	Singleton.player = self


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
	
	# Handle jump..
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
		if direction == -1:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# I usually do this through a state machine, but this'll do for now. <(o3o)/
	if is_on_floor():
		if direction:
			$Sprite.texture = spr_idle
		else:
			$Sprite.texture = spr_idle #PLACEHOLDER! TODO: figure out animated sprites
	else:
		if velocity.y < 20:
			$Sprite.texture = spr_rise
		else:
			$Sprite.texture = spr_fall
