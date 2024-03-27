extends CharacterBody2D
@export var gravity = 980
@onready var sprite = $Sprite2D
@onready var timer = $Timer

var bullet_speed = 300
var mouse_position

func _enter_tree():
	set_multiplayer_authority(get_parent().get_parent().name.to_int())


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	mouse_position = get_global_mouse_position()
	rotation = lerp_angle(rotation, atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x), 25 * delta)
	velocity.x = lerp(velocity.x, cos(rotation) * bullet_speed, 8 * delta)
	velocity.y = lerp(velocity.y, sin(rotation) * bullet_speed, 8 * delta)
	
	$Sprite2D.self_modulate.a = sqrt(.3335 * timer.get_time_left())
	
	move_and_slide()
	#self.look_at(mouse_position)
	
	#collisions
	if get_last_slide_collision():
		var i = get_slide_collision(0).get_collider()
		#print(i, get_parent().get_parent())
		if i.has_method('hurt') and i != get_parent().get_parent():
			i.hurt.rpc(Vector2(cos(rotation), sin(rotation) - 1.002) * 100, sqrt(.3335 * timer.get_time_left()) * 10)
			self.queue_free()
		if i == get_parent().get_parent():
			i.hurt(Vector2(cos(rotation), sin(rotation) * 2) * 200, sqrt(.3335 * timer.get_time_left()) * 3)
			self.queue_free()

func _on_timer_timeout():
	self.queue_free()

@rpc("any_peer")
func hurt(direction, damage_percent):
	velocity += direction
	
	
#idea, hold right click to slow down some, kinda like the rocket from ultra kill, but you could position some, perhaps even pause the timer while this is the case
