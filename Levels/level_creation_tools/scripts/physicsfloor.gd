extends RigidBody2D



# these are configured as "Watch" in the MultiplayerSynchronizer
@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float
@export var is_drop_box = false

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
	# Synchronizing the physics values directly causes problems since you can't
	# directly update physics values outside of _integrate_forces. This is
	# an attempt to resolve that problem while still being able to use
	# MultiplayerSynchronizer to replicate the values.

	# The object owner makes shadow copies of the physics values.
	# These shadow copies get synchronized by the MultiplyaerSynchronizer
	# The client copies the synchronized shadow values into the 
	# actual physics properties inside integrate_forces
	if is_multiplayer_authority():
		replicated_position = position
		replicated_rotation = rotation
		replicated_linear_velocity = linear_velocity
		replicated_angular_velocity = angular_velocity
	else:
		position = replicated_position
		rotation = replicated_rotation
		linear_velocity = replicated_linear_velocity
		angular_velocity = replicated_angular_velocity

@rpc("any_peer", "call_local")
func hurt(direction, damage_percent):
#	var collision = position
	#if get_colliding_bodies():
		#collision = get_colliding_bodies()[0].position
	#apply_impulse(direction * Vector2(1,-1), collision)
	linear_velocity += direction * Vector2(1,-1)
	#print(linear_velocity)
	#apply_central_impulse(direction * 1000)
	
var hit = false
func _process(delta):
	if !is_drop_box: return
	if hit:return
	if $RayCast2D.is_colliding():
		for i in $children.get_children():
			i.freeze = false
			i.apply_impulse((global_position-i.global_position) * -3)
			i.apply_torque_impulse(12)
			
		$Sprite2D.play('dead')
		$AudioStreamPlayer.play()
		Camera.add_trauma(.5, Vector2(0,1))
		hit= true
