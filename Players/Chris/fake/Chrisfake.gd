extends CharacterBody2D

@export var jump_strength : int
@export var speed : int
@export var gravity = 980
@onready var sprite = $Sprite2D

var health = 100
var walk_animation_speed = 0
func _process(delta):
#region debug keybinds
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != 3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed('restart'):
		get_tree().reload_current_scene()
#endregion
	var direction = Input.get_axis('left', "right")
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, 12 * delta) #add jump buffer later
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 12*delta)
		walk_animation_speed += velocity.x * .0005
		sprite.position.y = abs(sin(walk_animation_speed) * 3)
		if abs(sin(walk_animation_speed) * 3) <= .8:
			sprite.scale.x = .9
			sprite.scale.y = 1.1
	
	if Input.is_action_just_pressed('up') and is_on_floor():
		velocity.y -= jump_strength
		sprite.scale.y += .3
		sprite.scale.x -= .3
	velocity.y += gravity * delta
	
	sprite.scale.x = lerp(sprite.scale.x, 1.0, 12* delta) #messing around with squshing you can delete
	sprite.scale.y = lerp(sprite.scale.y, 1.0, 12* delta)
	sprite.rotation = lerp_angle(sprite.rotation, 0.0, 8*delta)
	
	
	move_and_slide()

func hurt(direction, damage_percent):
	sprite.scale.x += .2
	sprite.scale.y -= .1
	velocity += direction
	
	var push_direction = 1
	if is_on_floor():
		push_direction = 1
	else:
		push_direction = -1
	sprite.rotate(sign((get_global_mouse_position().x-global_position.x)) * .8 * push_direction)
	
	health -= damage_percent
	
