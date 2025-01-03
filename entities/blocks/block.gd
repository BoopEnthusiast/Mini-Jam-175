class_name Block
extends RigidBody2D

const HIT_MIN_FORCE: float = 15000.0
const HIT_MAX_ANGLE: float = 70.0
const PLAYER_MASS: float = 1.0
const IMPULSE_DELTA: float = 0.01

var has_hit_player := false

func _physics_process(_delta):
    # if sleeping:
    #     freeze = true

    if not has_hit_player:
        var state := PhysicsServer2D.body_get_direct_state(get_rid())
        var contact_count := state.get_contact_count()
        # var colliding_bodies := get_colliding_bodies()
        for index in contact_count:
            # var body := colliding_bodies[index]
            handle_collision(index, state)


func handle_collision(contact_index: int, state: PhysicsDirectBodyState2D):
    if has_hit_player:
        return

    var body := state.get_contact_collider_object(contact_index)
    if not (body is Player):
        return
    var player: Player = body

    # Hit must be on the underside of the block, e.g. player jumping on top doesn't count.
    # The contact normal should be within a certain n degrees of Vector2.DOWN.
    var contact_normal := -state.get_contact_local_normal(contact_index)
    var contact_dot_product := Vector2.DOWN.dot(contact_normal)
    if contact_dot_product <= 1.0 - HIT_MAX_ANGLE / 90.0:
        return

    # Hit should occur only if there is a large force applied to the player.
    # 1 = player, 2 = self
    # From https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional
    var eq_pt_1 := (2 * mass) / (PLAYER_MASS + mass)
    var eq_pt_2_top := (player.velocity - linear_velocity).dot(player.global_position - global_position)
    var eq_pt_2_bottom := (player.global_position - global_position).length_squared()
    var eq_pt_3 := player.global_position - global_position
    var player_velocity_result := player.velocity - eq_pt_1 * (eq_pt_2_top / eq_pt_2_bottom) * eq_pt_3

    # From https://en.wikipedia.org/wiki/Impulse_(physics)
    var player_momentum := player.velocity * PLAYER_MASS
    var player_momentum_result := player_velocity_result * PLAYER_MASS
    var player_force := (player_momentum_result - player_momentum) / IMPULSE_DELTA

    if player_force.length() < HIT_MIN_FORCE:
        return
    
    # Hit should be a crush, so the player must be grounded.
    # if not player.is_on_floor():
    #     return

    has_hit_player = true
    player.health -= 1
    print("Block hit player")
    # Destroy after short delay for player to see the hit.
    get_tree().create_timer(0.05).timeout.connect(queue_free)

    if Singleton.camera != null:
        Singleton.camera.add_trauma(1.0)
