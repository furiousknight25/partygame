extends CharacterBody2D

@export var jump_strength : int
@export var speed : int
@export var gravity = 980
@onready var sprite = $Sprite2D
@onready var text = $RichTextLabel
@onready var musicC = get_tree().current_scene.get_node("/root/MusicC")

var health = 100
var walk_animation_speed = 0
var dash_strength = 10
var mouse_position 
var buff_jump = 0.0
var jump_length = .1
var coyote_time = .1
var dash_timer = 0

func _process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		mouse_position = get_global_mouse_position()
		var direction = Input.get_axis('left', "right")
		
		if direction:
			velocity.x = lerp(velocity.x, speed * direction, 12 * delta) #add jump buffer later
			#dash function
			if Input.is_action_just_pressed('shift') and dash_timer < 0:
				dash_timer = .4
				velocity.x +=  speed * direction * 5
		dash_timer -= delta
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, 5*delta)
			walk_animation_speed += velocity.x * .0005
			if abs(sin(walk_animation_speed) * 3) <= .8:
				sprite.scale.x = .9
				sprite.scale.y = 1.1
		
		if Input.is_action_just_pressed("up"):
					buff_jump = .2
		if is_on_floor():
			coyote_time = .1
		if coyote_time > 0 and buff_jump > 0:
			jump_length = .2
			coyote_time = 0
			buff_jump = 0
			velocity.y -= jump_strength
		if Input.is_action_just_released('up'):
			jump_length = 0
		if jump_length > 0 and Input.is_action_pressed('up'):
			velocity.y -= 1400 * delta
			jump_length -= delta
		
		velocity.y += gravity * delta
		sprite.scale.x = lerp(sprite.scale.x, 1.0, 12 * delta) #messing around with squshing you can delete
		sprite.scale.y = lerp(sprite.scale.y, 1.0, 12 * delta)
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 8 * delta)
		if position.length() >= 23:
			position = Vector2.ZERO
	else: velocity.y += 9.8
	move_and_slide()
	
	#health display
	text.modulate = text.modulate.lerp(Color('ffbbf2'), 5 * delta)
	text.scale = lerp(text.scale, Vector2.ONE, 15 * delta)
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))

func death():
	$CollisionShape2D.disabled = true
	health = 0
	for i in $weapon.get_children():
		if i.is_in_group('bullets'):
			i.queue_free()

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
	if health <= 0:
		death()

@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

