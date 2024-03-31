extends CharacterBody2D

@export var speed = 3
@export var max_speed = 75.0
@export var rotation_speed = 3

@onready var text = $RichTextLabel
@onready var bullet = preload("res://Players/Chris/bullet.tscn")
@onready var musicC = get_tree().current_scene.get_node("/root/MusicC")
@onready var blast_sound = $blast


var rotation_direction = 0
var health := 100
var pitch_strength = 0.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	velocity.y = 100
var stop_loop = true
func get_input():
	rotation_direction = Input.get_axis("left", "right")
	if Input.get_axis("down", "up"):
		velocity += transform.x * Input.get_axis("down", "up") * speed
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		velocity.y = clamp(velocity.y, -max_speed, max_speed)
		
		if stop_loop: 
			$StudioEventEmitter2D.play()
			$CPUParticles2D.emitting = true
			stop_loop = false
	else:
		stop_loop = true
		$CPUParticles2D.emitting = false
		$StudioEventEmitter2D.stop()
	if Input.is_action_just_pressed('kill'):
		death()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		get_input()
		rotation += rotation_direction * rotation_speed * delta
		velocity = lerp(velocity, Vector2(0,0), delta)
		blast()
		if global_position.length() >= 1000:
			death()
		modulate = lerp(modulate, Color('ffffff'), delta*5)
	else: velocity.y += 9.8#just adding gravity if you die for lols, u can delete
	move_and_slide()
	$PointLight2D.energy = lerp($PointLight2D.energy, 0.0, delta*7)
	pitch_strength = lerp(pitch_strength, .6, delta)
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))


func blast():
	if Input.is_action_just_pressed('z'):
		pitch_strength += .1
		blast_sound.pitch_scale = pitch_strength
		blast_sound.play()
		Camera.add_trauma(.3, transform.x)
		velocity -= transform.x * 20
		var b = bullet.instantiate()
		#b.name = str(multiplayer.get_unique_id())
		$Spawn_marker.add_child(b, true)
		#b.add_to_group("bullets")
		b.global_position = $Spawn_marker.global_position
		b.rotation = $".".rotation
		b.velocity = transform.x * 200
		
		$PointLight2D.energy = 1
	
func death():
	change_stocks.rpc(name.to_int(), 0)
	$CollisionShape2D.disabled = true
	health = 0
	$Death.play()
	$Death_particles.emitting = true
	$StudioEventEmitter2D.stop()
	
@rpc("any_peer")
func hurt(direction, damage_percent):
	if damage_percent > 0: modulate = Color("ff0000")
	velocity += direction
	health -= damage_percent
	if health <= 0:
		death()
@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

@rpc("any_peer", "call_local")
func change_stocks(id, stock): #server id here
	Director.players[id]['stocks'] = stock
	var total_stocks = Director.players.size()
	for i in Director.players:
		total_stocks = total_stocks - Director.players[i]['stocks'] #okay this is working its going up
	musicC.change_level.rpc(total_stocks)
@rpc("any_peer", "reliable")
func set_stocks(director_info): #then sync here 
	Director.players = director_info
