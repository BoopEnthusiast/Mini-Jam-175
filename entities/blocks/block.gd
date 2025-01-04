class_name Block
extends RigidBody2D

const HIT_MIN_FORCE: float = 10000.0
const HIT_MIN_DOT: float = 0.33

var has_hit_player := false
var force_applied := 0.0


func _ready() -> void:
	set_multiplayer_authority(MultiplayerSingleton.player_1_id)
	if not multiplayer.is_server():
		process_mode = PROCESS_MODE_DISABLED


func _physics_process(delta):
	var state := PhysicsServer2D.body_get_direct_state(get_rid())
	var contact_count := state.get_contact_count()

	# if contact_count == 0:
	# 	position.x = move_toward(position.x, MultiplayerSingleton.spawner_node.position.x, delta * 1000.0)

	if not has_hit_player:
		for index in contact_count:
			handle_collision(index, state)


func handle_collision(contact_index: int, state: PhysicsDirectBodyState2D):
	if not is_valid_hit(contact_index, state):
		return

	var player: Player = state.get_contact_collider_object(contact_index)

	var collision_force := player_collision_force(player)
	force_applied += collision_force

	if force_applied < HIT_MIN_FORCE:
		return
	
	# Destroy after short delay for player to see the hit.
	get_tree().create_timer(0.05).timeout.connect(queue_free)

	# If the player can't be hit, just destroy the block.
	if not player.can_take_damage:
		return false

	has_hit_player = true
	player.health -= 1

	# Apply screenshake
	if Singleton.camera != null:
		Singleton.camera.add_trauma(2.0)


func is_valid_hit(contact_index: int, state: PhysicsDirectBodyState2D) -> bool:
	# If the block has already hit the player, invalid hit.
	if has_hit_player:
		return false

	# If the hit isn't on the player, invalid hit.
	var body := state.get_contact_collider_object(contact_index)
	if not (body is Player):
		return false
	
	# Hit must be on the underside of the block, e.g. player jumping on top doesn't count.
	if not is_collision_on_underside(contact_index, state):
		return false
	
	# # Hit must require a large amount of force to be appled to the player
	# var collision_force := player_collision_force(body)
	# if collision_force < HIT_MIN_FORCE:
	# 	return false

	# Hit should be a crush, so the player must be grounded.
	#if not player.is_on_floor():
	#    return
	
	return true


func player_collision_force(player: Player) -> float:
	const PLAYER_MASS: float = 1.0
	const IMPULSE_DELTA: float = 0.01 # every collision should have a static time

	var player_velocity := Vector2.ZERO
	# var player_velocity := player.velocity

	# Calculate the resulting player velocity from the collision
	# From https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional
	var eq_mass := (2 * mass) / (PLAYER_MASS + mass)
	var eq_vel_dot := (player_velocity - linear_velocity).dot(player.global_position - global_position)
	var eq_pos_len_sq := (player.global_position - global_position).length_squared()
	var eq_pos := player.global_position - global_position
	var player_velocity_result := player_velocity - eq_mass * (eq_vel_dot / eq_pos_len_sq) * eq_pos

	# Calulcate the impulse from the change in velocity and the force required to cause that impulse
	# From https://en.wikipedia.org/wiki/Impulse_(physics)
	var player_momentum := player.velocity * PLAYER_MASS
	var player_momentum_result := player_velocity_result * PLAYER_MASS
	var player_force := (player_momentum_result - player_momentum) / IMPULSE_DELTA

	print("Hit force: ", player_force.length())
	
	return player_force.length()


func is_collision_on_underside(contact_index: int, state: PhysicsDirectBodyState2D) -> bool:
	# The contact normal should be within a certain n degrees of Vector2.DOWN.
	var contact_normal := -state.get_contact_local_normal(contact_index)
	var contact_dot_product := Vector2.DOWN.dot(contact_normal)

	return contact_dot_product >= HIT_MIN_DOT
