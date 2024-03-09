extends Camera2D


@export var decay := .8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(1280*.03,720*.03) #Maximum displacement in pixels.
@export var max_roll = 0.01 #Maximum rotation in radians (use sparingly).
@onready var noise = preload("res://tools/cam_noise.tres")

var noise_y = 0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 2 #Trauma exponent. Use [2,3]

func _ready():
	ignore_rotation = false
	position = Vector2(1280/2, 720*.5)
	randomize()
	
	#noise.seed = randi()

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x,0.0,1)
		lerp(offset.y,0.0,1)
		lerp(rotation,0.0,1)

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)
	#noise.seed = randi()

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	print(noise.get_noise_2d(noise.seed*2,noise_y))
	noise_y += 1
	
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)
	
	
