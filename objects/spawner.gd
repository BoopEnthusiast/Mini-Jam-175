class_name Spawner
extends Marker2D


const SQUARE_BLOCK = preload("res://entities/blocks/SquareBlock.tscn")

const SPEED = 100.0


func _enter_tree() -> void:
	MultiplayerSingleton.spawner_node = self


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	var direction = Input.get_axis("left", "right")
	position.x += direction * SPEED * delta
	
	if Input.is_action_just_pressed("jump_spawn"):
		var new_block = SQUARE_BLOCK.instantiate()
		
