extends Area2D


const FINISHED_SCENE = preload("res://worlds/finishedScene.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("switch_scene")


func switch_scene() -> void:
	get_tree().change_scene_to_packed(FINISHED_SCENE)
