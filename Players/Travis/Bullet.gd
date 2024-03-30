extends CharacterBody2D



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") #980
var health := 100
@export var bounce := .8




func _enter_tree():
	set_multiplayer_authority(get_parent().get_parent().get_parent().get_multiplayer_authority())
	
func _physics_process(delta):
#region JUNK you dont have to care abouts
	if not is_multiplayer_authority(): return
	if not is_on_floor():
		velocity.y += gravity * delta
	if get_last_slide_collision():
		velocity += get_last_slide_collision().get_normal() * (bounce * get_real_velocity().length())
		velocity = lerp(velocity, Vector2.ZERO, delta * 3)
	if !get_floor_normal():
		var forward_rotation = atan2(get_real_velocity().y, get_real_velocity().x) - PI/2
	
	move_and_slide()
#endregion

@rpc("any_peer")
func hurt(direction, damage_percent): #damage percent is just a whole number that 
	velocity += direction
	
	
