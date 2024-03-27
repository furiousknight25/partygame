extends CharacterBody2D
@onready var rock: RigidBody2D = $rock
@onready var Thrower = $Sprite2D
@onready var Thrower_sprite = $Sprite2D
@onready var kick_timer = $KickTimer
@onready var mouse_area = $MouseArea
@onready var TeleportCooldown = $TeleportCooldown
@onready var text = $HealthText
@onready var musicC = get_tree().current_scene.get_node("/root/MusicC")

@export var gravity = 6
@export var strength = 12
var states = ['hold', 'thrown']
var current_state
var teleported = false
var flipped = false
@export var bounce = .2
@export var stand_threshold = 10
var health = 100
var last_velocity = Vector2.ZERO 
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
	
func _ready():
	#Engine.set_time_scale(.1)
	set_hold_process()
func _process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		if Input.is_action_just_pressed('kill'):
			hurt(Vector2.ZERO, 100)
		text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
		var mouse_position = get_global_mouse_position()
		$state.text = current_state
		match current_state:
			'hold':
				hold_process()
			'thrown':
				throw_process()
		
		velocity.y += gravity
		if self.is_on_floor():
			velocity.x = lerp(velocity.x,0.0, 10 * delta)
		#velocity.x += Input.get_axis('left','right') * 50 HA ZAAA DEBUG
		if Input.is_action_just_pressed('RightM'):
			if current_state == "thrown" and teleported == false:
				var player_old_position = global_position
				var rock_old_position = rock.global_position
				var player_old_velocity = velocity
				var rock_old_velocity = rock.linear_velocity
				rock.linear_velocity = player_old_velocity
				velocity = rock_old_velocity
				global_position = rock_old_position
				rock.global_position = player_old_position
				rock.freeze = false
				teleported = true
			elif current_state == "hold":
				set_throw_process()
		if get_global_mouse_position() > self.global_position:
			$Sprite2D.scale.x = -1.5
			flipped = false
		else:
			$Sprite2D.scale.x = 1.5
			flipped = true
		if get_last_slide_collision():
			if get_last_slide_collision().get_collider() is CharacterBody2D:
				velocity += get_last_slide_collision().get_normal() * (bounce * get_real_velocity().length())
				if get_last_slide_collision().get_collider().has_method('hurt') and velocity.length() >= 50 and kick_timer.time_left == 0:
					get_last_slide_collision().get_collider().hurt.rpc((last_velocity * 2) + Vector2(0,-10),12)
					kick_timer.stop()
					kick_timer.start()
		if !get_floor_normal():
			var forward_rotation = atan2(get_real_velocity().y, get_real_velocity().x) - PI/2
		if get_real_velocity().length() >= stand_threshold:
			Thrower.rotation = lerp_angle(Thrower.rotation, atan2(get_real_velocity().y, get_real_velocity().x) + PI/2, 25*delta)
		else:
			Thrower.rotation = lerp_angle(Thrower.rotation, 0.0 + PI, 12*delta)
		mouse_process_stuff(delta)
		
		if global_position.length() >= 1000:
			death()
	else: velocity.y += 9.8
	last_velocity = velocity
	move_and_slide()
	if kick_timer.time_left: $CollisionShape2D.debug_color = Color.CRIMSON
	else: $CollisionShape2D.debug_color = Color.GREEN
	
func set_hold_process():
	rock.freeze = true
	rock.get_child(0).disabled = true
	current_state = 'hold'
	rock.linear_velocity = Vector2(0,0)
	teleported = false
	
func hold_process():
	
	if flipped == false:
		rock.global_position = $Sprite2D/RockInitial.global_position
	elif flipped == true:
		rock.global_position = $Sprite2D/RockInitial.global_position
		
func set_throw_process():
	rock.throw(strength)
	rock.get_child(0).disabled = false
	rock.can_hit = true
	current_state = 'thrown'

	
func throw_process():
	pass

func mouse_process_stuff(delta):
	mouse_area.global_position = get_global_mouse_position()
	if Input.is_action_just_pressed('LeftM') and TeleportCooldown.is_stopped() == true:
		for i in mouse_area.get_overlapping_bodies():
			if !i.has_method('set_stuff') or i == self: return
			$CollisionShape2D.disabled = true
			var enemy_old_position_LMB = i.global_position
			var enemy_old_velocity_LMB = i.velocity
			var player_old_position_LMB = global_position
			var player_old_velocity_LMB = velocity
			global_position = enemy_old_position_LMB + Vector2(20,0)
			velocity = enemy_old_velocity_LMB
			i.set_stuff.rpc(i.global_position, player_old_velocity_LMB)
			if flipped == false:
				i.set_stuff.rpc(player_old_position_LMB + Vector2(-i.scale.x/2 - 5, -i.scale.y/2 - 32), i.velocity)
			else:
				i.set_stuff.rpc(player_old_position_LMB + Vector2(i.scale.x/2 - 5, -i.scale.y/2 - 32), i.velocity)
			await get_tree().create_timer(.01).timeout
			$CollisionShape2D.disabled = false
			TeleportCooldown.start()

func hurt(direction, damage_percent):
	#print(direction, " ", damage_percent)
	velocity += direction
	
	var push_direction = 1
	if is_on_floor():
		push_direction = 1
	else:
		push_direction = -1
	
	health -= damage_percent
	if health <= 0:
		death()

func death():
	change_stocks.rpc(name.to_int(), 0)
	$CollisionShape2D.disabled = true
	health = 0
	

@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

@rpc("any_peer", "call_local")
func change_stocks(id, stock): 
	Director.players[id]['stocks'] = stock
	
	var total_stocks = Director.players.size()
	for i in Director.players:
		total_stocks = total_stocks - Director.players[i]['stocks'] #okay this is working its going up
	musicC.change_level.rpc(total_stocks)
		
@rpc("any_peer", "reliable")
func set_stocks(director_info): #then sync here 
	Director.players = director_info

