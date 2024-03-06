extends CharacterBody2D
@export var speed : int
@export var gravity = 980
@onready var sprite = $Sprite2D

var bullet_speed = 650
var mouse_position

func _enter_tree():
	set_multiplayer_authority(get_parent().get_parent().get_parent().name.to_int())

func _ready():
	var timer = $Timer

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	mouse_position = get_global_mouse_position()
	rotation = lerp_angle(rotation, atan2(mouse_position.y - global_position.y, mouse_position.x - global_position.x), 20 * delta)
	velocity.x = lerp(velocity.x, cos(rotation) * bullet_speed, 12 * delta)
	velocity.y = lerp(velocity.y, sin(rotation) * bullet_speed, 12 * delta)
	
	move_and_slide()
	self.look_at(mouse_position)
	
	#collisions
	if get_last_slide_collision():
		var i = get_slide_collision(0).get_collider()
		if i.has_method('hurt'):
			i.hurt.rpc(Vector2(cos(rotation), sin(rotation) - 1.002) * 500, 10)
			self.queue_free()
			
		
	

func _on_timer_timeout():
	self.queue_free()
