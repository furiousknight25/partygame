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
	change_stocks(1)
	
func _process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		if Input.is_action_just_pressed('kill'):
			death()
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
			if abs(sin(walk_animation_speed) * 3) <= .8:
				sprite.scale.x = .9
				sprite.scale.y = 1.1
		
		if Input.is_action_just_pressed('up') and is_on_floor():
			velocity.y -= jump_strength
			sprite.scale.y += .3
			sprite.scale.x -= .3
		
		velocity.y += gravity * delta
		
		sprite.scale.x = lerp(sprite.scale.x, 1.0, 12 * delta) #messing around with squshing you can delete
		sprite.scale.y = lerp(sprite.scale.y, 1.0, 12 * delta)
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 8 * delta)
		if global_position.length() >= 3000:
			death()
	else: velocity.y += 9.8
	move_and_slide()
	
	#health display
	text.modulate = text.modulate.lerp(Color('ffbbf2'), 5 * delta)
	text.scale = lerp(text.scale, Vector2.ONE, 15 * delta)
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))

func death():
	change_stocks(0)
	$CollisionShape2D.disabled = true
	health = 0

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
	if health <= 0:
		death()

@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

@rpc("any_peer")
func change_stocks(stock):
	Director.players[name.to_int()]['stocks'] = stock
	if !multiplayer.is_server():
		set_stocks.rpc_id(1, name.to_int(), stock)
	
@rpc("any_peer", "reliable")
func set_stocks(id, stock):
	#print(id)
	Director.players[id]['stocks'] = stock
