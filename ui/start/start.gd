class_name Start
extends Node

@onready var dropper_title := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/DropperTitle
@onready var dropper_controlls := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/DropperControlls
@onready var dropper_objective := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/DropperObjective

@onready var player_title := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/PlayerTitle
@onready var player_controlls := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Control/PlayerControlls
@onready var player_objective := $GridContainer/CenterColumn/MarginContainer/ScrollContainer/VBoxContainer/Objective/PlayerObjective

var show_dopper_guide := false:
	set = set_show_dropper_guide


func set_show_dropper_guide(value: bool):
	if value:
		dropper_title.visible = true
		dropper_controlls.visible = true
		dropper_objective.visible = true

		player_title.visible = false
		player_controlls.visible = false
		player_objective.visible = false
	else:
		dropper_title.visible = false
		dropper_controlls.visible = false
		dropper_objective.visible = false

		player_title.visible = true
		player_controlls.visible = true
		player_objective.visible = true
	
	show_dopper_guide = value


func _on_start_button_pressed() -> void:
	pass # Replace with function body.
