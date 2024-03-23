extends Node2D

var players = {}
var fullscreen := false 


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen"):
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
		else:
			fullscreen = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed('restart'):
		get_tree().reload_current_scene()
	if !multiplayer.is_server(): return
	if Engine.get_frames_drawn() % 40 >= 10: return
	print(players)
	
func set_total():
	var total_stocks = 0
	for i in Director.players:
		total_stocks += Director.players[i]['stocks']
