class_name MainNode
extends Node2D


const BLOCKS = [
	preload("res://entities/blocks/SquareBlock.tscn"),
	preload("res://entities/blocks/LineBlock.tscn"),
	preload("res://entities/blocks/TBlock.tscn"),
	preload("res://entities/blocks/LBlock.tscn"),
	preload("res://entities/blocks/ZBlock.tscn"),
]

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _enter_tree() -> void:
	Singleton.main_node = self


func _ready() -> void:
	multiplayer_spawner.spawn_function = spawn_function


func spawn_function(spawn_info):
	var new_block = BLOCKS[spawn_info["block_index"]].instantiate()
	new_block.global_position = spawn_info["global_position"]
	new_block.global_rotation = spawn_info["global_rotation"]
	return new_block
