class_name Block
extends RigidBody2D

var has_hit_player := false

func _physics_process(_delta):
    if sleeping:
        freeze = true

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
    # Contact angle must be <45°
    if contact_dot_product <= 0.5:
        return
    
    # Hit should be a crush, so the player must be grounded.
    if not player.is_on_floor():
        return

    has_hit_player = true
    player.health -= 1
    print("Block hit player")
    # TODO destroy block?
