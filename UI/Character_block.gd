extends VSplitContainer

var multiplayer_test

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	set_text(name.to_int())
	multiplayer.connected_to_server.connect(on_connected_to_server)
	if not is_multiplayer_authority(): return
	modulate.a = .5

func on_connected_to_server():
	_on_option_button_item_selected($PanelContainer/Select/OptionButton.get_selected_id())
	

@rpc("any_peer")
func set_text(text):
	$PanelContainer2/RichTextLabel.text = var_to_str(text)

@rpc('call_local')
func change_color():
	modulate.a = .5

@rpc('any_peer')
func _on_option_button_item_selected(index):
	if multiplayer_test.state != 'menu': return
	Director.players[multiplayer.get_unique_id()]['choice'] = index
	if !multiplayer.is_server():
		for i in Director.players:
			if i != multiplayer.get_unique_id():
				set_choice.rpc_id(i, index, multiplayer.get_unique_id())
	if multiplayer.is_server():
		for i in Director.players:
			if i != 1:
				set_choice.rpc_id(i, index, 1)

@rpc("any_peer")
func set_choice(index, id):
	Director.players[id]['choice'] = index
