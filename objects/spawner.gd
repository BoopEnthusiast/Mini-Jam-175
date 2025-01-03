class_name Spawner
extends Marker2D

const BLOCKS = [
	preload("res://entities/blocks/SquareBlock.tscn"),
	preload("res://entities/blocks/LineBlock.tscn"),
	preload("res://entities/blocks/TBlock.tscn"),
	preload("res://entities/blocks/LBlock.tscn"),
	preload("res://entities/blocks/ZBlock.tscn"),
]

const SPEED = 100.0

var can_spawn_block := false

func _enter_tree() -> void:
	MultiplayerSingleton.spawner_node = self
	multiplayer


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if MultiplayerSingleton.is_singleplayer:
		automatic_spawner(delta)
		
	else:
		var direction = Input.get_axis("left", "right")
		position.x += direction * SPEED * delta
		
		if Input.is_action_just_pressed("jump_spawn"):
			var new_block = BLOCKS[0].instantiate()

func automatic_spawner(delta: float):
	if Singleton.player == null:
		return

	if can_spawn_block:
		spawn_block()

	position.x = move_toward(position.x, Singleton.player.position.x, SPEED * delta)

func spawn_block():
	if not can_spawn_block:
		return

	can_spawn_block = false

	var block_index := randi_range(0, BLOCKS.size() - 1)
	var new_block = BLOCKS[block_index].instantiate()

	new_block.global_position = global_position

	# Give block a random cardinal rotation
	var block_rotation := (randi_range(0, 3) / 4.0) * 2.0 * PI
	new_block.global_rotation = block_rotation

	get_tree().root.add_child(new_block)

func _on_spawn_timer_timeout():
	can_spawn_block = true
