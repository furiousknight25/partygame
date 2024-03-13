extends Node2D

@export var aria_scene :PackedScene
@export var jesse_scene :PackedScene
@export var travis_scene :PackedScene
@export var chris_scene :PackedScene

@onready var players = $Players
@onready var dir = DirAccess.open("res://Levels/level_rotation/").get_files()

func _ready():
	multiplayer.peer_disconnected.connect(remove_player)
	var index = 0
	for i in Director.players:
		#return
		var choice = 2
		var current_player
		#if Director.players[i]['choice']: #OHHOHHHH, error exists because 0 is false, why dindt 4 work
		choice = Director.players[i]['choice']
		match choice:
			0:
				current_player = chris_scene.instantiate()
				print('christ')
			1:
				current_player = jesse_scene.instantiate()
			2:
				current_player = aria_scene.instantiate()
			3:
				current_player = travis_scene.instantiate()
			
		current_player.name = str(Director.players[i].id)
		
		players.add_child(current_player)
		var spawnpoints : Array = $SpawnPoints.get_children()
		current_player.global_position = spawnpoints[index].global_position
		index += 1


func change_level():
	if multiplayer.is_server():
		for c in get_children():
			remove_child(c)
			c.queue_free()
		# Add new level.
		var level = load("res://Levels/level_rotation/" + dir[randi_range(0, dir.size()) - 1])
		add_child(level.instantiate()) #chunker to make

func _process(delta):
	if players.get_child_count() <= 1:
		if not multiplayer.is_server(): return
		get_parent().get_parent().change_level(load("res://Levels/level_test.tscn"))
		#get_parent().change_level()
		#change_level.call_deferred()
		#print(players.get_child_count())




func remove_player(peer_id):
	var player = players.get_node_or_null(str(peer_id))
	print(peer_id)
	if player:
		player.queue_free()
