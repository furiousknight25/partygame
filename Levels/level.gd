extends Node2D

const SPAWN_RANDOM := 5.0

@onready var spawnpoints : Array = $SpawnPoints.get_children()
@onready var Players = $Players

@export var aria_scene :PackedScene
@export var jesse_scene :PackedScene
@export var travis_scene :PackedScene
@export var chris_scene :PackedScene

func _ready():
	var index = 0
	for i in Director.players:
		print(Director.players)
		#return
		var choice
		#if Director.players[i]['choice']: #OHHOHHHH, error exists because 0 is false, why dindt 4 work
		choice = Director.players[i]['choice']
		#else:
			#choice = 2
		var current_player
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
		add_child(current_player)
		for spawn in spawnpoints:
			
			if spawn.name == str(index):
				
				current_player.global_position = spawn.global_position
		index += 1

