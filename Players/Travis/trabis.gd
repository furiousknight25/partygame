extends CharacterBody2D

@onready var magnet_stuff = $Magnet/CPUParticles2D
@onready var magnet = $Magnet
@onready var text = $HealthText
@onready var musicC = get_tree().current_scene.get_node("/root/MusicC")
@onready var bullet = preload("res://Players/Travis/Bullet.tscn")

const SPEED = 150.0
const JUMP_VELOCITY = -150.0
const JUMP_HORIZONTAL = 200
var gravity = 980
var health = 100
var buff_jump = 0.0
var jump_length = .1
var coyote_time = .1

func _enter_tree(): #multiplayer stuff
	set_multiplayer_authority(name.to_int())

	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
		
		if not is_on_floor():
			velocity.y += gravity * delta
		
		var direction = Input.get_axis("left", "right")
		var jump_direction = 0
		# Jump Func
		
		if Input.is_action_just_pressed("up"):
			buff_jump = .2
		if is_on_floor():
			coyote_time = .1
		if coyote_time > 0 and buff_jump > 0:
			jump_length = .12
			coyote_time = 0
			buff_jump = 0
			if direction: jump_direction = sign(velocity.x)
			velocity += Vector2(JUMP_HORIZONTAL * jump_direction,JUMP_VELOCITY)
			$JumpParticles.restart()
		if Input.is_action_just_released('up'):
			jump_length = 0
		if jump_length > 0 and Input.is_action_pressed('up'):
			velocity.y -= 1400 * delta
			jump_length -= delta
		buff_jump -= delta
		coyote_time -= delta
		#left and right movement
		var acceleration = 15
		if !is_on_floor(): acceleration = 8 #when in air reduce your control
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)
		modulate = lerp(modulate, Color('ffffff'), delta*5)
		if global_position.length() >= 1000:
			death()
		#character flip
		if get_global_mouse_position().x >= position.x:
			$Sprite2D.flip_h = false
		else: $Sprite2D.flip_h = true
		$Magnet.rotation = atan2(get_global_mouse_position().y - global_position.y, get_global_mouse_position().x - global_position.x)
	else: velocity.y += 9.8
	magnet_process(delta)
	move_and_slide()
	
	
	

func magnet_process(delta):
	if Input.is_action_pressed('RightM') or Input.is_action_pressed("LeftM"):
		magnet_stuff.emitting = true
		magnet_stuff.color = Color(Input.get_axis("LeftM", 'RightM') + 1, .1,  Input.get_axis('RightM', 'LeftM') + 1, .2)
		for i in magnet.get_overlapping_bodies():
			if i != self and i.has_method('hurt'):
				i.hurt.rpc(Vector2(cos(magnet.rotation), sin(magnet.rotation)) * 50 * Input.get_axis("LeftM", 'RightM') + Vector2(0,-1) * delta, 10 * delta)
			elif i == self:
				i.hurt(Vector2(cos(magnet.rotation), sin(magnet.rotation)) * 10 * Input.get_axis("LeftM", 'RightM') + Vector2(0,-1) * delta,0)
	else: magnet_stuff.emitting = false
	
	if Input.is_action_just_pressed('mm'):
		var new_bullet = bullet.instantiate()
		$"Magnet/Magnert positom".add_child(new_bullet,true)
		
		new_bullet.top_level = true
		new_bullet.global_position = $"Magnet/Magnert positom".global_position
		magnet.transform.x
		new_bullet.velocity += 100 * magnet.transform.x
		
		
		
		
		
		
		
		
		
		
		
func death():
	change_stocks.rpc(name.to_int(), 0)
	$"Character hitbox".disabled = true
	health = 0
	
@rpc("any_peer")
func hurt(direction, damage_percent):
	if damage_percent > 0: modulate = Color("ff0000")
	velocity += direction
	health -= damage_percent
	if health <= 0:
		death()

@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

@rpc("any_peer", "call_local")
func change_stocks(id, stock): #server id here
	Director.players[id]['stocks'] = stock
	var total_stocks = Director.players.size()
	for i in Director.players:
		total_stocks = total_stocks - Director.players[i]['stocks'] #okay this is working its going up
	musicC.change_level.rpc(total_stocks)
	
@rpc("any_peer", "reliable")
func set_stocks(director_info): #then sync here 
	Director.players = director_info

