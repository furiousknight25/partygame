extends CharacterBody2D

@onready var magnet_stuff = $Magnet/CPUParticles2D
@onready var magnet = $Magnet
@onready var text = $HealthText
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_HORIZONTAL = 600
var gravity = 980

var health = 100

func _enter_tree(): #multiplayer stuff
	set_multiplayer_authority(name.to_int())
	change_stocks(1)
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
		
		if not is_on_floor():
			velocity.y += gravity * delta


		# Jump Func
		if Input.is_action_just_pressed("up") and is_on_floor():
			velocity += Vector2(JUMP_HORIZONTAL,JUMP_VELOCITY)


		#left and right movement
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, .3)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)


		#character flip
		if get_global_mouse_position().x >= position.x:
			pass
		$Magnet.rotation = atan2(get_global_mouse_position().y - global_position.y, get_global_mouse_position().x - global_position.x)
	else: velocity.y += 9.8
	move_and_slide()

	#Particles
	if Input.is_action_pressed('RightM') or Input.is_action_pressed("LeftM"):
		magnet_stuff.emitting = true
		
		for i in magnet.get_overlapping_bodies():
			if i != self and i.has_method('hurt'):
				i.hurt.rpc(Vector2(cos(magnet.rotation), sin(magnet.rotation)) * 100 * Input.get_axis("LeftM", 'RightM') + Vector2(0,-1), 1)
	else: magnet_stuff.emitting = false
	

func death():
	change_stocks(0)
	$"Character hitbox".disabled = true
	health = 0

@rpc("any_peer")
func hurt(direction, damage_percent):
	velocity += direction
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

