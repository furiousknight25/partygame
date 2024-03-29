extends RigidBody2D
@onready var timer = $TeleportToHand
@onready var player = $".."
@onready var can_hit = true




var last_velocity = Vector2.ZERO
func _ready():
	add_collision_exception_with(player)
	
func _enter_tree():
	set_multiplayer_authority(get_parent().get_multiplayer_authority())
		
func _process(delta):
	if not is_multiplayer_authority(): return
	if player.health <= 0: return
	if player.current_state != 'thrown':
		$Line2D.modulate.a = lerp($Line2D.modulate.a, .7, delta * 12)
		$Line2D.set_point_position(0, global_position)
		var angle_to = atan2(global_position.y - get_global_mouse_position().y, global_position.x- get_global_mouse_position().x) + PI
		var strength_arrow = get_global_mouse_position() - global_position
		$Line2D.set_point_position(1, ((Vector2(cos(angle_to), sin(angle_to)) * strength_arrow.length() * .2) + global_position))
	else: $Line2D.modulate.a = lerp($Line2D.modulate.a, 0.0, delta * 12)
	if get_colliding_bodies() and player.current_state == 'thrown':
		
		if get_colliding_bodies()[0].has_method('hurt') and can_hit == true and player.current_state == 'thrown': #layer 8 for enemy
			get_colliding_bodies()[0].hurt.rpc(last_velocity, 25)
			print(last_velocity)
			can_hit = false 
			linear_velocity = -linear_velocity
			timer.start()
			
		elif freeze == false and !get_colliding_bodies()[0].has_method('hurt'):
			freeze = true
			timer.start()
	if global_position.length() >= 1000:
		_on_timer_timeout()
	last_velocity = linear_velocity
	
	#ball effect
	if timer.time_left > 0:
		var offset = randf_range(timer.time_left - 1, 1- timer.time_left)
		var offsety = randf_range(timer.time_left - 1, 1- timer.time_left)
		position += Vector2(offset, offsety) * delta * 40
		global_position.x = move_toward(global_position.x, player.global_position.x, delta * 2)
		global_position.y = move_toward(global_position.y, player.global_position.y, delta * 2)
func throw(strength):
	global_position = $"../Sprite2D/RockFinal".global_position
	freeze = false
	#global_position = player.global_position + Vector2(20,0)
	#print(global_position, player.global_position)
	apply_central_impulse(Vector2(get_global_mouse_position().x - global_position.x, get_global_mouse_position().y - global_position.y) * strength)

func _on_timer_timeout():
	self.to_global($"../Sprite2D/RockInitial".position)
	global_position = $"../Sprite2D/RockInitial".global_position
	player.set_hold_process()
	#print('timeout')
	timer.stop()

