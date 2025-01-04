extends Node2D


const MAIN = preload("res://worlds/main.tscn")

const ADDRESS = "localhost"
const MAX_CLIENTS = 2

var multiplayer_peer = ENetMultiplayerPeer.new()
var port = 6969
var saved_ip: String = "localhost"
var external_ip: String = ""

@onready var lobby_container: HBoxContainer = $CanvasLayer/Lobby/LobbyContainer
@onready var host_join_label: Label = $CanvasLayer/HostJoinLabel
@onready var ip_enter: TextEdit = $CanvasLayer/Lobby/LobbyContainer/VBoxContainer2/IPEnter


func _ready() -> void: 
	multiplayer.peer_connected.connect(_player_connected)


func _on_host_pressed() -> void:
	multiplayer_peer.create_server(port, MAX_CLIENTS)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Hosting now")
	host_join_label.text = "Host"
	MultiplayerSingleton.player_1_id = multiplayer.get_unique_id()
	lobby_container.visible = false


func _on_join_pressed() -> void:
	multiplayer_peer.create_client(saved_ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joining server")
	host_join_label.text = "Client"
	MultiplayerSingleton.player_2_id = multiplayer.get_unique_id()
	lobby_container.visible = false


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
	lobby_container.visible = false


func _on_ip_text_changed() -> void:
	saved_ip = ip_enter.text.strip_edges()
