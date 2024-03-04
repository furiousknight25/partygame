extends VSplitContainer


func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	set_text(name.to_int())
	#change_color.rpc_id(name.to_int()) #from this line
	#MultiplayerTest.player_loaded.rpc()

@rpc("any_peer")
func set_text(text):
	$PanelContainer2/RichTextLabel.text = var_to_str(text)

@rpc('call_local')
func change_color():
	modulate.a = .5

@rpc('any_peer')
func _on_option_button_item_selected(index):
	
	Director.players[multiplayer.get_unique_id()]['choice'] = index
	print(Director.players)
	if !multiplayer.is_server():
		for i in Director.players:
			if i != multiplayer.get_unique_id():
				set_choice.rpc_id(i, index, multiplayer.get_unique_id())
	if multiplayer.is_server():
		#var new_list = Director.players
		#new_list.erase(1)
		for i in Director.players:
			if i != 1:
				set_choice.rpc_id(i, index, 1)

@rpc("any_peer")
func set_choice(index, id):
	Director.players[id]['choice'] = index

