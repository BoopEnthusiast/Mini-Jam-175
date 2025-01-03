extends Node2D


func _enter_tree() -> void:
	Singleton.main_node = self
