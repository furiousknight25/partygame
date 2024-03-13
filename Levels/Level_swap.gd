extends Node2D

@onready var dir = DirAccess.open("res://Levels/level_rotation/").get_files()

func change_level():
	if multiplayer.is_server():
		for c in get_children():
			remove_child(c)
			c.queue_free()
		# Add new level.
		var level = load("res://Levels/level_rotation/" + dir[randi_range(0, dir.size()) - 1])
		add_child(level.instantiate()) #chunker to make
