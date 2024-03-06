extends Area2D

var mouse_position 
var press = true
var tween

signal clicked 


func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	
	rotation = lerp_angle(rotation, atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x), 20 * delta)
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and press:
		emit_signal('clicked', Vector2(cos(rotation), sin(rotation)) * 200, 0)
		press = false
		for i in 10:
			move_local_x(2.0)
		#global_position = global_position.move_toward(mouse_position, 22)
		for a in get_overlapping_bodies():
			if a.has_method('hurt') and a != get_parent():
				a.hurt.rpc(Vector2(cos(rotation), sin(rotation) - 1.002) * 500, 10)
	elif !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		press = true
	position = lerp(position, Vector2(3,0), 5 * delta)
	

