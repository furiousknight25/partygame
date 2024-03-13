extends Node2D

var players = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	if multiplayer.is_server():
		print(players)
		await 500

