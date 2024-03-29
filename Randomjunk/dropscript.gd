extends AnimatableBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play('drop')

func _process(delta):
	return
	print(animation_player.current_animation)
