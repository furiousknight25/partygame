extends Sprite2D

@export var chris_scene: PackedScene
@export var jesse_scene: PackedScene
@export var aria_scene: PackedScene
@export var travis_scene: PackedScene
#chris 0, jesse 1, aria 2, travis 3

@onready var multiplayer_test = $"../../../../.."

@rpc("any_peer", "call_local")
func set_fighter(chosen: int, id: int): #hooked to a ready function, initializes this stuf
	return
	for i in get_children():
		if str_to_var(i.name) == chosen:
			i.name = var_to_str(id)

@rpc("any_peer", "call_local")
func spawn_playground(id: int, choice, real_id): #id is name
	var pos
	for i in get_children():
		if str_to_var(i.name) == id:
			pos = i
			if i.get_children():
				i.get_child(0).queue_free()
	
	var current_player
	match choice:
		0:
			current_player = chris_scene.instantiate()
		1:
			current_player = jesse_scene.instantiate()
		2:
			current_player = aria_scene.instantiate()
		3:
			current_player = travis_scene.instantiate()
	current_player.get_child(0).set_multiplayer_authority(real_id)
	current_player.name = str(real_id)
	
	pos.add_child(current_player, true) #ig ignore this error for now 
	#lets try index
	current_player.global_position = pos.global_position

@rpc("call_local", "any_peer")
func clear_children():
	for i in get_children():
		if i.get_children():
			i.get_child(0).queue_free()

var shake_level = 0
@onready var original_position = position
var threshold = 7
var started = false

var velocity = Vector2.ZERO
func _process(delta):
	rotate(randf_range(-delta,delta) * .1)
	rotation = lerp(rotation, 0.0, delta)
	$"../../Panel".scale = lerp($"../../Panel".scale, Vector2.ONE, delta * 12)
	$"../../Panel".rotation = lerp($"../../Panel".rotation, 0.0, delta * 3)
	if Input.is_action_just_pressed('smash'):
		if multiplayer.is_server():
			shake()
			$"../../Panel".rotation += randf_range(-.04, .04)
			$"../../Panel".scale += Vector2(.15,.1)
		else:
			shake.rpc_id(1)
	
	position += velocity * delta
	if started: velocity.y += 980 * delta
	if !multiplayer.is_server() or started: return
	position.x += randf_range(-shake_level, shake_level)
	position.y += randf_range(-shake_level, shake_level)
	position = lerp(position, original_position, delta * 6)
	shake_level = clamp(shake_level - delta, 0, threshold + 1)
	
	if shake_level > threshold:
		started = true
		velocity.y -= 250
		end()

@rpc("any_peer")
func shake():
	shake_level += .2

func end():
	await get_tree().create_timer(1.5).timeout
	multiplayer_test.start_game()
	position += Vector2(99999,99999)
