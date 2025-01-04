extends Node

var show_dopper_guide := false:
	set = set_show_dropper_guide


func set_show_dropper_guide(value: bool):
	if value:
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/DropperTitle.visible = true
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/DropperControlls.visible = true
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/DropperObjective.visible = true

		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/PlayerTitle.visible = false
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/PlayerControlls.visible = false
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/PlayerObjective.visible = false
	else:
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/DropperTitle.visible = false
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/DropperControlls.visible = false
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/DropperObjective.visible = false

		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/PlayerTitle.visible = true
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/PlayerControlls.visible = true
		$GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/PlayerObjective.visible = true
	
	show_dopper_guide = value


func _on_start_button_pressed() -> void:
	pass # Replace with function body.
