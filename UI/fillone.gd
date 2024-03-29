extends GridContainer

#organizer for one player gameplay
func _process(delta):
	if get_child_count() == 2:
		if get_child_count(): 
			$Control.show()
			move_child($Control, 1)
	else:
		if get_child_count(): $Control.hide()
