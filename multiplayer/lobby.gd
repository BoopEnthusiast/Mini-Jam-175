extends Node2D


const MAIN = preload("res://worlds/main.tscn")

const PORT = 6969
const ADDRESS = "localhost"
const MAX_CLIENTS = 2

var multiplayer_peer = ENetMultiplayerPeer.new()

@onready var lobby: Control = $CanvasLayer/Lobby
@onready var host_join_label: Label = $CanvasLayer/HostJoinLabel


func _ready() -> void: 
	multiplayer.peer_connected.connect(_player_connected)


func _on_host_pressed() -> void:
	multiplayer_peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Hosting now")
	host_join_label.text = "Host"
	setup_world()
	MultiplayerSingleton.player_1_id = multiplayer.get_unique_id()


func _on_join_pressed() -> void:
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joining server")
	host_join_label.text = "Client"
	setup_world()
	MultiplayerSingleton.player_2_id = multiplayer.get_unique_id()


func setup_world() -> void:
	var new_main = MAIN.instantiate()
	add_child(new_main)
	lobby.visible = false


func _player_connected(id: int) -> void:
	print("player connected")
	if multiplayer.is_server():
		MultiplayerSingleton.player_2_id = id
	else:
		MultiplayerSingleton.player_1_id = id
	call_deferred("set_node_authority")


func set_node_authority() -> void:
	MultiplayerSingleton.spawner_node.set_multiplayer_authority(MultiplayerSingleton.player_2_id)
	Singleton.player.set_multiplayer_authority(MultiplayerSingleton.player_1_id)
