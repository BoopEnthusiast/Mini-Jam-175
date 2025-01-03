class_name Block
extends RigidBody2D

func _physics_process(_delta):
    if sleeping:
        freeze = true

    for body in get_colliding_bodies():
        handle_collision(body)


func handle_collision(body: Node2D):
    if not (body is Player):
        return

    print("Block hit player") # TODO replace with damage code
