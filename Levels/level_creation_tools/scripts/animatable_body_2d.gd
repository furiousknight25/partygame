extends Node2D

@export var tension = .5
@export var damp = .05
var target_pos = .8
var shake_pos = .8 #from .2 to .8
var velocity = 0.0

@onready var sprite = $AnimatableBody2D/Sprite2D
@onready var path_2d = $Path2D.curve
@onready var line_2d = $Line2D


func _process(delta):
	var displacement = (target_pos - shake_pos) * delta  #distance to center
	velocity += (displacement * tension) - (velocity * damp)
	shake_pos += velocity
	$Path2D/PathFollow2D.progress_ratio = shake_pos
	var rotation_offset = target_pos - shake_pos
	sprite.rotation = lerp_angle(sprite.rotation, rotation_offset * -6, 2 * delta)
	
	$AnimatableBody2D.global_position = $Path2D/PathFollow2D.global_position
var end = true

func _ready():
	line_2d.set_point_position(0, path_2d.get_point_position(0))
	line_2d.set_point_position(1, path_2d.get_point_position(1))
func _on_timer_timeout():
	if end:
		target_pos = .2
	else:
		target_pos = .8
	end = !end
