extends Control


const MAIN = preload("res://worlds/main.tscn")

var multiplayer_peer = ENetMultiplayerPeer.new()


func _ready() -> void: 
	multiplayer.peer_connected.connect(_player_connected)


func _on_host_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(6969, 2)
	multiplayer.multiplayer_peer = peer
	print("Hosting now")


func _on_join_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 6969)
	multiplayer.multiplayer_peer = peer
	print("Joining server")
	print("Heyl yeah")


func _player_connected() -> void:
	MultiplayerSingleton.player_2_id = multiplayer.get_unique_id()
