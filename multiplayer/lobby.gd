extends Node2D


const MAIN = preload("res://worlds/main.tscn")

const ADDRESS = "localhost"
const MAX_CLIENTS = 2

var multiplayer_peer = ENetMultiplayerPeer.new()
var port = 6969
var ip: String = "localhost"

@onready var ip_enter: TextEdit = $CanvasLayer/Lobby/LobbyContainer/VBoxContainer2/IPEnter
@onready var lobby: Control = $CanvasLayer/Lobby
@onready var start: Start = $CanvasLayer/Start


func _ready() -> void: 
	multiplayer.peer_connected.connect(_player_connected)


func _on_host_pressed() -> void:
	multiplayer_peer.create_server(port, MAX_CLIENTS)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Hosting now: " + str(multiplayer.get_unique_id()))
	MultiplayerSingleton.player_1_id = multiplayer.get_unique_id()
	lobby.visible = false
	start.is_multiplayer = true
	start.set_show_dropper_guide(false)
	start.visible = true


func _on_join_pressed() -> void:
	multiplayer_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joining server: " + str(multiplayer.get_unique_id()))
	MultiplayerSingleton.player_2_id = multiplayer.get_unique_id()
	lobby.visible = false
	start.is_multiplayer = true
	start.set_show_dropper_guide(true)
	start.visible = true


func _player_connected(id: int) -> void:
	start.other_player_connected = true
	print("player connected" + str(multiplayer.get_unique_id()))
	MultiplayerSingleton.is_singleplayer = false
	if multiplayer.is_server():
		MultiplayerSingleton.player_2_id = id
	else:
		MultiplayerSingleton.player_1_id = id


# Called by the start menu
func setup_world() -> void:
	var new_main = MAIN.instantiate()
	add_child(new_main)


func set_node_authority() -> void:
	MultiplayerSingleton.spawner_node.set_multiplayer_authority(MultiplayerSingleton.player_2_id)
	Singleton.player.set_multiplayer_authority(MultiplayerSingleton.player_1_id)


func _on_singleplayer_pressed() -> void:
	MultiplayerSingleton.is_singleplayer = true
	lobby.visible = false
	start.set_show_dropper_guide(false)
	start.visible = true


func _on_ip_text_changed(new_text: String) -> void:
	ip = new_text.strip_edges()


func _on_port_text_changed(new_text: String) -> void:
	port = int(new_text)
