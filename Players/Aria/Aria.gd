extends CharacterBody2D

@export var jump_strength : int
@export var speed : int
@export var gravity = 980
@onready var sprite = $Sprite2D
@onready var text = $RichTextLabel

var health = 100
var walk_animation_speed = 0
var dash_strength = 10
var mouse_position 

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _process(delta):
#region debug keybinds
	if not is_multiplayer_authority(): return
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
	
	mouse_position = get_global_mouse_position()
	var direction = Input.get_axis('left', "right")
	
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, 12 * delta) #add jump buffer later
		#dash function
		if Input.is_action_just_pressed('shift'):
			velocity.x = lerp(velocity.x, dash_strength * speed * direction, 16 * delta)
		
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
	
	#sprite flip
	if global_position.x - mouse_position.x < 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
	
	velocity.y += gravity * delta
	
	sprite.scale.x = lerp(sprite.scale.x, 1.0, 12 * delta) #messing around with squshing you can delete
	sprite.scale.y = lerp(sprite.scale.y, 1.0, 12 * delta)
	sprite.rotation = lerp_angle(sprite.rotation, 0.0, 8 * delta)
	
	move_and_slide()
	
	#health display
	text.modulate = text.modulate.lerp(Color('ffbbf2'), 5 * delta)
	text.scale = lerp(text.scale, Vector2.ONE, 15 * delta)
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
	if health <= 0:
		health = 100


@rpc("any_peer")
func hurt(direction, damage_percent):
	sprite.scale.x += .2
	sprite.scale.y -= .1
	velocity += direction
	
	var push_direction = -1
	if is_on_floor():
		push_direction = -1
	else:
		push_direction = -1
	sprite.rotate(sign((get_global_mouse_position().x-global_position.x)) * .8 * push_direction)
	
	health -= damage_percent
	
