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

    # Hit should only occur if the force the block applies to the player is large.
    # E.g., the player jumping into the side of the block, mid-air should not count.
    # The contact normal should be within a certain n degrees of Vector2.DOWN
    
    var contact_normal := -state.get_contact_local_normal(contact_index)
    var contact_dot_product := Vector2.DOWN.dot(contact_normal)

    # Contact angle must be <90°
    if contact_dot_product <= 0.0:
        return
    
    has_hit_player = true
    print("Block hit player") # TODO replace with damage code
