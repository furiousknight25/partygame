extends CharacterBody2D

@onready var magnet_stuff = $Magnet/CPUParticles2D
@onready var magnet = $Magnet
@onready var text = $HealthText
@onready var musicC = get_tree().current_scene.get_node("/root/MusicC")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_HORIZONTAL = 600
var gravity = 980

var health = 100

func _enter_tree(): #multiplayer stuff
	set_multiplayer_authority(name.to_int())

	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
		
		if not is_on_floor():
			velocity.y += gravity * delta


		# Jump Func
		if Input.is_action_just_pressed("up") and is_on_floor():
			var jump_direction
			if get_global_mouse_position() > global_position:
				jump_direction = 1
			else: jump_direction = -1
			velocity += Vector2(JUMP_HORIZONTAL * jump_direction,JUMP_VELOCITY)


		#left and right movement
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, 10 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)

		if global_position.length() >= 3000:
			death()
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
				i.hurt.rpc(Vector2(cos(magnet.rotation), sin(magnet.rotation)) * 50 * Input.get_axis("LeftM", 'RightM') + Vector2(0,-1) * delta, 10 * delta)
	else: magnet_stuff.emitting = false
	
	
func death():
	change_stocks.rpc(name.to_int(), 0)
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

