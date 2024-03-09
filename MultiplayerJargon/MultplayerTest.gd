extends Node2D

@export var container: PackedScene

const PORT = 4433
var choice = {0:'Chris', 1:'Jesse', 2:'Aria', 3:'Travis'}
	
var players_loaded = 0

var ip 

func _ready():
	multiplayer.connected_to_server.connect(on_connected_to_server)
	#upnp_setup()

#192.168.1.24
#192.168.74.193 hotspot
func _on_host_pressed(): #64.8.134.2
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_add_player) #right track
	_add_player(multiplayer.get_unique_id())
	send_player_info('host', multiplayer.get_unique_id())

func _on_join_pressed():
	#print('attempted')
	var text_type = $ui/Menu/Main/Control/TextEdit
	var peer = ENetMultiplayerPeer.new()
	ip = text_type.text
	#ip = 'localhost'
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
		Director.players[id]['choice'] = 'host'
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

func upnp_setup(): #internet connection
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT, PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())

