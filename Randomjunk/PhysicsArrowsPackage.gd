extends Node2D

@export var body_to_observe : Node2D
@export var velocity_arrow_multiplier := .5
@export var accel_arrow_multiplier := 5
@export var hide_text : bool
@export var hide_vectors : bool

@onready var velocity_text = $velocity_text
@onready var acceleration_text = $acceleration_text
@onready var velocity_arrow = $velocity
@onready var acceleration_arrow = $acceleration

var velocity : Vector2
var acceleration : Vector2
var old_acceleration : Vector2

# ): I ussualy like acceleration to be red but raycast modulate didnt like it, the sacrafices for programming cleanliness 

func _process(delta): 
#region seting accel and velocity 
	if body_to_observe is RigidBody2D:
		velocity = body_to_observe.linear_velocity
	elif body_to_observe is CharacterBody2D:
		velocity = body_to_observe.velocity
	else:
		print('nonvalid object to observe eat a fucking burger please')
	acceleration = velocity - old_acceleration
	old_acceleration = velocity
#endregion
	global_position = body_to_observe.global_position
	velocity_text.text =  'velocity: ' + '('+ var_to_str(snappedf(velocity.x, .01)) + ', ' + var_to_str(snappedf(velocity.y, .01)) + ')'
	acceleration_text.text =  'accel: ' + '('+ var_to_str(snappedf(acceleration.x, .01)) + ', ' + var_to_str(snappedf(acceleration.y, .01)) + ')'
	
	velocity_arrow.target_position = velocity * velocity_arrow_multiplier
	acceleration_arrow.target_position = acceleration * accel_arrow_multiplier
#region hide stuff
	if !hide_text:
		velocity_text.show()
		acceleration_text.show()
	else:
		velocity_text.hide()
		acceleration_text.hide()
	
	if !hide_vectors:
		velocity_arrow.show()
		acceleration_arrow.show()
	else:
		velocity_arrow.hide()
		acceleration_arrow.hide()

#endregion
