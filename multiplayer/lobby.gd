extends Node2D


const MAIN = preload("res://worlds/main.tscn")

const ADDRESS = "localhost"
const MAX_CLIENTS = 2

var multiplayer_peer = ENetMultiplayerPeer.new()
var port = 6969
var ip: String = "localhost"

@onready var host_join_label: Label = $CanvasLayer/HostJoinLabel
@onready var ip_enter: TextEdit = $CanvasLayer/Lobby/LobbyContainer/VBoxContainer2/IPEnter
@onready var lobby: Control = $CanvasLayer/Lobby


func _ready() -> void: 
	multiplayer.peer_connected.connect(_player_connected)


func _on_host_pressed() -> void:
	var err = multiplayer_peer.create_server(port, MAX_CLIENTS)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Hosting now: " + str(err))
	host_join_label.text = "Host"
	MultiplayerSingleton.player_1_id = multiplayer.get_unique_id()
	lobby.visible = false


func _on_join_pressed() -> void:
	var err = multiplayer_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joining server: " + str(err))
	host_join_label.text = "Client"
	MultiplayerSingleton.player_2_id = multiplayer.get_unique_id()
	lobby.visible = false


func _player_connected(id: int) -> void:
	print("player connected")
	if multiplayer.is_server():
		MultiplayerSingleton.player_2_id = id
	else:
		MultiplayerSingleton.player_1_id = id
	setup_world()
	call_deferred("set_node_authority")


func setup_world() -> void:
	var new_main = MAIN.instantiate()
	add_child(new_main)


func set_node_authority() -> void:
	print("Setting node authority")
	print(MultiplayerSingleton.player_2_id,"   ",MultiplayerSingleton.player_1_id)
	print(multiplayer.get_unique_id())
	MultiplayerSingleton.spawner_node.set_multiplayer_authority(MultiplayerSingleton.player_2_id)
	Singleton.player.set_multiplayer_authority(MultiplayerSingleton.player_1_id)


func _on_singleplayer_pressed() -> void:
	MultiplayerSingleton.is_singleplayer = true
	setup_world()
	lobby.visible = false


func _on_ip_text_changed(new_text: String) -> void:
	ip = new_text.strip_edges()


func _on_port_text_changed(new_text: String) -> void:
	port = int(new_text)
