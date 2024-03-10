extends Camera2D
#keep in mind they are TWO camera shake systems being used here

var decay := .8 #How quickly shaking will stop [0,1].
var max_offset := Vector2(1280*.01,720*.01) #this reduces how much your camera can shake
var max_roll = 0.01 #Maximum rotation in radians (use sparingly).
@onready var noise = preload("res://tools/cam_noise.tres")

var noise_y = 0 #Value used to move through the noise
var trauma := 0.0 #Current shake strength
var trauma_pwr := 2 #Trauma exponent. Use [2,3]

var tension = 2 #this simulates the camera going back to its orignal position like an elastic spring
var damp = .1 #this changes how fast your camera resets to its original state
const target_pos = Vector2(1280/2, 720*.5) # where to reset your position back to, its a variable that never changes
var shake_pos = Vector2(1280/2, 720*.5) #this gets changed to simulate an offset 
var velocity = Vector2.ZERO #changes how fast your offset changes

func _ready():
	ignore_rotation = false #allows the camera to rotate
	randomize() #makes the random systems more random

func _process(delta):
	if trauma: 
		trauma = max(trauma - decay * delta, 0)
		shake()
	var displacement = (target_pos - shake_pos) * delta    #distance to center
	velocity += (displacement * tension) - (velocity * damp)
	shake_pos += velocity
	offset = shake_pos #this is the property that moves the camera

func add_trauma(amount : float, direction): #this function starts everything
	trauma = min(trauma + amount, 1.0) #for the regular camera shake motion
	velocity += direction #for the spring camera motion
	#noise.seed = randi()

func shake(): #you can kinda ignore this
	var amt = pow(trauma, trauma_pwr)
	#print(noise.get_noise_2d(noise.seed*2,noise_y))
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)
	
	
