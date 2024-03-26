extends Panel

var selected = 0
@onready var fightbox = get_parent().get_parent().get_child(1)
#chris 0, jesse 1, aria 2, travis 3

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	set_text(name.to_int())
	multiplayer.connected_to_server.connect(on_connected_to_server)
	if not is_multiplayer_authority(): return
	modulate.r = .8
	for i in fightbox.get_children():
		if str_to_var(i.name) == get_parent().get_child_count():
			fightbox.set_fighter.rpc(str_to_var(i.name), name.to_int())
	sync_server_to_peer.rpc_id(1)

func on_connected_to_server():
	select_set(selected)

@rpc("authority")
func sync_server_to_peer():
	for i in fightbox.get_children():
		for x in Director.players:
			sync.rpc_id(x, str_to_var(i.name), str_to_var(i.name))
		
			
@rpc("any_peer")
func sync(names, names2):
	fightbox.set_fighter.rpc(names, names2)
	print(names)
	
func select(choice):
	if not is_multiplayer_authority(): return
	selected = choice
	select_set(choice)
	fightbox.spawn_playground.rpc(name.to_int(), selected)
	Camera.add_trauma(.5, Vector2(0,1))
	for i in $GridContainer.get_children():
		i.button_pressed = false
		if i.name == var_to_str(choice): i.button_pressed = true

@rpc('any_peer')
func select_set(index):
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


@rpc("any_peer")
func set_text(text):
	$RichTextLabel.text = var_to_str(text)
