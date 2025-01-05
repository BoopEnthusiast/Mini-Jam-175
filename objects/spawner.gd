class_name Spawner
extends Marker2D


const SPEED = 100.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var spawn_timer: Timer = $Timer

var can_spawn_block := false

@onready var next_block_index: int = randi_range(0, Singleton.main_node.BLOCKS.size() - 1)
var next_rotation = (randi_range(0, 3) / 4.0) * 2.0 * PI


func _enter_tree() -> void:
	MultiplayerSingleton.spawner_node = self


func _ready() -> void:
	if not MultiplayerSingleton.is_singleplayer:
		set_multiplayer_authority(MultiplayerSingleton.player_2_id)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if MultiplayerSingleton.is_singleplayer:
		automatic_spawner(delta)
		
	else:
		var direction = Input.get_axis("left", "right")
		position.x = clamp(position.x + direction * SPEED * delta, -370, 370)
		if can_spawn_block:
			rpc("spawn_block")
			can_spawn_block = false


func automatic_spawner(delta: float):
	if Singleton.player == null:
		return
	
	if can_spawn_block:
		spawn_block()
	
	position.x = move_toward(position.x, Singleton.player.position.x, SPEED * delta)


@rpc("reliable", "any_peer", "call_remote")
func spawn_block():
	if not can_spawn_block:
		return
	
	
	if MultiplayerSingleton.is_singleplayer:
		can_spawn_block = false
		
		animated_sprite_2d.play("click")
		
		var block_index := next_block_index
		next_block_index = randi_range(0, Singleton.main_node.BLOCKS.size() - 1)
		display_next_block()
		var new_block = Singleton.main_node.BLOCKS[block_index].instantiate()
		
		new_block.global_position = global_position
		new_block.global_position.y -= 100
		
		# Give block a random cardinal rotation
		var block_rotation = next_rotation
		next_rotation = (randi_range(0, 3) / 4.0) * 2.0 * PI
		new_block.global_rotation = block_rotation
		
		Singleton.main_node.add_child(new_block)
	
	else:
		animated_sprite_2d.play("click")
		
		var block_index := next_block_index
		next_block_index = randi_range(0, Singleton.main_node.BLOCKS.size() - 1)
		
		var block_global_position := global_position
		block_global_position.y -= 100
		
		# Give block a random cardinal rotation
		var block_rotation = next_rotation
		next_rotation = (randi_range(0, 3) / 4.0) * 2.0 * PI
		
		var spawn_info = {
			"block_index": block_index,
			"global_position": block_global_position,
			"global_rotation": block_rotation,
		}
		Singleton.main_node.multiplayer_spawner.spawn(spawn_info)


func display_next_block() -> void:
	var new_block: Block = Singleton.main_node.BLOCKS[next_block_index].instantiate()
	new_block.process_mode = Node.PROCESS_MODE_DISABLED
	new_block.global_position = Vector2(700, -300)
	new_block.global_rotation = next_rotation
	new_block.name = "DisplayBlock"
	Singleton.main_node.add_child(new_block)
	delete_block(new_block)


func delete_block(block_to_delete: Block) -> void:
	await get_tree().create_timer(2).timeout
	block_to_delete.queue_free()


func _on_spawn_timer_timeout():
	can_spawn_block = true


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("default")
