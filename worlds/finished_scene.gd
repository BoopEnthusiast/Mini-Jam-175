extends Control

@onready var total_time: Label = $GridContainer/MarginContainer/VBoxContainer/VBoxContainer/TotalTime
@onready var blocks_spawned: Label = $GridContainer/MarginContainer/VBoxContainer/VBoxContainer/BlocksSpawned
@onready var blocks_destroyed: Label = $GridContainer/MarginContainer/VBoxContainer/VBoxContainer/BlocksDestroyed

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_ready() -> void:
	total_time.text = "Total Time: %s" % [round_to_dec(Singleton.time, 2)]
	blocks_spawned.text = "Blocks Spawned: %s" % [Singleton.blocks_spawned]
	blocks_destroyed.text = "Blocks Destroyed: %s" % [Singleton.blocks_destroyed]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
