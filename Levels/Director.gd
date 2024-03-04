extends Node2D

var players = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	#if players.has(1): 
		#print(players[1])
	if multiplayer.is_server():
		print(players)
		await 5
