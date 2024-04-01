extends Sprite2D


var drop = false
var velocity = -25
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(randf_range(-delta,delta) * .2)
	rotation = lerp(rotation, 0.0, delta)
	
	position.y += sin(Engine.get_frames_drawn() * .01) * .05
	
	
	if drop:
		if velocity == -25:
			$Plane2.rotate(-.2)
			#var go_to = $Plane2.to_global($Plane2.position)
			#$Plane2.top_level = true
			#$Plane2.global_position = go_to
		
		velocity += 2
		$Plane2.position.y += velocity * delta
		$Plane2.position.x += delta * 50
		$Plane2.rotate(delta)
		
