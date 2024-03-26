extends Sprite2D

@export var chris_scene: PackedScene
@export var jesse_scene: PackedScene
@export var aria_scene: PackedScene
@export var travis_scene: PackedScene
#chris 0, jesse 1, aria 2, travis 3


@rpc("any_peer", "call_local")
func set_fighter(chosen: int, id: int): #hooked to a ready function, initializes this stuf
	return
	for i in get_children():
		if str_to_var(i.name) == chosen:
			i.name = var_to_str(id)

@rpc("any_peer", "call_local")
func spawn_playground(id: int, choice, real_id): #id is name
	var pos
	for i in get_children():
		if str_to_var(i.name) == id:
			pos = i
			if i.get_children():
				i.get_child(0).queue_free()
	
	var current_player
	match choice:
		0:
			current_player = chris_scene.instantiate()
		1:
			current_player = jesse_scene.instantiate()
		2:
			current_player = aria_scene.instantiate()
		3:
			current_player = travis_scene.instantiate()
	current_player.get_child(0).name = str(real_id)
	current_player.name = str(real_id)
	
	pos.add_child(current_player, true) #ig ignore this error for now 
	#lets try index
	current_player.global_position = pos.global_position

@rpc("call_local")
func clear_children():
	for i in get_children():
		if i.get_children():
			i.get_child(0).queue_free()
