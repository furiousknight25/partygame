extends Node2D

@export var player_scene: PackedScene #maybe make this an array later
@export var rock_scene: PackedScene
@export var container: PackedScene

const PORT = 4433
var choice = {0:'Chris', 1:'Jesse', 2:'Aria', 3:'Travis'}
	
var players_loaded = 0

var ip 
@onready var text_type = $ui/Menu/Main/Control/TextEdit
func _ready():
	multiplayer.connected_to_server.connect(on_connected_to_server)

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player) #right track
	_add_player(multiplayer.get_unique_id())
	send_player_info('host', multiplayer.get_unique_id())
	
func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	ip = text_type.text
	peer.create_client(ip, PORT) #may have to switch to ip of the host
	multiplayer.multiplayer_peer = peer
	
func _add_player(id = 1): #starts lobby code
	var c = container.instantiate()
	c.name = str(id)
	$ui/Menu/select/HBoxContainer.add_child(c)
	
@rpc("any_peer")
func send_player_info(name, id): #starts global data
	if !Director.players.has(id):
		Director.players[id] = {
			"name": name,
			"id": id,
		}
	
	if multiplayer.is_server(): 
		for i in Director.players:
			send_player_info.rpc(Director.players[i].name, i)

func on_connected_to_server():
	send_player_info.rpc_id(1, 'player', multiplayer.get_unique_id()) #maybe do index stuff here for name


#region level management
func start_game():
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Levels/level_test.tscn"))
		

func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
#endregion
