extends Marker2D


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		return
	
	if Input.is_action_just_pressed("jump_spawn"):
		pass
