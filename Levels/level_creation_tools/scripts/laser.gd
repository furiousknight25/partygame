extends RayCast2D

@export var time_to_shoot = 3
@onready var timer = time_to_shoot

@onready var ray_cast_2d = self
@onready var sprite = $Sprite2D
@onready var line = $Line2D
@onready var point_light_2d = $PointLight2D


func _ready():
	return
	ray_cast_2d.target_position = transform.y * 300
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer < 0:
		shoot()
		timer = time_to_shoot
	
	var offset = timer/time_to_shoot * 2.5
	
	sprite.position.x = randf_range(-offset, offset)
	sprite.position.y = randf_range(-offset, offset)
	sprite.position = lerp(sprite.position, Vector2.ZERO, delta)
	sprite.scale = lerp(sprite.scale, Vector2.ONE, delta)
	
	line.width = lerp(line.width, 0.0, delta * 6)
	timer -= delta
	point_light_2d.energy = lerp(point_light_2d.energy, 0.0, delta * 12)

func shoot():
	$AudioStreamPlayer.play()
	point_light_2d.energy = 2.5
	sprite.position += transform.x * 50
	sprite.scale.y = 3
	sprite.scale.x = .3
	var line_end_position = ray_cast_2d.target_position
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider().has_method('hurt'):
			line_end_position = to_local(ray_cast_2d.get_collider().global_position)
			ray_cast_2d.get_collider().hurt.rpc(transform.y * 100, 25)
	line.width = 12
	line.set_point_position(1, line_end_position)
