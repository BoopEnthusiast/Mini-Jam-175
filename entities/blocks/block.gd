class_name Block
extends RigidBody2D

var has_hit_player = false

func _physics_process(_delta):
    if sleeping:
        freeze = true

    if not has_hit_player:
        for body in get_colliding_bodies():
            handle_collision(body)


func handle_collision(body: Node2D):
    if not (body is Player):
        return

    has_hit_player = true
    print("Block hit player") # TODO replace with damage code
