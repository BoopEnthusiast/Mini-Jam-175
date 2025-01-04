class_name Player
extends CharacterBody2D

var checkState = func():
	faceDirection()
	
	if velocity.y < 20:
		sprite.play("rise")
	else:
		sprite.play("fall")
	
	if is_on_floor():
		setStateGrounded()
	elif is_on_wall_only():
		setStateWallslide()

const SPEED = 300.0
const ACCEL = 70.0
const JUMP_VELOCITY = -400.0

var was_on_floor := false
var has_double_jumped := false
var has_pressed_jump := false
var has_wall_jumped := false
var can_take_damage := true

var can_dash := true
var is_dashing := false
var dash_direction := Vector2.ZERO

var hearts_list: Array[TextureRect]

var direction := 0.0

@onready var dash_recharge_timer: Timer = $DashRechargeTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hearts: HBoxContainer = $HealthLayer/Hearts
@onready var i_frames: Timer = $IFrames
@onready var i_frame_player: AnimationPlayer = $IFramePlayer

# Health is dependent on the nodes, so is below them
@export var health := 3:
	set(value):
		print(can_take_damage)
		if can_take_damage:
			health = value
			update_heart_display()
			can_take_damage = false
			print(i_frames)
			i_frames.start()
			i_frame_player.play("i_frames")
			if Singleton.camera != null:
				Singleton.camera.add_trauma(1.0)
		if health <= 0:
			pass # TODO: Start end screen


func _enter_tree() -> void:
	Singleton.player = self


func _ready() -> void:
	MultiplayerSingleton.is_singleplayer
	# Get displayed hearts
	for child in hearts.get_children():
		hearts_list.append(child)


func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health


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
		has_wall_jumped = false
	
	# Handle dash
	if Input.is_action_just_pressed("dash") && can_dash:
		dash_duration_timer.start()
		is_dashing = true
		can_dash = false
		
		var input_direction := Input.get_axis("left", "right")
		if input_direction == 0.0:
			dash_direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
		else:
			dash_direction = Vector2.LEFT if input_direction < 0.0 else Vector2.RIGHT
			
		velocity.x = dash_direction.x * SPEED * 2.0
	
	# Handle jump. Only set if is the authority
	if Input.is_action_just_pressed("jump_spawn"):
		if is_on_floor() or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only() and not has_wall_jumped:
			has_wall_jumped = true
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * SPEED
		elif not has_double_jumped:
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
		elif not jump_buffer.is_stopped() and is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			jump_buffer.start()
	
	if not is_dashing:
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
		faceDirection()
		
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
		faceDirection()
		
		if direction:
			sprite.play("walk")
		else:
			sprite.play("default")
		
		if not is_on_floor():
			setStateAirborne()

func setStateWallslide() -> void:
	if get_wall_normal().x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	sprite.play("wall")
	
	checkState = func():
		if is_on_floor():
			setStateGrounded()
		elif not is_on_wall():
			setStateAirborne()

func faceDirection() -> void:
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false


func _on_i_frames_timeout() -> void:
	print("I frames over")
	can_take_damage = true
	i_frame_player.stop()

func _on_dash_duration_timeout() -> void:
	is_dashing = false
	dash_recharge_timer.start()

func _on_dash_recharge_timeout() -> void:
	can_dash = true
