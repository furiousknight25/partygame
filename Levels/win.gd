extends Node2D

@onready var survivor = $Survivor

@export var aria_scene :PackedScene
@export var jesse_scene :PackedScene
@export var travis_scene :PackedScene
@export var chris_scene :PackedScene
@export var death_ball :PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Survivor.hide()
	$Wins.hide()
	$fin.modulate.a = 0.0
	if not multiplayer.is_server(): return
	
	
	var score = 0
	var greatest_of_them_all
	for i in Director.players:
		if Director.players[i]['points'] > score:
			greatest_of_them_all = i
			score = Director.players[i]['points']
	
	survivor.text = "player " + var_to_str(Director.players[greatest_of_them_all]['name'])
	
	await get_tree().create_timer(2.7).timeout
	var choice = 1
	var current_player
	choice = Director.players[greatest_of_them_all]['choice']
	match choice:
		0:
			current_player = chris_scene.instantiate()
		1:
			current_player = jesse_scene.instantiate()
		2:
			current_player = aria_scene.instantiate()
		3:
			current_player = travis_scene.instantiate()
	current_player.name = str(greatest_of_them_all)
	$DropPoints.add_child(current_player)
	
	
	await get_tree().create_timer(2.8).timeout
	var death_choice = 1
	for i in Director.players:
		if i != greatest_of_them_all:
			var ball = death_ball.instantiate()
			$DropPoints.add_child(ball, true)
			death_choice = Director.players[i]['choice']
			
			for n in ball.get_children():
				if n.name == var_to_str(death_choice):
					n.show()
					
			for x in $DropPoints/points.get_children():
				if x.name == var_to_str(Director.players[i]['name']):
					ball.global_position = x.global_position
			
			
			

func shake():
	Camera.add_trauma(2, Vector2(0,1))
