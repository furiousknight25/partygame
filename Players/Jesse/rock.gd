extends RigidBody2D
@onready var timer = $TeleportToHand
@onready var player = $".."
@onready var can_hit = true

func _enter_tree():
	set_multiplayer_authority(get_parent().name.to_int())
		
func _process(delta):
	#print(freeze)
	if not is_multiplayer_authority(): return
	if player.health <= 0: return
	if get_colliding_bodies() and player.current_state == 'thrown':
		#print(get_colliding_bodies()[0].collision_layer)
		if get_colliding_bodies()[0].has_method('hurt') and can_hit == true and player.current_state == 'thrown': #layer 8 for enemy
			get_colliding_bodies()[0].hurt.rpc(linear_velocity * 5 * Vector2(1,-1), 10)
			can_hit = false #might have to use transform.x or manual velocity 
			linear_velocity = (-linear_velocity + player.velocity) * .75
			timer.start()
		elif get_colliding_bodies()[0].collision_layer==3 and freeze == false:
			freeze = true
			$CollisionShape2D.disabled = true
			timer.start()
			
		#player.set_hold_process()
		#print(get_colliding_bodies())
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

