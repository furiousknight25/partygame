extends Area2D

var mouse_position 
var press = true
var tween
var canShoot = true

signal clicked 

@onready var bullet = preload("res://Players/Aria/bullet.tscn")
@onready var timer = $"../Timer"

func _enter_tree():
	set_multiplayer_authority(get_parent().name.to_int())

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	var count = get_tree().get_nodes_in_group("bullets").size()
	mouse_position = get_global_mouse_position()
	
	rotation = lerp_angle(rotation, atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x), 20 * delta)
	
	#flip weapon sprite to match direction facing
	#if global_position.x - mouse_position.x < 0:
		#$Sprite2D.flip_v = false
	#else:
		#$Sprite2D.flip_v = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and press and count < 10:
		
		if canShoot == true:
			emit_signal('clicked', Vector2(cos(rotation), sin(rotation)) * 200, 0)
			shoot()
			canShoot = false
			timer.start(1.0)
			for i in 10:
				move_local_x(-2.0)
			press = false
		#global_position = global_position.move_toward(mouse_position, 22)
	elif !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		press = true
	position = lerp(position, Vector2(0,0), 5 * delta)
	
func _on_timer_timeout():
	canShoot = true

func shoot():
	var b = bullet.instantiate()
	add_child(b, true)
	
	b.rotation = atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x)
	#b.add_to_group("bullets")
	b.global_position = $Area2D.global_position
		
		
