extends CharacterBody2D
@onready var rock = $rock
@onready var Thrower = $Sprite2D
@onready var Thrower_sprite = $Sprite2D
@onready var kick_timer = $KickTimer
@onready var mouse_area = $MouseArea
@onready var TeleportCooldown = $TeleportCooldown
@onready var text = $HealthText

var gravity = 10
var strength = 15
var states = ['hold', 'thrown']
var current_state
var teleported = false
var flipped = false
var bounce = .2
var stand_threshold = 100

var health = 100

func _enter_tree():
	set_multiplayer_authority(name.to_int())

	
func _ready():
	#Engine.set_time_scale(.1)
	set_hold_process()
func _process(delta):
	#print(kick_timer.time_left)
	if not is_multiplayer_authority(): return
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))
	var mouse_position = get_global_mouse_position()
	$state.text = current_state
	match current_state:
		'hold':
			hold_process()
		'thrown':
			throw_process()
	
	#velocity = rock.linear_velocity
	velocity.y += gravity
	if  self.is_on_floor():
		velocity.x = lerp(self.velocity.x,0.0,.6)
	velocity.x += Input.get_axis('left','right') * 50
	#print(current_state, ' ', teleported)
	if Input.is_action_just_pressed('RightM'):
		
		if current_state == "thrown" and teleported == false:
				#rock.set_linear_velocity(Vector2(0,0))
			var player_old_position = global_position
			var rock_old_position = rock.global_position
			var player_old_velocity = velocity
			var rock_old_velocity = rock.linear_velocity
			#print(rock_old_velocity)
			rock.linear_velocity = player_old_velocity
			velocity = rock_old_velocity
			global_position = rock_old_position + Vector2(20,0)
			rock.global_position = player_old_position + Vector2(20,0)
			teleported = true
		elif current_state == "hold":
			set_throw_process()
	if get_global_mouse_position() > self.global_position:
		$Sprite2D.flip_h = get_local_mouse_position().x > 0
		flipped = false
	else:
		$Sprite2D.flip_h = get_local_mouse_position().x > 180
		flipped = true
	if get_last_slide_collision():
		
		velocity += get_last_slide_collision().get_normal() * (bounce * get_real_velocity().length())
		velocity = lerp(velocity, Vector2.ZERO, delta * 3)
		#Thrower_sprite.scale.x = velocity.length() * .003 + 1
		#Thrower_sprite.scale.y = velocity.length() * -.003 + 1
		#if get_last_slide_collision().get_collider().collision_layer == 8 and velocity.length() >= 500 and kick_timer.time_left == 0:
			#get_last_slide_collision().get_collider().hurt(velocity * .5,1)
			#
			#kick_timer.stop()
			#kick_timer.start()
	if !get_floor_normal():
		var forward_rotation = atan2(get_real_velocity().y, get_real_velocity().x) - PI/2
	if get_real_velocity().length() >= stand_threshold:
		Thrower.rotation = lerp_angle(Thrower.rotation, atan2(get_real_velocity().y, get_real_velocity().x) - PI/2, 25*delta)
	else:
		Thrower.rotation = lerp_angle(Thrower.rotation, 0, 12*delta)
	Thrower_sprite.scale.x = lerp(Thrower_sprite.scale.x, 1.0, delta * 8)
	Thrower_sprite.scale.y = lerp(Thrower_sprite.scale.y, 1.0, delta * 2)
	Thrower.rotation = lerp_angle(Thrower.rotation, 0.0, 8 * delta)
	#print(kick_timer.time_left)
	mouse_process_stuff(delta)
	
	
	move_and_slide()
	
func set_hold_process():
	rock.freeze = true
	rock.get_child(0).disabled = true
	current_state = 'hold'
	rock.linear_velocity = Vector2(0,0)
	teleported = false
	
func hold_process():
	if flipped == false:
		rock.global_position = global_position + Vector2(20,0)
	elif flipped == true:
		rock.global_position = global_position + Vector2(-20,0)
		
func set_throw_process():
	rock.throw(strength)
	rock.get_child(0).disabled = false
	rock.can_hit = true
	current_state = 'thrown'
	#print(current_state)
	
func throw_process():
	pass

func mouse_process_stuff(delta):
	mouse_area.global_position = get_global_mouse_position()
	if Input.is_action_just_pressed('LeftM') and TeleportCooldown.is_stopped() == true:
		for i in mouse_area.get_overlapping_bodies():
			$CollisionShape2D.disabled = true
			var enemy_old_position_LMB = i.global_position
			var enemy_old_velocity_LMB = i.velocity
			var player_old_position_LMB = global_position
			var player_old_velocity_LMB = velocity
			global_position = enemy_old_position_LMB + Vector2(0,0)
			velocity = enemy_old_velocity_LMB
			i.velocity = player_old_velocity_LMB
			if flipped == false:
				i.global_position = player_old_position_LMB + Vector2(-i.scale.x/2 - 5, -i.scale.y/2 - 5)
			else:
				i.global_position = player_old_position_LMB + Vector2(i.scale.x/2 + 5, -i.scale.y/2 - 5)
			await get_tree().create_timer(.01).timeout
			$CollisionShape2D.disabled = false
			TeleportCooldown.start()
func _on_collision_timer_timeout():
		pass

@rpc("any_peer")
func hurt(direction, damage_percent):
	#print(direction, " ", damage_percent)

	velocity += direction
	print('asd')
	
	var push_direction = 1
	if is_on_floor():
		push_direction = 1
	else:
		push_direction = -1
	
	health -= damage_percent
	if health <= 0:
		print('dead')
		#queue_free()
