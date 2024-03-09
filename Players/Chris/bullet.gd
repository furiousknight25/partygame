extends CharacterBody2D


func _enter_tree():
	set_multiplayer_authority(get_parent().get_parent().name.to_int())

	
func _physics_process(delta):
	#if not is_multiplayer_authority(): return
	if get_last_slide_collision():
		#print('they should actually add')
		#print(get_last_slide_collision().get_collider())
		if get_last_slide_collision().get_collider():
			if get_last_slide_collision().get_collider().has_method('hurt'):
				get_last_slide_collision().get_collider().hurt.rpc(Vector2(50,60), 10)
		queue_free()
	move_and_slide()
	
