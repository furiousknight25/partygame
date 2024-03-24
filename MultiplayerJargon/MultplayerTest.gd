extends Node2D

@export var container: PackedScene

const PORT = 4433

var ip
var state = 'menu'
var dir = DirAccess.open("res://Levels/level_rotation/").get_files()

const DEV_MODE = false


func _ready():
	multiplayer.connected_to_server.connect(on_connected_to_server)
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func  _process(delta):
	steam_process(delta)
	if not multiplayer.is_server(): return
	if Input.is_action_just_pressed('ui_home'):
		change_level.call_deferred(load("res://Levels/level_test.tscn"))
	if DEV_MODE == true: return
	var total_stocks = 0
	for i in Director.players:
		total_stocks += Director.players[i]['stocks']
	if state == 'start':
		if total_stocks <= 1:
			for i in Director.players: Director.players[i]['stocks'] = 1
			await get_tree().create_timer(1).timeout
			change_level(load("res://Levels/level_rotation/" + dir[randi_range(0, dir.size()) - 1]))

func _on_port_forward_pressed():
	upnp_setup()
	$ui/Menu/Main/Control/TextEdit.text = var_to_str(ip) + ' I have your ip'

func _on_host_pressed(): 
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player) #right track
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player(multiplayer.get_unique_id())
	send_player_info(multiplayer.get_unique_id())
	
func _on_join_pressed():
	var text_type = $ui/Menu/Main/Control/TextEdit
	var peer = ENetMultiplayerPeer.new()
	ip = text_type.text
	if DEV_MODE == true: ip = 'localhost'
	peer.create_client('localhost', PORT)
	multiplayer.multiplayer_peer = peer
	
	
func _add_player(id = 1):
	var c = container.instantiate()
	c.name = str(id)
	$ui/Menu/select/HBoxContainer.add_child(c)
	
	var musicC = get_tree().current_scene.get_node("/root/MusicC")
	musicC.start()
	musicC.mute()
	
func remove_player(peer_id):
	var player = $ui/Menu/select/HBoxContainer.get_node_or_null(str(peer_id))
	Director.players.erase(peer_id)
	if player:
		player.queue_free()

@rpc("any_peer")
func send_player_info(id): #starts global data
	if !Director.players.has(id):
		Director.players[id] = {
			'stocks': 1,
			'choice': 1
		}
	sync_server_to_peer()
func on_connected_to_server():
	send_player_info.rpc_id(1, multiplayer.get_unique_id()) #maybe do index stuff here for name

#region level management
func start_game():
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Levels/level_rotation/" + dir[randi_range(0, dir.size()) - 1]))
		state = 'start'
		sync_server_to_peer()

func sync_server_to_peer():
	for i in Director.players:
		if i != 1:
			sync.rpc_id(i, Director.players)
@rpc("any_peer")
func sync(director_info):
	Director.players = director_info

func change_level(scene: PackedScene):
	%Animation_Transition.play('open')
	for i in Director.players:
		if i != 1:
			play_trans.rpc_id(i, 'open')
	await %Animation_Transition.animation_finished
	if not multiplayer.is_server(): return
	
	var level = $Level
	if level:
		for c in level.get_children():
			level.remove_child(c)
			c.queue_free()
	# Add new level.
		level.add_child(scene.instantiate()) #chunker to make
	%Animation_Transition.play('close')
	for i in Director.players:
		if i != 1:
			play_trans.rpc_id(i, 'close')
#endregion
@rpc('any_peer')
func play_trans(anim):
	%Animation_Transition.play(anim)

func _on_option_button_item_selected(index):
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Levels/level_rotation/" + dir[index - 1]))
		state = 'start'
		
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
	ip = upnp.query_external_address()


#region steam stuff 
var steam_enabled = false

var lobby_id = 0


func _steam_setup(player_type):
	OS.set_environment('SteamAppID', str(480))
	OS.set_environment('SteamGameID', str(480))
	Steam.steamInitEx()
	steam_enabled = true
	
	
	if player_type == 'steam_host': host_steam()
	if player_type == 'steam_join': host_steam()

func host_steam():
	var peer = SteamMultiplayerPeer.new()
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	peer.lobby_created.connect(_on_lobby_created)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player) #right track
	multiplayer.peer_disconnected.connect(remove_player)
	_add_player(multiplayer.get_unique_id())
	send_player_info(multiplayer.get_unique_id())

func join_lobby(id):
	var peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	
	lobby_id = id
	
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		lobby_id = this_lobby_id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)

func _open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("305 Mr. Worldwide Requesting a lobby list")
	Steam.requestLobbyList()

func _on_lobby_match_list(these_lobbies: Array) -> void:
	print(these_lobbies)

			
	for lobby in these_lobbies:
		var lobby_name = Steam.getLobbyData(lobby,'name')
		var memb_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name,' Player Count: ', memb_count))
		but.set_size(Vector2(100,5))
		but.connect('pressed', Callable($ui/Menu,'set_character').bind('steam_join', lobby))
		
		%Lobbies.add_child(but)
	

func _check_lobbies():
	if %Lobbies.get_child_count() > 0:
		for i in %Lobbies.get_children():
			i.queue_free()
	_open_lobby_list()

func steam_process(delta):
	if !steam_enabled: return
	Steam.run_callbacks()
#endregion
